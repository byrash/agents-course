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
  llm_provider, llm_model, openai_api_key,
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

echo ""
echo "============================================"
echo "  Deployed for: $STUDENT_NAME"
echo "  Server IP:    $(tofu output -raw server_ip)"
echo "  Dashboard:    $(tofu output -raw dashboard_url)"
echo "  SSH (root):   $(tofu output -raw ssh_command)"
echo "  SSH (agent):  $(tofu output -raw ssh_zeroclaw)"
echo "============================================"
echo ""
echo "Cloud-init takes 3-5 minutes to finish setup."
echo "Check progress: ssh root@$(tofu output -raw server_ip) 'tail -f /var/log/cloud-init-output.log'"
