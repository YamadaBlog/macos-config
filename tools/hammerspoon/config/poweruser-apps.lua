-- SPDX-License-Identifier: MIT
-- App shortcuts. Cmd+E = Finder.
-- Overrides Cmd+E everywhere (Finder: Eject; Safari/Notes: Use Selection for Find).
local M = {}

local function finder()
  local app = hs.application.get("com.apple.finder")
  local hasWindow = false
  if app then
    for _, w in ipairs(app:allWindows()) do
      if w:isStandard() then hasWindow = true; break end
    end
  end
  if hasWindow then
    hs.application.launchOrFocusByBundleID("com.apple.finder")
  else
    -- No Finder window: open one on the home folder
    hs.task.new("/usr/bin/open", nil, { os.getenv("HOME") }):start()
  end
end

M.finder = hs.hotkey.bind({ "cmd" }, "e", finder)
return M
