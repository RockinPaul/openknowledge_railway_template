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
In the Google Cloud console, under APIs and Services then Credentials, create an OAuth client ID
of type **Web application** — configuring the consent screen first if that project has none. Give
it any placeholder redirect URI for now; you correct it once Railway has generated your domain.
The client ID and secret it shows you are the `OAUTH2_PROXY_CLIENT_ID` and
`OAUTH2_PROXY_CLIENT_SECRET` the deploy form asks for. Everything else, including the agent token
and the cookie secret, is generated for you.

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

After deploying, edit your Google client so its authorized redirect URI is
`https://YOUR-CADDY-DOMAIN/oauth2/callback`, using the domain Railway gave the caddy service, then
open that domain and sign in. Agents connect to the same domain with `/mcp` appended, sending
`MCP_TOKEN` as a bearer token.

The third field, `OAUTH2_PROXY_EMAIL_DOMAINS`, is the comma-separated list of email domains
allowed to sign in. It has no default, and `*` admits any Google account. Note that a domain
allowlist cannot express a single person: signing in with a personal gmail.com address means the
only value that works is `gmail.com`, which admits every Gmail user. Use an account on a domain
you control.

## Why Deploy OpenKnowledge on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your
infrastructure so you don't have to deal with configuration, while allowing you to vertically and
horizontally scale it.

By deploying OpenKnowledge on Railway, you are one step closer to supporting a complete full-stack
application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
