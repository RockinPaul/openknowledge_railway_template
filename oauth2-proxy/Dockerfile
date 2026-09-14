# Google login for the browser editor. Private: only Caddy talks to it.
#
# A thin wrapper over the upstream image. It exists so the IPv6 bind and the
# proxy settings are baked rather than supplied as service variables, which
# template generation nulls into required composer fields.
FROM quay.io/oauth2-proxy/oauth2-proxy:v7.13.0

# Railway's private network is IPv6-only, so listen on [::].
# Port 8080 rather than oauth2-proxy's default 4180: Railway's health check
# probes the port it expects for the container, and a service listening only on
# 4180 is started and then stopped as unhealthy with nothing in its own log.
# REVERSE_PROXY makes oauth2-proxy trust the forwarded headers Caddy sets, which
# it needs for the client IP and for building the post-login redirect.
# FLUSH_INTERVAL follows the never-buffer rule: the editor streams.
# SKIP_PROVIDER_BUTTON goes straight to Google instead of an interstitial.
ENV OAUTH2_PROXY_PROVIDER=google \
    OAUTH2_PROXY_HTTP_ADDRESS=[::]:8080 \
    OAUTH2_PROXY_REVERSE_PROXY=true \
    OAUTH2_PROXY_SKIP_PROVIDER_BUTTON=true \
    OAUTH2_PROXY_FLUSH_INTERVAL=100ms \
    OAUTH2_PROXY_UPSTREAMS=http://ok.railway.internal:8080/ \
    OAUTH2_PROXY_PING_PATH=/ping \
    OAUTH2_PROXY_SESSION_STORE_TYPE=cookie
EXPOSE 8080
