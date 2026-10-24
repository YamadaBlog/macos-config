---
name: apres
description: A message the user typed while Claude was working, held until the turn was fully finished. Use only when the user types /apres.
disable-model-invocation: true
argument-hint: <message>
---

The user queued this message with /apres so that it reaches you only once your previous work was completely
finished (Claude Code holds queued commands until the turn ends, while plain messages are slipped in mid-turn).
Treat it exactly as a normal message from the user:

$ARGUMENTS
