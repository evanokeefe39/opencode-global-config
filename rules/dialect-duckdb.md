# DuckDB Rules
- Store analytical datasets in columnar Parquet for best performance.
- Push computation to DuckDB (vectorized execution) instead of Python loops.
- Use sensible file chunking (128–512MB) and predicates for partition pruning.
- Beware memory ceilings; stage huge operations in batches.
