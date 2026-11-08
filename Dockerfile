# CaseCite on Railway. The base image is built by .github/workflows/publish-ghcr.yml
# from upstream thomasunise/casecite (Apache-2.0) at the pinned tag, using
# upstream's own root Dockerfile (nginx :80 + uvicorn, one container). This
# overlay only bakes Railway-specific defaults, so the template carries just
# generated secrets and service references:
#   DB_SSL=internal          Railway Postgres is reached over the private
#                            (WireGuard) network; its self-signed cert would
#                            fail upstream's CERT_REQUIRED "require" mode.
#   DISK_ENCRYPTION_ACKNOWLEDGED=true
#                            Railway volumes are encrypted at rest.
#   TRUSTED_PROXIES          nginx (127.0.0.1) + Railway's edge (100.64.0.0/10),
#                            so rate limits/lockouts see the real client IP.
# railway/entrypoint.sh also makes nginx listen on $PORT (Railway healthcheck).
ARG BASE_IMAGE=casecite-base:local
FROM ${BASE_IMAGE}
ENV DB_SSL=internal \
    DISK_ENCRYPTION_ACKNOWLEDGED=true \
    TRUSTED_PROXIES=127.0.0.1,100.64.0.0/10 \
    VECTOR_DB=chroma \
    CHROMA_PERSIST_DIR=/app/data/chroma \
    UPLOAD_DIR=/app/data/uploads \
    ALLOW_REGISTRATION=false
COPY railway/entrypoint.sh /railway-entrypoint.sh
RUN chmod 755 /railway-entrypoint.sh && grep -q 'listen 80;' /etc/nginx/sites-enabled/default
CMD ["/railway-entrypoint.sh"]
