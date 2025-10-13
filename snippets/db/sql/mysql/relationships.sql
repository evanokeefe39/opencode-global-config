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