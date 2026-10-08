-- SPDX-License-Identifier: MIT
-- Contextes construits d'apres les chemins observes sur ce Mac (2026-10-08).
-- enabled passe a true seulement apres test du workspace OmniWM correspondant.
local home = os.getenv("HOME")
return {
  { id = "focus", name = "Focus", workspace = "Focus", enabled = false,
    paths = { home .. "/Documents" }, urls = {} },
  { id = "web", name = "Web", workspace = "Web", enabled = false,
    paths = { "/Applications/Safari.app" }, urls = {} },
  { id = "messages", name = "Messages", workspace = "Messages", enabled = false,
    paths = { "/Applications/Discord.app" }, urls = {} },
  { id = "atelier", name = "Atelier", workspace = "Atelier", enabled = false,
    paths = { home .. "/Projects/macos-config", "/Applications/Ghostty.app" }, urls = {} },
}
