-- CLI « hs » pour diagnostics et tests (scripts/verify, agents).
require("hs.ipc")
-- Charge le module de contextes power-user (un seul require).
poweruser = require("poweruser")
-- Raccourcis d'applications (Cmd+E = Finder).
poweruserApps = require("poweruser-apps")
-- Restarts OmniWM and Neru when an Accessibility setting changes (prevents a system-wide freeze).
axGuard = require("ax-guard")
-- Hide apps with no window on the active OmniWM workspace (no parked-window strip in the right margin).
-- Click-through wallpaper strip over the right gap (hides parked windows without hiding apps).
marginVeil = require("margin-veil")
wsHide = require("ws-hide")
-- Cmd+F1 pastes the prompt-optimisation prompt at the cursor (clipboard restored).
promptInsert = require("prompt-insert")
-- Safari: Cmd+Left/Right = previous/next tab (outside text fields).
safariTabs = require("safari-tabs")
-- Cmd+F3: reopen apps and Claude Code sessions after a crash.
sessionRestore = require("session-restore")
-- F3/F4 (Mission Control, Spotlight) do nothing.
functionKeys = require("function-keys")
-- Cmd+F2: next wallpaper of ~/Pictures (the theme follows).
wallpaperCycle = require("wallpaper-cycle")
