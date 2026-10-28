#!/bin/sh
# Installs mastermem's hooks and MCP into Codex or Cursor (macOS, Linux). The dashboard shows this line:
#   curl -fsSL https://raw.githubusercontent.com/mastermem/mastermem-claude/<version tag>/install.sh | sh -s -- codex <server>
# The device token is never an argument (shell history, ps): it comes from MASTERMEM_TOKEN or is asked for on the
# terminal. It downloads mastermem-hook for this machine and runs `mastermem-hook install <client> --server <server>`
# with the token on stdin; the helper copies itself into the client's config dir, so the download is removed afterwards.
set -eu
usage() {
  echo "usage: install.sh codex|cursor <server>   (the token: MASTERMEM_TOKEN, else asked for)" >&2
  exit 2
}
client=${1:-}
server=${2:-}
case "$client" in codex | cursor) ;; *) usage ;; esac
[ -n "$server" ] || usage
if [ $# -gt 2 ]; then
  echo "mastermem: do not pass the token as an argument; paste it when asked or set MASTERMEM_TOKEN" >&2
  exit 2
fi
tmp=
noecho=
trap '[ -z "$tmp" ] || rm -rf "$tmp"; [ -z "$noecho" ] || stty echo </dev/tty 2>/dev/null || true' EXIT
trap 'exit 130' INT TERM
token=${MASTERMEM_TOKEN:-}
if [ -z "$token" ] && (: </dev/tty) 2>/dev/null; then
  # from the terminal, not stdin (stdin is this script when piped from curl); no echo while it is typed
  printf 'mastermem device token: ' >/dev/tty
  noecho=1
  stty -echo </dev/tty 2>/dev/null || true
  IFS= read -r token </dev/tty || true
  stty echo </dev/tty 2>/dev/null || true
  noecho=
  printf '\n' >/dev/tty
fi
[ -n "$token" ] || {
  echo "mastermem: no token (set MASTERMEM_TOKEN or run it in a terminal)" >&2
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
# The release this script belongs to (publish.sh sets the tag) and its signing key (allowed_signers): the helper is
# only run when SHA256SUMS carries a valid signature of that key and lists the downloaded file with its hash.
version=v0.6.1
signer='mastermem-release ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2CxwEGYaZbQAYM/mlghTalJzTqbTu+5YAUKzqtz5mD'
repo=${MASTERMEM_RELEASE_BASE:-https://raw.githubusercontent.com/mastermem/mastermem-claude/$version}
tmp=$(mktemp -d)
command -v ssh-keygen >/dev/null || { echo "mastermem: ssh-keygen (OpenSSH) is needed to check the download" >&2; exit 1; }
curl -fsSLo "$tmp/SHA256SUMS" "$repo/SHA256SUMS"
curl -fsSLo "$tmp/SHA256SUMS.sig" "$repo/SHA256SUMS.sig"
printf '%s\n' "$signer" >"$tmp/allowed_signers"
ssh-keygen -q -Y verify -f "$tmp/allowed_signers" -I mastermem-release -n mastermem-release -s "$tmp/SHA256SUMS.sig" <"$tmp/SHA256SUMS" >/dev/null || {
  echo "mastermem: the release signature does not check out; nothing was installed" >&2
  exit 1
}
file=plugins/mastermem/hooks/bin/$os-$arch/mastermem-hook
curl -fsSLo "$tmp/mastermem-hook" "$repo/$file"
want=$(awk -v f="$file" '$2 == f { print $1 }' "$tmp/SHA256SUMS")
if command -v sha256sum >/dev/null; then got=$(sha256sum "$tmp/mastermem-hook" | cut -d' ' -f1); else got=$(shasum -a 256 "$tmp/mastermem-hook" | cut -d' ' -f1); fi
[ -n "$want" ] && [ "$got" = "$want" ] || {
  echo "mastermem: the downloaded helper does not match the signed release; nothing was installed" >&2
  exit 1
}
chmod +x "$tmp/mastermem-hook"
printf '%s\n' "$token" | "$tmp/mastermem-hook" install "$client" --server "$server"
