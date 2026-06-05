#!/usr/bin/env bash
# Boot the OJS + DB containers in a GitHub Codespace and install OJS so it is
# reachable at the Codespace's forwarded public URL (port 8080).
#
# Runs automatically as the devcontainer postCreateCommand. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."

# All docker compose commands target the Codespaces stack.
export COMPOSE_FILE=docker-compose.codespaces.yml

# Codespaces forwarded URL for port 8080:
#   https://<codespace>-8080.<forwarding-domain>
FWD_DOMAIN="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
if [ -n "${CODESPACE_NAME:-}" ]; then
  CS_HOST="${CODESPACE_NAME}-8080.${FWD_DOMAIN}"
  CS_URL="https://${CS_HOST}"
else
  CS_HOST="localhost:8080"
  CS_URL="http://localhost:8080"
fi
export SERVERNAME="$CS_HOST"
echo "==> OJS public URL will be: ${CS_URL}"

echo "==> Waiting for Docker daemon ..."
for i in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done

echo "==> Starting db + ojs ..."
docker compose up -d

echo "==> Waiting for database to be healthy ..."
for i in $(seq 1 40); do
  [ "$(docker compose ps db --format '{{.Health}}' 2>/dev/null)" = "healthy" ] && break
  sleep 3
done

echo "==> Waiting for OJS HTTP ..."
for i in $(seq 1 40); do
  [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/ || echo 000)" != "000" ] && break
  sleep 3
done

echo "==> Installing OJS (admin / adminpass1) ..."
# DB credentials are expanded INSIDE the container (quoted heredoc).
docker compose exec -T ojs sh -s <<'EOS'
set -eu
if grep -q '^installed = On' /var/www/html/config.inc.php 2>/dev/null; then
  echo "   already installed"; exit 0
fi
curl -s -o /tmp/i.out -w '   install HTTP=%{http_code}\n' \
  "http://localhost/index/install/install" \
  --data "installing=1&adminUsername=admin&adminPassword=adminpass1&adminPassword2=adminpass1&adminEmail=admin%40ajam.local&locale=en&additionalLocales%5B%5D=en&timeZone=UTC&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8&filesDir=%2Fvar%2Fwww%2Ffiles&databaseDriver=mysqli&databaseHost=${OJS_DB_HOST}&databaseUsername=${OJS_DB_USER}&databasePassword=${OJS_DB_PASSWORD}&databaseName=${OJS_DB_NAME}&createDatabase=0&oaiRepositoryId=ajam&enableBeacon=0"
if grep -qi 'errors occurred' /tmp/i.out; then
  echo "   !! install errors:"; sed 's/<[^>]*>/ /g' /tmp/i.out | grep -iE 'must|writable|error' | head
  exit 1
fi
EOS

echo "==> Creating the 'ajam' journal (via localhost, before host lock-down) ..."
OJS_PUBLIC_URL="http://localhost:8080" OJS_JOURNAL_PATH="ajam" bash deploy/create-journal.sh || true

echo "==> Pointing OJS at the Codespace URL + trusting the proxy ..."
docker compose exec -T -e CSU="$CS_URL" -e CSH="$CS_HOST" ojs sh -s <<'EOS'
set -eu
CFG=/var/www/html/config.inc.php
# general base_url (used for static asset URLs) — overwrite the template default
sed -i "s|^base_url = .*|base_url = \"$CSU\"|" "$CFG"
# per-context base_url (used for routing)
if grep -q '^base_url\[index\]' "$CFG"; then
  sed -i "s|^base_url\[index\].*|base_url[index] = \"$CSU\"|" "$CFG"
else
  sed -i "/^\[general\]/a base_url[index] = \"$CSU\"" "$CFG"
fi
# trust the Codespaces reverse proxy (real host + https scheme)
sed -i 's|^trust_x_forwarded_for.*|trust_x_forwarded_for = On|' "$CFG"
# allow the forwarded host (and localhost) past OJS's host check
HOSTONLY="${CSH%%:*}"
if grep -q '^allowed_hosts' "$CFG"; then
  sed -i "s|^allowed_hosts.*|allowed_hosts = '[\"$HOSTONLY\",\"localhost\"]'|" "$CFG"
else
  sed -i "/^\[general\]/a allowed_hosts = '[\"$HOSTONLY\",\"localhost\"]'" "$CFG"
fi
echo "   patched:"; grep -E '^(base_url|base_url\[index\]|trust_x_forwarded_for|allowed_hosts)' "$CFG"
EOS

docker compose restart ojs >/dev/null
echo ""
echo "──────────────────────────────────────────────────────────────"
echo " OJS is up.   ${CS_URL}/ajam"
echo " Admin login: admin / adminpass1   (change after first login)"
echo " Make port 8080 PUBLIC in the Ports tab to share it."
echo "──────────────────────────────────────────────────────────────"
