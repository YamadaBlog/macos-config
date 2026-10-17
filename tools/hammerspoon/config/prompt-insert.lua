-- Cmd+F1: paste a fixed prompt at the cursor of the focused text field (Ghostty, editors, browsers).
-- Pasting, not typing: typed newlines would press Return (and submit in Claude Code). The clipboard is
-- saved first and put back 0.5 s later, so the paste does not replace it. Bound twice because the F1 key
-- sends "brightness down" unless fn is held: Cmd+brightness-down (system key) and Cmd+fn+F1 (real F1).
local M = {}

M.text = [[
Optimise ce prompt pour **Claude Code avec Claude Opus 5.5 en mode Max Thinking**, afin d'obtenir les meilleures performances possibles.

Effectue une recherche approfondie sur Internet, notamment dans la documentation officielle d'Anthropic, sur GitHub et Reddit, pour identifier les techniques de prompting les plus efficaces et les bonnes pratiques récentes.

Réécris ensuite mon prompt pour le rendre **clair, précis, concis et parfaitement structuré**, en maximisant la qualité du raisonnement, la fiabilité et l'efficacité de Claude Code.

Supprime toute instruction inutile ou redondante. Privilégie les techniques réellement documentées et éprouvées plutôt que les formulations complexes sans bénéfice démontré.

**Fournis uniquement le prompt final optimisé, prêt à copier-coller, sans explication.**

reformule :]]

local restoreTimer

function M.insert()
  local saved = hs.pasteboard.readAllData()
  hs.pasteboard.setContents(M.text)
  hs.eventtap.keyStroke({ "cmd" }, "v", 0)
  if restoreTimer then restoreTimer:stop() end
  restoreTimer = hs.timer.doAfter(0.5, function()
    if saved and next(saved) then hs.pasteboard.writeAllData(saved) else hs.pasteboard.clearContents() end
  end)
end

M.hotkey = hs.hotkey.bind({ "cmd" }, "f1", M.insert)

-- NX_KEYTYPE_BRIGHTNESS_DOWN = 3; only with Cmd and no other modifier.
M.tap = hs.eventtap.new({ hs.eventtap.event.types.systemDefined }, function(e)
  local k = e:systemKey()
  if k.key ~= "BRIGHTNESS_DOWN" then return false end
  local f = e:getFlags()
  if not (f.cmd and not f.alt and not f.ctrl and not f.shift) then return false end
  if k.down and not k["repeat"] then M.insert() end
  return true
end)
M.tap:start()

return M
