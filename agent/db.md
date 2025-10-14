---
name: db
mode: primary
description: Consolidated database agent handling relational databases and object storage directly.
---

# DB Agent (@db)

## Purpose
Handle all database operations including relational databases (PostgreSQL, DuckDB, MySQL, SQLite) and object storage (S3).

## Capabilities
- Detect database type and dialect from config or connection strings
- Perform schema introspection, performance analysis, and data quality checks
- Manage S3 buckets and objects
- Support multiple SQL dialects with optimized queries

## External Intelligence
- Global: @rules/general-guidelines.md, @rules/data-integrity.md, @rules/delegation-pattern.md
- Rules: Inlined below (all database rules consolidated)
- Snippets: Inlined below (all SQL queries, scripts, and templates)

## Commands
- /database detect — Identify type and dialect
- /relational inspect — Basic schema introspection for relational databases
- /relational delegate — Route to dialect-specific operations
- /duckdb inspect — Inspect schema and data files for DuckDB
- /duckdb sample — Generate data samples from DuckDB
- /pgsql analyze — Analyze schema, indexes, and relationships for PostgreSQL
- /pgsql plan — Generate query execution plan for PostgreSQL
- /s3 list — List S3 objects and metadata
- /s3 validate — Validate bucket policies
- /s3 sample — Preview object data

## Rules
# Relational Database Rules
- Normalize schemas to at least 3NF for OLTP; denormalize judiciously for OLAP.
- Define explicit primary keys and foreign keys with indexes.
- Use transactions for multi-step writes; prefer SERIALIZABLE for critical paths.
- Enforce not-null and check constraints for data integrity.
- Avoid over-indexing; measure with EXPLAIN/ANALYZE before changes.

# DuckDB Rules
- Store analytical datasets in columnar Parquet for best performance.
- Push computation to DuckDB (vectorized execution) instead of Python loops.
- Use sensible file chunking (128–512MB) and predicates for partition pruning.
- Beware memory ceilings; stage huge operations in batches.

# PostgreSQL Rules
- Prefer UUID (gen_random_uuid()) for distributed IDs over SERIAL.
- Use connection pooling (pgBouncer); keep sessions short-lived.
- Monitor pg_stat_statements; optimize highest total_time queries first.
- Always EXPLAIN (ANALYZE, BUFFERS) before tuning; beware nested loops on large joins.
- Use partial and composite indexes where predicates allow.
- Keep autovacuum enabled; watch bloat and vacuum lag.

# S3 Rules
- Enforce encryption at rest (SSE-S3 or SSE-KMS) and TLS in transit.
- Apply least-privilege IAM; block public ACLs and policies by default.
- Version objects and define lifecycle transitions (e.g., to Glacier) when appropriate.
- Use prefix partitioning by domain/date to reduce list and scan costs.
- Validate bucket ownership and region before processing.

## Snippets/Templates

### Object Storage

#### s3-bucket-policy.json
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": ["arn:aws:s3:::example-bucket", "arn:aws:s3:::example-bucket/*"],
      "Condition": { "Bool": { "aws:SecureTransport": "false" } }
    }
  ]
}
```

#### s3-list-objects.py
```python
import boto3

def list_objects(bucket, prefix=""):
    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            print(obj["Key"], obj["Size"])
```

### Relational

#### duckdb-query-example.sql
```sql
PRAGMA show_tables;
SELECT COUNT(*) AS rows FROM 'data.parquet';
```

#### postgres-sample.sql
```sql
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema NOT IN ('pg_catalog', 'information_schema');
```

### SQL Queries

#### Universal

##### data_quality_template.sql
```sql
-- Data Quality Assessment Template
-- Replace {table_name} and {column_name}
SELECT 
    '{column_name}' AS column_name,
    COUNT(*) AS total_rows,
    COUNT({column_name}) AS non_null_count,
    COUNT(DISTINCT {column_name}) AS unique_count,
    ROUND((COUNT({column_name}) * 100.0 / COUNT(*)), 2) AS completeness_pct
FROM {table_name};
```

##### detection.sql
```sql
-- Universal detection (DB version, database name, current user)
SELECT 
    version() AS db_version,
    current_database() AS database_name,
    current_user AS current_user;
```

#### MySQL

##### columns.sql
```sql
-- Column detail for current database (set $1 = table name if your client supports variables)
SELECT column_name,
       data_type,
       character_maximum_length,
       is_nullable,
       column_default,
       ordinal_position,
       column_key,
       extra
FROM information_schema.columns
WHERE table_name = $1
  AND table_schema = DATABASE()
ORDER BY ordinal_position;
```

##### discovery.sql
```sql
-- MySQL initial discovery
SELECT table_schema,
       table_name,
       table_rows AS estimated_rows,
       table_comment
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
ORDER BY table_rows DESC;
```

##### indexes.sql
```sql
-- Index listing for a table
-- Replace {table_name}
SHOW INDEX FROM {table_name};
```

##### performance.sql
```sql
-- Top normalized statements (requires performance_schema)
-- Replace {table_name} to filter
SELECT *
FROM performance_schema.events_statements_summary_by_digest
WHERE digest_text LIKE CONCAT('%%', '{table_name}', '%%');
```

##### relationships.sql
```sql
-- Foreign key relationships
SELECT
  table_name AS source_table,
  column_name AS source_column,
  referenced_table_name AS target_table,
  referenced_column_name AS target_column,
  constraint_name
FROM information_schema.key_column_usage
WHERE referenced_table_name IS NOT NULL
ORDER BY table_name;
```

##### sample.sql
```sql
-- Simple random sample (note: ORDER BY RAND() is O(n))
-- Replace {table_name}
SELECT * FROM {table_name} ORDER BY RAND() LIMIT 100;
```

##### storage_engines.sql
```sql
-- Storage engines by table
SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = DATABASE();
```

#### PostgreSQL

##### columns.sql
```sql
-- Column detail for a specific table (set $1 = table name, adjust schema if needed)
SELECT column_name,
       data_type,
       character_maximum_length,
       is_nullable,
       column_default,
       ordinal_position
FROM information_schema.columns
WHERE table_name = $1
  AND table_schema = 'public'
ORDER BY ordinal_position;
```

##### discovery.sql
```sql
-- PostgreSQL / Supabase initial discovery
SELECT schemaname,
       tablename,
       tableowner,
       (SELECT reltuples::BIGINT FROM pg_class WHERE relname = tablename) AS estimated_rows
FROM pg_tables
WHERE schemaname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY estimated_rows DESC NULLS LAST;
```

##### extensions.sql
```sql
-- Installed extensions
SELECT name, default_version, installed_version
FROM pg_available_extensions
WHERE installed_version IS NOT NULL;
```

##### performance.sql
```sql
-- Top queries by total time (requires pg_stat_statements)
-- Replace {table_name} to filter by table name if desired
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
WHERE query LIKE '%%{table_name}%%'
ORDER BY total_time DESC;
```

##### relationships.sql
```sql
-- Foreign key relationships across schema
SELECT
  tc.table_name AS source_table,
  kcu.column_name AS source_column,
  ccu.table_name AS target_table,
  ccu.column_name AS target_column,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;
```

##### sample.sql
```sql
-- Size-aware sampling (approximate) + hard cap
-- Replace {table_name}
SELECT * FROM {table_name} TABLESAMPLE BERNOULLI(5) LIMIT 100;
```

##### triggers.sql
```sql
-- Triggers
SELECT * FROM sqlite_master WHERE type = 'trigger';
```

## Domain Documentation

### DuckDB vs PostgreSQL
| Feature | DuckDB | PostgreSQL |
|--------|--------|------------|
| Storage | File-based | Server process |
| Strength | Local OLAP, Parquet | OLTP + mature ecosystem |
| Parallelism | Vectorized | Process-based concurrency |
| Best Use | Embedded analytics | Web/API backends |

### Relational DB Best Practices
- Model entities explicitly with primary keys and FKs.
- Use appropriate data types (NUMERIC vs FLOAT for money).
- Prefer prepared/parameterized statements to avoid injection.
- Add created_at/updated_at timestamps to mutable entities.

### S3 Storage Standards
- Use folder-style prefixes to organize data (domain/year=YYYY/month=MM/day=DD).
- Prefer Parquet for analytics workloads; store CSV only at ingestion edges.
- Maintain a catalog (Glue/Hive) if external query engines will be used.
- Keep access logs; enable object lock where compliance requires.

#### SQLite

##### columns.sql
```sql
-- Column info (replace $1 with table name)
PRAGMA table_info($1);
```

##### discovery.sql
```sql
-- SQLite discovery
SELECT name, type, sql
FROM sqlite_master
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
ORDER BY name;
```

##### indexes.sql
```sql
-- Indexes
SELECT * FROM sqlite_master WHERE type = 'index';
```

##### sample.sql
```sql
-- Bounded sample via LIMIT/OFFSET (approximate)
-- Replace {table_name}
SELECT * FROM {table_name}
LIMIT 100
OFFSET (SELECT CAST((COUNT(*) * 0.1) AS INTEGER) FROM {table_name});
```

##### triggers.sql
```sql
-- Triggers
SELECT * FROM sqlite_master WHERE type = 'trigger';
