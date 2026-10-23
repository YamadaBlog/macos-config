-- F4: cleaning mode. Every key is swallowed (letters, modifiers, brightness, volume, media) while the
-- trackpad keeps working; a click on the centred banner, or 2 minutes, ends it. Touch ID / power cannot be blocked.
-- Bound on F4 (keycode 118, fn) and on the Spotlight / Launchpad codes the bare F4 sends (177, 131).
local M = {}
local DURATION = 120
local types = hs.eventtap.event.types
local f4 = { [118] = true, [177] = true, [131] = true }

-- The card: ~/.config/macos-config/keyboard-clean.png (a personal image, kept out of the repo; a pumpkin
-- otherwise) full-bleed, the countdown in Didot over a dark fade, a gold bar that empties with the time left.
-- Entrance in the Attack on Titan way: lightning flash, the card falls in and the screen shakes. A click unlocks.
local W, H = 340, 400
local GOLD = { red = 0.83, green = 0.66, blue = 0.38 }
local IMAGE = os.getenv("HOME") .. "/.config/macos-config/keyboard-clean.png"

local function build(frame)
  local c = hs.canvas.new(frame)
  c:level(hs.canvas.windowLevels.screenSaver)
  c:behavior({ "canJoinAllSpaces", "stationary" })
  local img = hs.fs.attributes(IMAGE) and hs.image.imageFromPath(IMAGE)
  c:appendElements(
    { type = "rectangle", action = "clip", roundedRectRadii = { xRadius = 22, yRadius = 22 } },
    { type = "rectangle", action = "fill", fillColor = { white = 0.04 }, trackMouseUp = true },
    img and { type = "image", image = img, imageScaling = "scaleProportionally", imageAlignment = "top",
              frame = { x = (W - H) / 2, y = 0, w = H, h = H }, trackMouseUp = true }
        or { type = "text", text = "🎃", frame = { x = 0, y = 90, w = W, h = 160 }, textAlignment = "center", textSize = 120 },
    { type = "rectangle", action = "fill", frame = { x = 0, y = H - 170, w = W, h = 170 }, trackMouseUp = true,
      fillGradient = "linear", fillGradientAngle = 90,
      fillGradientColors = { { white = 0.04, alpha = 0 }, { white = 0.04, alpha = 0.75 }, { white = 0.04, alpha = 0.97 } } },
    { id = "time", type = "text", frame = { x = 0, y = H - 108, w = W, h = 70 }, textAlignment = "center",
      textFont = "Didot-Bold", textSize = 54, textColor = { white = 0.97 },
      textShadow = { blurRadius = 12, color = { white = 0, alpha = 0.9 }, offset = { h = -1, w = 0 } } },
    { type = "rectangle", action = "fill", frame = { x = 40, y = H - 30, w = W - 80, h = 3 },
      fillColor = { white = 1, alpha = 0.12 } },
    { id = "bar", type = "rectangle", action = "fill", frame = { x = 40, y = H - 30, w = W - 80, h = 3 }, fillColor = GOLD },
    { id = "flash", type = "rectangle", action = "fill", fillColor = { red = 1, green = 0.93, blue = 0.7, alpha = 0 } },
    { type = "resetClip" })
  c:mouseCallback(function(_, msg) if msg == "mouseUp" then M.stop() end end)
  return c
end

-- Lightning flash, a fall from above with a short bounce, then a decaying shake (about 0.7 s at 60 fps).
local function entrance(c, x, y)
  local t = 0
  M.anim = hs.timer.doEvery(1 / 60, function()
    t = t + 1 / 60
    local dy, dx = 0, 0
    if t < 0.28 then
      local k = t / 0.28; dy = -(1 - k * k) * 260
    elseif t < 0.7 then
      local k = (t - 0.28) / 0.42; local amp = 14 * (1 - k)
      dx, dy = amp * math.sin(t * 90), amp * 0.6 * math.cos(t * 110)
    else
      M.anim:stop(); M.anim = nil
    end
    c:topLeft({ x = x + dx, y = y + dy })
    c.flash.fillColor = { red = 1, green = 0.93, blue = 0.7, alpha = math.max(0, 0.9 - t * 2.2) }
  end)
end

local function banner(left)
  if not M.canvas then
    local s = hs.screen.mainScreen():frame()
    local x, y = s.x + (s.w - W) / 2, s.y + (s.h - H) / 2
    M.canvas = build({ x = x, y = y - 260, w = W, h = H })
    M.canvas:show()
    entrance(M.canvas, x, y)
  end
  M.canvas.time.text = string.format("%d:%02d", left // 60, left % 60)
  M.canvas.bar.frame = { x = 40, y = H - 30, w = math.max(0, (W - 80) * left / DURATION), h = 3 }
end

function M.stop()
  if M.block then M.block:stop(); M.block = nil end
  if M.timer then M.timer:stop(); M.timer = nil end
  if M.anim then M.anim:stop(); M.anim = nil end
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
  if fl.cmd or fl.alt or fl.ctrl or fl.shift then return false end
  -- Start once F4 and any modifier are released: a swallowed key-up would leave them pressed for the apps.
  hs.timer.waitUntil(function() return next(hs.eventtap.checkKeyboardModifiers()) == nil end,
                     function() hs.timer.doAfter(0.15, M.start) end, 0.05)
  return true
end)
M.trigger:start()

return M
