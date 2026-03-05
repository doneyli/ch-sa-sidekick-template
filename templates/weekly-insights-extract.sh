#!/usr/bin/env bash
# ============================================================================
#  Weekly Insights Data Extractor — Langfuse CLI → Structured Summary
# ============================================================================
#
#  Pulls the past week's Claude Code activity from Langfuse via the
#  `langfuse` CLI and produces structured JSON + markdown summaries
#  for the /weekly-insights skill.
#
#  Usage:
#    ./weekly-insights-extract.sh [--days 7] [--output-dir ./insights]
#
#  Requirements:
#    - langfuse CLI (brew install langfuse or npm i -g langfuse)
#    - jq
#    - Environment: LANGFUSE_PUBLIC_KEY, LANGFUSE_SECRET_KEY, LANGFUSE_HOST
#
#  Output:
#    weekly_insights_YYYYMMDD.json  — Machine-readable aggregate data
#    weekly_insights_YYYYMMDD.md    — Human-readable summary for the skill
# ============================================================================

set -euo pipefail

# --- Defaults ---
DAYS=7
OUTPUT_DIR="."

# --- Parse args ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)       DAYS="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [--days N] [--output-dir DIR]"
            echo "  --days N          Lookback window in days (default: 7)"
            echo "  --output-dir DIR  Output directory (default: .)"
            exit 0
            ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# --- Verify dependencies ---
for cmd in langfuse jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' not found in PATH." >&2
        exit 1
    fi
done

mkdir -p "$OUTPUT_DIR"

# --- Time window ---
NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if [[ "$(uname)" == "Darwin" ]]; then
    FROM_ISO=$(date -u -v-${DAYS}d +"%Y-%m-%dT%H:%M:%SZ")
    DATE_LABEL=$(date -u +"%Y%m%d")
    NOW_DISPLAY=$(date -u +"%b %d, %Y")
    FROM_DISPLAY=$(date -u -v-${DAYS}d +"%b %d")
else
    FROM_ISO=$(date -u -d "-${DAYS} days" +"%Y-%m-%dT%H:%M:%SZ")
    DATE_LABEL=$(date -u +"%Y%m%d")
    NOW_DISPLAY=$(date -u +"%b %d, %Y")
    FROM_DISPLAY=$(date -u -d "-${DAYS} days" +"%b %d")
fi

echo "============================================================"
echo "  Weekly Insights Extractor"
echo "  Window: ${FROM_ISO} → ${NOW_ISO} (${DAYS} days)"
echo "  Output: ${OUTPUT_DIR}"
echo "============================================================"
echo ""

# --- Temp files ---
TRACES_RAW=$(mktemp)
OBS_RAW=$(mktemp)
trap 'rm -f "$TRACES_RAW" "$OBS_RAW"' EXIT

# ============================================================================
#  Fetch traces (paginated)
# ============================================================================

echo "Fetching traces..."
PAGE=1
TRACE_COUNT=0

: > "$TRACES_RAW"  # truncate

while true; do
    RESULT=$(langfuse api traces list \
        --from-timestamp "$FROM_ISO" \
        --to-timestamp "$NOW_ISO" \
        --tags "claude-code" \
        --limit 100 \
        --page "$PAGE" \
        --fields "core,io" \
        --json 2>/dev/null)

    BATCH_COUNT=$(echo "$RESULT" | jq '.body.data | length')
    if [[ "$BATCH_COUNT" -eq 0 ]]; then
        break
    fi

    # Append traces as individual JSON lines
    echo "$RESULT" | jq -c '.body.data[]' >> "$TRACES_RAW"
    TRACE_COUNT=$((TRACE_COUNT + BATCH_COUNT))

    TOTAL_PAGES=$(echo "$RESULT" | jq '.body.meta.totalPages // 0')
    if [[ "$PAGE" -ge "$TOTAL_PAGES" ]]; then
        break
    fi

    PAGE=$((PAGE + 1))
    if [[ "$PAGE" -gt 50 ]]; then
        echo "Warning: Hit 50-page safety limit for traces" >&2
        break
    fi
done

echo "  Found ${TRACE_COUNT} traces"

# ============================================================================
#  Fetch observations (tool calls, paginated)
# ============================================================================

echo "Fetching tool observations..."
PAGE=1
OBS_COUNT=0

: > "$OBS_RAW"

while true; do
    RESULT=$(langfuse api observations list \
        --from-start-time "$FROM_ISO" \
        --to-start-time "$NOW_ISO" \
        --type SPAN \
        --limit 100 \
        --page "$PAGE" \
        --json 2>/dev/null) || break

    BATCH_COUNT=$(echo "$RESULT" | jq '.body.data | length')
    if [[ "$BATCH_COUNT" -eq 0 ]]; then
        break
    fi

    echo "$RESULT" | jq -c '.body.data[]' >> "$OBS_RAW"
    OBS_COUNT=$((OBS_COUNT + BATCH_COUNT))

    TOTAL_PAGES=$(echo "$RESULT" | jq '.body.meta.totalPages // 0')
    if [[ "$PAGE" -ge "$TOTAL_PAGES" ]]; then
        break
    fi

    PAGE=$((PAGE + 1))
    if [[ "$PAGE" -gt 100 ]]; then
        echo "Warning: Hit 100-page safety limit for observations" >&2
        break
    fi
done

echo "  Found ${OBS_COUNT} observations"

# ============================================================================
#  Aggregate with jq (external .jq files to avoid bash quoting issues)
# ============================================================================

echo "Aggregating data..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JSON_OUT="${OUTPUT_DIR}/weekly_insights_${DATE_LABEL}.json"
MD_OUT="${OUTPUT_DIR}/weekly_insights_${DATE_LABEL}.md"

# Build the full JSON report
jq -n -f "${SCRIPT_DIR}/weekly-insights-aggregate.jq" \
    --slurpfile traces "$TRACES_RAW" \
    --slurpfile obs "$OBS_RAW" \
    --arg from "$FROM_ISO" \
    --arg to "$NOW_ISO" \
    --arg days "$DAYS" \
    --arg generated "$NOW_ISO" \
    > "$JSON_OUT"

echo "  JSON written: ${JSON_OUT}"

# Generate markdown summary
jq -r -f "${SCRIPT_DIR}/weekly-insights-format.jq" \
    --arg from_display "$FROM_DISPLAY" \
    --arg now_display "$NOW_DISPLAY" \
    "$JSON_OUT" > "$MD_OUT"

echo "  Markdown written: ${MD_OUT}"

echo ""
echo "============================================================"
echo "  Done. Files:"
echo "    JSON: ${JSON_OUT}"
echo "    MD:   ${MD_OUT}"
echo "============================================================"
