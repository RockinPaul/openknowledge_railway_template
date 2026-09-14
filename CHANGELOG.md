# Changelog

## 2026-09-14

Initial template.

- Three services: `caddy` (public gateway), `oauth2-proxy` (Google sign-in) and `ok` (the server,
  volume at `/data`), implementing the recipe from upstream's remote-control documentation.
- `@inkeep/open-knowledge` pinned to 0.71.13; upstream publishes to npm many times a day.
- `caddy:2.11-alpine` and `oauth2-proxy:v7.15.4` — upstream's recipe floats the majors (`caddy:2`,
  `oauth2-proxy:v7`); pinned to the current stable minor of each.
- `OK_BIND=::` and `OAUTH2_PROXY_HTTP_ADDRESS=[::]:8080` for Railway's IPv6-only private network.
  oauth2-proxy's default `:4180` deploys, logs a clean start, then stops the container with no error,
  because the health check probes the port the platform expects.
- `PORT` baked into the images rather than set as a service variable, so template generation cannot
  null it into a required composer field.
- Caddy answers `/up` itself for the platform health check, so the probe never meets a redirect.
- `ok` pinned to one replica: the collaboration server is single-writer per volume.
- Per-service `watchPatterns`, so a documentation commit does not rebuild every service and
  restart live editing sessions.
