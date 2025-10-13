-- Top normalized statements (requires performance_schema)
-- Replace {table_name} to filter
SELECT *
FROM performance_schema.events_statements_summary_by_digest
WHERE digest_text LIKE CONCAT('%%', '{table_name}', '%%');