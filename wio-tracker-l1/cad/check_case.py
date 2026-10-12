"""Fit checks for the Wio Tracker L1 case (E-ink): the fit-test coupon and the numbers behind it.

Renders the parts where they sit with OpenSCAD into build/, then measures (PLAN.md section 7 step 5):
the case in both docks (clearance, pogo window over the dock's slot, the hump over the dock's back
rest); the board bay (only the latch touches the board, tongue free, board tilts in under the hooks);
the latch blocker's gap; the hold-down pads' gaps; the wall round each heat-set insert and the screw
length; the cell at CELL_MAX; the panel under its lips and snap bar; and that every coupon piece is
one body and the pieces go together without overlapping.

    python cad/check_case.py
    python cad/check_case.py -D PCB_T=1.2 -D "CELL_MAX=[10.3,36,67]"   # any OpenSCAD override, passed through

Needs OpenSCAD (on the PATH, or set OPENSCAD to its executable) and:
    pip install trimesh manifold3d numpy rtree ezdxf shapely networkx
Run it from the project folder. build/ is ignored by git. The dock checks need the check meshes in
ref/ (not in the repo); without them they're skipped.
"""
import argparse, json, math, os, re, shutil, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
import warnings
import numpy as np, trimesh, ezdxf
warnings.filterwarnings('ignore', category=RuntimeWarning)
from shapely.geometry import Polygon, LineString
from shapely.ops import unary_union, polygonize

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, 'wio-tracker-l1.scad')
REF = os.path.join(HERE, '..', 'ref')
DOCKS = ('ref-dock-eink.stl', 'ref-dock-oled.stl')
STRAIN_MAX = 0.02  # flexures: bending strain, PLA or PETG

def openscad():
    for c in (os.environ.get('OPENSCAD'), shutil.which('openscad'), r'C:\Program Files\OpenSCAD\openscad.com',
              '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'):
        if c and os.path.exists(c): return c
    sys.exit('OpenSCAD not found: put it on the PATH or set OPENSCAD')

def scad(part, out, defs):
    args = [openscad(), '-o', out, '-D', f'PART="{part}"'] + sum([['-D', d] for d in defs], [])
    if os.path.exists(out): os.remove(out)
    r = subprocess.run(args + [SCAD], capture_output=True, text=True)
    log = r.stdout + r.stderr   # where the echoes go depends on the platform
    if 'top level object is empty' in log: return log
    if r.returncode or 'ERROR' in log:
        sys.exit(f'OpenSCAD failed on {part}:\n{log[-2000:]}')
    return log

def build(defs):
    d = os.path.join(HERE, '..', 'build', 'check'); os.makedirs(d, exist_ok=True)
    parts = ['a_boss', 'a_tray', 'a_corner', 'a_front', 'a_door', 'a_tb', 'a_tb_open', 'd_adapter', 'a_shell', 'a_tray_full', 'a_front_full', 'a_pads', 'a_blocker',
             'e_case', 'd_board', 'd_panel', 'd_panel_low', 'd_cell', 'd_strap']
    jobs = [(p, os.path.join(d, p + '.stl')) for p in parts] + [(p, os.path.join(d, p + '.dxf')) for p in ('s_boss', 's_boss_low')]
    with ThreadPoolExecutor(6) as ex:
        logs = list(ex.map(lambda j: scad(j[0], j[1], defs), jobs))
    m = re.search(r'wtl-chk: (\{.*\})"', logs[0])
    info = json.loads(m.group(1).replace('\\"', '"'))
    meshes = {p: (trimesh.load(f, force='mesh') if os.path.exists(f) else None) for p, f in jobs if f.endswith('.stl')}
    return info, meshes, {p: f for p, f in jobs if f.endswith('.dxf')}, logs[0]

def empty(m): return m is None or m.is_empty or len(m.faces) == 0
def inter(a, b):
    if empty(a) or empty(b): return None
    return trimesh.boolean.intersection([a, b], engine='manifold')   # raises if a mesh isn't a closed volume: fix the mesh
def minus(a, b): return trimesh.boolean.difference([a, b], engine='manifold')
def vol(m): return 0.0 if empty(m) else abs(m.volume)
def gap(a, b, n=4000):
    """Smallest distance from a's surface to b's (approximate, sampled); negative if they overlap."""
    if empty(a) or empty(b): return float('inf')
    if vol(inter(a, b)) > 1e-3: return -1.0
    pts = np.vstack([a.sample(n), a.vertices])
    _, dist, _ = trimesh.proximity.closest_point(b, pts)
    return float(dist.min())
def box(x0, x1, y0, y1, z0, z1): return trimesh.creation.box(bounds=[[x0, y0, z0], [x1, y1, z1]])
def moved(m, v): q = m.copy(); q.apply_translation(v); return q
def bodies(m): return len(m.split(only_watertight=False))

def dxf_polys(path):
    """Closed outlines from an OpenSCAD DXF section, as shapely polygons."""
    doc = ezdxf.readfile(path); lines = []
    for e in doc.modelspace():
        if e.dxftype() == 'LINE': lines.append(LineString([(e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y)]))
        elif e.dxftype() == 'LWPOLYLINE':
            pts = [(p[0], p[1]) for p in e.get_points()]
            if e.closed: pts.append(pts[0])
            lines.append(LineString(pts))
    shells = {}
    for p in polygonize(unary_union(lines)):
        q = Polygon(p.exterior); shells[(round(q.area, 3), tuple(np.round(q.centroid.coords[0], 2)))] = q
    return list(shells.values())

def web_round(path, centre, d):
    """Thinnest material between the round hole at centre (diameter d) and any other edge of the section."""
    rings = dxf_polys(path)
    hole = min(rings, key=lambda r: abs(r.area - math.pi * d * d / 4) + 10 * np.hypot(r.centroid.x - centre[0], r.centroid.y - centre[1]))
    return min(hole.exterior.distance(r.exterior) for r in rings if r is not hole)

def loops(m, z):
    s = m.section(plane_origin=[0, 0, z], plane_normal=[0, 0, 1])
    return [] if s is None else [np.array(d) for d in s.discrete]
def bb(l): return l[:, 0].min(), l[:, 0].max(), l[:, 1].min(), l[:, 1].max()

def dock_frame(dock):
    """Find the case pocket in a dock mesh: its x and y range, its floor and its rim, and the pogo slot in its floor."""
    top = dock.bounds[1][2]
    L = [bb(l) for l in loops(dock, top - 10)]
    out = max(L, key=lambda b: (b[1] - b[0]) * (b[3] - b[2]))
    pk = max((b for b in L if b[0] > out[0] + 1 and b[1] < out[1] - 1), key=lambda b: (b[1] - b[0]) * (b[3] - b[2]))
    o = np.array([[pk[0] + 2.5, pk[2] + 1.0, top - 1.0]])
    floor = dock.ray.intersects_location(o, [[0, 0, -1]], multiple_hits=False)[0][0][2]
    S = [bb(l) for l in loops(dock, floor - 1.0)]
    slot = min((b for b in S if b[0] > pk[0] and b[1] < pk[1] and b[3] < pk[3]), key=lambda b: abs((b[1] - b[0]) - 36.74) + abs((b[3] - b[2]) - 12.46))
    return dict(x=(pk[0], pk[1]), y=(pk[2], pk[3]), floor=floor, top=top, slot=slot)

def to_dock(m, I, D, back=0.0, lift=0.02, dx=0.0):
    """The case in the dock: dock end down on the pocket's floor, back toward the pocket's back wall, centred across."""
    T = np.array([[1, 0, 0, (D['x'][0] + D['x'][1]) / 2 - (I['X0'] + I['X1']) / 2 + dx],
                  [0, 0, -1, D['y'][1] - back],
                  [0, 1, 0, D['floor'] + lift],
                  [0, 0, 0, 1.0]])
    q = m.copy(); q.apply_transform(T); return q

def old_envelope(depth):
    """The old back shell's outside over the part that goes in the dock, as a convex solid."""
    f = os.path.join(REF, 'ref-eink-back-shell.stl')
    if not os.path.exists(f): return None
    old = trimesh.load(f, force='mesh')
    far = depth + 8   # hull a little further up, so the 0.5 mm finger notch in its side near the dock line is bridged
    cut = old.section(plane_origin=[0, far, 0], plane_normal=[0, 1, 0])
    pts = np.vstack([old.vertices[old.vertices[:, 1] <= far]] + [np.array(d) for d in cut.discrete])
    return inter(trimesh.convex.convex_hull(pts), box(-10, 80, -10, depth, -10, 40))

def dock_checks(I, M, rep):
    case = M['e_case']; Wd = I['X1'] - I['X0']; depth = I['DOCK_POCKET'][2]
    low = inter(case, box(-10, 80, -10, depth, -10, I['RIM_Z']))        # the shell's outside, as far up as the dock reaches
    env = old_envelope(depth)
    if env is None: print('  SKIP  dock rule: ref-eink-back-shell.stl is not in ref/')
    else:
        pts = np.vstack([low.sample(8000), low.vertices])
        proud = max(0.0, -float(trimesh.proximity.signed_distance(env, pts).min())); short = vol(minus(env, low))
        rep('dock rule: the dock end keeps the old shell\'s profile', proud <= 0.1 and short < 30,   # 0.1: mesh facets; the pocket has 0.85 slack
            f'nowhere more than {proud:.2f} mm outside the old shell and {short:.1f} mm3 smaller, over the bottom {depth} mm ({vol(low) / 1000:.1f} cm3)')
    rep('dock rule: nothing new on the bottom of the back', I['DOCK_KEEP'] >= depth + 1 and abs(I['Z_FRONT'] - 26.5) < 0.05,
        f'hump starts at {I["DOCK_KEEP"]} mm, the docks are {depth} deep; front face at {I["Z_FRONT"]} (old case 26.5)')
    for name in DOCKS:
        f = os.path.join(REF, name); tag = name[4:-4]
        if not os.path.exists(f):
            print(f'  SKIP  {tag}: {name} is not in ref/'); continue
        dock = trimesh.load(f, force='mesh'); D = dock_frame(dock)
        pw, pd, dd = D['x'][1] - D['x'][0], D['y'][1] - D['y'][0], D['top'] - D['floor']
        sw, sd = D['slot'][1] - D['slot'][0], D['slot'][3] - D['slot'][2]
        P, S = I['DOCK_POCKET'], I['DOCK_SLOT']
        rep(f'{tag}: the mesh is the dock in the plan', max(abs(pw - P[0]), abs(pd - P[1]), abs(dd - P[2]), abs(sw - S[0]), abs(sd - S[1])) < 0.1,
            f'pocket {pw:.2f} x {pd:.2f}, {dd:.1f} deep, slot {sw:.2f} x {sd:.2f}')
        # seat it: the pocket's two back corners aren't cut the same, so look for where the case sits freely
        side, front = (pw - Wd) / 2, pd - I['Z_FRONT']; best = (-1.0, 0, 0)
        both = trimesh.util.concatenate([low, inter(case, box(-10, 80, -10, depth + 2, I['RIM_Z'], 40))])
        for dx in (-0.3, -0.2, -0.1, 0.0):
            for back in (0.3, 0.4, 0.5):
                if vol(inter(to_dock(case, I, D, back=back, dx=dx), dock)) > 0.01: continue
                g = gap(to_dock(both, I, D, back=back, lift=0.3, dx=dx), dock, 2500)
                if g > best[0]: best = (g, dx, back)
        g, dx, back = best
        rep(f'{tag}: the case seats in the pocket', g >= 0.1 and side >= 0.2 and front >= 0.3,
            f'{pw - Wd:.2f} mm slack across, {front:.2f} front to back; sitting {-dx:.1f} left of centre and {back:.1f} off the back wall it has {g:.2f} mm all round')
        # pogo window on the case's end face over the slot in the pocket's floor
        cx = I['POGO_C'][0] + (D['x'][0] + D['x'][1]) / 2 - (I['X0'] + I['X1']) / 2 + dx; cy = D['y'][1] - back - I['POGO_C'][1]
        wx, wy = I['POGO_WIN'][0] / 2, I['POGO_WIN'][1] / 2
        inside = min(cx - wx - D['slot'][0], D['slot'][1] - cx - wx, cy - wy - D['slot'][2], D['slot'][3] - cy - wy)
        ox, oy = cx - (D['slot'][0] + D['slot'][1]) / 2, cy - (D['slot'][2] + D['slot'][3]) / 2
        rep(f'{tag}: pogo window over the dock\'s slot', inside >= 0 and abs(ox) <= 0.75 and abs(oy) <= 0.75,
            f'centres {ox:+.2f}, {oy:+.2f} mm apart, window {inside:.2f} mm inside the slot')
        # the hump starts above the pocket's back wall
        if I['HUMP'] <= 0: rep(f'{tag}: hump clears the dock\'s back rest', True, 'no hump at this cell size'); continue
        hump = inter(case, box(-10, 80, -10, 120, -50, -0.005))
        g = gap(to_dock(hump, I, D), dock, 3000)
        rep(f'{tag}: hump clears the dock\'s back rest', g >= 1.0, f'{I["HUMP"]:.1f} mm hump starts {I["DOCK_KEEP"] - dd:.1f} mm above the rest; nearest {g:.2f} mm')

def bay_checks(I, M, rep):
    tray, board, blk = M['a_tray_full'], M['d_board'], M['a_blocker']
    ox, oy = I['BAY_O']; G, PRE, PW = I['BAY_GAP'], I['BAY_PRE'], I['BAY_PW']; H = I['BOARD'][1]
    assert all(l[0] == 'T' for l in I['LATCHES']), 'bay_checks is written for latches on the top edge'
    def tb(ta, tb_, na, nb, z0, z1):   # a box in the latch edge's frame: t along +x, n outward = +y
        return box(ox + ta, ox + tb_, oy + H + na, oy + H + nb, z0, z1)
    top = I['Z_TF'] + I['SO_H'] + I['BAY_SLOT_H'] + I['BAY_LIP_T']
    pils = trimesh.util.concatenate([tb(l[1] - 0.01, l[2] + 0.01, -G - PRE - 1.2, -G - PRE + PW + 0.01, I['Z_TF'] - 0.01, top + 0.1) for l in I['LATCHES']])
    rest = minus(tray, pils)
    pre, clash = vol(inter(board, tray)), vol(inter(board, rest)); want = PRE * I['PCB_T'] * sum(l[2] - l[1] for l in I['LATCHES'])
    rep('bay: only the latches touch the board', clash < 0.01 and 0.5 * want < pre < 1.3 * want,
        f'latch preload {pre:.2f} mm3 ({PRE} mm), everything else {clash:.3f} mm3')
    reach = I['BAY_LIP'] + PRE; n0 = bodies(tray)
    for i, (e, t0, t1, d) in enumerate(I['LATCHES']):
        tr = (t1 - I['BAY_TL'], t1) if d < 0 else (t0, t0 + I['BAY_TL'])
        ra = (tr[0] + 0.5, tr[0] + 1.5) if d < 0 else (tr[1] - 1.5, tr[1] - 0.5)
        cut = tb(ra[0], ra[1], -G - PRE - 0.05, -G - PRE + PW + 0.05, I['Z_TB'] - 5, I['Z_TF'] + 0.5)
        n1 = bodies(minus(tray, cut)); L = I['BAY_TL'] - (t1 - t0) / 2; strain = 1.5 * PW * reach / L ** 2
        rep(f'bay: latch {i + 1} tongue free to its root, and bends far enough', n1 == n0 + 1 and strain <= 0.025,
            f'{n1 - n0} more piece(s) when cut at the root; {strain * 100:.1f} % strain pushed {reach:.2f} mm clear of the board')
        g0, g1 = I['GRIPS'][i]; zone = tb(g0 - 1, g1 + 1, -G - PRE - 1, 12, I['Z_TF'] + 0.05, I['Z_SKIN'])
        grip = inter(tray, zone); rib = inter(blk, zone)
        g = gap(rib, grip); stop = vol(inter(rib, moved(grip, [0, g + 0.25, 0])))
        rep(f'latch {i + 1} blocker beside the grip tab', abs(g - I['BLOCK_GAP']) <= 0.1 and stop > 0.3,
            f'gap {g:.2f} mm (want {I["BLOCK_GAP"]}); the tab pushed 0.25 further meets the rib over {stop:.1f} mm3; the latch needs {reach:.2f} mm to let go')
    # tilt in: bottom edge pushed under the hook, top edge raised, then lowered onto the pins; it may slide back a little while tilted
    y0 = I['BOARD_Y0']; th_max = math.degrees(math.asin((I['PCB_T'] + 0.15 + I['BAY_LIP_T'] + 0.3) / H)); worst = 0
    for th in np.linspace(th_max, 0.3, 9):
        best = 1e9
        for off in (0, 0.2, 0.4, 0.6, 0.8, 1.0):
            b2 = board.copy()
            b2.apply_transform(trimesh.transformations.rotation_matrix(math.radians(th), [1, 0, 0], [0, y0, I['Z_BB']]))
            b2.apply_translation([0, off, 0])
            best = min(best, vol(inter(b2, rest)))
            if best < 0.01: break
        worst = max(worst, best)
    rep('bay: board tilts in under the hook and onto its pins', worst < 0.05, f'{th_max:.1f} deg to 0, worst overlap {worst:.3f} mm3')
    v = vol(inter(blk, tray)) + vol(inter(blk, board)); rep('latch blockers clear of the tray and board', v < 0.01, f'overlap {v:.3f} mm3')

def run(defs):
    I, M, D, log = build(defs)
    for l in log.splitlines():
        if 'wtl:' in l: print('  ' + l.split('"')[1])
    res = []
    def rep(name, ok, detail):
        res.append(bool(ok)); print(f"  {'PASS' if ok else 'FAIL'}  {name}: {detail}")
    # 1. the coupon: every piece one body, and they go together
    names = {'a_tray': 'tray', 'a_boss': 'shell corner', 'a_front': 'front (panel side and corner)', 'a_door': 'panel door'}
    for k, nm in names.items():
        n = bodies(M[k]); rep(f'coupon: {nm} is one piece', n == 1 and M[k].is_watertight, f'{n} bodies, watertight {M[k].is_watertight}, {vol(M[k]) / 1000:.1f} cm3')
    tot = sum(vol(M[k]) for k in names) / 1000
    rep('coupon: little plastic', tot < 16, f'{tot:.1f} cm3 in all (about {tot * 1.25:.0f} g in PETG)')
    v = [vol(inter(M[a], M[b])) for a, b in (('a_boss', 'a_tray'), ('a_boss', 'a_corner'), ('a_tray', 'a_corner'))]
    seat = max(gap(M['a_tray'], M['a_boss'], 2000), gap(M['a_corner'], M['a_tray'], 2000))
    rep('coupon: boss, tray and front corner stack', max(v) < 0.01 and seat < 0.05, f'overlaps {v[0]:.3f}, {v[1]:.3f}, {v[2]:.3f} mm3; faces {seat:.2f} mm apart')
    low = inter(M['a_corner'], box(-10, 80, -10, 120, -10, I['RIM_Z'] - 0.05))
    g = gap(low, M['a_boss']); rep('coupon: tongue and post clear of the shell', g >= 0.1, f'{g:.2f} mm')
    # 2. heat-set inserts and screws
    p = I['SCREWS'][2]; grow = (I['INSERT_OD'] - I['INSERT_HOLE_D']) / 2
    w = min(web_round(D[k], p, I['INSERT_HOLE_D']) for k in ('s_boss', 's_boss_low')) - grow
    o = np.array([[p[0], p[1], I['Z_TB'] - I['INSERT_DEPTH'] - 0.01]])
    under = I['Z_TB'] - I['INSERT_DEPTH'] - M['a_boss'].ray.intersects_location(o, [[0, 0, -1]], multiple_hits=True)[0][:, 2].min()
    rep('insert: wall round it', w >= 1.95 and under >= 1.5, f'{w:.2f} mm once the {I["INSERT_OD"]} mm insert is in (want 2.0), {under:.1f} mm under the hole')
    iron = trimesh.creation.cylinder(radius=I['IRON_D'] / 2, height=I['RIM_Z'] + 6 - I['Z_TB'], sections=64)
    walls = inter(M['a_shell'], box(-10, 80, -10, 120, I['Z_TB'] + 0.3, 60))   # the shell above the bosses
    room = min(gap(moved(iron, [q[0], q[1], (I['RIM_Z'] + 6 + I['Z_TB']) / 2 + 0.05]), walls, 3000) for q in I['SCREWS'])
    rep('insert: the iron reaches it', room >= 1.0, f'{room:.2f} mm between a {I["IRON_D"]} mm tip and the walls, at every boss')
    eng = I['SCREW_L'] - (I['Z_SEAT'] - I['Z_TB']); spare = I['INSERT_DEPTH'] - eng
    rep('screw length', eng >= 0.6 * I['INSERT_L'] and spare >= 0.3, f'M3 x {I["SCREW_L"]}: {eng:.1f} mm in the insert, {spare:.1f} mm short of the end of the hole')
    # 3. the full parts' cores go together
    pairs = (('a_shell', 'a_tray_full'), ('a_shell', 'a_front_full'), ('a_tray_full', 'a_front_full'), ('a_front_full', 'd_board'), ('a_shell', 'd_board'))
    v = [vol(inter(M[a], M[b])) for a, b in pairs]
    rep('shell, tray, front and board don\'t overlap', max(v) < 0.01, ', '.join(f'{x:.3f}' for x in v) + ' mm3')
    # 4. board bay and lid lock
    bay_checks(I, M, rep)
    board = M['d_board']
    for i, pad in enumerate(sorted(M['a_pads'].split(only_watertight=False), key=lambda m: (m.centroid[1], m.centroid[0]))):
        g = gap(pad, board, 800); c = pad.centroid
        on = I['BAY_O'][0] <= c[0] <= I['BAY_O'][0] + I['BOARD'][0] and I['BOARD_Y0'] <= c[1] <= I['BOARD_Y0'] + I['BOARD'][1]
        rep(f'hold-down pad {i + 1} at ({c[0]:.1f}, {c[1]:.1f})', on and abs(g - I['PAD_GAP']) <= 0.05, f'{g:.2f} mm above the board (want {I["PAD_GAP"]})')
    g = gap(M['a_pads'], M['a_tray_full'], 2000); rep('hold-down pads clear of the hook and latches', g >= 0.3, f'{g:.2f} mm')
    # 5. cell bay
    cell, strap, shell = M['d_cell'], M['d_strap'], M['a_shell']
    v = vol(inter(cell, shell)) + vol(inter(cell, M['a_tray_full'])); g = gap(cell, shell, 6000)
    spare = I['Z_TB'] - I['BACK_T'] - I['CELL_MAX'][0]
    rep('cell at CELL_MAX fits', v < 0.01 and g >= 0.25, f'{I["CELL_MAX"]}: overlap {v:.2f} mm3, nearest {g:.2f} mm; {spare:.1f} mm spare in thickness in the dock zone')
    v = vol(inter(strap, shell)); rep('strap round the cell fits', v < 0.01, f'{I["STRAP_T"]} mm strap: overlap {v:.2f} mm3, hump {I["HUMP"]:.1f} mm')
    # 6. e-ink panel
    front = M['a_front_full']
    v = vol(inter(M['d_panel'], front)); slack = (I['PKT_X'][1] - I['PKT_X'][0] - I['PANEL'][0], I['PKT_Y'][1] - I['PKT_Y'][0] - I['PANEL'][1])
    rep('panel drops into its pocket', v < 0.01 and min(slack) >= 0.4, f'overlap {v:.3f} mm3; pocket {slack[0]:.2f} wider and {slack[1]:.2f} longer than the panel')
    door, tb, ad = M['a_door'], M['a_tb'], M['d_adapter']; zdoor, dgap, ztb, adgap, slide = I['DOOR']
    v = [vol(inter(door, M[k])) for k in ('a_front_full', 'd_panel', 'd_panel_low', 'd_board', 'a_tray_full', 'a_shell', 'a_tb', 'd_adapter')]
    g = min(gap(door, M[k], 3000) for k in ('d_panel', 'd_panel_low'))
    rep('door closes over the panel', bodies(door) == 1 and max(v) < 0.01 and abs(g - dgap) <= 0.05,
        'overlaps ' + ', '.join(f'{x:.3f}' for x in v) + f' mm3 with the front, panel (both ends of its play), board, tray, shell, turn buttons, adapter; {g:.2f} mm off the glass')
    up = moved(door, [0, 0, -0.5]); rail = vol(inter(up, front)); arms = [vol(inter(up, b)) for b in tb.split(only_watertight=False)]
    free = vol(inter(up, M['a_tb_open']))
    rep('door held by the rail and two turn buttons', rail > 0.5 and len(arms) == 2 and min(arms) > 0.3 and free < 0.01,
        f'pulled back 0.5 mm it meets the rail over {rail:.1f} mm3 and the buttons over {arms[0]:.1f} and {arms[1]:.1f} mm3; with the buttons swung open, {free:.2f} mm3')
    way = [moved(door, [slide, 0, -dz]) for dz in (4, 2, 1, 0.5, 0)] + [moved(door, [dx, 0, 0]) for dx in (slide * 0.66, slide * 0.33)]
    w = max(vol(inter(q, front)) + vol(inter(q, M['a_tb_open'])) + vol(inter(q, M['d_panel'])) for q in way)
    rep('door goes in: down, then slid left under the rail', w < 0.01, f'worst overlap on the way {w:.3f} mm3 (set down {slide} mm to the right, buttons open)')
    v = [vol(inter(M[a], M[k])) for a in ('a_tb', 'a_tb_open') for k in ('d_board', 'a_tray_full', 'a_shell', 'd_panel', 'd_adapter')]
    room = min(ztb - I['Z_BT'], zdoor - I['Z_BT'])
    rep('door and turn buttons clear of the board', max(v) < 0.01 and room >= 0.4,
        f'buttons, shut or open: overlap {max(v):.3f} mm3; their posts end {ztb - I["Z_BT"]:.2f} mm above the board, the door is {zdoor - I["Z_BT"]:.2f} mm above it')
    v = vol(inter(ad, M['a_front_full'])) + vol(inter(ad, M['a_tray_full'])); g = gap(ad, M['a_tray_full'], 1500)
    rep('ribbon adapter sits in its seat under the tray\'s post', v < 0.01 and abs(g - adgap) <= 0.1, f'overlap {v:.3f} mm3; post {g:.2f} mm behind it')
    mx, my = (I['WIN'][0] - I['PANEL_ACTIVE'][0]) / 2, (I['WIN'][1] - I['PANEL_ACTIVE'][1]) / 2
    rep('window shows the active area', min(mx, my) >= 0.5, f'{mx:.2f} and {my:.2f} mm round it')
    # 7. docks
    dock_checks(I, M, rep)
    print(f"  {'ALL OK' if all(res) else 'PROBLEMS'} ({sum(res)}/{len(res)})")
    return all(res)

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('-D', action='append', default=[], help='OpenSCAD override, e.g. -D PCB_T=1.2')
    a = ap.parse_args()
    print('\n=== Wio Tracker L1 E-ink: fit test and case cores ===')
    sys.exit(0 if run(a.D) else 1)
