#!/usr/bin/env python3
"""Pixel-level scroll analysis: film.swift frames + the bench's scroll-bench.tsv.

usage: analyze-pixels.py PREFIX WID:COLUMN:OFFSET [WID:COLUMN:OFFSET ...]
  PREFIX-N.txt  output of `film` (per frame: t xRed xGreen xBlue) for runs N = 1..
  PREFIX-N.tsv  ~/Library/Logs/OmniWM/scroll-bench.tsv copied after each run
  WID:COLUMN:OFFSET  test-app window id, its colour column in film output (0 red, 1 green, 2 blue) and the
                     pixels film reports minus the x OmniWM placed it at, measured at rest.
Reports calculated->pixels latency, frames without movement, reversal latency, column spacing, end-of-gesture step.
"""
import sys,glob,statistics as st
def pct(v,p):
    v=sorted(v); return v[min(len(v)-1,int(round(p/100*(len(v)-1))))] if v else float("nan")
WIN={a.split(":")[0]:(int(a.split(":")[1]),float(a.split(":")[2])) for a in sys.argv[2:]}
for L in (sys.argv[1],):
    lags=[];irr=0;mov=0;rev=[];dev=[];endj=[]
    for i in range(1,100):
        if not glob.glob(f"{L}-{i}.txt"): break
        ideal={w:[] for w in WIN}
        for l in open(f"{L}-{i}.tsv").read().splitlines()[1:]:
            t,w,x,_=l.split("\t")
            if w in ideal: ideal[w].append((float(t),float(x)))
        fr=[tuple(map(float,l.split())) for l in open(f"{L}-{i}.txt") if l.strip()]
        I=ideal[list(WIN)[-1]]
        if not I: continue
        t0,t1=I[0][0],I[-1][0]
        disp={}
        for w,(c,o) in WIN.items():
            disp[w]=[(f[0],f[1+c]-o) for f in fr if t0<=f[0]<=t1+0.15 and 1<f[1+c]<2070]
            Iw=ideal[w]
            for t,x in disp[w]:
                cands=[ti for ti,xi in Iw if ti<=t and abs(xi-x)<1.5]
                if cands and t<=t1: lags.append((t-cands[-1])*1000)
            D=[d for d in disp[w] if d[0]<=t1]
            for (ta,xa),(tb,xb) in zip(D,D[1:]):
                a=[x for ti,x in Iw if ti<=ta-0.025]; b=[x for ti,x in Iw if ti<=tb-0.025]
                if a and b and abs(b[-1]-a[-1])>2:
                    mov+=1; step=abs(xb-xa); exp=abs(b[-1]-a[-1])*(tb-ta)/max(1e-6,(tb-ta))
                    if step<0.5 or (tb-ta)>0.0125: irr+=1
        # reversal: first ideal direction change (blue), then first displayed direction change after it
        sgn=lambda v:(v>0)-(v<0)
        Is=[(I[k+1][0],sgn(I[k+1][1]-I[k][1])) for k in range(len(I)-1) if I[k+1][1]!=I[k][1]]
        tr=next((Is[k][0] for k in range(1,len(Is)) if Is[k][1]!=Is[k-1][1]),None)
        Db=disp[list(WIN)[-1]]; Ds=[(Db[k+1][0],sgn(Db[k+1][1]-Db[k][1])) for k in range(len(Db)-1) if abs(Db[k+1][1]-Db[k][1])>0.5]
        if tr:
            before=[s for t,s in Ds if t<tr]; d0=before[-1] if before else None
            td=next((t for t,s in Ds if t>=tr and d0 is not None and s!=d0),None)
            if td: rev.append((td-tr)*1000)
        # spacing red/blue
        R=dict((round(t,4),x) for t,x in disp[list(WIN)[0]]); B=dict((round(t,4),x) for t,x in disp[list(WIN)[-1]])
        dev+=[B[k]-R[k] for k in R if k in B and k<=t1]
        tail=[x for t,x in Db if t>t1-0.05]
        endj+=[abs(b-a) for a,b in zip(tail,tail[1:])]
    med=pct(dev,50); d=[abs(x-med) for x in dev]
    print(f"{L}: calc->pixels ms p50={pct(lags,50):5.1f} p95={pct(lags,95):5.1f} p99={pct(lags,99):5.1f} | irregular frames {irr}/{mov} ({100*irr/max(1,mov):.1f}%) | reversal->pixels ms p50={pct(rev,50):5.1f} max={max(rev) if rev else float('nan'):5.1f} | spacing dev p95={pct(d,95):.0f} max={max(d) if d else 0:.0f} pt | end step max={max(endj) if endj else 0:.0f} pt")
