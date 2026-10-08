-- SPDX-License-Identifier: MIT
-- Raccourcis d'applications. Cmd+E = Finder (choix de l'utilisateur, 2026-10-08).
-- Remplace globalement Cmd+E (Finder : Éjecter ; Safari/Notes : Utiliser la sélection pour rechercher).
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
    -- Aucune fenêtre Finder : en ouvrir une sur le dossier personnel
    hs.task.new("/usr/bin/open", nil, { os.getenv("HOME") }):start()
  end
end

M.finder = hs.hotkey.bind({ "cmd" }, "e", finder)
return M
