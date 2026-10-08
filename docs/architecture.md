# Machine architecture: who does what

## Layers
```
macOS 26.6 (SIP off, SSV sealed, dev-minimal debloat)
├── Package managers
│   ├── Lix (Nix daemon) ── Home Manager (repo: home-manager/) ── CLI + shell
│   └── Homebrew (/opt/homebrew) ── GUI apps (homebrew/Brewfile)
├── Interaction
│   ├── OmniWM ............ windows (Dwindle layout), workspaces, 3-finger horizontal gestures
│   ├── Hammerspoon ....... contexts (Hyper+P) → drives OmniWM through omniwmctl (IPC)
│   ├── Neru .............. keyboard navigation (Hyper+N/G/S)
│   └── Raycast ........... launcher (Cmd+Space), quicklinks, snippets, clipboard
└── Apps: Ghostty, Safari, Discord, Lunar, Tailscale, TopNotch, Stats
```

## Responsibilities (one owner per function)
| Function | Owner | Must NOT handle it | Status |
|---|---|---|---|
| CLI installation | Home Manager | Homebrew (except pre-existing btop/htop) | tested |
| GUI app installation | Homebrew | Nix, nix-homebrew | tested |
| Nix daemon | Lix installer | nix-darwin (`nix.enable = false`) | tested |
| Shell, prompt, PATH | Home Manager (`shell.nix`) | hand edits of `~/.zshrc` | tested |
| Ctrl-R history | Atuin (local) | fzf (its Ctrl-R is disabled) | tested |
| Window placement / tiling | OmniWM (Dwindle everywhere) | Raycast window commands, Hammerspoon (`hs.window` unused), macOS edge tiling (off) | tested |
| Workspaces Focus/Web/Messages/Atelier | OmniWM (displayName 1–4) | macOS Spaces (a single native Space) | tested |
| App → workspace | OmniWM rules (Ghostty→Focus, Safari→Web, Discord→Messages, Finder→Atelier) | Hammerspoon | tested |
| Contexts (workspace + resources) | Hammerspoon `poweruser.lua` | — | tested 12/12 |
| Window borders / workspace bar | OmniWM — disabled by choice (can be re-enabled) | JankyBorders, SketchyBar (rejected) | decided |
| Keyboard navigation (hints) | Neru | Raycast | tested |
| Launcher | Raycast (Cmd+Space) | Spotlight (shortcut removed, icon kept) | tested |
| Clipboard history | Raycast (1 week, keychain exclusions) | OmniWM (`clipboard.historyEnabled = false`), Maccy (rejected) | tested |
| 2-finger gestures | macOS / apps (content scrolling) | OmniWM | — |
| 3-finger horizontal gestures | OmniWM | macOS (`TrackpadThreeFingerHorizSwipeGesture = 0`) | configured, physical test pending |
| 3-finger vertical, 4-finger gestures | macOS (Mission Control, Spaces, App Exposé) | OmniWM (workspace swipe and 4-finger Overview off) | — |
| Theme / palette | Stylix, palette generated from the wallpaper (`scripts/theme-auto.sh` → `home-manager/palette.nix`) → terminals and CLI; `scripts/theme-apply.sh` → Neru, macOS accent, OmniWM | hand-edited colors | tested |
| Display brightness | Lunar (pre-existing) | BetterDisplay (not installed) | kept |
| Display mode | 1728×1117 Retina (2×) | — | set |
| Notch | TopNotch (installed, not running) | OmniWM bar (disabled) | kept |
| Private network | Tailscale | — | tested |
| Finder/Dock preferences | user defaults (`docs/macos.md`); nix-darwin planned, NOT enabled | — | inspected |
| App startup | Home Manager LaunchAgents (OmniWM, Neru, Hammerspoon, Stats, theme-auto, logrotate); Raycast: its own | apps' internal "open at login" | tested |

## Key flows
- **Hyper+P → context**: Hammerspoon runs `omniwmctl workspace focus-name <Workspace>`;
  if that fails nothing opens (alert); otherwise it `open`s the resources. Resource apps
  have an OmniWM rule for their workspace, otherwise an existing window would pull focus elsewhere.
- **Shortcuts**: OmniWM owns Ctrl+digit, Ctrl+arrows and Ctrl+Option+letter; Neru and Hammerspoon use
  Hyper = Ctrl+Option+Cmd with disjoint letters (registry: `docs/raccourcis.md`). OmniWM reads **physical
  key positions** (QWERTY), Neru and Hammerspoon read the **characters** of the active layout.
- **Wallpaper → theme**: a LaunchAgent watches the macOS wallpaper index; `scripts/theme-auto.sh` regenerates
  the palette, applies it (Home Manager, Neru, OmniWM, Ghostty reload), commits theme files and re-checks
  the index at the end so back-to-back changes are not missed.
- **Shell**: `/bin/zsh` reads `~/.zshenv` (HM variables, `~/.local/bin`), `~/.zprofile` (brew shellenv),
  `~/.zshrc` (starship, zoxide, atuin, fzf); `/etc/zshrc` (Lix) adds Nix.

## Known limits
- A Finder window cannot be assigned by path: the Focus context opens no resource.
- Simulated arrow keystrokes must carry the fn flag to trigger OmniWM (real keys do).
- Apps with a minimum width (Safari ~570 pt, Finder ~500 pt) overflow when too many windows share a workspace.
