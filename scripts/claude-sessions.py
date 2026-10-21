#!/usr/bin/env python3
"""List and delete closed Claude Code sessions of both accounts (~/.claude and ~/.claude-2).

  claude-rm              pick sessions with fzf (Tab = several), confirm, move them to the Trash
  claude-rm --list       numbered table of closed sessions (oldest first)
  claude-rm --trash 3 5  move sessions 3 and 5 of --list (or session-id prefixes) to the Trash

A session is "open" while the process registered in <config>/sessions/<pid>.json runs: it is never listed.
Files go to ~/.Trash/claude-sessions/<config>/<project>/ (transcript and its subagent folder), so they can be
put back; Claude Code itself has no command to delete a single session.
"""
import glob
import json
import os
import shutil
import subprocess
import sys
import time

HOME = os.path.expanduser("~")
CONFIGS = [HOME + "/.claude", HOME + "/.claude-2"]
TRASH = HOME + "/.Trash/claude-sessions"


def open_ids():
    ids = set()
    for d in CONFIGS:
        for f in glob.glob(d + "/sessions/*.json"):
            try:
                os.kill(int(os.path.basename(f)[:-5]), 0)
                ids.add(json.load(open(f))["sessionId"])
            except Exception:
                pass
    return ids


def sessions():
    live, rows = open_ids(), []
    for d in CONFIGS:
        for f in glob.glob(d + "/projects/*/*.jsonl"):
            sid = os.path.basename(f)[:-6]
            if sid in live:
                continue
            custom = ai = cwd = ""
            for line in open(f, errors="ignore"):
                if '"custom-title"' in line or '"ai-title"' in line or ('"cwd"' in line and not cwd):
                    try:
                        e = json.loads(line)
                    except ValueError:
                        continue
                    cwd = cwd or e.get("cwd", "")
                    custom = e.get("customTitle") or custom
                    ai = e.get("aiTitle") or ai
            rows.append({"path": f, "id": sid, "account": "2" if d.endswith("-2") else "1",
                         "mtime": os.path.getmtime(f), "size": os.path.getsize(f),
                         "cwd": cwd.replace(HOME, "~"), "title": custom or ai or "(sans titre)"})
    return sorted(rows, key=lambda r: r["mtime"])


def line(i, r):
    return (f"{i:>3}  {time.strftime('%d/%m %H:%M', time.localtime(r['mtime']))}  c{r['account']}  "
            f"{r['size'] / 1048576:>6.1f} Mo  {r['title'][:50]:<50}  {r['cwd']}")


def trash(r):
    config = os.path.basename(os.path.dirname(os.path.dirname(os.path.dirname(r["path"]))))
    dest = os.path.join(TRASH, config, os.path.basename(os.path.dirname(r["path"])))
    os.makedirs(dest, exist_ok=True)
    shutil.move(r["path"], dest)
    sub = r["path"][:-6]
    if os.path.isdir(sub):
        shutil.move(sub, dest)
    print(f"Corbeille : {r['title']}")


def main():
    rows = sessions()
    args = sys.argv[1:]
    if args[:1] == ["--list"]:
        for i, r in enumerate(rows, 1):
            print(line(i, r))
        print(f"{len(rows)} sessions fermées")
        return
    if args[:1] == ["--trash"]:
        picked = []
        for a in args[1:]:
            if a.isdigit() and 1 <= int(a) <= len(rows):
                picked.append(rows[int(a) - 1])
            else:
                picked += [r for r in rows if r["id"].startswith(a)]
    else:
        if not rows:
            print("Aucune session fermée.")
            return
        menu = "\n".join(line(i, r) for i, r in enumerate(rows, 1))
        out = subprocess.run(["fzf", "--multi", "--tac", "--prompt", "Sessions à supprimer (Tab) > "],
                             input=menu, capture_output=False, stdout=subprocess.PIPE, text=True).stdout
        picked = [rows[int(l.split()[0]) - 1] for l in out.splitlines() if l.strip()]
        if not picked:
            return
        for r in picked:
            print("  " + r["title"])
        if input(f"Mettre ces {len(picked)} sessions à la Corbeille ? [o/N] ").strip().lower() not in ("o", "oui", "y"):
            return
    live = open_ids()  # checked again just before moving: a session may have been resumed meanwhile
    for r in picked:
        if r["id"] in live:
            print(f"Ouverte, gardée : {r['title']}")
        else:
            trash(r)


if __name__ == "__main__":
    main()
