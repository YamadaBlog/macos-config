-- Cmd+F3: reopen what a crash closed (apps, Claude Code sessions on their workspace) with
-- scripts/restore-session.py; the snapshot is written every minute by scripts/session-snapshot.py.
-- Bound twice because the F3 key sends Mission Control unless fn is held: Cmd+fn+F3 (real F3) and
-- Cmd+Mission Control (keycode 160).
local M = {}
local repo = os.getenv("HOME") .. "/dev/macos-config"
local logFile = os.getenv("HOME") .. "/Library/Logs/restore-session.log"

function M.restore()
  if M.task and M.task:isRunning() then return end
  hs.alert.show("Restauration de la session…")
  M.task = hs.task.new("/bin/bash", function(code)
    hs.alert.show(code == 0 and "Session restaurée" or "Restauration : erreur (voir restore-session.log)")
  end, { "-c", "/usr/bin/python3 " .. repo .. "/scripts/restore-session.py >> " .. logFile .. " 2>&1" })
  M.task:start()
end

M.hotkey = hs.hotkey.bind({ "cmd" }, "f3", M.restore)

M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  if e:getKeyCode() ~= 160 then return false end
  local f = e:getFlags()
  if not (f.cmd and not f.alt and not f.ctrl and not f.shift) then return false end
  if not e:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) or
     e:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) == 0 then M.restore() end
  return true
end)
M.tap:start()

return M
