-- Cmd+F2: next wallpaper among the images of ~/Pictures (alphabetical, loops). The theme follows through the
-- theme-auto agent, which reuses the saved palette of a wallpaper seen before (home-manager/palettes).
-- Bound twice like Cmd+F1: Cmd+fn+F2 (real F2) and Cmd+brightness up (NX_KEYTYPE_BRIGHTNESS_UP).
local M = {}
local dir = os.getenv("HOME") .. "/Pictures"

local function images()
  local list = {}
  for name in hs.fs.dir(dir) do
    if name:lower():match("%.png$") or name:lower():match("%.jpe?g$") or name:lower():match("%.heic$") then
      list[#list + 1] = dir .. "/" .. name
    end
  end
  table.sort(list)
  return list
end

function M.next()
  local list = images()
  if #list == 0 then hs.alert.show("Aucune image dans ~/Pictures") return end
  local current = hs.http.convertHtmlEntities(hs.screen.mainScreen():desktopImageURL() or ""):gsub("^file://", "")
  current = current:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  local i = 0
  for k, p in ipairs(list) do if p == current then i = k end end
  local nextImage = list[i % #list + 1]
  for _, s in ipairs(hs.screen.allScreens()) do s:desktopImageURL("file://" .. nextImage:gsub(" ", "%%20")) end
  hs.alert.show(nextImage:match("[^/]+$"))
end

M.hotkey = hs.hotkey.bind({ "cmd" }, "f2", M.next)

M.tap = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(e)
  local k = e:systemKey()
  if k.key ~= "BRIGHTNESS_UP" then return false end
  local f = e:getFlags()
  if not (f.cmd and not f.alt and not f.ctrl and not f.shift) then return false end
  if k.down and not k["repeat"] then M.next() end
  return true
end)
M.tap:start()

return M
