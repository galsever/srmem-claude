# mastermem for Claude Code

Team memory for Claude Code: the right memory before the agent makes the mistake, lessons saved when you
correct it. This repository is a Claude Code plugin marketplace with one plugin, `srmem` (the id from
before the rename to mastermem; it stays so existing installs keep working).

## Install

Create a device token in the mastermem dashboard (https://mastermem.com under Connect, Claude Code). Then,
in a terminal:

```
claude plugin marketplace add mastermem/mastermem-claude
claude plugin install srmem@srmem --config server=https://mastermem.com --config token=<device token>
```

Restart Claude Code (or run `/reload-plugins` in a running session).

Inside Claude Code instead: `/plugin marketplace add mastermem/mastermem-claude`, then `/plugin install srmem@srmem`;
the dialog asks for the server URL and the token.

New token (rotation, another team): run the `claude plugin install` line again with the new token, or
`/plugin configure srmem@srmem`.

## What it does

- Hooks on session start, prompt, tool batch, shell commands (Bash, PowerShell) and Stop send the hook
  event to `<server>/v1/hook/<event>`; the answer adds the matching memories to the agent's context and
  asks for a lesson after a correction.
- The MCP server (`<server>/mcp`, named `srmem` in Claude Code, so the tools stay `mcp__srmem__*`) gives the
  agent the memory tools.

When the server is down or slow, Claude Code keeps working without memories: every hook gives up after
1 to 3 seconds and never blocks.

## Requirements

Nothing to install: the plugin ships a small helper (`hooks/bin/`, macOS and Linux on Intel and Arm,
Windows 10 and 11) that sends the hook events. The token is kept in the platform's secure credential store
(on Linux `~/.claude/.credentials.json`, mode 0600), never in settings files or `hooks.json`, and the helper
gets it through its environment, so other users on a shared machine cannot see it in the process list.

Build the helper (maintainers): `./build.sh` (needs Go), then commit `plugins/srmem/hooks/bin/`. Tests:
`cd ../server && go test ./cmd/srmem-hook` (add `SRMEM_PLUGIN_E2E=1` for the end to end run with `claude`).

## Uninstall

```
claude plugin uninstall srmem@srmem
claude plugin marketplace remove srmem
```

Had the older srmem command line client installed (`srmem install --remote`)? Run `srmem uninstall` first, or every hook
fires twice.
