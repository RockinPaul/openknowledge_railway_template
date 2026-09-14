# Deploy and Host OpenKnowledge on Railway

[OpenKnowledge](https://openknowledge.ai) is an open-source, AI-native Markdown knowledge base. It
gives you a live collaborative editor in the browser and an MCP endpoint that Claude, Cursor and
other agents connect to directly, over a knowledge base that is a real git repository with full
version history.

## About Hosting OpenKnowledge

The server has no login of its own, so a public domain would give anyone who finds it full read and
write access. This template follows the authentication recipe from OpenKnowledge's own
documentation: three services, where only the gateway is reachable from the internet. It gives
browsers a Google sign-in and agents a generated bearer token, and the two paths are kept separate
so the agent stream is never interrupted by a login redirect. The knowledge base lives on a volume
and survives redeploys.

What you supply is a Google OAuth client, because the editor is protected by a Google sign-in.
Create the client before deploying, then point its redirect URI at the domain Railway generates.
Everything else, including the agent token and the cookie secret, is generated for you.

## Common Use Cases

- Keep a team wiki that your coding agents can read and write through MCP, not just people.
- Give Claude or Cursor a durable, versioned knowledge base instead of pasted context.
- Run a personal Markdown knowledge base with real git history on infrastructure you control.

## Dependencies for OpenKnowledge Hosting

- A Google OAuth client (Web application type) for the browser sign-in.
- A volume for the knowledge base, which the template creates.
- An MCP-capable client, if you want to connect an agent rather than only use the editor.

### Deployment Dependencies

- [OpenKnowledge](https://github.com/inkeep/open-knowledge) — the upstream project (GPL-3.0-or-later).
- [Remote control documentation](https://openknowledge.ai/docs/remote-control/authentication) — the
  authentication recipe this template implements.
- [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/) — the browser sign-in layer (MIT).
- [Caddy](https://caddyserver.com) — the gateway (Apache-2.0).

### Implementation Details

Three services build from this template's repository, each from its own directory:

- **caddy** — the only public service. It gates `/mcp` behind a generated bearer token and sends
  every other path through the sign-in. It preserves the client `Host` and sets
  `X-Forwarded-Proto: https`, both of which the server requires, and answers the platform health
  check itself so the probe never meets a login redirect.
- **oauth2-proxy** — the Google sign-in for the browser, on the private network only.
- **ok** — the server, built from a pinned npm version because upstream publishes no image. Its
  entrypoint initialises the knowledge base on the empty volume at first boot and starts the server
  afterwards. One replica only: the collaboration server is single-writer.

After deploying, set your Google client's redirect URI to `https://YOUR-CADDY-DOMAIN/oauth2/callback`
and open the caddy service's URL. Agents connect to the same domain with `/mcp` appended, sending
`MCP_TOKEN` as a bearer token.

Consider setting `OAUTH2_PROXY_EMAIL_DOMAINS` on the sign-in service to your own domain. It defaults
to `*`, which lets any Google account sign in.

## Why Deploy OpenKnowledge on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your
infrastructure so you don't have to deal with configuration, while allowing you to vertically and
horizontally scale it.

By deploying OpenKnowledge on Railway, you are one step closer to supporting a complete full-stack
application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
