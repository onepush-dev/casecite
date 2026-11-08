# CaseCite on Railway

CaseCite — open-source, self-hosted legal RAG: caselaw research and document analysis for law firms. Deploy on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/pTbByj)

This repository packages [CaseCite](https://github.com/thomasunise/casecite) v1.3.0 (Apache-2.0) for Railway. It is an independent community packaging, not affiliated with or endorsed by the CaseCite project. The image is built by GitHub Actions from upstream's own root `Dockerfile` at tag v1.3.0, plus a tiny overlay of Railway defaults (see `Dockerfile`).

## Services

| Service | What | Storage |
|---|---|---|
| **CaseCite** | `ghcr.io/onepush-dev/casecite:1.3.0` — nginx serves the React app on :80 and proxies `/api` to uvicorn (FastAPI) in the same container | volume `/app/data` (uploads, Chroma vectors, audit logs, instance secrets) |
| **Postgres** | Railway Postgres | volume |
| **Redis** | Railway Redis (default `noeviction` policy, which CaseCite requires: it stores revoked-token markers and lockout counters) | volume |

## First login

1. Open the CaseCite domain and choose **Register**.
2. The first account becomes the admin and needs the **registration bootstrap token**: copy `REGISTRATION_BOOTSTRAP_TOKEN` from the CaseCite service's Variables tab. Nobody without it can claim the instance. Public registration stays off afterwards (`ALLOW_REGISTRATION=false`); invite users from the admin panel.
3. Add an AI provider: each user can save their own OpenAI/Anthropic key in Settings, or set `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` (and optionally `VOYAGE_API_KEY`, `COURTLISTENER_API_TOKEN`, `SENDGRID_API_KEY` + `NOREPLY_EMAIL`) on the CaseCite service.

## Variables (CaseCite service)

| Variable | Value | Purpose |
|---|---|---|
| `SECRET_KEY` | generated (64 hex) | JWT/session signing |
| `ENCRYPTION_SALT` | generated (32 hex) | Key-derivation salt for encrypted user secrets |
| `AUDIT_HMAC_KEY` | generated (64 hex) | Tamper-evident audit-log chain |
| `REGISTRATION_BOOTSTRAP_TOKEN` | generated (32 hex) | Required to register the first (admin) account |
| `DATABASE_URL` | `postgresql+asyncpg://postgres:…@${{Postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/postgres` | Postgres (private network) |
| `REDIS_URL` | `redis://default:…@${{Redis.RAILWAY_PRIVATE_DOMAIN}}:6379` | Redis (private network) |
| `ALLOWED_HOSTS` / `CORS_ORIGINS` / `FRONTEND_URL` | your Railway domain | Host allow-list, CORS and links in emails |

Baked image defaults (override as variables if needed): `DB_SSL=internal`, `healthcheck.railway.app` auto-appended to `ALLOWED_HOSTS` (Railway healthcheck), nginx also listening on IPv6 and on `$PORT`, `DISK_ENCRYPTION_ACKNOWLEDGED=true` (Railway volumes are encrypted at rest), `TRUSTED_PROXIES=127.0.0.1,100.64.0.0/10`, `VECTOR_DB=chroma`, `ALLOW_REGISTRATION=false`.

## Notes

- Back up the `/app/data` volume **and** Postgres; `/app/data` holds instance secrets and the vector index.
- Adding a custom domain: append it to `ALLOWED_HOSTS` and `CORS_ORIGINS` (comma-separated) and update `FRONTEND_URL`.
- To upgrade, bump `UPSTREAM_REF` / `IMAGE` in `.github/workflows/publish-ghcr.yml`; migrations run automatically on start.
