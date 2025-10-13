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