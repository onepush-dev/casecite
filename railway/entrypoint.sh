#!/bin/sh
# Railway healthchecks (and private networking) use IPv6, and probe $PORT.
# Upstream's nginx listens on IPv4 :80 only, so add [::]:80 and, when Railway
# injects a different PORT, that port too. The public domain targets :80.
set -e
CONF=/etc/nginx/sites-enabled/default
add_listen() {
  grep -qF "listen $1;" "$CONF" || sed -i "0,/listen 80;/s//listen 80;\n    listen $1;/" "$CONF"
}
add_listen "[::]:80"
if [ -n "${PORT:-}" ] && [ "$PORT" != "80" ]; then
  add_listen "$PORT"
  add_listen "[::]:$PORT"
fi
grep -E "^\s*listen" "$CONF" | sed 's/^/railway: nginx /'
exec /start.sh "$@"
