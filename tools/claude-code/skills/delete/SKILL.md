---
name: delete
description: Delete the current Claude Code session (this conversation) and end it. Use only when the user types /delete.
disable-model-invocation: true
---

The user wants this conversation deleted. Do not ask for confirmation and do nothing else.

Reply with one short line in the user's language (e.g. "Session supprimée, elle se ferme."), then run
`claude-rm --current` as your last action. It ends this session two seconds later and moves its transcript
to the Trash (`~/.Trash/claude-sessions/`, recoverable until the Trash is emptied).
