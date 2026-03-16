#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    cat <<'USAGE'
Destroy a student's ZeroClaw server on Hetzner Cloud.

Usage:
  ./scripts/teardown-student.sh <student-name> <student.tfvars>

Example:
  ./scripts/teardown-student.sh alice students/alice.tfvars
USAGE
    exit 1
}

[[ $# -lt 2 ]] && usage

STUDENT_NAME="$1"
TFVARS_FILE="$2"

[[ -f "$INFRA_DIR/$TFVARS_FILE" ]] && TFVARS_FILE="$INFRA_DIR/$TFVARS_FILE"

cd "$INFRA_DIR"

if ! tofu workspace select "$STUDENT_NAME" 2>/dev/null; then
    echo "Error: workspace '$STUDENT_NAME' not found. Nothing to destroy."
    exit 1
fi

echo "==> This will PERMANENTLY destroy $STUDENT_NAME's server."
echo "    All data on the server will be lost."
echo ""
read -rp "Are you sure? Type the student name to confirm: " confirm

if [[ "$confirm" != "$STUDENT_NAME" ]]; then
    echo "Aborted."
    exit 0
fi

tofu destroy -var-file="$TFVARS_FILE" -auto-approve

tofu workspace select default
tofu workspace delete "$STUDENT_NAME"

echo ""
echo "==> Server for $STUDENT_NAME has been destroyed."
