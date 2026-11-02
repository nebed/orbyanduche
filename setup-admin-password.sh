#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="${ORBYANDUCHE_GCP_PROJECT:-personal-projects-384213}"
ZONE="${ORBYANDUCHE_GCP_ZONE:-us-central1-a}"
INSTANCE="${ORBYANDUCHE_GCE_INSTANCE:-postbox}"
SSH_USER="${ORBYANDUCHE_SSH_USER:-$USER}"
PASSWORD_FILE="${ORBYANDUCHE_ADMIN_PASSWORD_FILE:-/tmp/orbyanduche-admin-password}"
REMOTE_PASSWORD_FILE="/tmp/orbyanduche-admin-password-$$"
LOCAL_TEMP="$(mktemp "${TMPDIR:-/tmp}/orbyanduche-admin-password.XXXXXX")"

cleanup() {
  rm -f "$LOCAL_TEMP"
}
trap cleanup EXIT

umask 077
openssl rand -hex 32 > "$LOCAL_TEMP"
chmod 0600 "$LOCAL_TEMP"

gcloud compute scp \
  --project="$PROJECT" \
  --zone="$ZONE" \
  "$LOCAL_TEMP" \
  "${SSH_USER}@${INSTANCE}:${REMOTE_PASSWORD_FILE}"

gcloud compute ssh \
  --project="$PROJECT" \
  --zone="$ZONE" \
  "${SSH_USER}@${INSTANCE}" \
  --command="set -eu; if sudo -n docker exec -i orbyanduche-api python /app/set_admin_password.py < '${REMOTE_PASSWORD_FILE}'; then sudo rm -f '${REMOTE_PASSWORD_FILE}'; else status=\$?; sudo rm -f '${REMOTE_PASSWORD_FILE}'; exit \$status; fi"

install -m 0600 "$LOCAL_TEMP" "$PASSWORD_FILE"
printf 'Admin password set in SQLite. Local copy: %s\n' "$PASSWORD_FILE"
