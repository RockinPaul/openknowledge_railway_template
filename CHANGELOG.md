# Changelog

## 2026-10-15

- `@inkeep/open-knowledge` 0.71.13 → 0.86.16. Upstream security fixes in this range include refusing
  incoming symlinks into private state (on sync pull and elsewhere), refusing opaque-origin writes and
  non-JSON bodies on the local `/api`, withholding `.git`/`node_modules` under skill roots, closing
  ways around the read-only command grant, and Next.js 16.3.8 for its September security release.
- `oauth2-proxy` v7.15.4 → v7.15.5: no panic on a short GCM ciphertext, Microsoft Graph errors
  surfaced during Entra group overage, Bitbucket API auth fix.
- Agents using `/mcp`: the `conflicts` and `resolve_conflict` tools from 0.71 are no longer listed in
  0.86. The other tools, including `write`, `edit`, `search`, `history` and `exec`, are unchanged.

### Upgrading an existing deployment

Nothing to change by hand: the variables and the `/data` layout are the same. Verified locally with
the template's entrypoint: a 0.71.13 project with a document written through `/mcp` was opened by
0.86.16, the document read back and was found by search, and new writes worked. A fresh 0.86.16
volume still initialises with `ok init --no-mcp --no-skills`, the host check still refuses a proxied
request whose host is not `OK_EXTERNAL_URL`, and `/collab` upgrades to a WebSocket. On the first
start after the update the server logs that it replaced a stale lock file left by the previous
container; that is expected.

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
