-- SPDX-License-Identifier: MIT
-- Contexts (Hyper+P): each one switches to an OmniWM workspace, then opens its resources.
local home = os.getenv("HOME")
return {
  { id = "focus", name = "Focus", workspace = "Focus", enabled = true,
    paths = {}, urls = {} }, -- workspace only: Finder cannot be assigned by path
  { id = "web", name = "Web", workspace = "Web", enabled = true,
    paths = { "/Applications/Safari.app" }, urls = {} },
  { id = "messages", name = "Messages", workspace = "Messages", enabled = true,
    paths = { "/Applications/Discord.app" }, urls = {} },
  { id = "atelier", name = "Atelier", workspace = "Atelier", enabled = true,
    paths = { require("repo-path") }, urls = {} },
}
