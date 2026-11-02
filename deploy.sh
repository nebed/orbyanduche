#!/usr/bin/env bash
set -Eeuo pipefail

DOMAIN="orbyanduche.nebed.io"
FRONTEND_DIR="/var/www/orbyanduche"
IMAGE_NAME="orbyanduche-api"
CONTAINER_NAME="orbyanduche-api"
APP_UID="10001"
APP_GID="10001"
RUNTIME_ENV_FILE="${ORBYANDUCHE_ENV_FILE:-/etc/orbyanduche/runtime.env}"
SERVICE_ACCOUNT_KEY="${ORBYANDUCHE_GCP_KEY_FILE:-/etc/orbyanduche/gcp-key.json}"
CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
DATA_ROOT="/mnt/data"
QRCODE_DIR="${DATA_ROOT}/qrcodes"
INSTANCE_DIR="${DATA_ROOT}/orbyanduche/instance"

cd "$(dirname "$(readlink -f "$0")")"

if [[ "$EUID" -ne 0 ]]; then
  echo "Run with sudo so the script can configure Docker, Nginx, and persistent directories." >&2
  exit 1
fi

for required in "$RUNTIME_ENV_FILE" "$CERT_DIR/fullchain.pem" "$CERT_DIR/privkey.pem" dist/index.html; do
  if [[ ! -f "$required" ]]; then
    echo "Required runtime/site file is missing: $required" >&2
    exit 1
  fi
done

for variable in MAILGUN_API_KEY TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN; do
  if ! grep -Eq "^[[:space:]]*${variable}=" "$RUNTIME_ENV_FILE"; then
    echo "Required variable ${variable} is missing from ${RUNTIME_ENV_FILE}" >&2
    exit 1
  fi
done

if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io
fi
systemctl enable --now docker

if [[ ! -d "$DATA_ROOT" ]]; then
  echo "Persistent data disk is not mounted at ${DATA_ROOT}; refusing to create app data on the boot disk." >&2
  exit 1
fi
mkdir -p "$QRCODE_DIR" "$INSTANCE_DIR" "$FRONTEND_DIR" /etc/orbyanduche
chown -R "${APP_UID}:${APP_GID}" "$QRCODE_DIR" "$INSTANCE_DIR"
chmod 0750 "$QRCODE_DIR" "$INSTANCE_DIR"

# Runtime secrets are mounted at execution time and never enter the Docker build context.
chmod 0600 "$RUNTIME_ENV_FILE"
RUNTIME_ENV_FILE="$(readlink -f "$RUNTIME_ENV_FILE")"
if [[ -f "$SERVICE_ACCOUNT_KEY" ]]; then
  chown "${APP_UID}:${APP_GID}" "$SERVICE_ACCOUNT_KEY"
  chmod 0400 "$SERVICE_ACCOUNT_KEY"
  SERVICE_ACCOUNT_KEY="$(readlink -f "$SERVICE_ACCOUNT_KEY")"
else
  SERVICE_ACCOUNT_KEY=""
fi

IMAGE_TAG="${ORBYANDUCHE_IMAGE_TAG:-$(date -u +%Y%m%d%H%M%S)}"
docker build --pull --tag "${IMAGE_NAME}:${IMAGE_TAG}" --tag "${IMAGE_NAME}:current" .

# Smoke-test the image before replacing the live API container.
SMOKE_CONTAINER="${CONTAINER_NAME}-smoke"
docker rm -f "$SMOKE_CONTAINER" >/dev/null 2>&1 || true
DOCKER_ARGS=(run --detach --name "$SMOKE_CONTAINER" --publish 127.0.0.1:15000:5000 --env-file "$RUNTIME_ENV_FILE" --mount "type=bind,src=${QRCODE_DIR},dst=/app/qrcodes" --mount "type=bind,src=${INSTANCE_DIR},dst=/app/instance")
if [[ -n "$SERVICE_ACCOUNT_KEY" ]]; then
  DOCKER_ARGS+=(--mount "type=bind,src=${SERVICE_ACCOUNT_KEY},dst=/run/secrets/gcp-service-account.json,readonly" --env GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcp-service-account.json)
fi
docker "${DOCKER_ARGS[@]}" "$IMAGE_NAME:$IMAGE_TAG" >/dev/null

if [[ -n "$SERVICE_ACCOUNT_KEY" ]] && ! docker exec "$SMOKE_CONTAINER" test -r /run/secrets/gcp-service-account.json; then
  docker logs "$SMOKE_CONTAINER" >&2 || true
  docker rm -f "$SMOKE_CONTAINER" >/dev/null 2>&1 || true
  echo "The container user cannot read the mounted service-account credential." >&2
  exit 1
fi

smoke_ok=false
for _ in $(seq 1 30); do
  if curl --fail --silent --max-time 2 http://127.0.0.1:15000/api/ping | grep -q 'pong'; then
    smoke_ok=true
    break
  fi
  sleep 2
done
if [[ "$smoke_ok" != true ]]; then
  docker logs "$SMOKE_CONTAINER" >&2 || true
  docker rm -f "$SMOKE_CONTAINER" >/dev/null 2>&1 || true
  echo "New API image failed its /api/ping smoke test; the current API was not replaced." >&2
  exit 1
fi
docker rm -f "$SMOKE_CONTAINER" >/dev/null

DOCKER_ARGS=(run --detach --restart unless-stopped --name "$CONTAINER_NAME" --publish 127.0.0.1:5000:5000 --env-file "$RUNTIME_ENV_FILE" --mount "type=bind,src=${QRCODE_DIR},dst=/app/qrcodes" --mount "type=bind,src=${INSTANCE_DIR},dst=/app/instance")
if [[ -n "$SERVICE_ACCOUNT_KEY" ]]; then
  DOCKER_ARGS+=(--mount "type=bind,src=${SERVICE_ACCOUNT_KEY},dst=/run/secrets/gcp-service-account.json,readonly" --env GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/gcp-service-account.json)
fi

OLD_CONTAINER="${CONTAINER_NAME}-previous"
OLD_CONTAINER_NAME=""
docker rm -f "$OLD_CONTAINER" >/dev/null 2>&1 || true
if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  OLD_CONTAINER_NAME="$CONTAINER_NAME"
elif docker container inspect orbyanduche >/dev/null 2>&1; then
  OLD_CONTAINER_NAME="orbyanduche"
fi
if [[ -n "$OLD_CONTAINER_NAME" ]]; then
  docker stop "$OLD_CONTAINER_NAME" >/dev/null
  docker rename "$OLD_CONTAINER_NAME" "$OLD_CONTAINER"
fi
if ! docker "${DOCKER_ARGS[@]}" "$IMAGE_NAME:$IMAGE_TAG" >/dev/null; then
  if docker container inspect "$OLD_CONTAINER" >/dev/null 2>&1; then
    docker rename "$OLD_CONTAINER" "$OLD_CONTAINER_NAME"
    docker start "$OLD_CONTAINER_NAME" >/dev/null
  fi
  exit 1
fi

api_ready=false
for _ in $(seq 1 30); do
  if curl --fail --silent --max-time 2 http://127.0.0.1:5000/api/ping | grep -q 'pong'; then
    api_ready=true
    break
  fi
  sleep 2
done
if [[ "$api_ready" != true ]]; then
  docker logs "$CONTAINER_NAME" >&2 || true
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  if docker container inspect "$OLD_CONTAINER" >/dev/null 2>&1; then
    docker rename "$OLD_CONTAINER" "$OLD_CONTAINER_NAME"
    docker start "$OLD_CONTAINER_NAME" >/dev/null
  fi
  echo "New API failed after replacement; attempted to restore the previous container." >&2
  exit 1
fi
docker rm "$OLD_CONTAINER" >/dev/null 2>&1 || true

# Deploy the frontend only after the backend passes its local health check.
find "$FRONTEND_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
cp -a dist/. "$FRONTEND_DIR/"
chown -R www-data:www-data "$FRONTEND_DIR"
install -o root -g root -m 0644 orbyanduche_nginx.conf "/etc/nginx/sites-available/${DOMAIN}"
ln -sfn "/etc/nginx/sites-available/${DOMAIN}" "/etc/nginx/sites-enabled/${DOMAIN}"
nginx -t
systemctl reload nginx

curl --fail --silent --show-error --max-time 10 "https://${DOMAIN}/api/ping" >/dev/null
echo "Deployment complete: https://${DOMAIN} (API health check passed)."
