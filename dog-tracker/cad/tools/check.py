#!/usr/bin/env python3
"""Fit and integrity checks on the exported parts (run cad/tools/export.py --parts first).

    python3 cad/tools/check.py [variant ...]

Loads build/<variant>/*.stl (assembled pose) and reports:
  - each printed part is watertight and in one piece
  - overlaps between printed parts, and between parts and the stand-ins
    (boards, cell, washer, spring, nickel strips, O-rings, strap)
  - the gaps that matter
  - swap: that the cap screws off along its thread without hitting the
    barrel or the pod, the cell slides out, the washer goes into the cap,
    the barrel drops into its trough, the washer lands on the strip, the
    battery wires' hole from the potting pocket opens fully into the
    compartment, and the magnetic connector stays clear of the lid and the
    XIAO wherever it sits in its opening
  - that the lid and its O-ring push in without hitting anything
Needs: pip install manifold3d trimesh numpy
"""
import itertools, json, os, sys
import numpy as np
import trimesh
import manifold3d as m3
from manifold3d import Manifold as M

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PRINTED = ('pod', 'lid', 'barrel', 'cap')
LEAD = 4.0                  # the cap's thread: 2 starts, 2 mm apart
TOL = 2e-3                  # mm3: overlaps smaller than this are touching faces


def load(path):
    tm = trimesh.load(path, force='mesh')
    tm.merge_vertices()
    man = M(m3.Mesh(vert_properties=np.asarray(tm.vertices, np.float32), tri_verts=np.asarray(tm.faces, np.uint32)))
    return tm, man


def vol(m):
    return 0.0 if m.is_empty() else m.volume()


def gap(a, b, search=3.0):
    try:
        return round(a.min_gap(b, search), 3)
    except Exception:
        return None


def bbox(m):
    b = m.bounding_box()
    return np.array(b[:3]), np.array(b[3:])


def turn(m, axis_x, axis_z, deg, dy):
    """Rotate m about the line x = axis_x, z = axis_z (parallel to Y) and move it dy along Y."""
    a = np.radians(deg)
    c, s = np.cos(a), np.sin(a)
    # rotation about +Y: (x, z) -> (x c + z s, -x s + z c)
    R = [[c, 0, s, 0], [0, 1, 0, 0], [-s, 0, c, 0]]
    return m.translate((-axis_x, 0, -axis_z)).transform(R).translate((axis_x, dy, axis_z))


def info(d):
    """The numbers the SCAD file echoes for the checks (build/<variant>/info.echo)."""
    out = {'r2': []}
    p = os.path.join(d, 'info.echo')
    if os.path.exists(p):
        for line in open(p):
            line = line.strip()
            if line.startswith('ECHO: "r2check: '):
                out.update(json.loads(line[len('ECHO: "r2check: '):-1]))
            elif line.startswith('ECHO: "r2: '):
                out['r2'].append(line[len('ECHO: "'):-1])
    return out


def check(variant):
    d = os.path.join(ROOT, 'build', variant)
    nums = info(d)
    parts, dm, tms = {}, {}, {}
    for f in sorted(os.listdir(d)):
        if not f.endswith('.stl'):
            continue
        name = f[:-4]
        tm, man = load(os.path.join(d, f))
        if name.startswith('dummy_'):
            if not man.is_empty():
                dm[name[6:]] = man
        else:
            parts[name] = man
            tms[name] = tm
    swap = 'barrel' in parts
    r = {}
    # 1 integrity
    r['parts'] = {k: dict(watertight=bool(tms[k].is_watertight), bodies=len(tms[k].split(only_watertight=False)),
                          volume_cm3=round(v.volume() / 1000, 2), grams_petg=round(v.volume() / 1000 * 1.27, 1))
                  for k, v in parts.items()}
    # 2 overlaps between printed parts
    r['part_overlaps_mm3'] = {f'{a} x {b}': round(v, 3) for a, b in itertools.combinations(parts, 2)
                              if (v := vol(parts[a] ^ parts[b])) > TOL}
    # 3 stand-ins against parts, and against each other
    clash = {}
    for k, m in dm.items():
        for p, pm in parts.items():
            if (v := vol(m ^ pm)) > TOL:
                clash[f'{k} x {p}'] = round(v, 3)
    for a, b in itertools.combinations(dm, 2):
        if (v := vol(dm[a] ^ dm[b])) > TOL:
            clash[f'{a} x {b}'] = round(v, 3)
    r['standin_overlaps_mm3'] = clash
    # 4 gaps
    g = {}
    for k in ('xiao', 'patch', 'l76k', 'pogo', 'fpc'):
        if k in dm:
            g[f'{k}_to_pod'] = gap(dm[k], parts['pod'])
            g[f'{k}_to_lid'] = gap(dm[k], parts['lid'])
    g['lid_to_pod'] = gap(parts['lid'], parts['pod'])
    if swap:
        pod, lid, barrel, cap = (parts[k] for k in PRINTED)
        lo, hi = bbox(cap)
        ax, az = (lo[0] + hi[0]) / 2, (lo[2] + hi[2]) / 2          # the cap is round: its middle is the barrel's axis
        g['barrel_to_pod'] = gap(barrel, pod)
        g['cap_to_pod'] = gap(cap, pod)
        g['cap_to_barrel'] = gap(cap, barrel)
        g['cap_to_strap'] = gap(cap, dm['strap'], 6.0)
        g['cell_to_barrel'] = gap(dm['cell'], barrel)
        g['washer_to_strip'] = gap(dm['washer'], dm['strip_neg'])
        g['washer_to_cap'] = gap(dm['washer'], cap)
        # the cap screws off: turn it back along the helix and pull it out
        hits = []
        for dy in np.arange(0.25, 14.0, 0.25):
            moved = turn(cap, ax, az, dy * 360 / LEAD, dy)
            v = vol(moved ^ barrel) + vol(moved ^ pod)
            if v > TOL:
                hits.append((round(float(dy), 2), round(v, 3)))
        r['cap_unscrew_hits'] = hits[:8]
        # the same move without turning must hit the thread (it's a real thread)
        # (half a ridge spacing: a whole one would land the cap on the other start)
        r['cap_pull_without_turning_blocked'] = vol(cap.translate((0, 1.0, 0)) ^ barrel) > 1.0
        # with the cap off, the cell slides out of the mouth
        r['cell_slide_out_hits'] = [round(float(dy), 1) for dy in np.arange(0.5, 50, 1.0)
                                    if vol(dm['cell'].translate((0, dy, 0)) ^ barrel) > TOL][:5]
        # the washer goes into the cap through its thread and seal bore
        r['washer_in_hits'] = [round(float(dy), 1) for dy in np.arange(0.5, 16, 0.5)
                               if vol(dm['washer'].translate((0, -dy, 0)) ^ cap) > TOL][:5]
        # the barrel drops into its trough from the back
        r['barrel_in_hits'] = [round(float(dz), 1) for dz in np.arange(0.5, 26, 0.5)
                               if vol(barrel.translate((0, 0, -dz)) ^ pod) > TOL][:5]
        # the cap's clearance from the strap region and the bridge
        r['cap_below_back_mm'] = round(-lo[2], 2)
        if 'X_B' in nums:
            # the battery wires' slot: a box 0.2 mm inside it, from the middle of the
            # pocket to 6 mm inside the compartment, must not touch the pod, the lid or a board
            w, h = nums['WIRE_SLOT'][0] / 2 - 0.2, nums['WIRE_SLOT'][1] / 2 - 0.2
            L = nums['X_D'] + 6 - nums['X_B']
            yc, zc = nums['Y_E'] - nums['POCKET'] / 2, nums['WIRE_HOLE_Z']
            rod = M.cube((L, 2 * w, 2 * h)).translate((nums['X_B'], yc - w, zc - h))
            r['wire_hole_blocked_mm3'] = round(vol(rod ^ pod) + vol(rod ^ lid), 3)
            r['wire_hole_into_boards_mm3'] = {k: round(v, 3) for k in ('l76k', 'patch', 'xiao', 'fpc')
                                              if k in dm and (v := vol(rod ^ dm[k])) > TOL}
            r['walls_mm'] = {k: round(nums[k], 2) for k in ('POCKET_WALL', 'LID_CORNER_WALL') if k in nums}
            # the magnetic connector (exported in the middle of its opening) pushed
            # to the top of the opening, toward the outer face, and to the bottom,
            # toward the lid: it must clear the XIAO, the lid and the pod
            play = (nums['POGO_FACE'][1] - nums['POGO_BODY'][1]) / 2
            top, bot = dm['pogo'].translate((0, 0, play)), dm['pogo'].translate((0, 0, -play))
            r['pogo_top_hits_mm3'] = {k: round(v, 3) for k, v in
                                     (('pod', vol(top ^ pod)), ('xiao', vol(top ^ dm['xiao'])),
                                      ('pod (bottom)', vol(bot ^ pod)), ('lid (bottom)', vol(bot ^ lid))) if v > TOL}
            g['pogo_top_to_xiao'] = gap(top, dm['xiao'])
            g['pogo_bottom_to_lid'] = gap(bot, lid)
    else:
        g['cell_to_lid'] = gap(dm['cell'], parts['lid'])
        g['cell_to_body'] = gap(dm['cell'], parts['pod'])
    # 5 the lid and its O-ring push in along +Z
    r['lid_push_in_hits'] = [round(float(dz), 1) for dz in np.arange(0.0, 20, 0.5)
                             if vol(parts['lid'].translate((0, 0, -dz)) ^ parts['pod']) > TOL][:5]
    r['oring_push_in_hits'] = [round(float(dz), 1) for dz in np.arange(0.2, 20, 0.5)
                               if vol(dm['oring'].translate((0, 0, -dz)) ^ parts['pod']) > TOL][:5]
    r['gaps_mm'] = g
    r['console'] = nums['r2']
    return r


def verdict(r):
    bad = []
    for k, v in r['parts'].items():
        if not v['watertight'] or v['bodies'] != 1:
            bad.append(f'{k} not one watertight body')
    for key in ('part_overlaps_mm3', 'standin_overlaps_mm3', 'lid_push_in_hits', 'oring_push_in_hits',
                'cap_unscrew_hits', 'cell_slide_out_hits', 'washer_in_hits', 'barrel_in_hits', 'pogo_top_hits_mm3'):
        if r.get(key):
            bad.append(f'{key}: {r[key]}')
    if r.get('wire_hole_blocked_mm3', 0) > TOL:
        bad.append(f"wire hole blocked: {r['wire_hole_blocked_mm3']} mm3")
    if r.get('wire_hole_into_boards_mm3'):
        bad.append(f"wire hole opens into a board: {r['wire_hole_into_boards_mm3']}")
    if 'washer_to_strip' in r.get('gaps_mm', {}) and (r['gaps_mm']['washer_to_strip'] or 0) > 0.01:
        bad.append(f"washer doesn't reach the - strip: {r['gaps_mm']['washer_to_strip']} mm")
    g = r.get('gaps_mm', {})
    for k in ('pogo_to_lid', 'pogo_bottom_to_lid', 'xiao_to_lid'):
        if g.get(k) is not None and g[k] < 0.2:
            bad.append(f'{k} only {g[k]} mm')
    if 'cap_pull_without_turning_blocked' in r and not r['cap_pull_without_turning_blocked']:
        bad.append('cap comes off without turning')
    return bad


if __name__ == '__main__':
    b = os.path.join(ROOT, 'build')
    variants = sys.argv[1:] or sorted(v for v in os.listdir(b) if os.path.exists(os.path.join(b, v, 'pod.stl')) and os.path.exists(os.path.join(b, v, 'lid.stl')))
    out = {}
    for v in variants:
        res = check(v)
        res['problems'] = verdict(res)
        out[v] = res
        print(f"{v}: {'PASS' if not res['problems'] else 'FAIL ' + '; '.join(res['problems'])}", file=sys.stderr)
    print(json.dumps(out, indent=1, default=str))
