# Delegation Pattern Snippet

Use this block to declare safe sub-agent delegation:

```markdown
## Delegation
| Condition | Delegate To |
|------------|-------------|
| Detected Postgres | @db-relational-pgsql |
| Detected DuckDB | @db-relational-duckdb |
| Detected S3 | @db-object-s3 |
```
