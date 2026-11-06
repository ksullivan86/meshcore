"""Draws the pictures in images/ from the meshes cad/check_case.py builds.

    python cad/check_case.py      # builds build/check/*.stl: every part where it sits
    python cad/export.py --fit    # the fit test STL, for its picture
    python cad/render.py          # images/*.png
    python cad/render.py inside   # just one of them (hero, open_case, inside, screen, sections, fit_test)

The 3D views are OpenSCAD previews of those meshes (imported meshes preview cleanly, unlike the CSG
itself), and the cross-sections are cut from the same meshes. Labels are placed by hand for these
camera angles: if you move a camera, move its labels too.

Needs OpenSCAD (on the PATH, or set OPENSCAD to its executable) and:
    pip install trimesh numpy shapely pillow
Run it from the project folder.
"""
import os, shutil, subprocess, sys, tempfile
import numpy as np, trimesh
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..')
B = os.path.join(ROOT, 'build', 'check')
OUT = os.path.join(ROOT, 'images')
TMP = tempfile.mkdtemp()

def openscad():
    for c in (os.environ.get('OPENSCAD'), shutil.which('openscad'), r'C:\Program Files\OpenSCAD\openscad.com',
              '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'):
        if c and os.path.exists(c): return c
    sys.exit('OpenSCAD not found: put it on the PATH or set OPENSCAD')

# ---------------------------------------------------------------- colours
SHELL, FRONT, TRAY, BOARD = [0.78, 0.79, 0.82], [0.30, 0.42, 0.62], [0.93, 0.62, 0.22], [0.13, 0.50, 0.27]
CELL, STRAP, PANEL, DOOR = [0.42, 0.56, 0.86], [0.12, 0.12, 0.12], [0.90, 0.90, 0.86], [0.80, 0.30, 0.28]
TB, ADAPT, PARTS = [0.97, 0.80, 0.22], [0.10, 0.36, 0.20], [0.25, 0.25, 0.25]
FRONT_LT, DOOR_LT = [0.60, 0.70, 0.88], [0.93, 0.50, 0.44]   # lighter, for views from inside, which the preview lights less
N = chr(10)

def scene(items, name, camera, size=(1400, 1000)):
    """items: [(mesh file, colour, [dx, dy, dz], alpha)]. An orthographic OpenSCAD preview."""
    lines = []
    for f, c, d, a in items:
        p = os.path.abspath(f if os.path.isabs(f) else os.path.join(B, f)).replace('\\', '/')
        if not os.path.exists(p): sys.exit(f'{p} is missing: run cad/check_case.py (and cad/export.py --fit) first')
        lines.append(f'translate({list(d)}) color({list(c) + [a]}) import("{p}");')
    s = os.path.join(TMP, name + '.scad'); open(s, 'w').write('\n'.join(lines))
    out = os.path.join(TMP, name + '.png')
    r = subprocess.run([openscad(), '-o', out, '--imgsize=%d,%d' % size, '--colorscheme=Tomorrow', '--projection=ortho',
                        '--camera=' + ','.join(str(v) for v in camera), s], capture_output=True, text=True)
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
    """text with its top-left at 'at', and a line from the box to the point 'to'"""
    box = d.multiline_textbbox(at, text, font=F, spacing=2)
    d.rectangle([box[0] - 6, box[1] - 4, box[2] + 6, box[3] + 4], fill=(255, 255, 255), outline=INK)
    d.multiline_text(at, text, font=F, fill=INK, spacing=2)
    if to is None: return
    to = tuple(int(v) for v in to)
    if box[1] <= to[1] <= box[3]: cx, cy = (box[2] + 6 if to[0] > box[2] else box[0] - 6), to[1]
    else: cx, cy = min(max(to[0], box[0]), box[2]), (box[3] + 4 if to[1] > box[3] else box[1] - 4)
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

def draw_section(parts, origin, normal, axes, scale, offset, size):
    """parts: [(mesh file, colour)], drawn in order, so later parts sit on top of earlier ones' holes"""
    BG = (248, 248, 248)
    im = Image.new('RGB', size, BG); d = ImageDraw.Draw(im)
    def P(u, v): return (offset[0] + u * scale, offset[1] - v * scale)
    for f, c in parts:
        m = trimesh.load(os.path.join(B, f), force='mesh')
        for q, depth in section_shells(m, origin, normal, axes):
            d.polygon([P(*xy) for xy in q.exterior.coords], fill=tuple(int(255 * x) for x in c) if depth % 2 == 0 else BG)
    return im, d, P

# ---------------------------------------------------------------- what goes in each picture
CLOSED = [('a_shell.stl', SHELL, (0, 0, 0), 1), ('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1)]
SHELL_IN = [('a_shell.stl', SHELL, (0, 0, 0), 1), ('d_cell.stl', CELL, (0, 0, 0), 1), ('d_strap.stl', STRAP, (0, 0, 0), 1)]
TRAY_IN = [('a_tray_full.stl', TRAY, (0, 0, 0), 1), ('d_board.stl', BOARD, (0, 0, 0), 1)]
FRONT_IN = [('a_front_full.stl', FRONT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_door.stl', DOOR, (0, 0, 0), 1),
            ('a_tb.stl', TB, (0, 0, 0), 1), ('d_adapter.stl', ADAPT, (0, 0, 0), 1)]
INSIDE_OPEN = [('a_front_full.stl', FRONT_LT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_tb_open.stl', TB, (0, 0, 0), 1),
               ('d_adapter.stl', ADAPT, (0, 0, 0), 1)]
INSIDE_SHUT = [('a_front_full.stl', FRONT_LT, (0, 0, 0), 1), ('d_panel.stl', PANEL, (0, 0, 0), 1), ('a_door.stl', DOOR_LT, (0, 0, 0), 1),
               ('a_tb.stl', TB, (0, 0, 0), 1), ('d_adapter.stl', ADAPT, (0, 0, 0), 1)]
SECTION_PARTS = [('a_shell.stl', SHELL), ('a_front_full.stl', FRONT), ('a_tray_full.stl', TRAY), ('d_cell.stl', CELL), ('d_strap.stl', STRAP),
                 ('d_board.stl', BOARD), ('d_under.stl', PARTS), ('d_panel.stl', PANEL), ('a_door.stl', DOOR), ('d_adapter.stl', ADAPT), ('a_tb.stl', TB)]
def up(items, dz): return [(f, c, (d[0], d[1], d[2] + dz), a) for f, c, d, a in items]

JOBS = {}
def job(f): JOBS[f.__name__] = f; return f

@job
def hero():
    im = scene(CLOSED, 'hero', (28, 46, 14, 38, 0, 15, 290))
    save(im.crop((250, 40, 1150, 960)), 'hero.png')

@job
def open_case():
    im = scene(SHELL_IN + up(TRAY_IN, 24) + up(FRONT_IN, 52), 'open', (28, 46, 30, 58, 0, 22, 330)); d = ImageDraw.Draw(im)
    title(d, 'How it goes together')
    label(d, 'front: the screen sits' + N + 'behind its window', (40, 80), (700, 250))
    label(d, 'posts down onto the tray,' + N + 'with the case screws through them', (40, 300), (440, 370))
    label(d, 'board', (1080, 380), (620, 430))
    label(d, 'tray: the board snaps in,' + N + 'with a latch on each short edge', (40, 520), (480, 575))
    label(d, 'strap round the cell,' + N + 'tied to the back of the case', (1080, 560), (805, 632))
    label(d, 'cell', (1080, 690), (740, 690))
    label(d, 'shell', (40, 700), (400, 760))
    label(d, 'pogo window' + N + '(for a dock)', (40, 800), (560, 748))
    label(d, 'heat-set insert boss', (1080, 460), (940, 492))
    save(im.crop((0, 0, 1400, 900)), 'open.png')

@job
def inside():
    a = scene([('a_tray_full.stl', TRAY, (0, 0, 0), 1)], 'tray', (28, 46, 15, 35, 0, 20, 250))
    b = scene(TRAY_IN, 'tray_board', (28, 46, 15, 35, 0, 20, 250))
    im = Image.new('RGB', (2000, 960), (248, 248, 248)); im.paste(a.crop((260, 60, 1160, 960)), (0, 30)); im.paste(b.crop((260, 60, 1160, 960)), (1100, 30))
    d = ImageDraw.Draw(im)
    def A(x, y): return (x - 260, y - 30)
    title(d, 'The tray', (20, 10)); title(d, 'With the board in', (1120, 10))
    label(d, 'top latch: pull its tab' + N + 'back to let the board go', (620, 60), A(935, 285))
    label(d, 'post that keeps the ribbon' + N + 'adapter in its seat', (240, 60), A(790, 190))
    label(d, 'stops near' + N + 'each corner', (20, 170), A(605, 200))
    label(d, 'side guides,' + N + 'two each side', (20, 330), A(420, 505))
    d.line([90, 387, A(395, 562)[0], A(395, 562)[1]], fill=INK, width=3)
    label(d, 'pin (a rough guide only)', (760, 230), A(995, 335))
    label(d, 'pocket under' + N + 'the buzzer', (840, 390), A(850, 455))
    label(d, 'window: the cell strap' + N + 'crosses here', (760, 520), A(720, 470))
    label(d, 'cut-out for the battery' + N + 'socket and its lead', (20, 640), A(455, 655))
    label(d, 'bottom latch, the same', (20, 840), A(575, 668))
    label(d, 'its pull tab', (560, 890), A(545, 728))
    save(im, 'inside.png')

@job
def screen():
    a = scene(INSIDE_OPEN, 'screen_open', (28, 46, 24, 145, 0, 180, 250))
    b = scene(INSIDE_SHUT, 'screen_shut', (28, 46, 24, 145, 0, 180, 250))
    im = Image.new('RGB', (2000, 1000), (248, 248, 248)); im.paste(a.crop((230, 60, 1170, 960)), (0, 90)); im.paste(b.crop((230, 60, 1170, 960)), (1040, 90))
    d = ImageDraw.Draw(im)
    def A(x, y, k=0): return (x - 230 + 1040 * k, y + 30)
    title(d, '1. Screen in its pocket, buttons open', (20, 16)); title(d, '2. Cover on, buttons shut', (1060, 16))
    label(d, 'ribbon adapter' + N + 'in its seat', (20, 90), A(720, 190))
    label(d, 'turn buttons,' + N + 'swung open', (20, 330), A(585, 450))
    label(d, 'menu button and' + N + 'joystick holes', (20, 560), A(560, 540))
    label(d, 'case-screw posts', (20, 900), A(490, 840))
    label(d, 'screen, face down' + N + 'in its pocket', (700, 900), A(800, 560))
    label(d, 'cover: its left edge tucks' + N + 'under a rail along the pocket', (1500, 880), A(930, 600, 1))
    label(d, 'turn buttons shut over it', (1080, 900), A(640, 760, 1))
    d.line([1220, 897, A(640, 485, 1)[0], A(640, 485, 1)[1]], fill=INK, width=3)
    save(im, 'screen.png')

@job
def sections():
    im, d, P = draw_section(SECTION_PARTS, (23.5, 0, 0), (1, 0, 0), (1, 2), 15, (60, 600), (1500, 760))
    title(d, 'Cut lengthwise through the screen, dock end on the left')
    label(d, 'front', (1180, 70), P(80, 27.3))
    label(d, 'screen', (300, 70), P(38, 26.3))
    label(d, 'cover behind it', (560, 70), P(48, 25.2))
    label(d, 'ribbon adapter', (1270, 330), P(86, 24.7))
    label(d, 'board', (820, 330), P(60, 19.0))
    label(d, 'bottom latch', (40, 120), P(18.5, 20.0))
    label(d, 'tray', (1000, 420), P(70, 14.2))
    label(d, 'cell', (700, 480), P(45, 9))
    label(d, 'strap: across the cell in a window in the tray,' + N + 'behind it in a groove in the floor', (420, 690), P(44, 1.9))
    label(d, 'pogo window', (40, 470), P(1, 18.8))
    save(im, 'section.png')
    im, d, P = draw_section(SECTION_PARTS, (0, 41.8, 0), (0, 1, 0), (0, 2), 24, (90, 820), (1500, 920))
    title(d, 'Cut across the case at the strap, seen from the dock end')
    label(d, 'screen and cover', (240, 70), P(18, 25.6))
    label(d, 'menu button hole', (860, 70), P(36, 27.6))
    label(d, 'board', (640, 230), P(25, 19.0))
    label(d, 'buzzer, under the board', (1100, 230), P(47, 16.5))
    label(d, 'strap closes on itself here, where' + N + 'the parts under the board are low', (170, 262), P(20, 14.9))
    label(d, 'tray: just its side rails here', (170, 392), P(5.5, 14.3))
    label(d, 'cell', (700, 560), P(28, 8))
    label(d, 'bar: the strap passes under it,' + N + 'so the strap is tied to the case', (1050, 640), P(48.3, 3.6))
    label(d, 'groove in the floor: no extra depth', (500, 860), P(30, 1.8))
    save(im, 'strap.png')

@job
def fit_test():
    im = scene([(os.path.join(ROOT, 'stl', 'wio-tracker-l1-eink-fit-test.stl'), TRAY, (0, 0, 0), 1)], 'fit', (83, 34, 0, 30, 0, 0, 330)); d = ImageDraw.Draw(im)
    label(d, 'tray: snap the board in', (80, 20), (280, 260))
    label(d, 'front, screen side', (620, 20), (820, 300))
    label(d, 'cover', (1100, 120), (1130, 300))
    label(d, 'turn buttons' + N + '(one spare)', (1150, 700), (1310, 560))
    label(d, 'strip of the back:' + N + 'thread the strap', (520, 760), (300, 840))
    label(d, 'shell corner: press in a heat-set insert', (520, 955), (585, 520))
    save(im, 'fit-test.png')

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for name in sys.argv[1:] or ['all']:
        for k, fn in JOBS.items():
            if name in ('all', k): fn()
