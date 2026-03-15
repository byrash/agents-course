FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETARCH
ARG ZEROCLAW_VERSION=v0.3.0

# Runtime dependencies: headless browser libs, sandbox, virtual framebuffer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates xvfb firejail \
    libnss3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
    libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
    libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 \
    libxshmfence1 libxfixes3 libx11-xcb1 fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 for agent-browser (Playwright backend)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Prebuilt ZeroClaw binary from GitHub releases
RUN set -e; \
    ARCH=$(case "${TARGETARCH:-amd64}" in \
        amd64) echo "x86_64" ;; \
        arm64) echo "aarch64" ;; \
        *)     echo "x86_64" ;; \
    esac); \
    mkdir -p /tmp/zc && \
    curl -fsSL "https://github.com/zeroclaw-labs/zeroclaw/releases/download/${ZEROCLAW_VERSION}/zeroclaw-${ARCH}-unknown-linux-gnu.tar.gz" \
        | tar xz -C /tmp/zc && \
    find /tmp/zc -name 'zeroclaw' -type f | head -1 | xargs -I{} cp {} /usr/local/bin/zeroclaw && \
    chmod +x /usr/local/bin/zeroclaw && \
    rm -rf /tmp/zc

RUN useradd -m -s /bin/bash -d /home/zeroclaw zeroclaw

USER zeroclaw
WORKDIR /home/zeroclaw

# agent-browser + Playwright headless Chromium
RUN mkdir -p ~/.npm-global \
    && npm config set prefix "$HOME/.npm-global" \
    && PATH="$HOME/.npm-global/bin:$PATH" npm install -g agent-browser \
    && PATH="$HOME/.npm-global/bin:$PATH" npx playwright install chromium

# Suppress xdg-open calls that hang on headless servers
RUN mkdir -p ~/.local/bin \
    && printf '#!/bin/sh\nexit 0\n' > ~/.local/bin/xdg-open \
    && chmod +x ~/.local/bin/xdg-open

RUN mkdir -p ~/.zeroclaw/workspace ~/.zeroclaw/memory ~/.config/zeroclaw

ENV PATH="/home/zeroclaw/.npm-global/bin:/home/zeroclaw/.local/bin:/usr/local/bin:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH=/home/zeroclaw/.cache/ms-playwright
ENV BROWSER=
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV RUST_LOG=info

COPY --chown=zeroclaw:zeroclaw entrypoint.sh /home/zeroclaw/entrypoint.sh
COPY --chown=zeroclaw:zeroclaw config.template.toml /home/zeroclaw/config.template.toml
COPY --chown=zeroclaw:zeroclaw workspace-defaults/ /home/zeroclaw/workspace-defaults/

RUN chmod +x /home/zeroclaw/entrypoint.sh

EXPOSE 42617

ENTRYPOINT ["/home/zeroclaw/entrypoint.sh"]
