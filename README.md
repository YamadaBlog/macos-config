# macos-config — configuration of a "power user" macOS machine

MacBook Pro 16 (Mac17,6, M5 Max, 64 GB) · macOS 26.6 (25G72) · French AZERTY.
This repo lets you **understand, verify and rebuild** the machine. It contains no secrets and no personal data.

> Assistant or new user: read **`AGENTS.md`** first.
>
> Language: the main docs are in English; some detailed docs, the changelog and parts of `kit/` are still in French.

## The environment in one minute
- **Packages**: CLI and shell via **Nix (Lix) + Home Manager** (`home-manager/`); apps via **Homebrew** (`homebrew/Brewfile`).
- **Windows**: **OmniWM** in **Dwindle** layout (1 window = full screen, the space splits on each new window),
  one workspace per app: **Focus** (Ghostty) · **Web** (Safari) · **Messages** (Discord) · **Atelier** (Finder).
- **Keyboard**: Ctrl+1..9 = workspace, Ctrl+Shift+1..9 = send the window there, Ctrl+arrows = focus,
  Ctrl+Option+W/Q/R/F/E/S = grow/shrink/balance/fullscreen/orientation/swap.
  Hyper (Ctrl+Option+Cmd) stays for Neru (N/G/S) and contexts (P). Option alone stays free for typing `{ } [ ] | @`.
- **Contexts**: **Hammerspoon** (Hyper+P) opens the workspace, then its resources.
- **Keyboard navigation**: **Neru**. **Launcher / clipboard**: Raycast (configuration pending).
- **Terminal**: Ghostty. **Theme**: palette derived automatically from the wallpaper (Stylix + `scripts/theme-auto.sh`).
- Details: `docs/architecture.md` · shortcuts: `docs/raccourcis.md` · status: `STATUS.md`.

## Tools (summary — full inventory: `inventory/elements.tsv`)
| Tool | Role | Managed by | Config | Status |
|---|---|---|---|---|
| Lix 2.95.2 | Nix | Lix installer | `/etc/nix/nix.conf` | tested |
| Home Manager | CLI + shell | flake `home-manager/` | repo = source | tested |
| rg fzf zoxide bat jq fd gh delta ast-grep yazi lazygit | CLI/TUI | Home Manager | `home-manager/home.nix` | tested (PATH) |
| Zsh · Starship · Atuin | shell, prompt, history | Home Manager | `home-manager/shell.nix` | tested |
| Homebrew 7.0.8 | GUI apps | brew.sh | `homebrew/Brewfile` | tested |
| OmniWM 0.7.6 | windows, workspaces | cask | `tools/omniwm/` | tested |
| Hammerspoon 1.1.1 | contexts | cask | `tools/hammerspoon/` | tested |
| Neru 1.57.0 | hints/grid/scrolling | cask (tap) | `tools/neru/` | tested |
| Ghostty 1.3.1 | terminal | cask | `tools/ghostty/` | configured |
| Raycast 2.7.1 | launcher, clipboard | cask | manual (encrypted export) | pending |
| Stats 3.0.20 | monitor | cask | `tools/stats/` | installed |
| Claude Code 2.1.294 | AI agent | native installer | `tools/claude-code/` | active |
| Lunar, Tailscale, TopNotch, Discord, Safari, Terminal | pre-existing | outside Homebrew | `tools/` sheets | kept |
| btop, htop | terminal monitors | brew (pre-existing) | `tools/btop/` | installed |

## Commands
```sh
scripts/verify.sh          # does the machine match the repo? (exit 0 = yes)
scripts/capture.sh         # prepare machine → repo capture (diff), then --accept
scripts/apply.sh <id>      # preview repo → machine, then --write (backup + rollback shown)
scripts/discover.sh        # raw inventory of what is installed
```

## Documentation
| Topic | File |
|---|---|
| Handover, rules, constraints | `AGENTS.md` |
| Status, remaining actions | `STATUS.md`, `docs/actions-humaines.md` |
| History | `CHANGELOG.md` |
| Responsibilities and interactions | `docs/architecture.md` |
| Shortcuts and gestures | `docs/raccourcis.md` |
| Inventory: scope and limits | `docs/inventaire.md` |
| macOS settings, Finder, Dock, menu bar, display | `docs/macos.md` |
| Permissions | `docs/permissions.md` |
| Services and startup | `docs/demarrage-services.md` |
| Secrets and private data | `docs/secrets.md` |
| Machine ↔ repo sync | `docs/synchronisation.md` |
| Rollback | `docs/restauration.md` |
| Full rebuild | `docs/reconstruction.md` |
| Pre-existing debloat | `docs/debloat.md` |
