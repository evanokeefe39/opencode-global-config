-- Top queries by total time (requires pg_stat_statements)
-- Replace {table_name} to filter by table name if desired
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
WHERE query LIKE '%%{table_name}%%'
ORDER BY total_time DESC;