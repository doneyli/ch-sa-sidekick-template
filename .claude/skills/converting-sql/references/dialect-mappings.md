# SQL Dialect Identification & Mapping Reference

## Dialect Identification Markers

| Dialect | Distinctive Syntax |
|---------|-------------------|
| **Snowflake** | `IFF()`, `QUALIFY`, `::variant`, `FLATTEN`, `LATERAL`, `TRY_CAST` |
| **Postgres** | `::type` casting, `ILIKE`, `GENERATE_SERIES`, `ARRAY_AGG`, `JSONB` |
| **MySQL** | backtick quoting, `IFNULL`, `GROUP_CONCAT`, `AUTO_INCREMENT` |
| **BigQuery** | backtick project.dataset.table, `SAFE_DIVIDE`, `STRUCT`, `UNNEST` |

## Common Type Mappings

| Source Type | ClickHouse Type | Notes |
|-------------|----------------|-------|
| `VARCHAR(N)` | `String` | ClickHouse String is unbounded |
| `TIMESTAMP_LTZ` | `DateTime64(3)` | Timezone handling varies |
| `VARIANT` / `JSONB` | `JSON` or `String` + JSON functions | JSON type requires 22.6+ |
| `BOOLEAN` | `Bool` or `UInt8` | Bool type requires 21.12+ |
| `DECIMAL(p,s)` | `Decimal(p,s)` | Max precision: Decimal256 |
| `INT` / `INTEGER` | `Int32` | Use smallest type that fits |
| `BIGINT` | `Int64` | |
| `FLOAT` / `REAL` | `Float32` | |
| `DOUBLE` | `Float64` | |
| `DATE` | `Date` or `Date32` | Date32 for dates before 1970 |
| `TEXT` / `CLOB` | `String` | |
| `BYTEA` / `BLOB` | `String` | ClickHouse doesn't have binary type |
| `ARRAY` | `Array(T)` | Nested arrays supported |
| `UUID` | `UUID` | |

## Common Syntax Differences

### QUALIFY (Snowflake/BigQuery -> ClickHouse)
```sql
-- Source
SELECT * FROM t QUALIFY ROW_NUMBER() OVER (...) = 1

-- ClickHouse
SELECT * FROM (SELECT *, ROW_NUMBER() OVER (...) AS rn FROM t) WHERE rn = 1
```

### IFF / IF (Snowflake -> ClickHouse)
```sql
-- Snowflake
IFF(condition, true_val, false_val)

-- ClickHouse
if(condition, true_val, false_val)
```

### GENERATE_SERIES (Postgres -> ClickHouse)
```sql
-- Postgres
SELECT generate_series(1, 100)

-- ClickHouse
SELECT number + 1 FROM numbers(100)
```

### GROUP_CONCAT (MySQL -> ClickHouse)
```sql
-- MySQL
GROUP_CONCAT(col SEPARATOR ',')

-- ClickHouse
groupArray(col)  -- returns Array, use arrayStringConcat() for string
```

### SAFE_DIVIDE (BigQuery -> ClickHouse)
```sql
-- BigQuery
SAFE_DIVIDE(a, b)

-- ClickHouse
if(b = 0, NULL, a / b)  -- or use intDivOrZero(a, b) for integer division
```
