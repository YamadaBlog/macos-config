---
name: delete
description: Delete closed Claude Code sessions (both accounts). Use when the user types /delete or asks to delete or clean up old conversations.
disable-model-invocation: true
---

Claude Code has no built-in command to delete one session; `claude-rm` (scripts/claude-sessions.py) does it.

1. Run `claude-rm --list` and show the table to the user as it is (number, date, account, size, title, folder).
   Open sessions are never listed.
2. Ask which numbers to delete, unless the user already said (`/delete 3 5`, "the griffe ones", "all").
   Map a description to numbers from the table and say which ones you picked.
3. Run `claude-rm --trash <numbers>` right after `--list` (the numbers are positions in that list).
4. Report what went to the Trash (`~/.Trash/claude-sessions/`, recoverable until the Trash is emptied).
