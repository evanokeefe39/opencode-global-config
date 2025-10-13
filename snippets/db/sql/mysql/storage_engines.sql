-- Storage engines by table
SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = DATABASE();