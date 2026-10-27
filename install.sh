#!/bin/sh
# Installs mastermem's hooks and MCP into Codex or Cursor (macOS, Linux). The dashboard shows this line:
#   curl -fsSL https://raw.githubusercontent.com/mastermem/mastermem-claude/main/install.sh | sh -s -- codex <server> <token>
# It downloads mastermem-hook for this machine and runs `mastermem-hook install <client> --server <server>` with the token
# on stdin; the helper copies itself into the client's config dir, so the download is removed afterwards.
set -eu
client=${1:-}
server=${2:-}
token=${3:-${MASTERMEM_TOKEN:-${MASTERMEM_TOKEN:-}}}
case "$client" in codex | cursor) ;; *)
  echo "usage: install.sh codex|cursor <server> <token>" >&2
  exit 2
  ;;
esac
[ -n "$server" ] && [ -n "$token" ] || {
  echo "usage: install.sh codex|cursor <server> <token>" >&2
  exit 2
}
os=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$(uname -m)" in x86_64 | amd64) arch=amd64 ;; arm64 | aarch64) arch=arm64 ;; *)
  echo "mastermem: unsupported CPU $(uname -m)" >&2
  exit 1
  ;;
esac
case "$os" in linux | darwin) ;; *)
  echo "mastermem: unsupported system $os (Windows: see the README)" >&2
  exit 1
  ;;
esac
base=${MASTERMEM_HOOK_BASE:-https://raw.githubusercontent.com/mastermem/mastermem-claude/main/plugins/mastermem/hooks/bin}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSLo "$tmp/mastermem-hook" "$base/$os-$arch/mastermem-hook"
chmod +x "$tmp/mastermem-hook"
printf '%s\n' "$token" | "$tmp/mastermem-hook" install "$client" --server "$server"
