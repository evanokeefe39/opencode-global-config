# S3 Storage Standards
- Use folder-style prefixes to organize data (domain/year=YYYY/month=MM/day=DD).
- Prefer Parquet for analytics workloads; store CSV only at ingestion edges.
- Maintain a catalog (Glue/Hive) if external query engines will be used.
- Keep access logs; enable object lock where compliance requires.
