#!/usr/bin/env python3
"""WindowServer-level scroll analysis: `poll` output + the bench's scroll-bench.tsv.
usage: analyze-windowserver.py PREFIX   (reads PREFIX-N.poll and PREFIX-N.tsv for N = 1..8)
Reports calculated->WindowServer latency, gaps between displayed updates, column desync."""
import sys,glob,collections,itertools
def pct(v,p):
    v=sorted(v); return v[min(len(v)-1,int(round(p/100*(len(v)-1))))] if v else float("nan")
lab=sys.argv[1]; W=2074
lags=[];gaps=[];desync=[];steps=[]
for i in range(1,9):
    ideal=collections.defaultdict(list); disp=collections.defaultdict(list)
    for line in open(f"{lab}-{i}.tsv").read().splitlines()[1:]:
        t,w,x,_=line.split("\t"); ideal[w].append((float(t),float(x)))
    for line in open(f"{lab}-{i}.poll"):
        t,w,x=line.split(); disp[w].append((float(t),float(x)))
    if not ideal: continue
    t0=min(r[0][0] for r in ideal.values()); t1=max(r[-1][0] for r in ideal.values())
    for w,D in disp.items():
        I=ideal.get(w,[])
        if not I: continue
        width=1025
        D=[d for d in D if t0<=d[0]<=t1+0.05]
        vis=[d for d in D if -width<d[1]<W-2]
        for (ta,xa),(tb,xb) in zip(vis,vis[1:]): gaps.append((tb-ta)*1000)
        for (t,x) in vis:
            cands=[ti for ti,xi in I if ti<=t and abs(xi-x)<0.6]
            if cands: lags.append((t-cands[-1])*1000)
    # desync on displayed positions sampled at 120 Hz
    pairs=collections.defaultdict(list); t=t0
    while t<=t1:
        shown={}
        for w,D in disp.items():
            xs=[x for tt,x in D if tt<=t]
            if xs and -1015<xs[-1]<W-1030: shown[w]=xs[-1]
        for a,b in itertools.combinations(sorted(shown),2): pairs[(a,b)].append(shown[b]-shown[a])
        t+=1/120
    for d in pairs.values():
        med=pct(d,50); desync+=[abs(x-med) for x in d]
print(f"{lab:8} displayed lag (tick->WindowServer) ms p50={pct(lags,50):5.1f} p95={pct(lags,95):5.1f} p99={pct(lags,99):5.1f} | display gap ms p50={pct(gaps,50):5.1f} p95={pct(gaps,95):5.1f} p99={pct(gaps,99):5.1f} max={max(gaps) if gaps else 0:5.0f} | desync pt p95={pct(desync,95):4.0f} p99={pct(desync,99):4.0f} max={max(desync) if desync else 0:4.0f}")
