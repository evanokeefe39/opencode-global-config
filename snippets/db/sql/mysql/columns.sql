-- Column detail for current database (set $1 = table name if your client supports variables)
SELECT column_name,
       data_type,
       character_maximum_length,
       is_nullable,
       column_default,
       ordinal_position,
       column_key,
       extra
FROM information_schema.columns
WHERE table_name = $1
  AND table_schema = DATABASE()
ORDER BY ordinal_position;