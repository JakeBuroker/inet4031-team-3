# Week 7: Security Hardening and Shift Left

Week 7 is Sprint 4 Kickoff (synchronous). You will apply RBAC, NetworkPolicy, and
SecurityContext to your deployed application, and add an automated image
vulnerability scan as a required CI check.

**Files you will modify:**
- `manifests/` - add RBAC, NetworkPolicy, and SecurityContext resources
- `.github/workflows/ci.yml` - add a Trivy vulnerability scan job

These changes land in the existing `manifests/` and `.github/workflows/` directories
created in Weeks 3 and 6, not here. This directory exists to satisfy the Week 1
`mkdir -p` step and holds no content of its own until Week 7.

See the full lab directions for complete steps.
