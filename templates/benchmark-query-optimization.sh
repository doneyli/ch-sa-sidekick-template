#!/usr/bin/env bash
# ============================================================================
#  Query Optimization Benchmark — Parameterized, Manifest-Driven
# ============================================================================
#
#  Runs a structured benchmark for any customer's original vs optimized queries.
#  Combines client-side timing (--time) and server-side metrics (system.query_log).
#
#  Usage:
#    chmod +x benchmark-query-optimization.sh
#    ./benchmark-query-optimization.sh \
#        --host <host> --password <password> \
#        --manifest benchmark.manifest
#
#  Requirements:
#    - clickhouse client CLI (or clickhouse-client)
#    - Manifest file with query definitions (see benchmark.manifest.example)
#
#  Compatible with Bash 3.2+ (macOS default)
# ============================================================================

set -euo pipefail

# --- Defaults ---
HOST=""
PASSWORD=""
USER="default"
DATABASE=""
SECURE="--secure"
RUNS=3
CONCURRENCY=25
MANIFEST=""
OUTPUT_DIR="."
CH_BIN=""
ENV_FILE=""

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)        HOST="$2"; shift 2 ;;
        --password)    PASSWORD="$2"; shift 2 ;;
        --user)        USER="$2"; shift 2 ;;
        --database)    DATABASE="$2"; shift 2 ;;
        --runs)        RUNS="$2"; shift 2 ;;
        --concurrency) CONCURRENCY="$2"; shift 2 ;;
        --manifest)    MANIFEST="$2"; shift 2 ;;
        --output-dir)  OUTPUT_DIR="$2"; shift 2 ;;
        --env-file)    ENV_FILE="$2"; shift 2 ;;
        --no-secure)   SECURE=""; shift ;;
        --help|-h)
            echo "Usage: $0 --manifest <file> --env-file <file>"
            echo "   or: $0 --manifest <file> --host <host> --password <password>"
            echo ""
            echo "Options:"
            echo "  --env-file FILE      Load credentials from .env file (recommended)"
            echo "  --host HOST          ClickHouse host (or CH_HOST in .env)"
            echo "  --password PASS      ClickHouse password (or CH_PASSWORD in .env)"
            echo "  --user USER          ClickHouse user (default: default, or CH_USER in .env)"
            echo "  --database DB        Default database (or CH_DATABASE in .env)"
            echo "  --runs N             Runs per query (default: 3)"
            echo "  --concurrency N      Parallel queries for concurrent tests (default: 25)"
            echo "  --manifest FILE      Path to benchmark manifest file"
            echo "  --output-dir DIR     Output directory for results (default: .)"
            echo "  --no-secure          Disable TLS (or CH_SECURE=false in .env)"
            exit 0
            ;;
        *) echo "Unknown arg: $1. Use --help for usage."; exit 1 ;;
    esac
done

# --- Load .env file if provided ---
if [[ -n "$ENV_FILE" ]]; then
    if [[ ! -f "$ENV_FILE" ]]; then
        echo "Error: .env file not found: $ENV_FILE"
        exit 1
    fi
    # Source the .env file, only exporting CH_* variables
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a

    # Map .env variables to script variables (CLI args take precedence)
    [[ -z "$HOST" && -n "${CH_HOST:-}" ]]         && HOST="$CH_HOST"
    [[ -z "$PASSWORD" && -n "${CH_PASSWORD:-}" ]] && PASSWORD="$CH_PASSWORD"
    [[ "$USER" == "default" && -n "${CH_USER:-}" ]] && USER="$CH_USER"
    [[ -z "$DATABASE" && -n "${CH_DATABASE:-}" ]] && DATABASE="$CH_DATABASE"
    if [[ -n "${CH_SECURE:-}" && "$CH_SECURE" == "false" ]]; then
        SECURE=""
    fi
fi

# --- Validate required args ---
if [[ -z "$HOST" || -z "$PASSWORD" || -z "$MANIFEST" ]]; then
    echo "Error: --manifest is required, plus credentials via --env-file or --host/--password."
    echo "Usage: $0 --manifest <file> --env-file <file>"
    echo "   or: $0 --manifest <file> --host <host> --password <password>"
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    echo "Error: Manifest file not found: $MANIFEST"
    exit 1
fi

# --- Detect clickhouse client binary ---
if command -v clickhouse &>/dev/null; then
    CH_BIN="clickhouse client"
elif command -v clickhouse-client &>/dev/null; then
    CH_BIN="clickhouse-client"
else
    echo "Error: Neither 'clickhouse' nor 'clickhouse-client' found in PATH."
    exit 1
fi

# --- Output files ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_CSV="${OUTPUT_DIR}/benchmark_results_${TIMESTAMP}.csv"
SUMMARY_TXT="${OUTPUT_DIR}/benchmark_summary_${TIMESTAMP}.txt"
SERVER_TSV="${OUTPUT_DIR}/benchmark_server_metrics_${TIMESTAMP}.tsv"
BENCH_PREFIX="bench_${TIMESTAMP}"

mkdir -p "$OUTPUT_DIR"

# --- Base CH command ---
CACHE_SETTINGS="--use_query_cache=0 --use_uncompressed_cache=0"
CH="$CH_BIN --host $HOST $SECURE --user $USER --password $PASSWORD $CACHE_SETTINGS"

# ============================================================================
#  Parse manifest
# ============================================================================

# Arrays (parallel-indexed, Bash 3.2 compatible)
M_LABELS=()
M_DBS=()
M_FILES=()
M_VARIANTS=()
M_TYPES=()   # "sql" or "mv" (table read)

MANIFEST_DIR="$(cd "$(dirname "$MANIFEST")" && pwd)"

while IFS= read -r line; do
    # Skip comments and blank lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue

    # Parse: label | database | sql_file_or_mv_table | variant
    IFS='|' read -r label db file_or_table variant <<< "$line"
    label="$(echo "$label" | xargs)"
    db="$(echo "$db" | xargs)"
    file_or_table="$(echo "$file_or_table" | xargs)"
    variant="$(echo "$variant" | xargs)"

    if [[ -z "$label" || -z "$db" || -z "$file_or_table" ]]; then
        echo "Warning: Skipping malformed manifest line: $line"
        continue
    fi

    # Default variant to label if not specified
    [[ -z "$variant" ]] && variant="$label"

    # Determine type: if file exists it's SQL, otherwise assume MV table name
    if [[ -f "$file_or_table" ]]; then
        M_TYPES+=("sql")
        M_FILES+=("$file_or_table")
    elif [[ -f "${MANIFEST_DIR}/${file_or_table}" ]]; then
        M_TYPES+=("sql")
        M_FILES+=("${MANIFEST_DIR}/${file_or_table}")
    else
        # Treat as MV table name (SELECT * FROM <table>)
        M_TYPES+=("mv")
        M_FILES+=("$file_or_table")
    fi

    M_LABELS+=("$label")
    M_DBS+=("$db")
    M_VARIANTS+=("$variant")
done < "$MANIFEST"

TOTAL_QUERIES=${#M_LABELS[@]}
if [[ $TOTAL_QUERIES -eq 0 ]]; then
    echo "Error: No valid entries found in manifest: $MANIFEST"
    exit 1
fi

# ============================================================================
#  Utility functions
# ============================================================================

drop_caches() {
    $CH --query "SYSTEM DROP FILESYSTEM CACHE" 2>/dev/null || true
    $CH --query "SYSTEM DROP MARK CACHE" 2>/dev/null || true
    $CH --query "SYSTEM DROP UNCOMPRESSED CACHE" 2>/dev/null || true
    $CH --query "SYSTEM DROP QUERY CACHE" 2>/dev/null || true
    sleep 1
}

# Run a single query, record timing + query_id
# Args: phase label db file_or_table type run_num [extra_settings]
run_single() {
    local phase="$1"
    local label="$2"
    local db="$3"
    local file_or_table="$4"
    local type="$5"
    local run_num="$6"
    local extra_settings="${7:-}"

    # Build a unique query_id for server-side correlation
    local safe_label
    safe_label=$(echo "$label" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')
    local query_id="${BENCH_PREFIX}_${phase}_${safe_label}_run${run_num}"

    local elapsed
    drop_caches

    if [[ "$type" == "sql" ]]; then
        elapsed=$($CH --database "$db" \
            --queries-file "$file_or_table" \
            --query_id "$query_id" \
            --format Null --time \
            $extra_settings 2>&1 >/dev/null | tail -1) || elapsed="ERROR"
    else
        # MV table read
        elapsed=$($CH --database "$db" \
            --query_id "$query_id" \
            --time \
            --query "SELECT * FROM ${file_or_table} FORMAT Null" \
            $extra_settings 2>&1 >/dev/null | tail -1) || elapsed="ERROR"
    fi

    echo "${phase},${label},${db},${run_num},${elapsed},${query_id}" >> "$RESULTS_CSV"
    printf "  %-30s run %d: %ss\n" "$label" "$run_num" "$elapsed"
}

# Run concurrent queries
# Args: phase label db file_or_table type n [extra_settings]
run_concurrent() {
    local phase="$1"
    local label="$2"
    local db="$3"
    local file_or_table="$4"
    local type="$5"
    local n="$6"
    local extra_settings="${7:-}"

    local safe_label
    safe_label=$(echo "$label" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')

    printf "  %-30s (%d concurrent): " "$label" "$n"
    drop_caches

    local start end elapsed
    start=$(date +%s%N)
    for i in $(seq 1 "$n"); do
        local query_id="${BENCH_PREFIX}_${phase}_${safe_label}_c${i}"
        if [[ "$type" == "sql" ]]; then
            $CH --database "$db" \
                --queries-file "$file_or_table" \
                --query_id "$query_id" \
                --format Null \
                $extra_settings 2>/dev/null &
        else
            $CH --database "$db" \
                --query_id "$query_id" \
                --query "SELECT * FROM ${file_or_table} FORMAT Null" \
                $extra_settings 2>/dev/null &
        fi
    done
    wait
    end=$(date +%s%N)
    elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
    echo "${elapsed}s total"

    echo "${phase},${label},${db},${n},${elapsed},${BENCH_PREFIX}_${phase}_${safe_label}" >> "$RESULTS_CSV"
}

# ============================================================================
#  Banner
# ============================================================================

echo "============================================================"
echo "  Query Optimization Benchmark — $(date)"
echo "  Host:        ${HOST}"
echo "  Manifest:    ${MANIFEST}"
echo "  Queries:     ${TOTAL_QUERIES}"
echo "  Runs/query:  ${RUNS}"
echo "  Concurrency: ${CONCURRENCY}"
echo "  Output:      ${OUTPUT_DIR}"
echo "============================================================"
echo ""

# CSV header
echo "phase,label,database,run_or_n,elapsed_s,query_id" > "$RESULTS_CSV"

# ============================================================================
#  Phase 1: Single-query latency (default max_threads)
# ============================================================================

echo "============================================"
echo "PHASE 1: SINGLE QUERY LATENCY ($RUNS runs, default max_threads)"
echo "============================================"
echo ""

for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    label="${M_LABELS[$idx]}"
    db="${M_DBS[$idx]}"
    file="${M_FILES[$idx]}"
    type="${M_TYPES[$idx]}"

    for run in $(seq 1 "$RUNS"); do
        run_single "latency" "$label" "$db" "$file" "$type" "$run"
    done
    echo ""
done

# ============================================================================
#  Phase 2: Single-query latency with reduced threads
# ============================================================================

echo "============================================"
echo "PHASE 2: SINGLE QUERY LATENCY (max_threads=1 and max_threads=2)"
echo "============================================"
echo ""

# Only test SQL queries (not MV reads — those are already fast)
for mt in 1 2; do
    echo "--- max_threads=${mt} ---"
    for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
        type="${M_TYPES[$idx]}"
        [[ "$type" == "mv" ]] && continue

        label="${M_LABELS[$idx]}"
        db="${M_DBS[$idx]}"
        file="${M_FILES[$idx]}"

        for run in $(seq 1 "$RUNS"); do
            run_single "latency_mt${mt}" "$label" "$db" "$file" "$type" "$run" "--max_threads=${mt}"
        done
        echo ""
    done
done

# ============================================================================
#  Phase 3: Concurrent load
# ============================================================================

echo "============================================"
echo "PHASE 3: CONCURRENT LOAD ($CONCURRENCY parallel)"
echo "============================================"
echo ""

echo "--- Default max_threads ---"
for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    label="${M_LABELS[$idx]}"
    db="${M_DBS[$idx]}"
    file="${M_FILES[$idx]}"
    type="${M_TYPES[$idx]}"

    run_concurrent "concurrent" "$label" "$db" "$file" "$type" "$CONCURRENCY"
done
echo ""

echo "--- max_threads=1 ---"
for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    type="${M_TYPES[$idx]}"
    [[ "$type" == "mv" ]] && continue

    label="${M_LABELS[$idx]}"
    db="${M_DBS[$idx]}"
    file="${M_FILES[$idx]}"

    run_concurrent "concurrent_mt1" "$label" "$db" "$file" "$type" "$CONCURRENCY" "--max_threads=1"
done
echo ""

echo "--- max_threads=2 ---"
for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    type="${M_TYPES[$idx]}"
    [[ "$type" == "mv" ]] && continue

    label="${M_LABELS[$idx]}"
    db="${M_DBS[$idx]}"
    file="${M_FILES[$idx]}"

    run_concurrent "concurrent_mt2" "$label" "$db" "$file" "$type" "$CONCURRENCY" "--max_threads=2"
done
echo ""

# ============================================================================
#  Phase 4: MV read latency (if MV entries exist in manifest)
# ============================================================================

HAS_MV=false
for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    [[ "${M_TYPES[$idx]}" == "mv" ]] && HAS_MV=true && break
done

if $HAS_MV; then
    echo "============================================"
    echo "PHASE 4: MV READ LATENCY ($RUNS runs)"
    echo "============================================"
    echo ""

    for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
        [[ "${M_TYPES[$idx]}" != "mv" ]] && continue

        label="${M_LABELS[$idx]}"
        db="${M_DBS[$idx]}"
        file="${M_FILES[$idx]}"

        for run in $(seq 1 "$RUNS"); do
            run_single "mv_read" "$label" "$db" "$file" "mv" "$run"
        done
        echo ""
    done
else
    echo "(Phase 4 skipped — no MV entries in manifest)"
    echo ""
fi

# ============================================================================
#  Phase 5: Row count validation
# ============================================================================

echo "============================================"
echo "PHASE 5: ROW COUNT VALIDATION"
echo "============================================"
echo ""

for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
    label="${M_LABELS[$idx]}"
    db="${M_DBS[$idx]}"
    file="${M_FILES[$idx]}"
    type="${M_TYPES[$idx]}"

    if [[ "$type" == "sql" ]]; then
        rows=$($CH --database "$db" --queries-file "$file" --format TSV 2>/dev/null | wc -l | tr -d ' ')
    else
        rows=$($CH --database "$db" --query "SELECT count() FROM ${file}" 2>/dev/null | tr -d ' ')
    fi
    printf "  %-30s %s rows\n" "$label" "$rows"
done
echo ""

# ============================================================================
#  Fetch server-side metrics from system.query_log
# ============================================================================

echo "============================================"
echo "Fetching server-side metrics from system.query_log..."
echo "============================================"
echo ""

# Wait for query_log flush (~7.5s default interval)
sleep 10

$CH --query "
SELECT
    query_id,
    query_duration_ms,
    read_rows,
    read_bytes,
    result_rows,
    memory_usage,
    ProfileEvents['SelectedParts'] AS selected_parts,
    ProfileEvents['SelectedRanges'] AS selected_ranges,
    ProfileEvents['SelectedGranules'] AS selected_granules
FROM system.query_log
WHERE query_id LIKE '${BENCH_PREFIX}%'
  AND type = 'QueryFinish'
ORDER BY query_id
FORMAT TSVWithNames
" > "$SERVER_TSV" 2>/dev/null || echo "Warning: Could not fetch server metrics (may need system.query_log access)"

# ============================================================================
#  Generate summary
# ============================================================================

{
    echo "============================================================"
    echo "  Benchmark Summary — $(date)"
    echo "  Host:        ${HOST}"
    echo "  Manifest:    ${MANIFEST}"
    echo "  Runs/query:  ${RUNS}"
    echo "  Concurrency: ${CONCURRENCY}"
    echo "============================================================"
    echo ""
    echo "--- Phase 1: Single-Query Latency (default max_threads) ---"
    echo ""
    printf "%-30s" "Query"
    for run in $(seq 1 "$RUNS"); do printf " %8s" "Run${run}"; done
    printf " %8s\n" "Avg"
    printf '%0.s-' $(seq 1 $((30 + (RUNS + 1) * 9))); echo ""

    for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
        label="${M_LABELS[$idx]}"
        printf "%-30s" "$label"
        total=0
        count=0
        for run in $(seq 1 "$RUNS"); do
            val=$(grep "^latency,${label}," "$RESULTS_CSV" | grep ",${run}," | head -1 | cut -d',' -f5)
            printf " %8s" "${val:-N/A}"
            if [[ -n "$val" && "$val" != "ERROR" ]]; then
                total=$(echo "$total + $val" | bc 2>/dev/null || echo "$total")
                count=$((count + 1))
            fi
        done
        if [[ $count -gt 0 ]]; then
            avg=$(echo "scale=3; $total / $count" | bc)
            printf " %8s" "$avg"
        else
            printf " %8s" "N/A"
        fi
        echo ""
    done
    echo ""

    echo "--- Phase 3: Concurrent Load ($CONCURRENCY parallel) ---"
    echo ""
    printf "%-30s %12s %12s %12s\n" "Query" "Default" "mt=1" "mt=2"
    printf '%0.s-' $(seq 1 66); echo ""
    for idx in $(seq 0 $((TOTAL_QUERIES - 1))); do
        label="${M_LABELS[$idx]}"
        c_def=$(grep "^concurrent,${label}," "$RESULTS_CSV" | head -1 | cut -d',' -f5)
        c_mt1=$(grep "^concurrent_mt1,${label}," "$RESULTS_CSV" | head -1 | cut -d',' -f5)
        c_mt2=$(grep "^concurrent_mt2,${label}," "$RESULTS_CSV" | head -1 | cut -d',' -f5)
        printf "%-30s %12s %12s %12s\n" "$label" "${c_def:-N/A}" "${c_mt1:-N/A}" "${c_mt2:-N/A}"
    done
    echo ""

} > "$SUMMARY_TXT"

# Print summary to stdout too
cat "$SUMMARY_TXT"

echo "============================================================"
echo "  Output Files:"
echo "    CSV:            ${RESULTS_CSV}"
echo "    Summary:        ${SUMMARY_TXT}"
echo "    Server metrics: ${SERVER_TSV}"
echo "============================================================"
echo ""
echo "Done."
