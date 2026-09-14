# OpenKnowledge on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/openknowledge?referralCode=YqmMB-&utm_medium=integration&utm_source=template&utm_campaign=generic)

Self-host [OpenKnowledge](https://openknowledge.ai), an AI-native Markdown knowledge base with a
live collaborative editor and an MCP endpoint that Claude, Cursor and other agents connect to
directly. Your notes are a real git repository on a volume you own.

This template follows upstream's own [authentication recipe](https://openknowledge.ai/docs/remote-control/authentication):
the server never faces the internet, and a proxy pair in front of it gives browsers a Google login
and agents a bearer token.

## What gets deployed

| Service | Image | Public | Purpose |
|---|---|---|---|
| `caddy` | `caddy:2.11-alpine` | **yes** | The only way in. Bearer-token gate on `/mcp`, everything else to the login |
| `oauth2-proxy` | `quay.io/oauth2-proxy/oauth2-proxy:v7.15.4` | no | Google login for the browser editor |
| `ok` | `node:24-slim` + `@inkeep/open-knowledge` | no | The server, editor, `/collab` WebSocket and `/mcp`. Volume at `/data` |

`ok` and `oauth2-proxy` have no domains at all. Caddy is the only route to either.

## Before you deploy: create a Google OAuth client

The editor is protected by a Google login, so the template needs a client. Create a **Web
application** client in the [Google Cloud console](https://console.cloud.google.com/apis/credentials),
with any placeholder redirect URI for now, and keep the client ID and secret.

After deploying, set the client's redirect URI to
`https://YOUR-CADDY-DOMAIN/oauth2/callback`, using the domain Railway gave the `caddy` service.
This order matters: the domain does not exist until the first deploy.

## First run

1. Deploy with the Google client ID and secret. The `ok` image builds from source, so allow a few
   minutes.
2. Set the OAuth redirect URI as above, then open the `caddy` service's URL and sign in.
3. To connect an agent, point it at `https://YOUR-CADDY-DOMAIN/mcp` and send `MCP_TOKEN` from the
   `caddy` service's variables as a bearer token.

## Variables

| Service | Variable | Default | Purpose |
|---|---|---|---|
| `oauth2-proxy` | `OAUTH2_PROXY_CLIENT_ID` | **you supply** | Google OAuth client ID |
| `oauth2-proxy` | `OAUTH2_PROXY_CLIENT_SECRET` | **you supply** | Google OAuth client secret |
| `oauth2-proxy` | `OAUTH2_PROXY_EMAIL_DOMAINS` | `*` | Restrict sign-in to your domain, e.g. `example.com`. Leave `*` and anyone with a Google account can sign in. |
| `caddy` | `MCP_TOKEN` | generated (48 hex) | Bearer token agents send to reach `/mcp` |
| `ok` | `OK_ALLOW_EXTERNAL` | `1` | Exposure consent. The server refuses to serve a proxied request without it. |

`OK_EXTERNAL_URL`, the redirect URL, the cookie secret and the private hostnames are all set by
reference or generated.

**Set `OAUTH2_PROXY_EMAIL_DOMAINS` to your own domain.** The default of `*` means any Google account
can sign in and edit.

## Why it is shaped this way

Four rules from upstream's proxy documentation drive the whole configuration, and getting any of
them wrong produces a deployment that looks fine and is not:

- **The server refuses proxied requests without consent.** Any request carrying a forwarding header
  gets `403 Proxied request refused` unless both `OK_ALLOW_EXTERNAL` and `OK_EXTERNAL_URL` are set.
  Every proxy stamps such a header, so the pair is a prerequisite rather than an option.
- **`Host` must reach the server unchanged.** It is compared against `OK_EXTERNAL_URL`, and a
  mismatch is a `403`. Caddy forwards the client's host with `header_up Host {host}`.
- **`X-Forwarded-Proto: https` must be set.** TLS ends at Railway's edge, so the hop to the server is
  plain HTTP. Without the header the server hands the editor a `ws://` socket, the browser blocks it
  as mixed content, and the editor loads but never syncs.
- **`/mcp` must not be buffered.** It is a server-sent-event stream. Caddy streams by default, and
  `/mcp` bypasses oauth2-proxy entirely so the login layer cannot interrupt it.

Two more Railway specifics: `OK_BIND=::` and `OAUTH2_PROXY_HTTP_ADDRESS=[::]:8080` because the
private network is IPv6-only — note that is not oauth2-proxy's default `4180`, which Railway starts
and then stops as unhealthy with nothing in the container's own log — and the `ok` service stays at
**one replica** because the collaboration server is single-writer: two replicas silently write to
the same volume.

## Bumping OpenKnowledge

Upstream publishes to npm many times a day, so this pins an exact version rather than tracking
latest. Change `OK_VERSION` in `ok/Dockerfile`.

## Component licenses

The wrapper files here are MIT (see `LICENSE`). OpenKnowledge is GPL-3.0-or-later, Caddy is Apache-2.0,
and oauth2-proxy is MIT.
