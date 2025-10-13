-- MySQL initial discovery
SELECT table_schema,
       table_name,
       table_rows AS estimated_rows,
       table_comment
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
ORDER BY table_rows DESC;