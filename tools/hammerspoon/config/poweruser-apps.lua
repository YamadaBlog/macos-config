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

-- Closing the last Finder window leaves Finder frontmost with no window: keystrokes go nowhere and OmniWM's
-- focus-follows-mouse treats Finder as an external focus, so even moving the mouse does not refocus.
-- Give the focus back to the standard window under the mouse.
local function windowUnderMouse()
  local p = hs.mouse.absolutePosition()
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() and w:application():bundleID() ~= "com.apple.finder" and hs.geometry.point(p):inside(w:frame()) then
      return w
    end
  end
end

M.finderWatch = hs.window.filter.new(false):setAppFilter("Finder", { allowRoles = "AXStandardWindow" })
M.finderWatch:subscribe(hs.window.filter.windowDestroyed, function()
  hs.timer.doAfter(0.3, function()
    local app = hs.application.get("com.apple.finder")
    if not app or not app:isFrontmost() then return end
    for _, w in ipairs(app:allWindows()) do
      if w:isStandard() and w:isVisible() then return end
    end
    local target = windowUnderMouse()
    if target then target:focus() end
  end)
end)
return M
