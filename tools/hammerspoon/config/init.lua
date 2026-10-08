-- CLI « hs » pour diagnostics et tests (scripts/verify, agents).
require("hs.ipc")
-- Charge le module de contextes power-user (un seul require).
poweruser = require("poweruser")
-- Raccourcis d'applications (Cmd+E = Finder).
poweruserApps = require("poweruser-apps")
