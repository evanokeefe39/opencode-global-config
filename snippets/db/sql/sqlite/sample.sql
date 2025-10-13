-- Bounded sample via LIMIT/OFFSET (approximate)
-- Replace {table_name}
SELECT * FROM {table_name}
LIMIT 100
OFFSET (SELECT CAST((COUNT(*) * 0.1) AS INTEGER) FROM {table_name});