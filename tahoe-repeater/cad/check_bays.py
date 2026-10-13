"""Checks for the board-bay test plates: one body, tongue free of everything but its root,
board fits home without touching anything but the latch (preload), tilt-in path clears the hooks."""
import trimesh, numpy as np, math, sys
from trimesh.transformations import rotation_matrix as R
SL_T, SO, PCB, GAP, PRE, PW, TL = 3.0, 7.0, 1.6, 0.2, -0.05, 2.4, 22
EAR = 3.5; PAD_W, PAD_L = 5, 9
def box(x0, x1, y0, y1, z0, z1):
    b = trimesh.creation.box(bounds=[[x0, y0, z0], [x1, y1, z1]]); return b
def vol(m):
    try: return 0.0 if m is None or m.is_empty else abs(m.volume)
    except Exception: return 0.0
def inter(a, b): return vol(trimesh.boolean.intersection([a, b], check_volume=False))
# per bay: size, standoff h, hook edge, latch [edge, t0, t1, dir], components [(u0,u1,v0,v1,h0 above board top, h1)]
B = {
 'bq':  dict(W=31.75, H=25.4, so=7, hook='B', latch=('T', 25, 28, -1),
             holes=[(2.54, 2.54, 2.5), (29.21, 2.54, 2.5), (2.54, 22.86, 2.5), (29.21, 22.86, 2.5)],
             comp=[(11.4, 20.3, 18.65, 26.0, 0, 3.2), (7.43, 15.43, 0, 6, 0, 4.5), (16.32, 24.32, 0, 6, 0, 4.5)]),
 'rak': dict(W=35, H=30, so=7, hook='L', latch=('R', 22, 27, 1),
             comp=[(-0.77, 6.58, 13.83, 22.77, 0, 3.26), (-21.77, -0.77, 12.1, 24.5, -1.62, 4.88), (12, 32, 0, 30, 0, 2.7)],
             under=[(21, 31, 16, 26, 0.01, 3.5),      # RAK1901, heights from the plate face
                    (6.0, 11.0, 1.3, 6.5, 1.0, 6.99), (6.0, 11.0, 23.5, 28.7, 1.0, 6.99)],
             holes=[(35, 15, 2.7), (4, 4, 2.7), (4, 26, 2.7)]),   # BAT and SOLAR sockets' pins, 7 mm in
 'mb':  dict(W=11.43, H=17.78, so=7, hook='L', latch=('R', 7, 10, -1), comp=[(1.18, 6.18, 6.26, 11.26, 0, 4.5)], holes=[(2.54, 15.24, 2.5)]),
 'ina': dict(W=20.4, H=25.6, so=4, hook='B', latch=('T', 3, 6, 1), comp=[], tl=17,
             holes=[(2.54, 2.54, 2.5), (17.86, 2.54, 2.5), (2.54, 23.06, 2.5), (17.86, 23.06, 2.5)]),
}
def ef(e, W, H):   # edge frame -> bay frame, as in the CAD
    return {'L': np.array([[0, -1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'R': np.array([[0, 1, 0, W], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'B': np.array([[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'T': np.array([[1, 0, 0, 0], [0, 1, 0, H], [0, 0, 1, 0], [0, 0, 0, 1.]])}[e]
ok = True
for name, c in B.items():
    m = trimesh.load(f'stl/bay_test_{name}.stl'); m.apply_translation([0, 0, -SL_T])   # bay frame: face at h = 0
    W, H, so = c['W'], c['H'], c['so']
    bodies = m.split(only_watertight=False)
    # board home: pushed against the hooks (GAP toward the hook edge)
    shift = {'L': (-GAP, 0), 'R': (GAP, 0), 'B': (0, -GAP), 'T': (0, GAP)}[c['hook']]
    board = box(shift[0], W + shift[0], shift[1], H + shift[1], so, so + PCB)
    for hu, hv, hd in c.get('holes', []):   # holes and half-holes the board really has
        cyl = trimesh.creation.cylinder(radius=hd/2, height=PCB + 2, sections=32); cyl.apply_translation([hu + shift[0], hv + shift[1], so + PCB/2])
        board = trimesh.boolean.difference([board, cyl], check_volume=False)
    parts = [board] + [box(u0 + shift[0], u1 + shift[0], v0 + shift[1], v1 + shift[1], so + PCB + h0, so + PCB + h1) for u0, u1, v0, v1, h0, h1 in c['comp']]
    parts += [box(u0, u1, v0, v1, h0, h1) for u0, u1, v0, v1, h0, h1 in c.get('under', [])]
    # the latch pillar, in the bay frame, to split its preload contact off from the rest
    e, t0, t1, d = c['latch']; T = ef(e, W, H)
    pw = max(t1 - t0, PAD_W); pa, pb = (t0, t0 + pw) if d > 0 else (t1 - pw, t1)   # pillar, ear and paddle
    pil = box(min(t0, pa) - 0.01, max(t1, pb) + 0.01, -GAP - PRE - 1.0, -GAP - PRE + PW + PAD_L + 0.01, -0.01, so + 1.75 + 1.4 + 0.1); pil.apply_transform(T)
    rest = trimesh.boolean.difference([m, pil], check_volume=False)
    clash = sum(inter(rest, p) for p in parts)
    pre = inter(m, board)
    # tongue free: cut the plate just short of the root; the tongue and pillar must come away as their own body
    tl = c.get('tl', TL); tr = (t0, t0 + tl) if d > 0 else (t1 - tl, t1)
    rootcut = box(tr[1] - 1.5 if d > 0 else tr[0] + 0.5, tr[1] - 0.5 if d > 0 else tr[0] + 1.5, -GAP - PRE - 0.05, -GAP - PRE + PW + 0.05, -SL_T - 1, 0.5)
    rootcut.apply_transform(T)
    freed = trimesh.boolean.difference([m, rootcut], check_volume=False).split(only_watertight=False)
    vols = sorted([abs(b.volume) for b in freed])
    # tilt-in: rotate the board about its hook-side bottom edge until its far edge clears the pillar, then down
    pivot = {'L': ([shift[0], 0, so], [0, 1, 0], 1), 'R': ([W + shift[0], 0, so], [0, 1, 0], -1),
             'B': ([0, shift[1], so], [1, 0, 0], -1), 'T': ([0, H + shift[1], so], [1, 0, 0], 1)}[c['hook']]
    span = W if c['hook'] in 'LR' else H
    th_max = math.degrees(math.asin((1.75 + 1.4 + 0.3) / span))
    worst = 0
    inward = {'L': (1, 0), 'R': (-1, 0), 'B': (0, 1), 'T': (0, -1)}[c['hook']]
    for th in np.linspace(th_max, 0.5, 8):
        best = 1e9
        for off in (0, 0.2, 0.4, 0.6, 0.8):   # the board may sit a little out of the hooks while tilted
            for sg in (1, -1):   # pick the sense that lifts the far edge
                Rm = R(math.radians(th) * sg, pivot[1], pivot[0]); b2 = board.copy(); b2.apply_transform(Rm)
                if b2.bounds[1][2] > so + PCB + 0.05: break
            b2.apply_translation([inward[0]*(off + GAP), inward[1]*(off + GAP), 0])
            best = min(best, inter(rest, b2))
            if best < 0.01: break
        worst = max(worst, best)
    print(f"{name:4s} bodies={len(bodies)} wt={m.is_watertight} size={np.round(m.extents,1).tolist()}  clash(not latch)={clash:.3f}  "
          f"latch preload overlap={pre:.2f} mm3  tongue frees on root cut: {len(freed)} bodies (smallest {vols[0]:.1f} mm3)  "
          f"tilt {th_max:.1f}deg..0 worst hook overlap={worst:.3f}")
    ok &= len(bodies) == 1 and clash < 0.01 and len(freed) == 2 and worst < 0.05
print('ALL OK' if ok else 'PROBLEMS')
