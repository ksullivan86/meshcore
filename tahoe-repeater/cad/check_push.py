"""Checks for the push-down RAK test plate: one body, the strip comes free when cut at its root,
the board sits home touching only standoffs, hooks and stops, and pressing the grip down
(the strip bending in its flex zone) swings the latch's lip off the board."""
import trimesh, numpy as np, math
from trimesh.transformations import rotation_matrix as R
SL_T, SO, PCB, GAP, PRE, PW, PAD_L, FLEX, T, S = 3.0, 7.0, 1.6, 0.2, -0.05, 2.4, 9, 6, 1.6, 0.8
W, H = 35, 30; t0, t1 = 22, 27; p = GAP + PRE
def box(x0, x1, y0, y1, z0, z1): return trimesh.creation.box(bounds=[[x0, y0, z0], [x1, y1, z1]])
def vol(m):
    try: return 0.0 if m is None or m.is_empty else abs(m.volume)
    except Exception: return 0.0
def inter(a, b): return vol(trimesh.boolean.intersection([a, b], check_volume=False))
m = trimesh.load('stl/bay_test_rak_push.stl'); m.apply_translation([0, 0, -SL_T])
bodies = m.split(only_watertight=False)
board = box(-GAP, W - GAP, 0, H, SO, SO + PCB)
for hu, hv, hd in [(35, 15, 2.7), (4, 4, 2.7), (4, 26, 2.7)]:
    c = trimesh.creation.cylinder(radius=hd/2, height=PCB + 2, sections=32); c.apply_translation([hu - GAP, hv, SO + PCB/2])
    board = trimesh.boolean.difference([board, c], check_volume=False)
nr, ne = -p - FLEX, -p + PW + PAD_L                 # strip, as n; x = W + n on the right edge
latchbox = box(W + nr, W + ne + 0.01, t0 - 0.01, t1 + 0.01, -SL_T - 1, 20)
latch = trimesh.boolean.intersection([m, latchbox], check_volume=False)
rest = trimesh.boolean.difference([m, latchbox], check_volume=False)
comp = [box(-0.77 - GAP, 6.58 - GAP, 13.83, 22.77, SO + PCB, SO + PCB + 3.26), box(21, 31, 16, 26, 0.01, 3.5),
        box(6, 11, 1.3, 6.5, 1.0, 6.99), box(6, 11, 23.5, 28.7, 1.0, 6.99)]
clash = inter(rest, board) + sum(inter(rest, c) for c in comp) + sum(inter(latch, c) for c in comp)
home = inter(latch, board)
rc = box(W + nr + 0.3, W + nr + 1.0, t0 - 0.05, t1 + 0.05, -SL_T - 1, 0.5)
freed = trimesh.boolean.difference([m, rc], check_volume=False).split(only_watertight=False)
print(f"bodies={len(bodies)} wt={m.is_watertight} size={np.round(m.extents,1).tolist()} clash={clash:.3f} latch on board at home={home:.3f} mm3 strip frees: {len(freed)} bodies")
# release: bend in the flex zone ~ rotation about its middle, on the strip's mid-thickness
piv = [W + nr + FLEX/2, 0, -SL_T + T/2]
res = []
for deg in np.arange(1, 9.01, 1):
    l2 = latch.copy(); l2.apply_transform(R(math.radians(deg), [0, 1, 0], piv))
    lip = l2.bounds  # not used
    res.append((deg, inter(l2, board), (math.radians(deg))*(ne - FLEX/2 - nr + FLEX/2 + 0)))
for deg, ov, _ in res:
    tip_drop = math.radians(deg) * ((W + ne) - piv[0])
    print(f"  {deg:.0f} deg: grip end down {tip_drop:.1f} mm, latch overlapping board {ov:.2f} mm3")
ok = len(bodies) == 1 and clash < 0.01 and home < 0.01 and len(freed) == 2 and any(ov < 0.01 for d, ov, _ in res[3:])
print('ALL OK' if ok else 'PROBLEMS')
