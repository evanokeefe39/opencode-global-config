# PostgreSQL Rules
- Prefer UUID (gen_random_uuid()) for distributed IDs over SERIAL.
- Use connection pooling (pgBouncer); keep sessions short-lived.
- Monitor pg_stat_statements; optimize highest total_time queries first.
- Always EXPLAIN (ANALYZE, BUFFERS) before tuning; beware nested loops on large joins.
- Use partial and composite indexes where predicates allow.
- Keep autovacuum enabled; watch bloat and vacuum lag.
