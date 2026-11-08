#!/bin/sh
# Railway probes the healthcheck on $PORT (injected when not set). Upstream's
# nginx listens on :80 only, so also listen on $PORT when it differs; the
# public domain keeps targeting :80.
set -e
CONF=/etc/nginx/sites-enabled/default
if [ -n "${PORT:-}" ] && [ "$PORT" != "80" ] && ! grep -q "listen $PORT;" "$CONF"; then
  sed -i "0,/listen 80;/s//listen 80;\n    listen $PORT;/" "$CONF"
  echo "railway: nginx also listening on PORT=$PORT"
fi
exec /start.sh "$@"
