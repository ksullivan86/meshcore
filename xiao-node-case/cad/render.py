#!/usr/bin/env python3
"""Draws the pictures in images/ from the parts check_case.py builds.

    python3 cad/check_case.py            # builds cad/build/case-1bay ... case-3bay (and checks them)
    python3 cad/check_case.py --fit      # builds cad/build/fit-1bay
    python3 cad/render.py                # every picture -> images/
    python3 cad/render.py hero-2bay      # just the pictures whose names start with that

A small numpy z-buffer rasterizer (orthographic, CAD-style edges), the same one the
dog-tracker's pictures use, so it needs nothing beyond numpy, trimesh, manifold3d and
matplotlib. Run it from the xiao-node-case folder.
"""
import json, math, os, re, subprocess, sys
import numpy as np
import trimesh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import manifold3d as m3
from manifold3d import Manifold as M

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SCAD = os.path.join(HERE, 'xiao-node-case.scad')

COL = dict(a_body='#ECEAE4', a_lid='#E2DED4', a_plate='#9AA0A6', d_boards='#2F7D3A', d_parts='#2B2B2B',
           d_pins='#C9A227', d_fpc='#E3A21A', d_plug='#1B1B1B', d_sma='#C9A227', ant='#2E2E2E',
           washer='#8A9198', kit='#ECEAE4', hl='#E0663A')


# ------------------------------------------------------------------ renderer
def hexrgb(h):
    h = h.lstrip('#')
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float) / 255.0


def man(tm):
    return M(m3.Mesh(vert_properties=np.asarray(tm.vertices, np.float32), tri_verts=np.asarray(tm.faces, np.uint32)))


def load(path):
    return man(trimesh.load(path, force='mesh'))


def arrays(m):
    mm = m.to_mesh()
    return np.asarray(mm.vert_properties)[:, :3].astype(float), np.asarray(mm.tri_verts).astype(int)


def camera(az, el):
    az, el = np.radians(az), np.radians(el)
    f = -np.array([np.cos(el) * np.cos(az), np.cos(el) * np.sin(az), np.sin(el)])
    up = np.array([0, 0, 1.0])
    if abs(np.dot(f, up)) > 0.99:
        up = np.array([0, 1.0, 0])
    r = np.cross(f, up); r /= np.linalg.norm(r)
    u = np.cross(r, f)
    return f, r, u


def render(objs, az=-60, el=30, size=(1100, 800), ss=2, margin=40, bg=(1, 1, 1), proj=False, frame=None):
    """objs: list of (manifold, hexcolor). frame: extra points that must fit in the picture."""
    W, H = size[0] * ss, size[1] * ss
    f, r, u = camera(az, el)
    data, allp = [], []
    for oid, (m, col) in enumerate(objs):
        if m is None or m.is_empty():
            continue
        V, F = arrays(m)
        data.append((oid, V, F, hexrgb(col)))
        allp.append(V)
    if frame is not None:
        allp.append(np.asarray(frame, float))
    P3 = np.vstack(allp)
    X, Y = P3 @ r, P3 @ u
    x0, x1, y0, y1 = X.min(), X.max(), Y.min(), Y.max()
    s = min((W - 2 * margin * ss) / (x1 - x0), (H - 2 * margin * ss) / (y1 - y0))
    ox = (W - s * (x1 - x0)) / 2 - s * x0
    oy = (H - s * (y1 - y0)) / 2 - s * y0
    zbuf = np.full((H, W), np.inf)
    img = np.ones((H, W, 3)) * np.array(bg)
    idb = np.full((H, W), -1, int)
    nbuf = np.zeros((H, W, 3))
    L1 = -np.array(camera(az - 35, el + 25)[0])
    L2 = -np.array(camera(az + 70, el - 10)[0])
    for oid, V, F, col in data:
        px = V @ r * s + ox
        py = H - (V @ u * s + oy)
        pz = V @ f
        tri = V[F]
        n = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
        nl = np.linalg.norm(n, axis=1); ok = nl > 1e-12
        n[ok] /= nl[ok, None]
        facing = (n @ f) < 0
        shade = 0.30 + 0.60 * np.clip(n @ L1, 0, 1) + 0.22 * np.clip(n @ L2, 0, 1)
        for t in np.nonzero(facing & ok)[0]:
            i0, i1, i2 = F[t]
            ax, ay, az_ = px[i0], py[i0], pz[i0]
            bx_, by_, bz = px[i1], py[i1], pz[i1]
            cx, cy, cz = px[i2], py[i2], pz[i2]
            xmin = max(int(np.floor(min(ax, bx_, cx))), 0); xmax = min(int(np.ceil(max(ax, bx_, cx))), W - 1)
            ymin = max(int(np.floor(min(ay, by_, cy))), 0); ymax = min(int(np.ceil(max(ay, by_, cy))), H - 1)
            if xmax < xmin or ymax < ymin:
                continue
            gx, gy = np.meshgrid(np.arange(xmin, xmax + 1) + 0.5, np.arange(ymin, ymax + 1) + 0.5)
            den = (by_ - cy) * (ax - cx) + (cx - bx_) * (ay - cy)
            if abs(den) < 1e-12:
                continue
            w0 = ((by_ - cy) * (gx - cx) + (cx - bx_) * (gy - cy)) / den
            w1 = ((cy - ay) * (gx - cx) + (ax - cx) * (gy - cy)) / den
            w2 = 1 - w0 - w1
            mk = (w0 >= -1e-6) & (w1 >= -1e-6) & (w2 >= -1e-6)
            if not mk.any():
                continue
            z = w0 * az_ + w1 * bz + w2 * cz
            sub = zbuf[ymin:ymax + 1, xmin:xmax + 1]
            upd = mk & (z < sub)
            if not upd.any():
                continue
            sub[upd] = z[upd]
            img[ymin:ymax + 1, xmin:xmax + 1][upd] = np.clip(col * shade[t], 0, 1)
            idb[ymin:ymax + 1, xmin:xmax + 1][upd] = oid
            nbuf[ymin:ymax + 1, xmin:xmax + 1][upd] = n[t]
    e = np.zeros((H, W), bool)
    for dy, dx in ((0, 1), (1, 0)):
        a_id, b_id = idb[:H - dy, :W - dx], idb[dy:, dx:]
        a_n, b_n = nbuf[:H - dy, :W - dx], nbuf[dy:, dx:]
        a_z, b_z = zbuf[:H - dy, :W - dx], zbuf[dy:, dx:]
        crease = np.sum(a_n * b_n, axis=2) < np.cos(np.radians(28))
        with np.errstate(invalid='ignore'):
            jump = np.abs(np.nan_to_num(a_z - b_z, posinf=1e9, neginf=-1e9)) > 0.6
        ed = (a_id != b_id) | ((a_id >= 0) & (crease | jump))
        e[:H - dy, :W - dx] |= ed
    img[e] = img[e] * 0.25
    out = img.reshape(size[1], ss, size[0], ss, 3).mean(axis=(1, 3))
    if proj:
        def to_px(p):
            p = np.asarray(p, float)
            return (p @ r * s + ox) / ss, (H - (p @ u * s + oy)) / ss
        return out, to_px
    return out


def save(img, name):
    os.makedirs(os.path.join(ROOT, 'images'), exist_ok=True)
    fn = os.path.join(ROOT, 'images', name)
    plt.imsave(fn, np.clip(img, 0, 1))
    return fn


def labelled(img, to_px, labels, fn, title=None, note=None, fs=12):
    """labels: (text, model point, (dx, dy) offset of the text from the point, in pixels)."""
    h, w = img.shape[:2]
    top = 70 if title else 0
    fig = plt.figure(figsize=(w / 100, (h + top) / 100), dpi=100)
    ax = fig.add_axes([0, 0, 1, h / (h + top)])
    ax.imshow(np.clip(img, 0, 1)); ax.axis('off')
    ax.set_xlim(0, w); ax.set_ylim(h, 0)
    for t, pt, off in labels:
        x, y = to_px(pt)
        ax.annotate(t, xy=(x, y), xytext=(x + off[0], y + off[1]), fontsize=fs, ha='center', va='center',
                    color='#1A1A1A', bbox=dict(boxstyle='round,pad=0.3', fc=(1, 1, 1, 0.9), ec='#999999', lw=0.6),
                    arrowprops=dict(arrowstyle='-', color='#333333', lw=0.9, shrinkA=0, shrinkB=2), annotation_clip=False)
        ax.plot([x], [y], 'o', ms=3.5, color='#1A1A1A')
    if title:
        fig.text(0.015, 1 - 12 / (h + top), title, ha='left', va='top', fontsize=20, weight='bold')
    if note:
        fig.text(0.015, 1 - 46 / (h + top), note, ha='left', va='top', fontsize=12, color='#444444')
    out = os.path.join(ROOT, 'images', fn)
    fig.savefig(out, facecolor='white')
    plt.close(fig)
    return out


def panels(items, fn, title=None, cols=None):
    """items: list of (image, caption). Side by side, captions under each."""
    cols = cols or len(items)
    rows = math.ceil(len(items) / cols)
    h, w = items[0][0].shape[:2]
    top = 60 if title else 0
    cap = 60
    fig = plt.figure(figsize=(cols * w / 100, (rows * (h + cap) + top) / 100), dpi=100)
    H = rows * (h + cap) + top
    for k, (im, c) in enumerate(items):
        rr, cc = divmod(k, cols)
        ax = fig.add_axes([cc / cols, 1 - (top + rr * (h + cap) + h) / H, 1 / cols, h / H])
        ax.imshow(np.clip(im, 0, 1)); ax.axis('off')
        fig.text((cc + 0.5) / cols, 1 - (top + rr * (h + cap) + h + 8) / H, c, ha='center', va='top', fontsize=12, wrap=True)
    if title:
        fig.text(0.015, 1 - 10 / H, title, ha='left', va='top', fontsize=20, weight='bold')
    out = os.path.join(ROOT, 'images', fn)
    fig.savefig(out, facecolor='white')
    plt.close(fig)
    return out


# ------------------------------------------------------------------ the case
def info(bays, fit=False):
    """The numbers OpenSCAD echoes for check_case.py."""
    out = os.path.join(HERE, 'build', f'info-{bays}.echo')
    cmd = ['openscad', '-o', out, '-D', f'BAYS={bays}', '-D', 'PART="none"', SCAD]
    subprocess.run(cmd, capture_output=True, text=True)
    m = re.search(r'xnc-chk: (\{.*\})"', open(out).read())
    return json.loads(m.group(1))


def parts(tag):
    d = os.path.join(HERE, 'build', tag)
    if not os.path.isdir(d):
        sys.exit(f'{d} is missing: run cad/check_case.py first')
    out = {}
    for f in os.listdir(d):
        if f.endswith('.stl'):
            m = load(os.path.join(d, f))
            if not m.is_empty():
                out[f[:-4]] = m
    return out


def opened(m, I, a):
    """A part on the lid, the lid a degrees open on its hinge."""
    y, z = I['HA']
    return m.translate((0, -y, -z)).rotate((-a, 0, 0)).translate((0, y, z))


def antennas(I):
    """Stand-in stubby antennas on the lid's SMA bulkheads."""
    out = None
    z0 = I['Z_TOP'] + 6.0
    for x in I['LORA_X']:
        base = M.cylinder(14, 5.0, 5.0, 48).translate((x, I['ANT_Y'], z0))
        whip = M.cylinder(90, 4.5, 3.4, 48).translate((x, I['ANT_Y'], z0 + 14))
        tip = M.sphere(3.4, 32).translate((x, I['ANT_Y'], z0 + 104))
        a = base + whip + tip
        out = a if out is None else out + a
    return out


def washers(I):
    """Stand-in M6 fender washers on the base plate's pins (assembled pose)."""
    W, D = I['P'] * I['BAYS'], I['D_IN']
    pt, wc, pl = 18.8, 19.4, 0.3
    if W - 2 * pl >= 2 * wc + 2 * 1.6 + 12:
        cs = [(pl, pl + wc, pl, D - pl), (W - pl - wc, W - pl, pl, D - pl)]
    else:
        cs = [(pl, W / 2 - 0.8, pl, pl + wc), (W / 2 + 0.8, W - pl, pl, pl + wc)]
    out = None
    z0 = -I['FLOOR_T'] - 8.0 + 1.2
    for x0, x1, y0, y1 in cs:
        nx, ny = int((x1 - x0 + 0.8) // pt), int((y1 - y0 + 0.8) // pt)
        for a in range(nx):
            for b in range(ny):
                x = (x0 + x1) / 2 - (nx - 1) * pt / 2 + a * pt
                y = (y0 + y1) / 2 - (ny - 1) * pt / 2 + b * pt
                for k in range(4):
                    w = (M.cylinder(1.5, 9.0, 9.0, 48) - M.cylinder(4, 3.2, 3.2, 24).translate((0, 0, -1))).translate((x, y, z0 + 1.6 * k + 0.02))
                    out = w if out is None else out + w
    return out


def cut(m, n, d):
    """Keep the side of the plane n.x >= d."""
    return None if m is None else m.trim_by_plane(n, d)


def box(x0, x1, y0, y1, z0, z1):
    return M.cube((x1 - x0, y1 - y0, z1 - z0)).translate((x0, y0, z0))


def clip(m, b):
    return None if m is None else m ^ b


KIT = ['d_boards', 'd_parts', 'd_pins']


def objs(p, names, move=None, lid_a=0, I=None):
    out = []
    for k in names:
        if k not in p:
            continue
        m = p[k]
        if lid_a and k in ('a_lid', 'd_sma'):
            m = opened(m, I, lid_a)
        if move and k in move:
            m = m.translate(move[k])
        out.append((m, COL[k]))
    return out


# ------------------------------------------------------------------ pictures
def hero(n):
    I, p = info(n), parts(f'case-{n}bay')
    o = objs(p, ['a_body', 'a_lid', 'a_plate', 'd_sma']) + [(antennas(I), COL['ant'])]
    return save(render(o, az=-62, el=24, size=(1000, 1000), margin=30), f'hero-{n}bay.png')


def kit_image(name):
    stl = os.path.join(ROOT, 'stl', f'xiao-node-case-{name}.stl')
    return save(render([(load(stl), COL['kit'])], az=-60, el=45, size=(800, 600)), f'kit-{name}.png')


def open_case():
    I, p = info(2), parts('case-2bay')
    o = objs(p, ['a_body', 'a_lid', 'a_plate', 'd_sma', 'd_fpc'] + KIT, lid_a=100, I=I)
    return save(render(o, az=-58, el=38, size=(1100, 1000), margin=30), 'open-2bay.png')


def front():
    I, p = info(2), parts('case-2bay')
    o = objs(p, ['a_body', 'a_lid', 'a_plate', 'd_sma'])
    img, to_px = render(o, az=-72, el=22, size=(1300, 800), margin=150, proj=True)
    bx, x2 = I['BX0'], I['BX0'] + I['P']
    xc = lambda b: b + I['USB_U']
    zt = I['Z_TOP']
    W = I['P'] * I['BAYS']
    L = [('USB-C, one per kit,\nlabelled underneath', (xc(x2) + 4, -2.4, I['ZX'] + 2.5), (-90, 215)),
         ('vents: air in low\nthrough both sides...', (W + 3.2, 22, 10), (190, -40)),
         ('...and out through\nthe lid', (W * 0.62, 34, zt), (150, -215)),
         ('lift tab: lift here\nto open the lid', (W / 2, -3.9, zt - 0.8), (-60, -190)),
         ('sprung tab: clicks into\nthe front wall', (5.0, -3.6, I['Z_LU'] - 5.0), (-150, 120)),
         ('plunger over the Wio\nboard\'s user button', (bx + I['PLUNGERS'][0][0], I['BY'] + I['PLUNGERS'][0][1], zt), (-120, -180)),
         ('LoRa SMA, labelled', (I['LORA_X'][1], I['ANT_Y'], zt + 6), (110, -120)),
         ('base plate, with the\nballast inside', (W * 0.75, -2.4, -I['FLOOR_T'] - 5), (190, 110))]
    return labelled(img, to_px, L, 'front-2bay.png')


def inside():
    """Looking down into the 2-bay case, lid off: bay 1 with its kit, bay 2 empty."""
    I, p = info(2), parts('case-2bay')
    P = I['P']
    keep = box(-10, P, -10, 60, -20, 40)
    o = objs(p, ['a_body', 'd_fpc']) + [(clip(p[k], keep), COL[k]) for k in KIT]
    size = (1400, 900)
    img, to_px = render(o, az=-90, el=89.9, size=size, margin=150, proj=True)
    b0, b1, BY, ZB = I['BX0'], I['BX0'] + P, I['BY'], I['ZB']
    K = I['KIT']
    L = [('kit: XIAO underneath,\nWio-SX1262 on top', (b0 + K[0] / 2, BY + 10, 20), (-20, 0)),
         ('front hooks\n(each corner)', (b1 + 1.0, BY - 0.1, ZB + 1.5), (-140, 120)),
         ('latch: its lip holds\nthe board\'s left edge', (b1 - 0.8, BY + 20.4, ZB + 1.6), (-200, -40)),
         ('finger tab: push toward\nthe wall to free the board', (b1 - 2.4, BY + 24.0, 3.0), (-40, -250)),
         ('rail along the right edge', (b1 + K[0] + 1.3, BY + 10, ZB + 1.8), (150, 60)),
         ('rail along the back', (b1 + 9, BY + K[1] + 1.2, ZB + 0.9), (120, -110)),
         ('standoffs, clear of\nthe header pins', (b1 + 5.0, BY + 3.4, ZB), (40, 170)),
         ('spool for the\nWiFi antenna\'s cable', (b1 - 0.2 + K[0] / 2, BY + I['SPOOL_P'][1], 9), (190, -40)),
         ('WiFi antenna (FPC) on\nthe back wall', (P + P / 2, 44.2, 10), (110, -120)),
         ('base plate\'s catch\nin its slot', (I['CATCH_X'], (I['CT'][0] + I['CT'][1]) / 2, 0.8), (-250, -60)),
         ('USB-C opening', (b1 + I['USB_U'], -1.2, I['ZX'] + 2), (210, 70))]
    return labelled(img, to_px, L, 'inside-2bay.png', note='Looking down into a 2-bay case with the lid off. The left bay has its kit in, the right one is empty.')


def fitting():
    """Putting a kit in: three steps on a 1-bay case, cut down the middle."""
    I, p = info(1), parts('case-1bay')
    bx, BY, ZB = I['BX0'], I['BY'], I['ZB']
    keep = box(-10, 60, -10, 34, -4, 22)
    body = clip(p['a_body'], keep)
    kit = [p[k] for k in KIT]
    th = math.degrees(math.asin((I['XIAO_T'] + 0.6) / I['KIT'][1])) + 6
    piv = (0, BY, ZB)

    def tilt(m, a, dy, dz):
        return m.translate((0, -piv[1], -piv[2])).rotate((a, 0, 0)).translate((0, piv[1] + dy, piv[2] + dz))

    frames = [([tilt(m, th, 1.5, 0.6) for m in kit], '1. Front edge first: hold the kit with its back raised,\njust behind the hooks, then slide it forward under them.'),
              ([tilt(m, th * 0.4, 0, 0.2) for m in kit], '2. Lower the back. Its left edge pushes the latch aside\n(the tongue in the floor flexes toward the wall).'),
              (kit, '3. Press until it clicks: the latch\'s lip is over the\nboard. To take it out, push the finger tab outward.')]
    xc_ = bx + 1.0   # through the left front hook; the latch is just beyond it
    items = []
    for ks, c in frames:
        o = [(cut(body, (-1, 0, 0), -xc_), COL['a_body'])] + [(cut(m, (-1, 0, 0), -xc_), COL[k]) for m, k in zip(ks, KIT)]
        items.append((render(o, az=0, el=0.01, size=(620, 440), margin=20,
                             frame=[(0, -3, -3), (0, 30, -3), (0, -3, 22), (0, 30, 22)]), c))
    return panels(items, 'step-fit-kit.png', title='Putting a kit in its bay')


def lid_views():
    """The hinge and the front tabs."""
    I, p = info(2), parts('case-2bay')
    items = []
    for a, c in ((0, 'Shut. The two sprung tabs at the front corners\nclick into the front wall; lift the tab between them.'),
                 (60, 'Opening. It turns on two clips at the back that\nsnap onto pins on the case.'),
                 (100, 'Open. It rests on the hinge cheeks at about 100°.\nTo take it off, pull it straight up off the pins.')):
        o = objs(p, ['a_body', 'a_lid', 'd_sma'], lid_a=a, I=I)
        items.append((render(o, az=-150, el=22, size=(640, 520), margin=20,
                             frame=[(-4, -4, -4), (88, -4, -4), (-4, 70, 75), (88, 70, 75)]), c))
    return panels(items, 'step-lid.png', title='The lid')


def hinge():
    I, p = info(2), parts('case-2bay')
    xs = 10.0
    keep = box(xs - 7, xs, 25, 70, -4, 90)
    out = []
    for a, fr in ((0, [(xs, 38, 8), (xs, 60, 8), (xs, 38, 30), (xs, 60, 30)]), (104, [(xs, 30, 4), (xs, 62, 4), (xs, 30, 72), (xs, 62, 72)])):
        o = [(clip(p['a_body'], keep), COL['a_body']), (clip(opened(p['a_lid'], I, a), keep), COL['a_lid'])]
        out.append(render(o, az=0, el=0.01, size=(560, 480), margin=20, frame=fr))
    return panels([(out[0], 'Shut: the lid\'s clip snapped round a pin on the\ncase, with a cheek behind it. Cut through the clip.'),
                   (out[1], 'Open: the lid\'s back edge rests on the cheek,\nso the lid stays up on its own.')], 'hinge.png', title='The hinge')


def base():
    I, p = info(2), parts('case-2bay')
    W = I['P'] * I['BAYS']
    o = [(p['a_plate'], COL['a_plate']), (washers(I), COL['washer'])]
    img, to_px = render(o, az=-60, el=42, size=(1300, 850), margin=160, proj=True)
    z = -I['FLOOR_T']
    L = [('M6 fender washers on pins:\none chamber at each end', (10, 12, z - 2), (-150, -120)),
         ('open chamber for any\nother weight', (W / 2 + 10, 12, z - 6), (40, 170)),
         ('catch: springs up through\na slot in the case\'s floor', (I['CATCH_X'], (I['CT'][0] + I['CT'][1]) / 2, z + I['CATCH_TOP']), (-80, -200)),
         ('side lip with a V that runs\nin a groove on the case', (W + 4.4, 30, z + 3), (130, -120)),
         ('partitions hold up\nthe case\'s floor', (21, 40, z), (-250, -120))]
    return labelled(img, to_px, L, 'base-2bay.png', note='The base plate slides on from the back, and the catch clicks up when it\'s home.')


def section():
    I, p = info(2), parts('case-2bay')
    x = I['BX0'] + I['PLUNGERS'][0][0] + 0.05   # through the plunger, just clear of the partition under it
    names = ['a_body', 'a_lid', 'a_plate', 'd_fpc'] + KIT
    o = [(cut(m, (-1, 0, 0), -x), c) for m, c in objs(p, names)] + [(cut(washers(I), (-1, 0, 0), -x), COL['washer'])]
    img, to_px = render(o, az=0, el=0.01, size=(1400, 820), margin=170, proj=True)
    BY, ZB, ZX, ZW = I['BY'], I['ZB'], I['ZX'], I['ZW']
    L = [('XIAO ESP32S3', (x, BY + 17, ZX - 0.5), (-260, 90)),
         ('Wio-SX1262 on top', (x, BY + 15, ZW - 0.6), (-240, -150)),
         ('USB-C socket sits in\nthe front wall', (x, -0.8, I['ZX'] + 1.6), (-170, 20)),
         ('plunger over the\nuser button', (x, BY + I['PLUNGERS'][0][1], I['Z_TOP'] - 1.2), (60, -150)),
         ('header pins, clear\nof the floor', (x, BY + 10, 2.0), (-80, 140)),
         ('WiFi antenna on\nthe back wall', (x, I['D_IN'] + 0.2, 10), (160, -60)),
         ('hinge', (x, I['HA'][0], I['HA'][1]), (130, -110)),
         ('spool for the WiFi\nantenna\'s cable', (x, BY + I['SPOOL_P'][1], 6), (-40, 190)),
         ('base plate (the washers are\nin its end chambers)', (x, 30, -I['FLOOR_T'] - 7.5), (190, 110))]
    return labelled(img, to_px, L, 'section-2bay.png', note='Cut down the middle of the left bay.')


def fit_test():
    I, p = info(1), parts('fit-1bay')
    items = [(render([(p['a_body'], COL['a_body']), (p['a_lid'], COL['a_lid'])] + [(p[k], COL[k]) for k in KIT if k in p],
                     az=-55, el=35, size=(620, 520), margin=20), 'The fit test with a kit in: one bay\'s floor and front wall,\nand a strip of lid on two columns.'),
             (render([(load(os.path.join(ROOT, 'stl', 'xiao-node-case-fit-test.stl')), COL['kit'])], az=-60, el=45, size=(620, 520), margin=20),
              'As it prints: the strip is turned over.')]
    return panels(items, 'step-fit-test.png', title='The fit test')


JOBS = {'hero-1bay': lambda: hero(1), 'hero-2bay': lambda: hero(2), 'hero-3bay': lambda: hero(3),
        'kit-1bay': lambda: kit_image('1bay'), 'kit-2bay': lambda: kit_image('2bay'), 'kit-3bay': lambda: kit_image('3bay'),
        'kit-fit-test': lambda: kit_image('fit-test'), 'open': open_case, 'front': front, 'inside': inside,
        'step-fit-kit': fitting, 'step-lid': lid_views, 'hinge': hinge, 'base': base, 'section': section,
        'step-fit-test': fit_test}

if __name__ == '__main__':
    want = sys.argv[1:]
    for k, f in JOBS.items():
        if not want or any(k.startswith(w) for w in want):
            print(f())
