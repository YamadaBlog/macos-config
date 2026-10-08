-- SPDX-License-Identifier: MIT
-- Une seule commande de projet ; aucune gestion de fenetres ni remap Hyper ici.
local M = { jobs = {} }
local chooser

-- Alertes aux couleurs du thème (poweruser-colors.lua, généré par Home Manager depuis la palette Stylix)
local okColors, colors = pcall(dofile, hs.configdir .. "/poweruser-colors.lua")
local alertStyle = nil
if okColors and type(colors) == "table" then
  alertStyle = {
    fillColor = { hex = colors.bg, alpha = 0.95 },
    strokeColor = { hex = colors.accent, alpha = 1 },
    textColor = { hex = colors.text, alpha = 1 },
    strokeWidth = 2, radius = 10, textSize = 18,
  }
end

local function message(text)
  hs.alert.show(text, alertStyle)
end

local function definitions()
  local ok, result = pcall(dofile, hs.configdir .. "/poweruser-projects.lua")
  if not ok or type(result) ~= "table" then
    message("Configurer poweruser-projects.lua")
    return {}
  end
  return result
end

local function spawn(executable, args, callback)
  local job
  job = hs.task.new(executable, function(code, stdout, stderr)
    M.jobs[job] = nil
    if callback then callback(code, stdout, stderr) end
  end, args)
  if not job then message("Impossible de creer la commande"); return false end
  M.jobs[job] = true
  if not job:start() then
    M.jobs[job] = nil
    message("Impossible de demarrer la commande")
    return false
  end
  return true
end

local function launch(id)
  local project
  for _, item in ipairs(definitions()) do
    if item.id == id and item.enabled == true then project = item; break end
  end
  if not project then message("Projet inconnu ou desactive"); return end
  if type(project.workspace) ~= "string" or project.workspace == "" then
    message("Le projet exige un workspace nomme")
    return
  end
  local backend, cli, command = "omniwm", "/opt/homebrew/bin/omniwmctl", nil
  local ok, selected = pcall(dofile, hs.configdir .. "/poweruser-backend.lua")
  if ok then
    if selected ~= "omniwm" and selected ~= "yabai" then
      message("Backend invalide : omniwm ou yabai")
      return
    end
    backend = selected
  elseif hs.fs.attributes(hs.configdir .. "/poweruser-backend.lua") then
    message("Corriger poweruser-backend.lua")
    return
  end
  if backend == "yabai" then
    cli = "/opt/homebrew/bin/yabai"
    command = {"-m", "space", "--focus", project.workspace}
  else
    command = {"workspace", "focus-name", project.workspace}
  end
  if not hs.fs.attributes(cli) then message("CLI du backend absent de /opt/homebrew/bin"); return end
  local resources = {}
  for _, file in ipairs(project.paths or {}) do
    if type(file) ~= "string" or file:sub(1, 1) ~= "/" or not hs.fs.attributes(file) then
      message("Chemin de projet absent ou non absolu")
      return
    end
    table.insert(resources, file)
  end
  for _, url in ipairs(project.urls or {}) do
    if type(url) ~= "string" or not url:match("^https?://") then
      message("Seuls les liens web http/https sont acceptes")
      return
    end
    table.insert(resources, url)
  end
  spawn(cli, command, function(code)
    if code ~= 0 then
      message("Workspace non active : verifier le backend, son service et le nom")
      return
    end
    -- Les arguments sont transmis directement ; aucun shell et aucun eval.
    if #resources > 0 then spawn("/usr/bin/open", resources) end
  end)
end

chooser = hs.chooser.new(function(choice)
  if choice then launch(choice.id) end
end)

local function show()
  local choices = {}
  for _, project in ipairs(definitions()) do
    if project.enabled == true and type(project.id) == "string" then
      table.insert(choices, {text = project.name or project.id,
        subText = "Workspace : " .. tostring(project.workspace), id = project.id})
    end
  end
  if #choices == 0 then message("Activer un projet dans poweruser-projects.lua"); return end
  chooser:choices(choices)
  chooser:show()
end

M.hotkey = hs.hotkey.bind({"ctrl", "alt", "cmd"}, "P", show)
hs.urlevent.bind("poweruser-project", function(_, params)
  if params.name then launch(params.name) else show() end
end)
M.launch = launch
M.show = show
return M
