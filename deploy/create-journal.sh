#!/usr/bin/env bash
# Create the "ajam" journal in OJS via its REST API (seeds default sections,
# genres, user groups, email templates, etc. — unlike a raw SQL insert).
# Idempotent-ish: re-running with an existing path returns an API error.
#
#   bash deploy/create-journal.sh
#
set -euo pipefail

BASE="${OJS_PUBLIC_URL:-http://localhost:8088/ojs}"
ADMIN_USER="${OJS_ADMIN_USER:-admin}"
ADMIN_PASS="${OJS_ADMIN_PASS:-adminpass1}"
JOURNAL_PATH="${OJS_JOURNAL_PATH:-ajam}"
JAR="$(mktemp)"

echo "Logging in as ${ADMIN_USER} ..."
CSRF=$(curl -s -c "$JAR" -b "$JAR" "${BASE}/index/login" \
  | grep -oE '"csrfToken":"[a-f0-9]+"' | head -1 | grep -oE '[a-f0-9]{16,}' || true)
curl -s -c "$JAR" -b "$JAR" -o /dev/null \
  --data "username=${ADMIN_USER}&password=${ADMIN_PASS}&csrfToken=${CSRF}&source=" \
  "${BASE}/index/login/signIn"

# refresh CSRF from an authenticated page
CSRF=$(curl -s -c "$JAR" -b "$JAR" "${BASE}/index/admin/contexts" \
  | grep -oE '"csrfToken":"[a-f0-9]+"' | head -1 | grep -oE '[a-f0-9]{16,}')

echo "Creating journal '${JOURNAL_PATH}' ..."
HTTP=$(curl -s -c "$JAR" -b "$JAR" -o /tmp/ajam-journal.json -w "%{http_code}" \
  -X POST "${BASE}/_/api/v1/contexts" \
  -H "Content-Type: application/json" -H "X-Csrf-Token: ${CSRF}" \
  --data "{\"name\":{\"en\":\"Algerian Journal of Applied Mathematics\"},\
\"acronym\":{\"en\":\"AJAM\"},\"abbreviation\":{\"en\":\"AJAM\"},\
\"contactName\":\"Editorial Office\",\
\"contactEmail\":\"editor.ajam@univ-ouargla.dz\",\
\"country\":\"DZ\",\"urlPath\":\"${JOURNAL_PATH}\",\
\"primaryLocale\":\"en\",\"enabled\":true}")

rm -f "$JAR"
if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
  echo "Journal created. Public URL: ${BASE}/${JOURNAL_PATH}"
  echo "Finish setup in OJS admin: Settings → Journal/Workflow/Distribution."
else
  echo "!! Create failed (HTTP ${HTTP}):"
  head -c 600 /tmp/ajam-journal.json; echo
  exit 1
fi
