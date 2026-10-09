-- Hide apps that have no window on the active OmniWM workspace (2026-10-09).
-- OmniWM parks windows of inactive workspaces 1 px inside the right screen edge (macOS keeps a
-- window's title bar on screen), so their edge and shadow darken the 8 px right margin. A hidden
-- app (Cmd+H) draws nothing. On each workspace change: unhide apps with a window on the new
-- workspace, hide apps whose managed windows are all elsewhere. Apps without managed windows,
-- and apps with a window on another monitor's visible workspace, are left alone.
local M = {}
local CTL = "/opt/homebrew/bin/omniwmctl"

local function apply(windowsJson, activeId)
  local ok, data = pcall(hs.json.decode, windowsJson)
  if not ok or not data or not data.result then return end
  local onActive, elsewhere = {}, {}
  for _, w in ipairs(data.result.payload.windows or {}) do
    local bid = w.app and w.app.bundleId
    if bid then
      if w.workspace and w.workspace.id == activeId then onActive[bid] = true
      else elsewhere[bid] = true end
    end
  end
  local unhid = false
  for bid in pairs(onActive) do
    local app = hs.application.get(bid)
    if app and app:isHidden() then app:unhide(); unhid = true end
  end
  -- OmniWM tried to focus the workspace while its app was still hidden, so nothing got focus
  -- (focus-follows-mouse only reacts to motion). Focus the window under the pointer, else the
  -- first window of the workspace.
  local candidates = {}
  for _, w in ipairs(data.result.payload.windows or {}) do
    if w.workspace and w.workspace.id == activeId and w.mode == "tiling" then table.insert(candidates, w) end
  end
  if #candidates > 0 then
    local front = hs.application.frontmostApplication()
    local frontOk = false
    for _, w in ipairs(candidates) do
      if front and w.app.bundleId == front:bundleID() then frontOk = true end
    end
    if unhid or not frontOk then
      local m = hs.mouse.absolutePosition()
      local h = hs.screen.mainScreen():fullFrame().h
      local px, py = m.x, h - m.y          -- OmniWM frames use a bottom-left origin
      local pick = candidates[1]
      for _, w in ipairs(candidates) do
        local f = w.frame
        if px >= f.x and px <= f.x + f.width and py >= f.y and py <= f.y + f.height then pick = w end
      end
      M.focusTimer = hs.timer.doAfter(0.15, function()
        hs.task.new(CTL, nil, { "window", "focus", pick.id }):start()
      end)
    end
  end
  for bid in pairs(elsewhere) do
    if not onActive[bid] then
      local app = hs.application.get(bid)
      if app and not app:isHidden() then app:hide() end
    end
  end
end

-- Debounced: moving a window (Ctrl+Shift+N) emits windows-changed, not active-workspace,
-- and hiding/unhiding emits windows-changed again (idempotent, so it settles).
M.debounce = hs.timer.delayed.new(0.12, function() M.refreshNow(M.activeId) end)

function M.refresh(activeId)
  if activeId then M.activeId = activeId end
  M.debounce:start()
end

function M.refreshNow(activeId)
  if not activeId then return end
  if M.query and M.query:isRunning() then M.query:terminate() end
  M.query = hs.task.new(CTL, function(code, out) if code == 0 then apply(out, activeId) end end, { "query", "windows" })
  M.query:start()
end

local function activeIdFrom(line)
  local ok, ev = pcall(hs.json.decode, line)
  if not ok or type(ev) ~= "table" then return nil end
  local p = (ev.result and ev.result.payload) or ev.payload or ev
  -- active-workspace events carry the workspace; windows-changed events do not (nil = keep last).
  return p and p.workspace and not p.windows and p.workspace.id or nil
end

function M.start()
  if M.sub and M.sub:isRunning() then return end
  -- A previous Hammerspoon instance may leave its subscriber running: stop orphans first.
  hs.execute("/usr/bin/pkill -f 'omniwmctl subscribe active-workspace'")
  hs.execute("/usr/bin/pkill -f 'omniwmctl subscribe active-workspace,windows-changed'")
  M.sub = hs.task.new(CTL, function() M.restartTimer = hs.timer.doAfter(3, M.start) end,
    function(_, out)
      for line in (out or ""):gmatch("[^\n]+") do M.refresh(activeIdFrom(line)) end
      return true
    end,
    { "subscribe", "active-workspace,windows-changed", "--reconnect", "--format", "ndjson" })
  M.sub:start()
end

M.start()
return M
