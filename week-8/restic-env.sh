# Usage: source week-8/restic-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/.env.backup"
export MINIO_PORT=9303   # TODO: change to your team's MinIO port
export RESTIC_REPOSITORY="s3:http://localhost:${MINIO_PORT}/backups"
export AWS_ACCESS_KEY_ID="${MINIO_ROOT_USER}"
export AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"
export RESTIC_PASSWORD
