# Public entry point. Caddy is the only way in: neither the server nor the login
# proxy has a domain of its own.
#
# The configuration is baked into the image rather than mounted, because managed
# platforms provide no way to mount a file.
FROM caddy:2.11-alpine

# PORT is overridden by Railway for the service that owns the public domain;
# this is the local default. Caddy proxies WebSocket upgrades transparently, so
# the editor's /collab socket needs no extra directive.
ENV PORT=8080
COPY Caddyfile /etc/caddy/Caddyfile
EXPOSE 8080
