"""Draws the pictures in images/ from the meshes cad/check_case.py builds.

    python cad/check_case.py      # builds build/check/*.stl (the parts where they sit)
    python cad/export.py --fit    # the fit test STL, for its picture
    python cad/render.py          # images/*.png

The 3D views are OpenSCAD previews of those meshes (imported meshes preview cleanly, unlike the
CSG itself); the cross-sections are cut from the same meshes. Labels are placed by hand for these
camera angles: if you move a camera, move its labels too. Needs OpenSCAD, and: pip install trimesh
numpy shapely pillow. Run it from the project folder.
"""
import os, shutil, subprocess, sys, tempfile, json, re
import numpy as np, trimesh
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..')
B = os.path.join(ROOT, 'build', 'check')
OUT = os.path.join(ROOT, 'images')

def openscad():
    for c in (os.environ.get('OPENSCAD'), shutil.which('openscad'), r'C:\Program Files\OpenSCAD\openscad.com',
              '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'):
        if c and os.path.exists(c): return c
    sys.exit('OpenSCAD not found: put it on the PATH or set OPENSCAD')

# ---------------------------------------------------------------- colours
SHELL, FRONT, TRAY, BOARD = [0.78, 0.79, 0.82], [0.30, 0.42, 0.62], [0.93, 0.62, 0.22], [0.13, 0.50, 0.27]
CELL, STRAP, PANEL, DOOR = [0.42, 0.56, 0.86], [0.12, 0.12, 0.12], [0.90, 0.90, 0.86], [0.80, 0.30, 0.28]
TB, ADAPT, PARTS = [0.97, 0.80, 0.22], [0.10, 0.36, 0.20], [0.25, 0.25, 0.25]

def scene(items, name, camera, size=(1400, 1000), ortho=True):
    """items: [(mesh file, colour, [dx, dy, dz], alpha)]; renders an OpenSCAD preview to name (in the scratch dir)."""
    lines = []
    for f, c, d, a in items:
        p = os.path.abspath(f if os.path.isabs(f) else os.path.join(B, f)).replace('\\', '/')
        lines.append(f'translate({list(d)}) color({list(c) + [a]}) import("{p}");')
    with tempfile.TemporaryDirectory() as t:
        s = os.path.join(t, 'scene.scad'); open(s, 'w').write('\n'.join(lines))
        out = os.path.join(TMP, name)
        r = subprocess.run([openscad(), '-o', out, '--imgsize=%d,%d' % size, '--colorscheme=Tomorrow',
                            '--camera=' + ','.join(str(v) for v in camera)] + (['--projection=ortho'] if ortho else []) + [s],
                           capture_output=True, text=True)
        if r.returncode or not os.path.exists(out): sys.exit(f'OpenSCAD failed on {name}:\n{(r.stdout + r.stderr)[-1500:]}')
    return Image.open(out).convert('RGB')

# ---------------------------------------------------------------- labels
def font(n):
    for f in (r'C:\Windows\Fonts\arial.ttf', '/System/Library/Fonts/Supplemental/Arial.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'):
        if os.path.exists(f): return ImageFont.truetype(f, n)
    return ImageFont.load_default()
F, FT = font(22), font(30)
INK = (25, 25, 25)

def label(d, text, at, to):
    """text with its top-left at 'at', and a line to the point 'to'"""
    box = d.multiline_textbbox(at, text, font=F, spacing=2)
    d.rectangle([box[0] - 6, box[1] - 4, box[2] + 6, box[3] + 4], fill=(255, 255, 255), outline=INK)
    d.multiline_text(at, text, font=F, fill=INK, spacing=2)
    if to is None: return
    cx = min(max(to[0], box[0]), box[2]); cy = box[3] + 4 if to[1] > box[3] else box[1] - 4 if to[1] < box[1] else (box[1] + box[3]) // 2
    if box[0] <= to[0] <= box[2] and box[1] <= to[1] <= box[3]: return
    if box[1] <= to[1] <= box[3]: cx = box[2] + 6 if to[0] > box[2] else box[0] - 6; cy = to[1]
    d.line([cx, cy, to[0], to[1]], fill=INK, width=3); d.ellipse([to[0] - 5, to[1] - 5, to[0] + 5, to[1] + 5], fill=INK)

def title(d, text, at=(24, 16)): d.text(at, text, font=FT, fill=INK)

def save(im, name): im.save(os.path.join(OUT, name)); print(name, im.size)

# ---------------------------------------------------------------- cross-sections, cut from the meshes
def section_shells(mesh, origin, normal, axes):
    """the mesh cut by a plane: its outlines as (shapely polygon, nesting depth), largest first. Even depth is material."""
    from shapely.geometry import Polygon, LineString
    from shapely.ops import unary_union, polygonize
    s = mesh.section(plane_origin=origin, plane_normal=normal)
    if s is None: return []
    segs = [LineString([(p[axes[0]], p[axes[1]]) for p in d]) for d in s.discrete]
    shells = {}
    for p in polygonize(unary_union(segs)):
        q = Polygon(p.exterior); shells[(round(q.area, 3), tuple(np.round(q.centroid.coords[0], 2)))] = q
    shells = sorted(shells.values(), key=lambda q: -q.area)
    return [(q, sum(1 for o in shells if o is not q and o.area > q.area and o.contains(q.representative_point()))) for q in shells]

def draw_section(parts, origin, normal, axes, scale, offset, size, flip=(1, -1)):
    """parts: [(mesh file, colour)], drawn in order, so later parts sit on top of earlier ones' holes"""
    BG = (248, 248, 248)
    im = Image.new('RGB', size, BG); d = ImageDraw.Draw(im)
    def P(u, v): return (offset[0] + flip[0] * u * scale, offset[1] + flip[1] * v * scale)
    for f, c in parts:
        m = trimesh.load(os.path.join(B, f), force='mesh')
        for q, depth in section_shells(m, origin, normal, axes):
            d.polygon([P(*xy) for xy in q.exterior.coords], fill=tuple(int(255 * x) for x in c) if depth % 2 == 0 else BG)
    return im, d, P

def main():
    global TMP
    os.makedirs(OUT, exist_ok=True)
    TMP = tempfile.mkdtemp()
    info = json.loads(open(os.path.join(B, 'info.json')).read()) if os.path.exists(os.path.join(B, 'info.json')) else None
    for name in sys.argv[1:] or ['all']:
        for k, fn in JOBS.items():
            if name in ('all', k): fn()

JOBS = {}
def job(f): JOBS[f.__name__] = f; return f

# ---------------------------------------------------------------- the pictures
CLOSED = [('a_shell.stl', SHELL, (0, 0, 0), 1), ('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1)]

SHELL_IN = [('a_shell.stl', SHELL, (0, 0, 0), 1), ('d_cell.stl', CELL, (0, 0, 0), 1), ('d_strap.stl', STRAP, (0, 0, 0), 1)]
TRAY_IN = [('a_tray_full.stl', TRAY, (0, 0, 0), 1), ('d_board.stl', BOARD, (0, 0, 0), 1)]
FRONT_IN = [('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_door.stl', DOOR, (0, 0, 0), 1),
            ('a_tb.stl', TB, (0, 0, 0), 1), ('d_adapter.stl', ADAPT, (0, 0, 0), 1)]
SECTION_PARTS = [('a_shell.stl', SHELL), ('a_front_full.stl', FRONT), ('a_tray_full.stl', TRAY), ('d_cell.stl', CELL), ('d_strap.stl', STRAP),
                 ('d_board.stl', BOARD), ('d_under.stl', PARTS), ('d_panel.stl', PANEL), ('a_door.stl', DOOR), ('d_adapter.stl', ADAPT), ('a_tb.stl', TB)]
def up(items, dz): return [(f, c, (d[0], d[1], d[2] + dz), a) for f, c, d, a in items]
def flip(items):   # the front, turned over to show its inside: mirrored about y = 46, z = 27
    return [(f, c, d, a, 'flip') for f, c, d, a in items]

@job
def raw():   # every view without labels, for placing labels
    views = {
        'hero': (CLOSED, (28, 46, 14, 38, 0, 15, 230)),
        'open': (SHELL_IN + up(TRAY_IN, 24) + up(FRONT_IN, 52), (28, 46, 30, 58, 0, 22, 330)),
        'tray': ([('a_tray_full.stl', TRAY, (0, 0, 0), 1)], (28, 46, 15, 35, 0, 20, 250)),
        'tray_board': (TRAY_IN, (28, 46, 15, 35, 0, 20, 250)),
        'screen_open': ([('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_tb_open.stl', TB, (0, 0, 0), 1),
                         ('d_adapter.stl', ADAPT, (0, 0, 0), 1)], (28, 46, 24, 145, 0, 180, 250)),
        'screen_shut': ([('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_door.stl', DOOR, (0, 0, 0), 1),
                         ('a_tb.stl', TB, (0, 0, 0), 1), ('d_adapter.stl', ADAPT, (0, 0, 0), 1)], (28, 46, 24, 145, 0, 180, 250)),
        'fit': ([(os.path.join(ROOT, 'stl', 'wio-tracker-l1-eink-fit-test.stl'), [0.93, 0.62, 0.22], (0, 0, 0), 1)], (83, 34, 0, 30, 0, 0, 330)),
    }
    for k, (items, cam) in views.items():
        scene(items, k + '.png', cam).save(os.path.join(OUT, '_raw_' + k + '.png'))
    for k, (origin, normal, axes, scale, offset, size, flip) in {
            'section_long': ((23.5, 0, 0), (1, 0, 0), (1, 2), 15, (60, 520), (1500, 640), (1, -1)),
            'section_strap': ((0, 41.8, 0), (0, 1, 0), (0, 2), 24, (90, 760), (1500, 860), (1, -1))}.items():
        im, d, P = draw_section(SECTION_PARTS, origin, normal, axes, scale, offset, size, flip)
        im.save(os.path.join(OUT, '_raw_' + k + '.png'))

if __name__ == '__main__':
    main()
