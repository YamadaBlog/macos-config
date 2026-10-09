-- Accessibility guard (2026-10-09).
-- Turning off a window manager's Accessibility while it runs leaves its event taps and AX observers
-- installed: every click, workspace switch or gesture then waits on it and the whole Mac seems frozen.
-- macOS posts "com.apple.accessibility.api" when an Accessibility setting changes. We then restart
-- OmniWM and Neru: if their permission is gone they start WITHOUT grabbing input (no freeze);
-- if it is still granted they simply resume. Debounced; costs one re-layout per permission change.
local M = {}

local function restartOmniWM()
  local app = hs.application.get("com.barut.OmniWM")
  if not app then return end
  app:kill9()                                   -- a stuck WM may not answer a polite quit
  -- Keep a reference: an unreferenced hs.timer is garbage-collected before it fires.
  M.reopenTimer = hs.timer.doAfter(1.5, function() hs.execute("/usr/bin/open -g -a OmniWM") end)
end

local function restartNeru()
  -- LaunchAgent org.nix-community.home.neru: kickstart -k restarts it (only if it is loaded).
  hs.execute("/bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.nix-community.home.neru", true)
end

-- Cooldown: a freshly restarted app may itself trigger the notification (permission prompt);
-- never restart more than once every 15 s, so this can never loop.
M.lastRestart = 0
M.debounce = hs.timer.delayed.new(1.0, function()
  if hs.timer.secondsSinceEpoch() - M.lastRestart < 15 then return end
  M.lastRestart = hs.timer.secondsSinceEpoch()
  hs.printf("ax-guard: Accessibility changed, restarting OmniWM and Neru")
  restartOmniWM()
  restartNeru()
end)

M.watcher = hs.distributednotifications.new(function() M.debounce:start() end, "com.apple.accessibility.api")
M.watcher:start()

return M
