#!/usr/bin/env python3
"""Summarise an OmniWM trace captured around a Niri column scroll (real or bench gesture).

usage: analyze-scroll-trace.py TRACE.log
Window = from the first to the last animation tick with scroll work. Reports frame pacing (tick intervals),
AX writes (lane ordinary) and, per window, the gaps between successive writes: a window only moves on screen
when its write lands, so large per-window gaps are what the eye sees as stutter and drift between columns.
"""
import re
import sys
from collections import defaultdict


def pct(values, p):
    if not values:
        return float("nan")
    v = sorted(values)
    return v[min(len(v) - 1, int(round(p / 100 * (len(v) - 1))))]


def row(name, values, unit="ms"):
    if not values:
        return f"  {name:<28} n=0"
    return (f"  {name:<28} n={len(values):<5} p50={pct(values, 50):7.2f} p95={pct(values, 95):7.2f} "
            f"p99={pct(values, 99):7.2f} max={max(values):7.2f} {unit}")


text = open(sys.argv[1], errors="replace").read()
ticks = []
for m in re.finditer(r"^t=([\d.]+) .*?interval=([\d.]+)ms expected=([\d.]+)ms.*?scroll=([\d.]+)ms.*?total=([\d.]+)ms",
                     text, re.M):
    ticks.append(tuple(float(x) for x in m.groups()))
scroll_ticks = [t for t in ticks if t[3] > 0]
if not scroll_ticks:
    sys.exit("no scroll ticks in this trace")
t0, t1 = scroll_ticks[0][0], scroll_ticks[-1][0]
in_window = [t for t in ticks if t0 <= t[0] <= t1]
expected = in_window[0][2]
intervals = [t[1] for t in in_window[1:] if t[1] > 0]
print(f"scroll window {t1 - t0:.2f} s, {len(in_window)} ticks at {1000 / expected:.0f} Hz")
print(row("tick interval", intervals))
print(row("tick work (total)", [t[4] for t in in_window]))
late = sum(1 for i in intervals if i > 1.5 * expected)
print(f"  missed frames (interval > 1.5x): {late} ({100 * late / max(1, len(intervals)):.1f} %)")

writes = defaultdict(list)
totals, queues = [], []
for m in re.finditer(r"t_ns=(\d+) .*?lane=(\w+) .*?event=attempt win=(\d+) .*?queue_us=([\d.]+) .*?total_us=([\d.]+)",
                     text):
    t = int(m.group(1)) / 1e9
    if m.group(2) != "ordinary" or not (t0 - 0.05 <= t <= t1 + 0.05):
        continue
    writes[m.group(3)].append(t)
    queues.append(float(m.group(4)) / 1000)
    totals.append(float(m.group(5)) / 1000)
print(f"AX writes during scroll: {sum(len(v) for v in writes.values())} on {len(writes)} windows")
print(row("write duration", totals))
print(row("write queue wait", queues))
coalesced = len([1 for m in re.finditer(r"t_ns=(\d+) .*?event=ledger-coalesced", text)
                 if t0 <= int(m.group(1)) / 1e9 <= t1])
print(f"  coalesced (skipped) writes: {coalesced}")
# What the eye sees: writes of windows on screen (target x within the screen), their gaps, and how far apart
# the columns are at the same instant (each window's last written x minus its x at the start of the scroll
# is the strip offset it currently shows; columns in sync show the same offset).
SCREEN_W = float(sys.argv[2]) if len(sys.argv) > 2 else 2074
targets = defaultdict(list)
for m in re.finditer(r"t_ns=(\d+) .*?request=(\d+) win=(\d+) .*?lane=ordinary .*?event=attempt", text):
    pass
for m in re.finditer(r"t_ns=(\d+) .*?win=(\d+) .*?lane=ordinary .*?event=outcome=confirmed target=\(([-\d.]+),", text):
    targets[m.group(2)].append((int(m.group(1)) / 1e9, float(m.group(3))))
vis_gaps = []
for win, rows in targets.items():
    rows = [r for r in rows if t0 - 0.05 <= r[0] <= t1 + 0.05]
    for (ta, xa), (tb, xb) in zip(rows, rows[1:]):
        if -1000 < xa < SCREEN_W - 2 and -1000 < xb < SCREEN_W - 2:
            vis_gaps.append((tb - ta) * 1000)
print(row("visible update gap", vis_gaps) + f"  >=25ms: {sum(1 for g in vis_gaps if g >= 25)}")
# Desync: two columns on screen at the same instant keep a constant x distance when in sync; report how far
# the distance between each pair of visible columns strays from its median, sampled every frame.
from itertools import combinations
pairs = defaultdict(list)
step, t = 1 / 120, t0
while t <= t1:
    shown = {}
    for w, rows in targets.items():
        xs = [x for (tt, x) in rows if tt <= t]
        if xs and -1000 < xs[-1] < SCREEN_W - 2:
            shown[w] = xs[-1]
    for a, b in combinations(sorted(shown), 2):
        pairs[(a, b)].append(shown[b] - shown[a])
    t += step
desync = []
for d in pairs.values():
    med = pct(d, 50)
    desync += [abs(x - med) for x in d]
print(row("column desync (visible)", desync, "pt"))
all_gaps = []
for win, ts in sorted(writes.items()):
    gaps = [(b - a) * 1000 for a, b in zip(ts, ts[1:])]
    all_gaps += gaps
    print(row(f"win {win} update gap", gaps) + f"  >=25ms: {sum(1 for g in gaps if g >= 25)}")
print(row("all windows update gap", all_gaps))

# Tracking quality, per visible window, sampled every frame (what the eye follows):
#   ideal(t)  = last target OmniWM prepared for the window (ledger-prepared, before any compensation)
#   shown(t)  = last frame confirmed written (what the app applied)
#   error     = |shown - ideal|                (latency + irregularity, in pt)
#   overshoot = shown beyond ideal in the direction ideal moves (what compensation could add)
#   step jitter = |Δshown - Δideal| between consecutive frames (stutter even when columns stay in sync)
ideal = defaultdict(list)
if len(sys.argv) > 3:  # scroll-bench.tsv: targets before latency compensation
    for line in open(sys.argv[3]).read().splitlines()[1:]:
        t, w, i, _ = line.split("\t")
        ideal[w].append((float(t), float(i)))
else:
    for m in re.finditer(r"t_ns=(\d+) .*?win=(\d+) .*?lane=ordinary .*?event=ledger-prepared target=\(([-\d.]+),", text):
        ideal[m.group(2)].append((int(m.group(1)) / 1e9, float(m.group(3))))
errors, overs, jitter = [], [], []
for w in ideal:
    I, S = ideal[w], targets.get(w, [])
    prev = None
    t = t0
    while t <= t1:
        i = [x for (tt, x) in I if tt <= t]
        s = [x for (tt, x) in S if tt <= t]
        if len(i) >= 2 and s and -1000 < s[-1] < SCREEN_W - 2:
            e = s[-1] - i[-1]
            errors.append(abs(e))
            v = i[-1] - i[-2]
            if v:
                overs.append(max(0.0, e * (1 if v > 0 else -1)))
            if prev:
                jitter.append(abs((s[-1] - prev[0]) - (i[-1] - prev[1])))
            prev = (s[-1], i[-1])
        else:
            prev = None
        t += 1 / 120
print(row("tracking error", errors, "pt"))
print(row("overshoot", overs, "pt"))
print(row("step jitter", jitter, "pt"))

# End of gesture: the largest single jump of a visible window in the last 250 ms of motion (a visible snap).
end_jumps = []
for w, S in targets.items():
    S = [r for r in S if t1 - 0.25 <= r[0] <= t1 + 0.3 and -1000 < r[1] < SCREEN_W - 2]
    end_jumps += [abs(b[1] - a[1]) for a, b in zip(S, S[1:])]
print(row("end-of-gesture step", end_jumps, "pt"))
