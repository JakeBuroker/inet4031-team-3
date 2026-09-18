# Week 8: Data Observability and Backup Verification

Week 8 is Sprint 4 Async (due before Sprint 4 Review). You will provision MinIO as a
backup target, automate PostgreSQL backups with restic on a GitHub Actions
schedule, apply a retention policy, and run a recovery drill.

**Files you will create:**
- `week-8/restic-env.sh` - restic configuration template (commit without real secrets)
- `week-8/.env.backup` - MinIO credentials (DO NOT COMMIT)
- `week-8/runbook.md` - recovery procedure and measured results
- `.github/workflows/backup.yml` - scheduled backup workflow

Working files for this week live directly in this `week-8/` directory.

See the full lab directions for complete steps.
