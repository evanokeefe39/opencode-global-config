-- Data Quality Assessment Template
-- Replace {table_name} and {column_name}
SELECT 
    '{column_name}' AS column_name,
    COUNT(*) AS total_rows,
    COUNT({column_name}) AS non_null_count,
    COUNT(DISTINCT {column_name}) AS unique_count,
    ROUND((COUNT({column_name}) * 100.0 / COUNT(*)), 2) AS completeness_pct
FROM {table_name};