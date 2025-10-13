# Relational Database Rules
- Normalize schemas to at least 3NF for OLTP; denormalize judiciously for OLAP.
- Define explicit primary keys and foreign keys with indexes.
- Use transactions for multi-step writes; prefer SERIALIZABLE for critical paths.
- Enforce not-null and check constraints for data integrity.
- Avoid over-indexing; measure with EXPLAIN/ANALYZE before changes.
