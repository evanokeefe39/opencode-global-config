-- Size-aware sampling (approximate) + hard cap
-- Replace {table_name}
SELECT * FROM {table_name} TABLESAMPLE BERNOULLI(5) LIMIT 100;