#!/usr/bin/env bash
# Headless OJS install for the AJAM stack.
#
# Why this exists: the pkpofficial image's built-in auto-installer
# (PKP_CLI_INSTALL=1) is unreliable — it curls OJS from the *pre-start* hook
# before Apache is listening, and it posts OJS 3.3-era form values
# (locale "en_US", no timeZone) that OJS 3.4 rejects. This script runs the
# same install POST *after* the container is up, with 3.4-correct values and
# the DB credentials from your environment.
#
# Run once, after `docker compose up -d`:
#     bash deploy/install-ojs.sh
#
set -euo pipefail

SVC=ojs
ADMIN_USER="${OJS_ADMIN_USER:-admin}"
ADMIN_PASS="${OJS_ADMIN_PASS:-adminpass1}"      # >= 8 chars, OJS requirement
ADMIN_EMAIL="${OJS_ADMIN_EMAIL:-admin@ajam.local}"
BASE_URL="${OJS_BASE_URL:-http://localhost:8088/ojs}"

echo "Installing OJS (admin user: ${ADMIN_USER}) ..."

docker compose exec -T "$SVC" sh -s <<EOF
set -eu
if grep -q '^installed = On' /var/www/html/config.inc.php; then
  echo "OJS already installed — skipping."
  exit 0
fi

curl -s -o /tmp/ajam-install.out -w "install HTTP=%{http_code}\n" \
  "http://localhost/index/install/install" \
  --data "installing=1\
&adminUsername=${ADMIN_USER}&adminPassword=${ADMIN_PASS}&adminPassword2=${ADMIN_PASS}\
&adminEmail=$(printf '%s' "${ADMIN_EMAIL}" | sed 's/@/%40/')\
&locale=en&additionalLocales%5B%5D=en&timeZone=UTC\
&clientCharset=utf-8&connectionCharset=utf8&databaseCharset=utf8\
&filesDir=%2Fvar%2Fwww%2Ffiles&databaseDriver=mysqli\
&databaseHost=\${OJS_DB_HOST}&databaseUsername=\${OJS_DB_USER}\
&databasePassword=\${OJS_DB_PASSWORD}&databaseName=\${OJS_DB_NAME}\
&createDatabase=0&oaiRepositoryId=ajam&enableBeacon=0"

if grep -qi "errors occurred" /tmp/ajam-install.out; then
  echo "!! Install reported errors:"
  sed 's/<[^>]*>/ /g' /tmp/ajam-install.out | grep -iE "must|writable|error" | head
  exit 1
fi
echo "OJS install completed."
EOF

echo "Applying reverse-proxy config (base_url + trust proxy) ..."
OJS_BASE_URL="$BASE_URL" bash "$(dirname "$0")/configure-ojs.sh"

echo
echo "──────────────────────────────────────────────"
echo " OJS ready at: ${BASE_URL}"
echo " Admin login:  ${ADMIN_USER} / ${ADMIN_PASS}"
echo " CHANGE THIS PASSWORD after first login."
echo "──────────────────────────────────────────────"
