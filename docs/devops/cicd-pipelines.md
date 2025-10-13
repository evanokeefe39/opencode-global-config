# CI/CD Pipelines
- Trigger: PRs to test, pushes to main/develop; manual approvals for deploys.
- Jobs: lint → test → build → scan → package → deploy (gated).
- Reusable workflows for Terraform and Docker build/push.