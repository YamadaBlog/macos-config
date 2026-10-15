# Raycast

Launcher and the single clipboard history. Free version, no account needed.

- **Install:** Homebrew cask. **Start:** Raycast's own "Open at Login" (the only startup mechanism).
- **Permission:** Accessibility.
- **Depends on:** Spotlight removed from Cmd+Space (symbolichotkeys 64 disabled by `scripts/macos-defaults.sh`).
- **Config:** stored in Raycast's encrypted databases; nothing is captured in this repo.

## Manual setup
1. Raycast hotkey: Cmd+Space.
2. Clipboard History: keep 1 week; exclude Keychain Access and your password manager.
3. Optional: add your own quicklinks and snippets.
4. Optional backup: Settings > Advanced > Export (password-protected `.rayconfig`), stored **outside** the repo.

Restore: Settings > Advanced > Import, or redo the steps above.
