-- CLI « hs » pour diagnostics et tests (scripts/verify, agents).
require("hs.ipc")
-- Charge le module de contextes power-user (un seul require).
poweruser = require("poweruser")
-- Raccourcis d'applications (Cmd+E = Finder).
poweruserApps = require("poweruser-apps")
-- Restarts OmniWM and Neru when an Accessibility setting changes (prevents a system-wide freeze).
axGuard = require("ax-guard")
-- Hide apps with no window on the active OmniWM workspace (no parked-window strip in the right margin).
wsHide = require("ws-hide")
