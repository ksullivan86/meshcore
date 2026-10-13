"""The board bays on the sled (stl/sled.stl, assembled pose): each board fits home touching nothing,
each latch's tongue comes free when its root is cut, and each board tilts in under its hooks
without touching anything else on the sled."""
import trimesh, numpy as np, math
from trimesh.transformations import rotation_matrix as R
GAP, PRE, PW, TL, PAD_W, PAD_L, PCB, SL_T = 0.2, -0.05, 2.4, 22, 5, 9, 1.6, 3.0
p = GAP + PRE
def box(x0, x1, y0, y1, z0, z1): return trimesh.creation.box(bounds=[[x0, y0, z0], [x1, y1, z1]])
def vol(m):
    try: return 0.0 if m is None or m.is_empty else abs(m.volume)
    except Exception: return 0.0
def inter(a, b): return vol(trimesh.boolean.intersection([a, b], check_volume=False))
def ef(e, W, H):
    return {'L': np.array([[0, -1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'R': np.array([[0, 1, 0, W], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'B': np.array([[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1.]]),
            'T': np.array([[1, 0, 0, 0], [0, 1, 0, H], [0, 0, 1, 0], [0, 0, 0, 1.]])}[e]
def sled_m(o, a):   # bay frame (u, v, h) to the sled, as sled_bay_m in the CAD
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    return np.array([[c, -s, 0, o[0]], [0, 0, -1, 0], [s, c, 0, o[1]], [0, 0, 0, 1.]])
# per bay: size, standoff h, hook edge, latch, placement, parts on the board [(u0,u1,v0,v1,h0 above top,h1)], holes
B = {
 'rak': dict(W=35, H=30, so=7, hook='L', latch=('R', 22, 27, 1), at=((-17, 20), 0),
             comp=[(-0.77, 6.58, 13.83, 22.77, 0, 3.26), (12, 32, 0, 30, 0, 2.7)],
             under=[(21, 31, 16, 26, 0.01, 3.5), (6.0, 11.0, 1.3, 6.5, 1.0, 6.99), (6.0, 11.0, 23.5, 28.7, 1.0, 6.99)],
             holes=[(35, 15, 2.7), (4, 4, 2.7), (4, 26, 2.7)]),
 'bq':  dict(W=31.75, H=25.4, so=7, hook='B', latch=('T', 25, 28, -1), at=((-15.9, 64), 0),
             holes=[(2.54, 2.54, 2.5), (29.21, 2.54, 2.5), (2.54, 22.86, 2.5), (29.21, 22.86, 2.5)],
             comp=[(11.4, 20.3, 18.65, 26.0, 0, 3.2), (7.43, 15.43, 0, 6, 0, 4.5), (16.32, 24.32, 0, 6, 0, 4.5)]),
 'mb':  dict(W=11.43, H=17.78, so=7, hook='L', latch=('R', 7, 10, -1), at=((12.5, 107), 0), comp=[(1.18, 6.18, 6.26, 11.26, 0, 4.5)], holes=[(2.54, 15.24, 2.5)]),
 'ina': dict(W=20.4, H=25.6, so=4, hook='B', latch=('T', 3, 6, 1), at=((1, 101), 90), comp=[], tl=17,
             holes=[(2.54, 2.54, 2.5), (17.86, 2.54, 2.5), (2.54, 23.06, 2.5), (17.86, 23.06, 2.5)]),
}
sled = trimesh.load('stl/sled.stl')
print('sled bodies', len(sled.split(only_watertight=False)), 'watertight', sled.is_watertight)
ok = len(sled.split(only_watertight=False)) == 1
for name, c in B.items():
    W, H, so = c['W'], c['H'], c['so']; S = sled_m(*c['at'])
    def T(m): m = m.copy(); m.apply_transform(S); return m
    shift = {'L': (-GAP, 0), 'R': (GAP, 0), 'B': (0, -GAP), 'T': (0, GAP)}[c['hook']]
    board = box(shift[0], W + shift[0], shift[1], H + shift[1], so, so + PCB)
    for hu, hv, hd in c.get('holes', []):
        cyl = trimesh.creation.cylinder(radius=hd/2, height=PCB + 2, sections=32); cyl.apply_translation([hu + shift[0], hv + shift[1], so + PCB/2])
        board = trimesh.boolean.difference([board, cyl], check_volume=False)
    parts = [board] + [box(u0 + shift[0], u1 + shift[0], v0 + shift[1], v1 + shift[1], so + PCB + h0, so + PCB + h1) for u0, u1, v0, v1, h0, h1 in c['comp']]
    parts += [box(*x) for x in c.get('under', [])]
    parts = [T(x) for x in parts]
    e, t0, t1, d = c['latch']; E = ef(e, W, H)
    pw = max(t1 - t0, PAD_W); pa, pb = (t0, t0 + pw) if d > 0 else (t1 - pw, t1)
    pil = box(min(t0, pa) - 0.01, max(t1, pb) + 0.01, -p - 1.0, -p + PW + PAD_L + 0.01, -0.01, so + 1.75 + 1.4 + 0.1); pil.apply_transform(S @ E)
    rest = trimesh.boolean.difference([sled, pil], check_volume=False)
    clash = sum(inter(rest, x) for x in parts)
    home = inter(sled, T(board))
    tl = c.get('tl', TL); tr = (t0, t0 + tl) if d > 0 else (t1 - tl, t1)
    rc = box(tr[1] - 1.5 if d > 0 else tr[0] + 0.5, tr[1] - 0.5 if d > 0 else tr[0] + 1.5, -p - 0.05, -p + PW + 0.05, -SL_T - 1, 0.5); rc.apply_transform(S @ E)
    freed = trimesh.boolean.difference([sled, rc], check_volume=False).split(only_watertight=False)
    vols = sorted(abs(b.volume) for b in freed)
    pivot = {'L': ([shift[0], 0, so], [0, 1, 0]), 'R': ([W + shift[0], 0, so], [0, 1, 0]),
             'B': ([0, shift[1], so], [1, 0, 0]), 'T': ([0, H + shift[1], so], [1, 0, 0])}[c['hook']]
    span = W if c['hook'] in 'LR' else H
    th_max = math.degrees(math.asin((1.75 + 1.4 + 0.3) / span))
    inward = {'L': (1, 0), 'R': (-1, 0), 'B': (0, 1), 'T': (0, -1)}[c['hook']]
    worst = 0
    for th in np.linspace(th_max, 0.5, 8):
        best = 1e9
        for off in (0, 0.2, 0.4, 0.6, 0.8):
            for sg in (1, -1):
                b2 = board.copy(); b2.apply_transform(R(math.radians(th) * sg, pivot[1], pivot[0]))
                if b2.bounds[1][2] > so + PCB + 0.05: break
            b2.apply_translation([inward[0]*(off + GAP), inward[1]*(off + GAP), 0])
            best = min(best, inter(rest, T(b2)))
            if best < 0.01: break
        worst = max(worst, best)
    good = clash < 0.01 and home < 0.01 and len(freed) == 2 and worst < 0.05
    ok &= good
    print(f"{name:4s} clash(not latch)={clash:.3f} latch on board={home:.3f} tongue frees: {len(freed)} bodies (smallest {vols[0]:.0f} mm3) tilt-in worst={worst:.3f} {'OK' if good else 'PROBLEM'}")
print('ALL OK' if ok else 'PROBLEMS')
