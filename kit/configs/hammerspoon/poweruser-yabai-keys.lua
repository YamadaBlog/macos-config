-- SPDX-License-Identifier: MIT
-- Charger uniquement dans la branche yabai. Aucun remap de Caps Lock ici.
local M = {jobs = {}, keys = {}}
local ok, selected = pcall(dofile, hs.configdir .. "/poweruser-backend.lua")
if not ok or selected ~= "yabai" then return M end
local cli = "/opt/homebrew/bin/yabai"
local function send(args)
  if not hs.fs.attributes(cli) then hs.alert.show("yabai absent"); return end
  local job
  job = hs.task.new(cli, function(code)
    M.jobs[job] = nil
    if code ~= 0 then hs.alert.show("Action yabai refusee ; verifier espace/fenetre") end
  end, args)
  if not job then hs.alert.show("Commande indisponible"); return end
  M.jobs[job] = true
  if not job:start() then M.jobs[job] = nil; hs.alert.show("Commande non demarree") end
end
local function bind(modifiers, key, args)
  table.insert(M.keys, hs.hotkey.bind(modifiers, key, function() send(args) end))
end
local normal, shifted = {"ctrl", "alt", "cmd"}, {"ctrl", "alt", "cmd", "shift"}
for key, direction in pairs({left="west", right="east", up="north", down="south"}) do
  bind(normal, key, {"-m", "window", "--focus", direction})
  bind(shifted, key, {"-m", "window", "--warp", direction})
end
-- Lettres proposées pour AZERTY ; validation physique à faire sur le Mac.
for key, label in pairs({W="Focus", E="Web", D="Messages", T="Atelier"}) do
  bind(normal, key, {"-m", "space", "--focus", label})
  bind(shifted, key, {"-m", "window", "--space", label})
end
bind(normal, "F", {"-m", "window", "--toggle", "float"})
bind(normal, "return", {"-m", "window", "--toggle", "zoom-fullscreen"})
return M
