---
name: import
description: Import the user's existing agent notes (CLAUDE.md, AGENTS.md, GEMINI.md, .cursor/rules, copilot-instructions, .windsurfrules) into mastermem as separate memories. Use when the user says yes to the mastermem import offer, or asks to migrate, import or move their notes, rules or memories into mastermem.
---

# Import agent notes into mastermem

Turn the notes the user already keeps for agents into mastermem memories: one memory per lesson, the right type
and scope, no secrets, nothing written before the user saw the list.

## 1. Find the notes

Look in the current repo and the home folder, read each file in full:

- `CLAUDE.md`, `CLAUDE.local.md` (any depth in the repo), `~/.claude/CLAUDE.md`, `~/.claude/rules/*.md`
- `AGENTS.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.windsurfrules`, `.cursorrules`, `.cursor/rules/*.mdc`

Tell the user in one line what you found (file and line count). Nothing found: say so and stop.

## 2. Check what mastermem has

Call `memory_scopes` for the spaces and scope keys, and `memory_search` for the main topics of the notes, so
you update existing memories instead of writing duplicates.

## 3. Split into memories

One memory per rule, preference, procedure or fact. For each:

- `description`: one line, the card the agent sees; `body`: what to do, why, a short example.
  End the body with `Imported from <file>.`
- `type`: `rule` (must or never), `preference` (how the user likes it), `procedure` (steps), `fact` (paths,
  hosts, names, versions).
- `scope`: `project:<repo name>` for anything about this repo, `global` for how the user works everywhere.
  Use a scope key that `memory_scopes` already lists when one fits.
- `space`: repo notes go to the team space; `CLAUDE.local.md` and `~/.claude/` notes to `private` unless the
  user says otherwise.
- `activation: always` only for the few rules that must hold in every session (5 at most). They wait for a
  person to confirm them in the dashboard.

Leave out: secrets (tokens, passwords, keys, connection strings), anything the agent sees from the code
anyway (file trees, the stack, standard commands from package.json), generic advice every agent follows,
and lines that only point to another file.

## 4. Show the plan, then write

Show the list grouped by file: `type`, `scope`, description, and one line of what you skipped and why.
Wait for an OK; take the user's edits.

Then write each with `memory_write`. When it returns near-duplicates, update the matching memory
(`update_of`) instead of forcing a new one.

## 5. Report

One short summary: memories written, updated, skipped, and how many always-on rules wait for confirmation in
the dashboard (`Rules`). Ask whether to keep the old files; the default is to keep them. Never delete or edit
them without a clear yes.
