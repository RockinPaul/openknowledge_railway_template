#!/bin/sh
# Initialise the project on first boot, then start the server.
#
# `ok start` needs an initialised project, and nobody is inside the container to
# run `ok init`. First boot scaffolds it on the empty volume; later boots find
# .ok/ and start directly. Official database images use the same pattern.
set -eu

# Both declarations are a prerequisite for running behind any proxy: the server
# refuses a request carrying a forwarding header with "403 Proxied request
# refused" unless both are set, and Caddy stamps X-Forwarded-Proto on every one.
if [ -z "${OK_ALLOW_EXTERNAL:-}" ]; then
  echo "OK_ALLOW_EXTERNAL is empty; the server refuses to serve a proxied request without it" >&2
  exit 1
fi
if [ -z "${OK_EXTERNAL_URL:-}" ]; then
  echo "OK_EXTERNAL_URL is empty; set it to the caddy service's public origin or every request 403s" >&2
  exit 1
fi

# A Railway volume root arrives owned by root with a lost+found directory in it.
# That is not an empty directory, so test for the project marker rather than for
# emptiness before deciding to initialise.
if [ ! -d /data/.ok ]; then
  echo "[entrypoint] /data is not initialised. Running ok init --no-mcp --no-skills"
  # stdin is closed so `ok init` takes its non-TTY defaults and cannot hang on a
  # prompt. --no-mcp --no-skills skip local agent config the container does not
  # need; the server still serves its /mcp endpoint.
  ok init --no-mcp --no-skills < /dev/null
fi

echo "[entrypoint] serving ${OK_EXTERNAL_URL} on [${OK_BIND}]:${PORT}"
exec ok start
