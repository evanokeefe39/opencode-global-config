# Relational DB Best Practices
- Model entities explicitly with primary keys and FKs.
- Use appropriate data types (NUMERIC vs FLOAT for money).
- Prefer prepared/parameterized statements to avoid injection.
- Add created_at/updated_at timestamps to mutable entities.
