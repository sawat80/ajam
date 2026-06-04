#!/usr/bin/env bash
# Patch the OJS config that the image auto-generates on first boot so it works
# behind the Nginx /ojs reverse proxy. Run ONCE after `docker compose up -d`
# and after the ojs container has created /var/www/html/config.inc.php.
#
#   bash deploy/configure-ojs.sh
#
set -euo pipefail

PROJECT="${COMPOSE_PROJECT_NAME:-ajam}"
SVC="ojs"
BASE_URL="${OJS_BASE_URL:-http://localhost:8080/ojs}"

echo "Patching OJS config in container ${PROJECT}-${SVC} ..."

docker compose exec -T "$SVC" sh -eu <<EOF
CFG=/var/www/html/config.inc.php
[ -f "\$CFG" ] || { echo "config.inc.php not found yet — start the stack first"; exit 1; }

# Public base URL (subpath aware)
sed -i 's|^base_url\[index\].*|base_url[index] = "${BASE_URL}"|' "\$CFG" || true
grep -q '^base_url\[index\]' "\$CFG" || \
  sed -i '/^\[general\]/a base_url[index] = "${BASE_URL}"' "\$CFG"

# Trust the reverse proxy so OJS reads the real client IP and scheme
sed -i 's|^trust_x_forwarded_for.*|trust_x_forwarded_for = On|' "\$CFG" || true
grep -q '^trust_x_forwarded_for' "\$CFG" || \
  sed -i '/^\[general\]/a trust_x_forwarded_for = On' "\$CFG"

# Restrict to expected host(s); adjust for production domain
sed -i 's|^; allowed_hosts.*|allowed_hosts = "{\\"value\\":[\\"localhost\\"]}"|' "\$CFG" || true

echo "config.inc.php patched."
EOF

echo "Restarting OJS to apply ..."
docker compose restart "$SVC"
echo "Done. Visit ${BASE_URL}"
