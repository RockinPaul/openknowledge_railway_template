# OpenKnowledge collaboration server: the editor, the /collab WebSocket and the
# /mcp endpoint. No public domain of its own — Caddy is the only way in.
#
# Upstream publishes no image, so this installs the npm package at a pinned
# version, following the Dockerfile in their Docker guide.
ARG OK_VERSION=0.71.13
ARG NODE_IMAGE=node:24-slim

FROM ${NODE_IMAGE}
ARG OK_VERSION
# git is a hard boot requirement: the server runs a git preflight at boot and
# the version-history subsystems shell out to the binary.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g "@inkeep/open-knowledge@${OK_VERSION}" \
    && npm cache clean --force

# PORT is baked rather than set as a service variable: this service has no
# public domain, so Railway assigns it no port, and a literal variable default
# is nulled into a required composer field by template generation.
# OK_BIND=:: because Railway's private network is IPv6-only; upstream warns not
# to combine "0.0.0.0 ::" on one port because the listeners conflict.
# OK_ALLOW_EXTERNAL is deliberately NOT baked. Without it the server refuses to
# boot and names the fix, which is the secure default; the template supplies it
# as a service variable instead.
ENV PORT=8080 \
    OK_BIND=::

# No VOLUME instruction: managed builders reject it, and persistence is the
# platform's job via a mounted volume.
WORKDIR /data
EXPOSE 8080
COPY --chmod=755 entrypoint.sh /usr/local/bin/railway-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
