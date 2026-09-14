# Changelog

## 2026-09-14

Initial template.

- Three services: `caddy` (public gateway), `oauth2-proxy` (Google sign-in) and `ok` (the server,
  volume at `/data`), implementing the recipe from upstream's remote-control documentation.
- `@inkeep/open-knowledge` pinned to 0.71.13; upstream publishes to npm many times a day.
- `OK_BIND=::` and `OAUTH2_PROXY_HTTP_ADDRESS=[::]:4180` for Railway's IPv6-only private network.
- `PORT` baked into the images rather than set as a service variable, so template generation cannot
  null it into a required composer field.
- Caddy answers `/up` itself for the platform health check, so the probe never meets a redirect.
- `ok` pinned to one replica: the collaboration server is single-writer per volume.
