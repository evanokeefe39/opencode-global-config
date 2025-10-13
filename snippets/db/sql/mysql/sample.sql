-- Simple random sample (note: ORDER BY RAND() is O(n))
-- Replace {table_name}
SELECT * FROM {table_name} ORDER BY RAND() LIMIT 100;