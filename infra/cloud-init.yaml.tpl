#cloud-config

package_update: true
package_upgrade: true

packages:
  - curl
  - ca-certificates
  - xvfb
  - firejail
  - libnss3
  - libatk1.0-0t64
  - libatk-bridge2.0-0t64
  - libcups2t64
  - libdrm2
  - libxkbcommon0
  - libxcomposite1
  - libxdamage1
  - libxrandr2
  - libgbm1
  - libpango-1.0-0
  - libcairo2
  - libasound2t64
  - libxshmfence1
  - libxfixes3
  - libx11-xcb1
  - fonts-liberation
  - jq

users:
  - name: zeroclaw
    shell: /bin/bash
    groups: [sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true

write_files:
  - path: /home/zeroclaw/.zeroclaw/config.toml
    owner: zeroclaw:zeroclaw
    permissions: "0600"
    content: |
      default_provider = "${llm_provider}"
      default_model = "${llm_model}"
      default_temperature = 0.7
      provider_timeout_secs = 120

      [channels_config]
      cli = true

      [channels_config.telegram]
      bot_token = "${telegram_bot_token}"
      allowed_users = ["${telegram_user_id}"]
      stream_mode = "partial"
      mention_only = false
      interrupt_on_new_message = true

      [autonomy]
      level = "supervised"
      workspace_only = true
      allowed_commands = ["curl", "wget", "git", "ls", "cat", "echo", "date", "node", "npx"]
      forbidden_paths = ["/etc/shadow", "/etc/passwd", "/root", "/proc", "/sys"]
      allowed_roots = []
      max_actions_per_hour = 100
      max_cost_per_day_cents = 500
      block_high_risk_commands = true
      auto_approve = ["web_search_tool", "web_fetch", "browser", "memory_store", "memory_recall", "file_read"]

      [security.sandbox]
      enabled = false

      [memory]
      backend = "sqlite"
      auto_save = true

      [browser]
      enabled = true
      backend = "agent_browser"
      native_headless = true
      allowed_domains = ["*"]

      [web_search]
      enabled = true
      provider = "duckduckgo"

      [web_fetch]
      enabled = true
      timeout_secs = 30
      max_response_size = 500000
      allowed_domains = ["*"]

      [agent]
      max_tool_iterations = 50

      [gateway]
      port = 42617
      host = "0.0.0.0"
      require_pairing = false
      allow_public_bind = true

      [cron]
      enabled = false

%{ if openai_api_key != "" || openrouter_api_key != "" }
  - path: /home/zeroclaw/.zeroclaw/.env
    owner: zeroclaw:zeroclaw
    permissions: "0600"
    content: |
%{ if openai_api_key != "" ~}
      OPENAI_API_KEY=${openai_api_key}
%{ endif ~}
%{ if openrouter_api_key != "" ~}
      OPENROUTER_API_KEY=${openrouter_api_key}
%{ endif ~}
%{ endif }

  - path: /home/zeroclaw/.zeroclaw/workspace/AGENTS.md
    owner: zeroclaw:zeroclaw
    permissions: "0644"
    content: |
      ${indent(6, ws_agents)}

  - path: /home/zeroclaw/.zeroclaw/workspace/SOUL.md
    owner: zeroclaw:zeroclaw
    permissions: "0644"
    content: |
      ${indent(6, ws_soul)}

  - path: /home/zeroclaw/.zeroclaw/workspace/IDENTITY.md
    owner: zeroclaw:zeroclaw
    permissions: "0644"
    content: |
      ${indent(6, ws_identity)}

  - path: /home/zeroclaw/.zeroclaw/workspace/USER.md
    owner: zeroclaw:zeroclaw
    permissions: "0644"
    content: |
      ${indent(6, ws_user)}

  - path: /home/zeroclaw/.zeroclaw/workspace/TOOLS.md
    owner: zeroclaw:zeroclaw
    permissions: "0644"
    content: |
      ${indent(6, ws_tools)}

  - path: /home/zeroclaw/start-zeroclaw.sh
    owner: zeroclaw:zeroclaw
    permissions: "0755"
    content: |
      #!/bin/bash
      set -euo pipefail

      if [ -f "$HOME/.zeroclaw/.env" ]; then
          set -a
          source "$HOME/.zeroclaw/.env"
          set +a
      fi

      Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp &
      sleep 1
      export DISPLAY=:99

      exec /usr/local/bin/zeroclaw daemon

  - path: /etc/systemd/system/zeroclaw.service
    permissions: "0644"
    content: |
      [Unit]
      Description=ZeroClaw AI Agent (${student_name})
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=simple
      User=zeroclaw
      Group=zeroclaw
      WorkingDirectory=/home/zeroclaw
      ExecStart=/home/zeroclaw/start-zeroclaw.sh
      Restart=on-failure
      RestartSec=5

      Environment=PATH=/home/zeroclaw/.npm-global/bin:/home/zeroclaw/.local/bin:/usr/local/bin:/usr/bin:/bin
      Environment=PLAYWRIGHT_BROWSERS_PATH=/home/zeroclaw/.cache/ms-playwright
      Environment=BROWSER=
      Environment=DBUS_SESSION_BUS_ADDRESS=/dev/null
      Environment=RUST_LOG=info

      [Install]
      WantedBy=multi-user.target

runcmd:
  # Node.js 22
  - curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  - apt-get install -y --no-install-recommends nodejs

  # ZeroClaw binary (auto-detect architecture)
  - |
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64)  ZC_ARCH="x86_64" ;;
      aarch64) ZC_ARCH="aarch64" ;;
      *)       ZC_ARCH="x86_64" ;;
    esac
    mkdir -p /tmp/zc
    curl -fsSL "https://github.com/zeroclaw-labs/zeroclaw/releases/download/${zeroclaw_version}/zeroclaw-$${ZC_ARCH}-unknown-linux-gnu.tar.gz" \
      | tar xz -C /tmp/zc
    find /tmp/zc -name 'zeroclaw' -type f | head -1 | xargs -I{} cp {} /usr/local/bin/zeroclaw
    chmod +x /usr/local/bin/zeroclaw
    rm -rf /tmp/zc

  # agent-browser + Playwright (as zeroclaw user)
  - |
    su - zeroclaw -c '
      mkdir -p ~/.npm-global
      npm config set prefix "$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"
      npm install -g agent-browser
      npx playwright install chromium
    '

  # Suppress xdg-open
  - |
    su - zeroclaw -c '
      mkdir -p ~/.local/bin
      printf "#!/bin/sh\nexit 0\n" > ~/.local/bin/xdg-open
      chmod +x ~/.local/bin/xdg-open
    '

  # Ensure directory ownership
  - chown -R zeroclaw:zeroclaw /home/zeroclaw

  # Enable and start
  - systemctl daemon-reload
  - systemctl enable zeroclaw
  - systemctl start zeroclaw
