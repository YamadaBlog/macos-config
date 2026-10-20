-- F3 (Mission Control, keycode 160) and F4 (Spotlight 177, Launchpad 131 on older keyboards) do nothing:
-- the Mac stays usable only through its own shortcuts. Cmd+F3 still reaches session-restore.lua.
local M = {}
-- Opt-in: home-manager creates this file when profile.nix sets lockDown.
if not hs.fs.attributes(os.getenv("HOME") .. "/.config/macos-config/lock-down") then return M end
local blocked = { [160] = true, [177] = true, [131] = true }

M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(e)
  if not blocked[e:getKeyCode()] then return false end
  return not (e:getKeyCode() == 160 and e:getFlags().cmd)
end)
M.tap:start()

return M
