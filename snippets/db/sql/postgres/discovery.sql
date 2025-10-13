-- PostgreSQL / Supabase initial discovery
SELECT schemaname,
       tablename,
       tableowner,
       (SELECT reltuples::BIGINT FROM pg_class WHERE relname = tablename) AS estimated_rows
FROM pg_tables
WHERE schemaname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY estimated_rows DESC NULLS LAST;