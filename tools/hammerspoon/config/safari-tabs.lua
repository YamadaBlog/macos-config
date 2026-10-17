-- Safari: Cmd+Left / Cmd+Right = previous / next tab (like Cmd+1…9 jumps to a tab).
-- Inside a text field (address bar, web forms) the keys keep their macOS meaning: start / end of line.
local M = {}

local textRoles = { AXTextField = true, AXTextArea = true, AXComboBox = true, AXSearchField = true }

local function inTextField()
  local ok, el = pcall(function() return hs.axuielement.systemWideElement():attributeValue("AXFocusedUIElement") end)
  if not ok or not el then return false end
  local role = el:attributeValue("AXRole")
  if textRoles[role] then return true end
  return el:attributeValue("AXEditable") == true
end

M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  local code = e:getKeyCode()
  if code ~= hs.keycodes.map.left and code ~= hs.keycodes.map.right then return false end
  local f = e:getFlags()
  if not (f.cmd and not f.alt and not f.ctrl and not f.shift) then return false end
  local app = hs.application.frontmostApplication()
  if not app or app:bundleID() ~= "com.apple.Safari" or inTextField() then return false end
  if code == hs.keycodes.map.left then
    hs.eventtap.keyStroke({ "ctrl", "shift" }, "tab", 0)
  else
    hs.eventtap.keyStroke({ "ctrl" }, "tab", 0)
  end
  return true
end)
M.tap:start()

return M
