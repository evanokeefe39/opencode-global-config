# S3 Rules
- Enforce encryption at rest (SSE-S3 or SSE-KMS) and TLS in transit.
- Apply least-privilege IAM; block public ACLs and policies by default.
- Version objects and define lifecycle transitions (e.g., to Glacier) when appropriate.
- Use prefix partitioning by domain/date to reduce list and scan costs.
- Validate bucket ownership and region before processing.
