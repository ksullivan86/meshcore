"""Fit checks for the XIAO node case.

Renders the parts in their assembled positions (and the kit stand-ins) with OpenSCAD into
build/, then measures: boards, header pins and parts under the board against the case;
the plunger over each Wio button; the paperclip holes for B and R; the USB-C cable against its opening; the FPC in its pocket
and the cable lengths; the board bays (latch preload, tongue free, tilting the kit in under the hooks); the lid sliding home over the latch; the thinnest
webs in the front wall, the cap and the lid; and that every printed part is one piece.

    python3 cad/check_case.py               # 1, 2 and 3 bays
    python3 cad/check_case.py --bays 1 --fit   # the fit test
    python3 cad/check_case.py -D WIFI='"rpsma"'  # any OpenSCAD override, passed through

Needs OpenSCAD on the PATH and: pip install trimesh manifold3d numpy rtree ezdxf shapely
Run it from the xiao-node-case folder. build/ is ignored by git.
"""
import argparse, json, math, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
import warnings
import numpy as np, trimesh, ezdxf
warnings.filterwarnings('ignore', category=RuntimeWarning)
from shapely.geometry import Polygon, LineString
from shapely.ops import unary_union, polygonize

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, 'xiao-node-case.scad')
WEB_MIN = 0.8      # two 0.4 mm perimeters
SW_TRAVEL = 0.25   # a tactile switch's travel
STRAIN_MAX = 0.02  # flexures: bending strain at full press, PLA or PETG

def scad(part, out, defs):
    args = ['openscad', '-o', out, '-D', f'PART="{part}"'] + sum([['-D', d] for d in defs], [])
    if os.path.exists(out): os.remove(out)
    r = subprocess.run(args + [SCAD], capture_output=True, text=True)
    if 'top level object is empty' in r.stderr: return r.stderr   # nothing to make (e.g. no FPC with an RP-SMA)
    if r.returncode or 'ERROR' in r.stderr:
        sys.exit(f'OpenSCAD failed on {part}:\n{r.stderr[-2000:]}')
    return r.stderr

def build(tag, defs, fit):
    d = os.path.join(HERE, 'build', tag); os.makedirs(d, exist_ok=True)
    parts = ['a_body', 'a_cap', 'a_lid', 'd_boards', 'd_parts', 'd_pins', 'd_clips', 'd_fpc', 'd_plug', 'd_sma']
    if not fit: parts.append('a_plate')
    jobs = [(p, os.path.join(d, p + '.stl')) for p in parts] + \
           [(p, os.path.join(d, p + '.dxf')) for p in ('s_front', 's_cap')]
    with ThreadPoolExecutor(4) as ex:
        logs = list(ex.map(lambda j: scad(j[0], j[1], defs), jobs))
    m = re.search(r'xnc-chk: (\{.*\})"', logs[0])
    info = json.loads(m.group(1))
    meshes = {}
    for p, f in jobs:
        if f.endswith('.stl'):
            meshes[p] = trimesh.load(f, force='mesh') if os.path.exists(f) else None
    return info, meshes, {p: f for p, f in jobs if f.endswith('.dxf')}, logs[0]

def empty(m): return m is None or m.is_empty or len(m.faces) == 0
def inter(a, b):
    if empty(a) or empty(b): return None
    try: return trimesh.boolean.intersection([a, b], engine='manifold')
    except Exception: return None
def vol(m): return 0.0 if empty(m) else abs(m.volume)
def gap(a, b, n=4000):
    """Smallest distance from a's surface to b's (approximate, sampled); negative if they overlap."""
    if empty(a) or empty(b): return float('inf')
    if vol(inter(a, b)) > 1e-3: return -1.0
    pts = np.vstack([a.sample(n), a.vertices])
    _, dist, _ = trimesh.proximity.closest_point(b, pts)
    return float(dist.min())

def dxf_polys(path):
    """Closed outlines from an OpenSCAD DXF section, as shapely polygons (material = outers minus holes)."""
    doc = ezdxf.readfile(path); lines = []
    for e in doc.modelspace():
        if e.dxftype() == 'LINE': lines.append(LineString([(e.dxf.start.x, e.dxf.start.y), (e.dxf.end.x, e.dxf.end.y)]))
        elif e.dxftype() == 'LWPOLYLINE':
            pts = [(p[0], p[1]) for p in e.get_points()]
            if e.closed: pts.append(pts[0])
            lines.append(LineString(pts))
    shells = {}
    for p in polygonize(unary_union(lines)):   # every face, holes included, as its outline
        q = Polygon(p.exterior); shells[(round(q.area, 3), tuple(np.round(q.centroid.coords[0], 2)))] = q
    return list(shells.values())

def webs(path, ignore_below=0.05):
    """Thinnest material between neighbouring openings (and between an opening and the edge) in a section."""
    rings = dxf_polys(path)
    if not rings: return None
    # material = symmetric build: outers contain holes; even-odd by containment depth
    rings.sort(key=lambda r: -r.area)
    depth = [sum(1 for o in rings if o is not r and o.area > r.area and o.contains(r.representative_point())) for r in rings]
    outers = [r for r, k in zip(rings, depth) if k % 2 == 0]
    holes = [r for r, k in zip(rings, depth) if k % 2 == 1]
    best = (float('inf'), '')
    for i, h in enumerate(holes):
        for j, g in enumerate(holes[i + 1:]):
            dd = h.distance(g)
            if ignore_below < dd < best[0]: best = (dd, f'between openings at {np.round(h.centroid.coords[0], 1).tolist()} and {np.round(g.centroid.coords[0], 1).tolist()}')
        for o in outers:
            if o.contains(h.representative_point()):
                dd = o.exterior.distance(h.exterior)
                if ignore_below < dd < best[0]: best = (dd, f'opening at {np.round(h.centroid.coords[0], 1).tolist()} to the edge')
    return best

def ray_gap(mesh, origin, direction):
    """Distance along a ray from origin to the first hit on mesh."""
    loc, _, _ = mesh.ray.intersects_location([origin], [direction], multiple_hits=True)
    if len(loc) == 0: return float('inf')
    return float(min(np.linalg.norm(l - np.array(origin)) for l in loc))

def box(x0, x1, y0, y1, z0, z1): return trimesh.creation.box(bounds=[[x0, y0, z0], [x1, y1, z1]])

def bays_check(I, M, rep, boards, parts, pins):
    body = M['a_body']; G, PRE, PW = I['BAY_GAP'], I['BAY_PRE'], 2.6
    e, t0, t1, d = I['LATCH']; W, H = I['KIT']
    for i in range(I['BAYS']):
        ox, oy = I['BX0'] + i * I['P'], I['BY'] + G          # the bay's nominal corner
        def tb(ta, tb_, na, nb, z0, z1):                      # a box in the latch edge's frame ("T": u = t, v = H + n)
            return box(ox + ta, ox + tb_, oy + H + na, oy + H + nb, z0, z1)
        pil = tb(t0 - 0.01, t1 + 0.01, -G - PRE - 1.0, -G - PRE + PW + 0.01, -0.01, I['ZB'] + I['XIAO_T'] + 0.15 + 1.4 + 0.1)
        rest = trimesh.boolean.difference([body, pil], engine='manifold')
        mine = box(ox - 3, ox + W + 3, -50, 200, -50, 200)
        bd = inter(boards, mine)
        pre = vol(inter(bd, body)); clash = vol(inter(bd, rest)) + vol(inter(inter(trimesh.util.concatenate([parts, pins]), mine), body))
        rep(f'bay {i + 1}: only the latch touches the kit', clash < 0.01 and 0.05 < pre < 1.0,
            f'latch preload {pre:.2f} mm3 ({PRE} mm), everything else {clash:.3f} mm3')
        # tongue: cut it just short of its root; it and the pillar should come away as their own body
        tr = (t1 - I['BAY_TL'], t1) if d < 0 else (t0, t0 + I['BAY_TL'])
        ra = (tr[0] + 0.5, tr[0] + 1.5) if d < 0 else (tr[1] - 1.5, tr[1] - 0.5)
        cut = tb(ra[0], ra[1], -G - PRE - 0.05, -G - PRE + PW + 0.05, -10, 0.5)
        n0 = len(body.split(only_watertight=False))
        n1 = len(trimesh.boolean.difference([body, cut], engine='manifold').split(only_watertight=False))
        rep(f'bay {i + 1}: latch tongue free to its root', n1 == n0 + 1, f'{n1 - n0} more piece(s) when cut at the root')
        # tilt in: front edge pushed into the hooks, back raised, then lowered; may slide back a little while tilted
        kit = inter(trimesh.util.concatenate([boards, parts, pins]), mine)
        span = H; th_max = math.degrees(math.asin((I['XIAO_T'] + 0.15 + 1.4 + 0.3) / span)); worst = 0
        for th in np.linspace(th_max, 0.5, 8):
            best = 1e9
            for off in (0, 0.2, 0.4, 0.6, 0.8):
                k2 = kit.copy()
                k2.apply_transform(trimesh.transformations.rotation_matrix(math.radians(th), [1, 0, 0], [0, oy - G, I['ZB']]))
                k2.apply_translation([0, off, 0])
                best = min(best, vol(inter(k2, rest)))
                if best < 0.01: break
            worst = max(worst, best)
        rep(f'bay {i + 1}: kit tilts in under the hooks', worst < 0.05, f'{th_max:.1f} deg to 0, worst overlap {worst:.3f} mm3')

def run(tag, defs, fit):
    print(f'\n=== {tag} ===')
    I, M, D, log = build(tag, defs, fit)
    for l in log.splitlines():
        if 'xnc:' in l: print('  ' + l.split('"')[1])
    res = []
    def rep(name, ok, detail):
        res.append(ok); print(f"  {'PASS' if ok else 'FAIL'}  {name}: {detail}")
    printed = {k: M[k] for k in ('a_body', 'a_cap', 'a_lid', 'a_plate') if not empty(M.get(k))}   # the fit test has no lid or plate
    # 1. every printed part is one piece (the buttons: one per button, on their spine when printed)
    for k, m in printed.items():
        n = len(m.split(only_watertight=False))
        rep(f'{k[2:]} is one piece', n == 1 and m.is_watertight, f'{n} bodies, watertight {m.is_watertight}')
    # 2. the kit against the case: nothing touches but the pads (boards resting on them) and the button feet
    boards, parts, pins = M['d_boards'], M['d_parts'], M['d_pins']
    for k in ('a_body', 'a_cap', 'a_lid', 'a_plate'):
        if k not in M: continue
        v = (vol(inter(boards, M[k])) if k != 'a_body' else 0) + vol(inter(parts, M[k])) + vol(inter(pins, M[k]))
        rep(f'kit clear of the {k[2:]}', v < 0.01, f'overlap {v:.3f} mm3' + (' (boards against the body: see the latch below)' if k == 'a_body' else ''))
    g = gap(pins, M['a_body']); rep('header pins clear of the floor and pads', g >= 0.4, f'{g:.2f} mm (want 0.4+)')
    g = gap(parts, M['a_body']); rep('parts on the boards clear of the body', g >= 0.1, f'{g:.2f} mm (the header plastic runs to the board edge; stops sit 0.2 off it)')
    g = gap(parts, M['a_cap']); rep('parts on the boards clear of the cap (nubs aside)', g >= 0.2, f'{g:.2f} mm')
    # board bays (as tahoe-repeater/cad/check_bays.py): the latch is the only thing that touches the boards,
    # the tongue is free to its root, and the kit tilts in under the hooks
    bays_check(I, M, rep, boards, parts, pins)
    # 3. plungers: gap from each nub to its button, and what pressing takes
    for i in range(I['BAYS']):
        bx = I['BX0'] + i * I['P']
        for (u, v, h) in I['PLUNGERS']:
            top = [bx + u, I['BY'] + v, I['ZB'] + h + 0.001]
            gz = ray_gap(M['a_cap'], top, [0, 0, 1])
            press = gz + SW_TRAVEL
            strain = 1.5 * I['TAB_T'] * press / (I['TAB_L'] - 1.5) ** 2
            rep(f'bay {i + 1} plunger over the Wio button', 0.15 <= gz <= 0.6 and strain <= STRAIN_MAX,
                f'gap {gz:.2f} mm, press {press:.2f} mm, tab strain {strain*100:.1f} %')
    # paperclips for B and R: through their holes to the button, touching nothing else
    clips = M['d_clips']
    vb = vol(inter(clips, M['a_body'])); vk = vol(inter(clips, boards)) + vol(inter(clips, parts))
    pushed = []   # each clip pushed 1.2 mm further along its hole: it should meet its button
    for part in clips.split(only_watertight=False):
        k = 0 if part.centroid[0] - I['BX0'] - I['P'] * round((part.centroid[0] - I['BX0']) // I['P']) < I['USB_U'] else 1
        e, t = np.array(I['CLIP_IN'][k]), np.array(I['CLIPS'][k]); dvec = (t - e) / np.linalg.norm(t - e)
        q = part.copy(); q.apply_translation(1.2 * dvec); pushed.append(q)
    reach = vol(inter(trimesh.util.concatenate(pushed), parts))
    ang = [math.degrees(math.atan2(e[2] - t[2], math.hypot(t[0] - e[0], t[1] - e[1]))) for e, t in zip(I['CLIP_IN'], I['CLIPS'])]
    rep('paperclips reach B and R', vb < 0.01 and vk < 0.01 and reach > 0.005,
        f'clear of the case {vb:.3f} and of the kit {vk:.3f} mm3, meets the button {reach:.3f} mm3, {ang[0]:.0f} deg down')
    g = gap(clips, M['a_body'], 2000); rep('paperclip holes clear round a 0.9 mm clip', g >= 0.15, f'{g:.2f} mm')
    # 4. USB-C: a normal cable's boot and plug go in without touching the case
    g = min(gap(M['d_plug'], M['a_body']), gap(M['d_plug'], M['a_cap']))
    rep('USB-C cable boot clear of the opening', g >= 0.25, f'{g:.2f} mm round an 11.5 x 6.5 boot')
    # 5. antennas
    if not empty(M['d_fpc']):
        rep('FPC sits in its pocket', vol(inter(M['d_fpc'], M['a_body'])) < 0.01, f'overlap {vol(inter(M["d_fpc"], M["a_body"])):.3f} mm3')
        bx = I['BX0']
        a = np.array([bx + I['WIFI_UFL'][0], I['BY'] + I['WIFI_UFL'][1], I['ZX'] + 1.2])   # the XIAO's U.FL, under the Wio
        b = np.array([bx + I['KIT'][0] + 1.0, a[1], a[2]])                                   # out from under its right edge
        c = np.array([bx + I['SPOOL_P'][0], I['BY'] + I['SPOOL_P'][1], I['ZB'] - 3.0])        # down to the spool
        e = np.array([I['FPC_X0'], I['FPC_Y'] + I['FPC'][0] / 2, I['FPC_Z0'] + I['FPC'][1]])   # to the FPC's top edge
        L = sum(np.linalg.norm(q - p) for p, q in ((a, b), (b, c), (c, e)))
        slack = I['FPC_CABLE'] - L; wrap = 2 * math.pi * (I['SPOOL'][0] + 0.6)
        rep('FPC cable reaches its U.FL', slack >= 3, f'route {L:.0f} mm, cable {I["FPC_CABLE"]} mm, slack {slack:.0f} mm '
            f'({max(0, slack) / wrap:.1f} turns round the spool)')
    if not empty(M['d_sma']):
        bx = I['BX0']; x = I['LORA_X'][0]
        a = np.array([bx + I['LORA_UFL'][0], I['BY'] + I['LORA_UFL'][1], I['ZW'] + I['LORA_UFL_H'] - 0.6])   # on top of the Wio
        b = np.array([a[0], I['BY'] + I['KIT'][1] + 3.0, a[2]])
        c = np.array([x, I['D_IN'] - 9.0, I['SMA_Z']])
        L = np.linalg.norm(b - a) + np.linalg.norm(c - b)
        zone = I['D_IN'] - 9.0 - (I['BY'] + I['KIT'][1] + 3.0)
        rep('LoRa pigtail reaches its SMA', I['PIGTAIL'] >= L + 3, f'route {L:.0f} mm, pigtail {I["PIGTAIL"]} mm, '
            f'{I["PIGTAIL"] - L:.0f} mm to coil in the back of the bay ({zone:.0f} mm deep there)')
        g = min(gap(M['d_sma'], M['a_lid']), gap(M['d_sma'], M['a_cap']))
        rep('SMA nuts clear of the cap and lid', g >= 0.3, f'{g:.2f} mm')
    if not empty(M.get('a_lid')):   # the case, not the fit test
        # 7. cap and lid sit on the body without overlapping it
        for k in ('a_cap', 'a_lid'):
            v = vol(inter(M[k], M['a_body'])); rep(f'{k[2:]} clear of the body', v < 0.01, f'overlap {v:.3f} mm3')
        v = vol(inter(M['a_cap'], M['a_lid'])); rep('lid and cap clear when shut', v < 0.01, f'overlap {v:.3f} mm3')
        # 8. latch: slide the lid on from open; the arm may only meet the post, and only as far as it can flex
        worst, where = 0.0, None
        for dy in np.arange(14.0, 0.0, -0.25):
            l2 = M['a_lid'].copy(); l2.apply_translation([0, dy, 0])
            vb = vol(inter(l2, M['a_body']))
            x = inter(l2, M['a_cap'])
            if vb > 0.01: worst, where = 99, f'lid hits the body at {dy:.2f} mm open'; break
            if not empty(x) and vol(x) > 0.001:
                dx = x.bounds[1][0] - x.bounds[0][0]
                if dx > worst: worst, where = dx, f'{dy:.2f} mm open'
        room = I['LT_SLOT'] - 0.2
        rep('lid slides home over the latch', worst <= room and worst >= I['LT_HOOK_DEPTH'] - 0.3,
            f'arm pushed out {worst:.2f} mm (room {room:.2f}) at {where}')
        l2 = M['a_lid'].copy(); l2.apply_translation([0, 0.5, 0])
        rep('latch holds the lid shut', vol(inter(l2, M['a_cap'])) > 0.05, f'pulled back 0.5 mm: hook meets post, {vol(inter(l2, M["a_cap"])):.2f} mm3')
    # 9. thinnest webs
    for k, nm in (('s_front', 'front wall (inner half)'), ('s_cap', 'cap (tab level)')):
        w = webs(D[k])
        if w: rep(f'thinnest web in the {nm}', w[0] >= WEB_MIN, f'{w[0]:.2f} mm, {w[1]}')
    print(f"  {'ALL OK' if all(res) else 'PROBLEMS'} ({sum(res)}/{len(res)})")
    return all(res)

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--bays', default='all')
    ap.add_argument('--fit', action='store_true', help='check the fit test (one bay, no base plate)')
    ap.add_argument('-D', action='append', default=[], help='OpenSCAD override, e.g. -D STACK_H=8.6')
    a = ap.parse_args()
    bays = [1, 2, 3] if a.bays == 'all' else [int(b) for b in a.bays.split(',')]
    ok = True
    for n in bays:
        defs = [f'BAYS={n}'] + (['FIT=true'] if a.fit else []) + a.D
        ok &= run(f'{"fit" if a.fit else "case"}-{n}bay', defs, a.fit)
    sys.exit(0 if ok else 1)
