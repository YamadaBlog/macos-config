-- Cmd+F4: cleaning mode. Every key is swallowed (letters, modifiers, brightness, volume, media) while the
-- trackpad keeps working; a click on the centred banner, or 2 minutes, ends it. Touch ID / power cannot be blocked.
-- Bound on F4 (keycode 118, fn) and on the Spotlight / Launchpad codes the bare F4 sends (177, 131).
local M = {}
local DURATION = 120
local types = hs.eventtap.event.types
local f4 = { [118] = true, [177] = true, [131] = true }

-- Halloween card: pumpkin inside an orange ring that empties with the time left, the countdown under it,
-- two bats that flap every second. A click anywhere on it unlocks.
local W, H, R = 300, 330, 92
local ORANGE, PURPLE = { red = 1, green = 0.55, blue = 0.1 }, { red = 0.13, green = 0.05, blue = 0.2, alpha = 1 }

local function banner(left)
  if not M.canvas then
    local s = hs.screen.mainScreen():frame()
    M.canvas = hs.canvas.new({ x = s.x + (s.w - W) / 2, y = s.y + (s.h - H) / 2, w = W, h = H })
    M.canvas:level(hs.canvas.windowLevels.screenSaver)
    M.canvas:behavior({ "canJoinAllSpaces", "stationary" })
    local cx, cy = W / 2, 30 + R
    M.canvas:appendElements(
      { type = "rectangle", action = "fill", roundedRectRadii = { xRadius = 36, yRadius = 36 }, fillColor = PURPLE,
        strokeColor = { red = 1, green = 0.55, blue = 0.1, alpha = 0.35 }, strokeWidth = 2, action = "strokeAndFill",
        shadow = { blurRadius = 30, color = { red = 1, green = 0.45, blue = 0, alpha = 0.55 }, offset = { h = 0, w = 0 } },
        withShadow = true, trackMouseUp = true },
      { type = "circle", center = { x = cx, y = cy }, radius = R, action = "stroke", strokeWidth = 10,
        strokeColor = { white = 1, alpha = 0.08 } },
      { id = "ring", type = "arc", center = { x = cx, y = cy }, radius = R, startAngle = 0, endAngle = 360,
        action = "stroke", strokeWidth = 10, strokeColor = ORANGE, strokeCapStyle = "round", arcRadii = false },
      { type = "text", text = "🎃", frame = { x = 0, y = cy - 52, w = W, h = 110 }, textAlignment = "center", textSize = 84 },
      { id = "bat1", type = "text", text = "🦇", frame = { x = 18, y = 18, w = 50, h = 40 }, textSize = 30 },
      { id = "bat2", type = "text", text = "🦇", frame = { x = W - 62, y = 34, w = 50, h = 40 }, textSize = 26 },
      { id = "time", type = "text", frame = { x = 0, y = cy + R + 22, w = W, h = 60 }, textAlignment = "center",
        textFont = "Menlo-Bold", textSize = 40, textColor = ORANGE })
    M.canvas:mouseCallback(function(_, msg) if msg == "mouseUp" then M.stop() end end)
    M.canvas:show(0.25)
  end
  local c, flap = M.canvas, left % 2 == 0
  c.ring.endAngle = 360 * left / DURATION
  c.time.text = string.format("%d:%02d", left // 60, left % 60)
  c.bat1.frame = { x = 18, y = flap and 14 or 22, w = 50, h = 40 }
  c.bat2.frame = { x = W - 62, y = flap and 38 or 30, w = 50, h = 40 }
end

function M.stop()
  if M.block then M.block:stop(); M.block = nil end
  if M.timer then M.timer:stop(); M.timer = nil end
  if M.canvas then M.canvas:delete(0.3); M.canvas = nil end
end

function M.start()
  if M.block then return end
  local left = DURATION
  M.block = hs.eventtap.new({ types.keyDown, types.keyUp, types.flagsChanged, types.systemDefined }, function(e)
    if e:getType() == types.systemDefined then return next(e:systemKey()) ~= nil end -- media keys only
    return true
  end)
  M.block:start()
  banner(left)
  M.timer = hs.timer.doEvery(1, function()
    left = left - 1
    if left <= 0 then M.stop() else banner(left) end
  end)
end

M.trigger = hs.eventtap.new({ types.keyDown }, function(e)
  if M.block or not f4[e:getKeyCode()] then return false end
  local fl = e:getFlags()
  if not fl.cmd or fl.alt or fl.ctrl or fl.shift then return false end
  -- Start once Cmd and F4 are released: a swallowed key-up would leave them pressed for the apps.
  hs.timer.waitUntil(function() return next(hs.eventtap.checkKeyboardModifiers()) == nil end,
                     function() hs.timer.doAfter(0.15, M.start) end, 0.05)
  return true
end)
M.trigger:start()

return M
