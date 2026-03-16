#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    cat <<'USAGE'
Deploy a ZeroClaw instance for a student on Hetzner Cloud.

Usage:
  ./scripts/deploy-student.sh <student.tfvars>

Example:
  ./scripts/deploy-student.sh students/alice.tfvars

The .tfvars file must contain at minimum:
  hcloud_token       = "hc..."
  student_name       = "alice"
  telegram_bot_token = "123456:ABC..."
  telegram_user_id   = "987654321"

Optional variables (have defaults):
  llm_provider, llm_model, openai_api_key, openrouter_api_key,
  server_type, location, instructor_ssh_public_key
USAGE
    exit 1
}

[[ $# -lt 1 ]] && usage

TFVARS_FILE="$1"

if [[ ! -f "$INFRA_DIR/$TFVARS_FILE" && ! -f "$TFVARS_FILE" ]]; then
    echo "Error: $TFVARS_FILE not found"
    exit 1
fi

[[ -f "$INFRA_DIR/$TFVARS_FILE" ]] && TFVARS_FILE="$INFRA_DIR/$TFVARS_FILE"
[[ -f "$TFVARS_FILE" ]] || true

STUDENT_NAME=$(grep 'student_name' "$TFVARS_FILE" | head -1 | sed 's/.*=\s*"\(.*\)"/\1/')

if [[ -z "$STUDENT_NAME" ]]; then
    echo "Error: student_name not found in $TFVARS_FILE"
    exit 1
fi

echo "==> Deploying ZeroClaw for student: $STUDENT_NAME"

cd "$INFRA_DIR"

tofu workspace select "$STUDENT_NAME" 2>/dev/null || tofu workspace new "$STUDENT_NAME"

tofu init -upgrade

tofu plan -var-file="$TFVARS_FILE" -out="$STUDENT_NAME.tfplan"

echo ""
read -rp "Apply this plan? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    rm -f "$STUDENT_NAME.tfplan"
    exit 0
fi

tofu apply "$STUDENT_NAME.tfplan"
rm -f "$STUDENT_NAME.tfplan"

SERVER_IP=$(tofu output -raw server_ip)
KEY_DIR="$INFRA_DIR/students/$STUDENT_NAME"
KEY_FILE="$KEY_DIR/id_ed25519"
CONFIG_FILE="$KEY_DIR/ssh_config"

mkdir -p "$KEY_DIR"

tofu output -raw student_private_key > "$KEY_FILE"
chmod 600 "$KEY_FILE"

tofu output -raw student_ssh_config > "$CONFIG_FILE"

cat <<EOF

============================================
  Deployed for: $STUDENT_NAME
  Server IP:    $SERVER_IP
  Dashboard:    http://$SERVER_IP:42617
============================================

  SSH key saved:   $KEY_FILE
  SSH config saved: $CONFIG_FILE

  Cloud-init takes 3-5 minutes to finish.
  Monitor: ssh -i $KEY_FILE zeroclaw@$SERVER_IP 'tail -f /var/log/cloud-init-output.log'

============================================
  GIVE THESE TO THE STUDENT:
============================================

  1. Key file:   $KEY_FILE
  2. Server IP:  $SERVER_IP
  3. Host alias: zc-$STUDENT_NAME

  --- Student setup (macOS / Linux) ---

  cp <path-to-key>/id_ed25519 ~/.ssh/zc-$STUDENT_NAME
  chmod 600 ~/.ssh/zc-$STUDENT_NAME
  cat >> ~/.ssh/config << 'SSHEOF'

  Host zc-$STUDENT_NAME
    HostName $SERVER_IP
    User zeroclaw
    IdentityFile ~/.ssh/zc-$STUDENT_NAME
    StrictHostKeyChecking no
  SSHEOF

  --- Student setup (Windows PowerShell) ---

  Copy-Item <path-to-key>\id_ed25519 \$env:USERPROFILE\.ssh\zc-$STUDENT_NAME
  icacls \$env:USERPROFILE\.ssh\zc-$STUDENT_NAME /inheritance:r /grant:r "\$(\$env:USERNAME):R"
  Add-Content \$env:USERPROFILE\.ssh\config @"

  Host zc-$STUDENT_NAME
    HostName $SERVER_IP
    User zeroclaw
    IdentityFile ~/.ssh/zc-$STUDENT_NAME
    StrictHostKeyChecking no
  "@

  --- VS Code Remote SSH ---

  1. Install VS Code extension: "Remote - SSH"
  2. Cmd+Shift+P (or Ctrl+Shift+P) -> "Remote-SSH: Connect to Host"
  3. Select "zc-$STUDENT_NAME"
  4. Open folder: ~/.zeroclaw/workspace/

============================================
EOF
