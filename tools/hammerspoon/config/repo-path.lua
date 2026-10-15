-- Location of the macos-config clone, written by ./install.sh to ~/.config/macos-config/repo
-- (one line). Falls back to ~/dev/macos-config, the original location.
local home = os.getenv("HOME")
local f = io.open(home .. "/.config/macos-config/repo", "r")
local path = f and f:read("*l")
if f then f:close() end
return (path and path ~= "") and path or (home .. "/dev/macos-config")  -- portable-default
