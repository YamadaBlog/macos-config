#!/usr/bin/env python3
"""Write Ghostty's colours from home-manager/palette.nix to ~/.config/ghostty/live-colors and reload Ghostty.

Called by theme-sync.sh as soon as the palette is known, before the Home Manager build: Ghostty shows the new
theme within a second instead of after the build. Same mapping as Stylix's Ghostty theme, which the build
writes afterwards (both then agree). The file is optional for Ghostty (config-file = ?live-colors).
"""
import os
import re
import signal
import subprocess
import sys

pal = dict(re.findall(r'(base0[0-9A-F]) = "([0-9a-fA-F]{6})"', open(sys.argv[1]).read()))
opacity = re.search(r"opacity = ([0-9.]+)", open(sys.argv[1]).read())
ansi = ["00", "08", "0B", "0A", "0D", "0E", "0C", "05", "03", "08", "0B", "0A", "0D", "0E", "0C", "07"]
lines = [f"background = {pal['base00']}", f"foreground = {pal['base05']}", f"cursor-color = {pal['base05']}",
         f"selection-background = {pal['base02']}", f"selection-foreground = {pal['base05']}"]
lines += [f"palette = {i}=#{pal['base' + k]}" for i, k in enumerate(ansi)]
lines.append(f"background-opacity = {opacity.group(1) if opacity else '0.94'}")
out = os.path.expanduser("~/.config/ghostty/live-colors")
open(out, "w").write("# Written by scripts/ghostty-live-colors.py from home-manager/palette.nix.\n" + "\n".join(lines) + "\n")
# Ghostty reloads its config on SIGUSR2. Match the executable path exactly (ps comm): pkill -f would also hit
# processes whose environment mentions Ghostty, and SIGUSR2 terminates most programs.
ps = subprocess.run(["/bin/ps", "-axo", "pid=,comm="], capture_output=True, text=True).stdout
for line in ps.splitlines():
    pid, _, comm = line.strip().partition(" ")
    if comm.strip() == "/Applications/Ghostty.app/Contents/MacOS/ghostty":
        os.kill(int(pid), signal.SIGUSR2)
