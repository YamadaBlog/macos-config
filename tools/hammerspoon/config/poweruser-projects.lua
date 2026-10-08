-- SPDX-License-Identifier: MIT
-- Contextes construits d'apres les chemins observes sur ce Mac (2026-10-08).
-- Contextes testes le 2026-10-08 (bureau OmniWM + ressources).
local home = os.getenv("HOME")
return {
  { id = "focus", name = "Focus", workspace = "Focus", enabled = true,
    paths = {}, urls = {} }, -- bureau seul : Finder ne peut pas être assigné par chemin
  { id = "web", name = "Web", workspace = "Web", enabled = true,
    paths = { "/Applications/Safari.app" }, urls = {} },
  { id = "messages", name = "Messages", workspace = "Messages", enabled = true,
    paths = { "/Applications/Discord.app" }, urls = {} },
  { id = "atelier", name = "Atelier", workspace = "Atelier", enabled = true,
    paths = { home .. "/dev/macos-config" }, urls = {} },
}
