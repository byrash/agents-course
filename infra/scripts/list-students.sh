#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_DIR="$(dirname "$SCRIPT_DIR")"

cd "$INFRA_DIR"

echo "Deployed student instances:"
echo "==========================="
echo ""

CURRENT=$(tofu workspace show)

for ws in $(tofu workspace list | sed 's/\*//g' | tr -d ' ' | grep -v '^default$'); do
    tofu workspace select "$ws" > /dev/null 2>&1

    IP=$(tofu output -raw server_ip 2>/dev/null || echo "unknown")
    STATUS=$(tofu output -raw server_status 2>/dev/null || echo "unknown")

    printf "  %-20s  IP: %-16s  Status: %s\n" "$ws" "$IP" "$STATUS"
done

tofu workspace select "$CURRENT" > /dev/null 2>&1

echo ""
echo "Total workspaces (excluding default): $(tofu workspace list | grep -cv 'default\|^$' || echo 0)"
