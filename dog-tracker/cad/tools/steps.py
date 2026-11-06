#!/usr/bin/env python3
"""The build guide's step pictures, in the same style as the Tahoe repeater's:
a title, one line under it, and numbered panels, each with a caption, a
picture drawn from the CAD and labels pointing at what matters.

    python3 cad/tools/export.py --parts --variant swap --variant sealed
    python3 cad/tools/steps.py            # every step picture -> images/step-*.png
    python3 cad/tools/steps.py close swap # just these

Each step is a function below. A panel's picture is either a render of the
exported parts (moved about as the step needs) or a flat drawing.
"""
import os, sys, textwrap
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyBboxPatch, Rectangle, Polygon, FancyArrowPatch, Arc
from manifold3d import Manifold as M

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import render as R

ROOT = R.ROOT
OR = '#E8590C'          # arrows and step numbers
INK = '#1A1A1A'
DPI = 100
_cache = {}


def P(v):
    if v not in _cache:
        _cache[v] = R.parts(v)
    return _cache[v]


# ---------- scenes -------------------------------------------------------

def rotm(rot):
    rx, ry, rz = np.radians(rot)
    X = np.array([[1, 0, 0], [0, np.cos(rx), -np.sin(rx)], [0, np.sin(rx), np.cos(rx)]])
    Y = np.array([[np.cos(ry), 0, np.sin(ry)], [0, 1, 0], [-np.sin(ry), 0, np.cos(ry)]])
    Z = np.array([[np.cos(rz), -np.sin(rz), 0], [np.sin(rz), np.cos(rz), 0], [0, 0, 1]])
    return Z @ Y @ X


class Scene:
    """A render of some parts, plus helpers to point at model points. cut: one
    plane or a list of planes (normal, offset), keeping dot(n, x) >= offset.
    rot: turn the whole scene (degrees about x, y, z) after cutting."""

    def __init__(self, items, az=-58, el=34, margin=30, cut=None, rot=None):
        self.items, self.az, self.el, self.margin, self.cut, self.rot = items, az, el, margin, cut, rot

    def make(self, size):
        objs = self.items
        cuts = self.cut if isinstance(self.cut, list) else ([self.cut] if self.cut else [])
        for n, o in cuts:
            objs = [(m.trim_by_plane(n, o), c) for m, c in objs]
        if self.rot:
            objs = [(m.rotate(self.rot), c) for m, c in objs]
        img, f = R.render(objs, az=self.az, el=self.el, size=size, margin=self.margin, proj=True)
        if self.rot:
            Rm = rotm(self.rot)
            return img, (lambda p, f=f: f(Rm @ np.asarray(p, float)))
        return img, f


class Flat:
    """A flat drawing: draw(ax, w, h) in pixel coordinates, y down."""

    def __init__(self, draw):
        self.draw = draw

    def make(self, size):
        return np.ones((size[1], size[0], 3)), (lambda p: (p[0], p[1]))


def items(v, names, move=None, extra=None, rot=None):
    p = P(v)
    move = move or {}
    rot = rot or {}
    out = []
    for k in names:
        if k not in p:
            continue
        m = p[k]
        if k in rot:
            c, ang = rot[k]                 # rotate about an axis through c: ang = (rx, ry, rz)
            m = m.translate([-x for x in c]).rotate(ang).translate(c)
        m = m.translate(move.get(k, (0, 0, 0)))
        out.append((m, R.COL[k]))
    return out + (extra or [])


def bb(v, k, move=(0, 0, 0)):
    b = np.array(P(v)[k].bounding_box())
    return b + np.array(list(move) * 2)


def ctr(b, dz=None):
    return ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, (b[2] + b[5]) / 2 if dz is None else dz)


def box(x0, x1, y0, y1, z0, z1):
    return M.cube((x1 - x0, y1 - y0, z1 - z0)).translate((x0, y0, z0))


def cyl_y(x, z, y0, y1, r, n=40):
    return M.cylinder(y1 - y0, r, r, n).rotate((-90, 0, 0)).translate((x, y0, z))


# ---------- panels -------------------------------------------------------

class Panel:
    """n: step number; text: caption; pic: Scene or Flat.
    labels: (text, point, (dx, dy)[, ha]) where point is a model point (3-tuple) or a pixel
    point ('px', x, y); arrows: (p0, p1[, rad]) model or pixel points; draw: extra drawing
    fn(ax, to_px, w, h); note, warn: small text under the picture."""

    def __init__(self, n, text, pic, labels=(), arrows=(), draw=None, note=None, warn=None, fs=11, curves=()):
        self.n, self.text, self.pic, self.curves = n, text, pic, curves
        self.labels, self.arrows, self.draw = labels, arrows, draw
        self.note, self.warn, self.fs = note, warn, fs


def _pt(to_px, p):
    if isinstance(p, tuple) and len(p) == 3 and p[0] == 'px':
        return p[1], p[2]
    x, y = to_px(p)
    return float(x), float(y)


def compose(fn, title, sub, panels, cols=3, pic_h=440, W=1600, head_h=118):
    rows = (len(panels) + cols - 1) // cols
    pw = W // cols
    top = (110 if sub else 70) if title else 10
    note_h = 62 if any(p.note or p.warn for p in panels) else 10
    rh = head_h + pic_h + note_h
    H = top + rows * rh + 10
    fig = plt.figure(figsize=(W / DPI, H / DPI), dpi=DPI)
    fig.patch.set_facecolor('white')
    bg = fig.add_axes([0, 0, 1, 1]); bg.set_xlim(0, W); bg.set_ylim(H, 0); bg.axis('off')
    if title:
        bg.text(20, 18, title, fontsize=25, weight='bold', va='top', color='black')
    if sub:
        bg.text(20, 66, sub, fontsize=15, va='top', color='#333333')
    for i, p in enumerate(panels):
        r, c = divmod(i, cols)
        x0, y0 = c * pw, top + r * rh
        if p.n is not None:
            bg.add_patch(Circle((x0 + 30, y0 + 22), 16, color=OR))
            bg.text(x0 + 30, y0 + 23, str(p.n), color='white', fontsize=14, weight='bold', ha='center', va='center')
        wrap = max(18, int((pw - 70) / 10.6))
        bg.text(x0 + (56 if p.n is not None else 20), y0 + 8, '\n'.join(textwrap.wrap(p.text, wrap)), fontsize=15, va='top', color='#222222',
                linespacing=1.15)
        size = (pw - 20, pic_h)
        img, to_px = p.pic.make(size)
        ax = fig.add_axes([(x0 + 10) / W, 1 - (y0 + head_h + pic_h) / H, size[0] / W, pic_h / H])
        ax.imshow(np.clip(img, 0, 1), extent=(0, size[0], size[1], 0))
        ax.set_xlim(0, size[0]); ax.set_ylim(size[1], 0); ax.axis('off')
        if isinstance(p.pic, Flat):
            p.pic.draw(ax, size[0], size[1])
        if p.draw:
            p.draw(ax, to_px, size[0], size[1])
        for a in p.arrows:
            a0, a1 = _pt(to_px, a[0]), _pt(to_px, a[1])
            rad = a[2] if len(a) > 2 else 0.0
            ax.add_patch(FancyArrowPatch(a0, a1, arrowstyle='-|>,head_length=12,head_width=8', lw=4, color=OR,
                                         connectionstyle=f'arc3,rad={rad}', mutation_scale=1, zorder=5))
        for cv in p.curves:
            pts = [_pt(to_px, q) for q in cv]
            xs, ys = zip(*pts)
            ax.plot(xs[:-1], ys[:-1], color=OR, lw=4, solid_capstyle='round', zorder=5)
            ax.add_patch(FancyArrowPatch(pts[-3], pts[-1], arrowstyle='-|>,head_length=12,head_width=8', lw=4,
                                         color=OR, mutation_scale=1, zorder=5))
        for lab in p.labels:
            t, pt, off = lab[:3]
            ha = lab[3] if len(lab) > 3 else 'center'
            x, y = _pt(to_px, pt)
            ax.annotate(t, xy=(x, y), xytext=(x + off[0], y + off[1]), fontsize=p.fs, ha=ha, va='center', color=INK,
                        bbox=dict(boxstyle='round,pad=0.3', fc='white', ec='#BBBBBB', lw=0.8), annotation_clip=False,
                        arrowprops=dict(arrowstyle='-', color='#222222', lw=1.1, shrinkA=0, shrinkB=0), zorder=6)
            ax.plot([x], [y], 'o', ms=4, color='#222222', zorder=7)
        yy = y0 + head_h + pic_h + 8
        if p.warn:
            bg.text(x0 + pw / 2, yy, p.warn, fontsize=12, weight='bold', color='#D9302C', ha='center', va='top')
            yy += 20
        if p.note:
            bg.text(x0 + pw / 2, yy, '\n'.join(textwrap.wrap(p.note, int(pw / 7.2))), fontsize=11.5, color='#444444', ha='center', va='top')
    out = os.path.join(ROOT, 'images', fn)
    fig.savefig(out, facecolor='white', dpi=DPI)
    plt.close(fig)
    return out


# ---------- flat drawing helpers ----------------------------------------

def draw_cell(ax, x, y, w, h, label=None, button=True, flip=False, wrap='#3B6EA5', nick=False, end_text=True):
    """A cell lying on its side: + end on the left (right if flip)."""
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle='round,pad=0,rounding_size=6', fc=wrap, ec='#1F3B5A', lw=1.5))
    bx = x + w if flip else x - 7
    if button:
        ax.add_patch(Rectangle((bx, y + h * 0.3), 7, h * 0.4, fc='#B0B0B0', ec='#555555', lw=1))
    nx = x - 3 if flip else x + w
    ax.add_patch(Rectangle((nx, y + 4), 3, h - 8, fc='#B0B0B0', ec='#555555', lw=1))
    if end_text:
        ax.text((x + w + 12) if flip else (x - 12), y + h / 2, '+', ha='center', va='center', fontsize=16, weight='bold',
                color='#C0392B')
        ax.text((x - 12) if flip else (x + w + 12), y + h / 2, '−', ha='center', va='center', fontsize=16, weight='bold')
    if label:
        ax.text(x + w / 2, y + h / 2, label, ha='center', va='center', color='white', fontsize=11, weight='bold')
    if nick:
        ax.add_patch(Polygon([(x + w * 0.62, y), (x + w * 0.66, y + 9), (x + w * 0.70, y)], fc='#C8C8C8', ec='#777777'))


def draw_meter(ax, x, y, reading, ok=True):
    ax.add_patch(FancyBboxPatch((x, y), 120, 150, boxstyle='round,pad=0,rounding_size=10', fc='#F2C230', ec='#6B5A10',
                                lw=1.5))
    ax.add_patch(Rectangle((x + 12, y + 14), 96, 44, fc='#C9D6C0', ec='#333333', lw=1))
    ax.text(x + 60, y + 36, reading, ha='center', va='center', fontsize=17, family='monospace',
            color='#111111' if ok else '#888888')
    ax.add_patch(Circle((x + 60, y + 100), 24, fc='#333333'))
    ax.text(x + 60, y + 100, 'V', color='white', ha='center', va='center', fontsize=13, weight='bold')
    return (x + 35, y + 150), (x + 85, y + 150)


def lead(ax, pts, col, lw=3):
    xs, ys = zip(*pts)
    ax.plot(xs, ys, color=col, lw=lw, solid_capstyle='round', zorder=4)


def say(ax, x, y, t, fs=11.5, col='#333333', ha='center', **k):
    ax.text(x, y, t, fontsize=fs, color=col, ha=ha, va='center', **k)


# ---------- the steps ----------------------------------------------------

SW = ['pod', 'lid', 'barrel', 'cap', 'pogo', 'strap']


def cap_axis():
    b = bb('swap', 'cap')
    return (b[0] + b[3]) / 2, (b[2] + b[5]) / 2      # x, z


def step_swap():
    cx, cz = cap_axis()
    cb = bb('swap', 'cap')
    cell = bb('swap', 'cell')
    pod = bb('swap', 'pod')

    def unscrew():
        mv = {k: (0, 7, 0) for k in ('cap', 'washer', 'spring', 'cushion')}
        sc = Scene(items('swap', SW, move=mv), az=45, el=30)
        top = (cx, cb[4] + 7, cz + 9.5)
        return Panel(1, 'Unscrew the cap anticlockwise, about 1¼ turns. The spring and washer come away with it.', sc,
                     curves=[arc_y(cx, cb[4] + 7, cz, 9.5, -30, 160)],
                     labels=[('Anticlockwise, seen\nfrom the cap end', top, (-170, 10))])

    def tip():
        mv = {k: (0, 30, 0) for k in ('cap', 'washer', 'spring', 'cushion')}
        mv['cell'] = (0, 21, 0)
        sc = Scene(items('swap', SW + ['cell', 'washer', 'spring', 'cushion', 'cap_oring'], move=mv), az=45, el=30)
        c = ctr(cell)
        return Panel(2, 'Tip the pod so the cap end points down, and the cell slides out.', sc,
                     arrows=[((c[0], c[1] + 26, c[2] + 12), (c[0], c[1] + 40, c[2] + 12))],
                     labels=[('Take the collar off first,\nor hold the dog\'s head up', (pod[0] + 10, 0, pod[5]), (30, -110))])

    def check():
        def d(ax, w, h):
            draw_cell(ax, 90, 150, 300, 90, 'NL169R', nick=True)
            say(ax, w / 2, 300, 'Look all round the wrap at every swap.\nA nick or a tear: retire the cell.', fs=13)
            ax.annotate('A nick in the wrap', xy=(90 + 300 * 0.66, 152), xytext=(330, 80), fontsize=11, ha='center',
                        bbox=dict(boxstyle='round,pad=0.3', fc='white', ec='#BBBBBB'), arrowprops=dict(arrowstyle='-'))
            say(ax, w / 2, 380, 'On many protected cells the can under the wrap\nis the raw negative, so a tear can bypass\n'
                                'the protection.', fs=11, col='#555555')
        return Panel(3, 'Check the wrap.', Flat(d))

    def insert():
        mv = {'cell': (0, 21, 0)}
        sc = Scene(items('swap', ['pod', 'lid', 'barrel', 'pogo', 'strap', 'cell', 'cap_oring'], move=mv), az=45, el=30)
        c = ctr(cell)
        return Panel(4, 'Drop a charged cell in, + end first. The battery sign on the outer face shows which way.', sc,
                     arrows=[((c[0], c[1] + 40, c[2] + 12), (c[0], c[1] + 26, c[2] + 12))],
                     labels=[('+ end goes in first', (c[0], cell[4] + 21, cell[5] - 2), (-30, -110)),
                             ('Battery sign', (cx + 18, -2, pod[5]), (-60, -110))])

    def close():
        mv = {k: (0, 5, 0) for k in ('cap', 'washer', 'spring', 'cushion')}
        sc = Scene(items('swap', SW, move=mv), az=45, el=30)
        return Panel(5, 'Screw the cap on clockwise until it stops firmly. Hand-tight is enough.', sc,
                     curves=[arc_y(cx, cb[4] + 5, cz, 9.5, 160, -30)],
                     labels=[('You feel the spring,\nthen the washer\'s O-ring,\nthen a firm stop', (cx, cb[4] + 5, cz - 8),
                              (-200, 60))])

    def charge():
        pg = bb('swap', 'pogo')
        plug = box(pg[0], pg[3], pg[4], pg[4] + 9, pg[2] - 0.5, pg[5] + 0.5)
        cable = cyl_y((pg[0] + pg[3]) / 2, (pg[2] + pg[5]) / 2, pg[4] + 9, pg[4] + 34, 1.8)
        ex = [(plug, '#2B2B2B'), (cable, '#2B2B2B')]
        sc = Scene(items('swap', SW, extra=ex), az=60, el=28)
        return Panel(6, 'Or charge it in the pod: clip the magnetic cable onto the end wall, beside the cap.', sc,
                     labels=[('Magnetic cable', ((pg[0] + pg[3]) / 2, pg[4] + 4, pg[5] + 0.5), (-90, -110)),
                             ('Off the dog, on something\nthat won\'t burn, 0 to 45 °C', (pod[3] - 5, -10, pod[5]), (-60, -110))],
                     note='50 mA: about 11 to 22 hours for a flat 16340')

    return compose('step-swap.png', '16. Swapping and charging',
                   'Swap a cell in the field in under a minute. Charge the spare outside the pod: it\'s much faster.',
                   [unscrew(), tip(), check(), insert(), close(), charge()], cols=3)


# ---------- more helpers -------------------------------------------------

def arc_y(cx, y, cz, r, t0, t1, n=24):
    """An arc round the barrel's axis (along Y) at height y. Angles are seen from the
    cap end (+Y): 0 is to the viewer's right (-X), 90 is up (+Z); increasing angle
    is anticlockwise."""
    t = np.radians(np.linspace(t0, t1, n))
    return [(cx - r * np.cos(a), y, cz + r * np.sin(a)) for a in t]


def wire(pts, r=0.45):
    segs = []
    for a, b in zip(pts[:-1], pts[1:]):
        segs.append(M.batch_hull([M.sphere(r, 10).translate(a), M.sphere(r, 10).translate(b)]))
    out = segs[0]
    for sg in segs[1:]:
        out = out + sg
    return out


RED, BLK, EPOXY, TAPE = '#C62828', '#222222', '#C9A227', '#7FB3D5'
BACK = dict(az=-118, el=-42)          # looking into the pod from the back (lid side)
CAPV = dict(az=45, el=30)            # the cap end and the outer face


def kit_parts(stl):
    """Split a print file into its parts: [(manifold, bbox)], biggest first."""
    import trimesh
    tm = trimesh.load(stl, force='mesh')
    out = []
    for b in tm.split(only_watertight=False):
        out.append((R.load_tm(b), b.bounds.ravel()))
    out.sort(key=lambda t: -(t[1][3] - t[1][0]) * (t[1][4] - t[1][1]))
    return out


# ---------- 1. before you start -----------------------------------------

def step_cells():
    def good(ax, w, h):
        draw_cell(ax, 110, 150, 270, 82, 'protected\n16340')
        lab = dict(fontsize=11, ha='center', bbox=dict(boxstyle='round,pad=0.3', fc='white', ec='#BBBBBB'),
                   arrowprops=dict(arrowstyle='-'))
        ax.annotate('Button top: the + end\nsticks out', xy=(104, 191), xytext=(130, 70), **lab)
        ax.annotate('"Protected" on the wrap,\n3.6 or 3.7 V, rechargeable', xy=(300, 232), xytext=(330, 320), **lab)
        say(ax, w / 2, 400, 'NL169R or NL169 (16340), P1835C2 (18350)', fs=12, col='#2E7D32', weight='bold')

    def bad(ax, w, h):
        rows = [('CR123A', '3 V, not rechargeable', '#6D6D6D', True),
                ('LiFePO4', '"3.2 V" RCR123A', '#4A7A3A', True),
                ('flat top', 'won\'t reach the + contact', '#3B6EA5', False)]
        for i, (t, why, col, btn) in enumerate(rows):
            y = 60 + i * 120
            draw_cell(ax, 90, y, 200, 60, t, wrap=col, button=btn, end_text=False)
            ax.plot([80, 300], [y - 8, y + 68], color='#D9302C', lw=4)
            ax.plot([80, 300], [y + 68, y - 8], color='#D9302C', lw=4)
            say(ax, 320, y + 30, why, fs=12, ha='left')

    def pouch(ax, w, h):
        ax.add_patch(FancyBboxPatch((50, 120), 300, 190, boxstyle='round,pad=0,rounding_size=10', fc='#B9BEC4',
                                    ec='#6B7178', lw=1.5))
        ax.add_patch(Rectangle((350, 150), 26, 130, fc='#1E5631', ec='#0E2A18'))
        lead(ax, [(376, 195), (430, 195), (450, 185)], RED)
        lead(ax, [(376, 235), (430, 235), (450, 245)], BLK)
        say(ax, 200, 215, '603040\n3.7 V, about 800 mAh', fs=13, weight='bold')
        lab = dict(fontsize=11, ha='center', bbox=dict(boxstyle='round,pad=0.3', fc='white', ec='#BBBBBB'),
                   arrowprops=dict(arrowstyle='-'))
        ax.annotate('Protection board:\nit must have one', xy=(363, 160), xytext=(360, 70), **lab)
        say(ax, w / 2, 380, 'When it arrives: 3.6 to 4.2 V on a meter,\nand flat. Send back a puffy one.', fs=12)

    return compose('step-cells.png', '1. Before you start: the battery',
                   'The pod charges to 4.2 V and the XIAO never cuts off a flat battery, so the cell has to protect itself.',
                   [Panel(1, 'Swap: a protected, button-top, rechargeable lithium-ion cell.', Flat(good)),
                    Panel(2, 'Never one of these, even though they fit the barrel.', Flat(bad)),
                    Panel(3, 'Sealed: a 603040 LiPo pouch with a protection board.', Flat(pouch))], cols=3, pic_h=420)


# ---------- 2. fit test ---------------------------------------------------

def step_fit_test():
    cx, cz = cap_axis()
    cb, cl, bl = bb('swap', 'cap'), bb('swap', 'cell'), bb('swap', 'barrel')
    yf = bl[1] + 2.0

    kp = kit_parts(os.path.join(ROOT, 'build', 'kits', 'fit.stl'))
    names = {}
    for m, b in kp:
        h, wx, wy = b[5] - b[2], b[3] - b[0], b[4] - b[1]
        if abs(wx - wy) < 1.5 and h > 14:
            names.setdefault('thread', (m, b))
        elif abs(wx - wy) < 1.5:
            names.setdefault('disc' if h < 6 else 'cap', (m, b))
        else:
            names.setdefault('wall', (m, b))
    sc0 = Scene([(m, R.COL['kit']) for m, b in kp], az=-60, el=42)
    lab = {'thread': 'Thread piece', 'cap': 'Cap (the real one:\nkeep it)', 'disc': 'Contact disc',
           'wall': 'Wall piece'}
    offs = {'thread': (-60, -100), 'cap': (60, -150), 'disc': (130, 60), 'wall': (40, 130)}
    L0 = [(lab[k], ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, b[5]), offs[k]) for k, (m, b) in names.items()]
    p1 = Panel(1, 'Print the fit test first: four pieces, about 40 minutes.', sc0, labels=L0)

    end = [((0, 1, 0), cb[1] - 9)]
    th = items('swap', ['barrel', 'cap_oring'], move={'cap_oring': (0, 0, 0)})
    capm = items('swap', ['cap', 'washer', 'spring', 'cushion'], move={k: (0, 8, 0) for k in ('cap', 'washer', 'spring', 'cushion')})
    sc1 = Scene(th + capm, cut=end, **CAPV)
    p2 = Panel(2, 'Thread piece: O-ring in its groove, a film of grease, then screw the cap on by hand.', sc1,
               curves=[arc_y(cx, cb[4] + 8, cz, 9.5, 200, 20)],
               labels=[('O-ring (20 × 1.5)', (cx, cb[1] + 1.5, cz + 10.5), (-170, -40)),
                       ('Clockwise, seen from the\ncap end: about 1¼ turns', (cx - 6, cb[4] + 8, cz - 8), (-170, 70))])

    disc = [((0, -1, 0), -(yf + 3.5))]
    mtr_pos = lambda ax, to_px, w, h, reading: None

    def disc_panel(n, text, flip, reading):
        p = P('swap')
        disc_m = p['barrel'].trim_by_plane((0, -1, 0), -(yf + 3.0))
        cell = p['cell']
        if flip:
            c = ctr(cl)
            cell = cell.translate([-x for x in c]).rotate((180, 0, 0)).translate(c)
        it = [(disc_m, R.COL['barrel']), (p['strip_pos'], R.COL['strip_pos']), (cell, R.COL['cell'])]
        sc = Scene(it, rot=(90, 0, 0), az=-60, el=22, margin=60)

        def d(ax, to_px, w, h):
            a, b = draw_meter(ax, w - 150, 20, reading, ok=(reading != '0.00'))
            tail = to_px((bl[0] + 7.5, bl[1] - 2.0, cz))
            top = to_px((cx, cl[4] - 1, cz + 3))
            lead(ax, [a, (a[0], tail[1] + 30), (tail[0], tail[1] + 30), tail], RED, 2.5)
            lead(ax, [b, (b[0], top[1] - 30), (top[0], top[1] - 30), top], BLK, 2.5)
        return Panel(n, text, sc, draw=d)

    p3 = disc_panel(3, 'Contact disc: + strip fitted, cell on it, + end down. It reads the cell\'s voltage.', False, '4.05')
    p4 = disc_panel(4, 'Turn the cell over, − end down: it reads nothing. That\'s the ring doing its job.', True, '0.00')

    pg = bb('swap', 'pogo')
    wall = [((0, 1, 0), pg[1] - 6), ((1, 0, 0), pg[0] - 8), ((-1, 0, 0), -(pg[3] + 8)), ((0, 0, 1), -0.5)]
    sc5 = Scene(items('swap', ['pod', 'pogo'], move={'pogo': (0, -9, 0)}), cut=wall, az=-110, el=22, margin=50)
    c = ctr(pg)
    p5 = Panel(5, 'Wall piece: the connector\'s flat half pushes in from behind, face level with the front.', sc5,
               arrows=[((c[0], c[1] - 14, c[2]), (c[0], c[1] - 4, c[2]))],
               labels=[('Opening: 11.5 × 5 mm', (c[0], pg[4], pg[5] + 0.3), (-120, -100)),
                       ('Rails keep it square', (pg[3] + 0.7, pg[1] + 2, c[2]), (110, -60))])

    def neg(ax, w, h):
        cxp, cyp = 160, 210
        ax.add_patch(Circle((cxp, cyp), 125, fc='#3B6EA5', ec='#1F3B5A', lw=2))
        ax.add_patch(Circle((cxp, cyp), 85, fc='#BDBDBD', ec='#555555', lw=1.5))
        ax.add_patch(Circle((cxp, cyp), 67, fc='none', ec=OR, lw=3, ls='--'))
        say(ax, cxp, cyp, '−', fs=30, weight='bold')
        lab = dict(fontsize=11, ha='left', bbox=dict(boxstyle='round,pad=0.3', fc='white', ec='#BBBBBB'),
                   arrowprops=dict(arrowstyle='-'))
        ax.annotate('Metal: at least\n10 mm across', xy=(cxp + 80, cyp - 30), xytext=(310, 110), **lab)
        ax.annotate('The spring touches here,\nin a ring about 9 mm across', xy=(cxp + 47, cyp + 48), xytext=(300, 330), **lab)
        say(ax, w / 2, 390, 'A small disc inside an insulating ring won\'t connect.', fs=11.5, col='#555555')

    p6 = Panel(6, 'Look at your cell\'s − end.', Flat(neg))
    return compose('step-fit-test.png', '2. Print the fit test',
                   'Forty minutes of printing now saves finding a problem after a two-and-a-half-hour print.',
                   [p1, p2, p3, p4, p5, p6], cols=3)


# ---------- 3. print the parts -------------------------------------------

def step_plates():
    def kit(stl, kind):
        kp = kit_parts(os.path.join(ROOT, 'build', 'kits', stl))
        L = []
        for m, b in kp:
            h, wx, wy = b[5] - b[2], b[3] - b[0], b[4] - b[1]
            top = ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, b[5])
            if h > 30:
                L.append(('Barrel: on its closed end,\na 3 to 5 mm brim helps', top, (120, -90)))
            elif abs(wx - wy) < 1.5:
                L.append(('Cap: on its end,\nthread up', top, (130, 40)))
            elif h < 8:
                L.append(('Lid: plate down', top, (110, -110)))
            else:
                L.append(('Pod: outer face down,\ncollar bridges on top', top, (-90, -120)))
        return Scene([(m, R.COL['kit']) for m, b in kp], az=-60, el=40, margin=60), L

    s1, l1 = kit('swap.stl', 'swap')
    s2, l2 = kit('sealed.stl', 'sealed')
    return compose('step-plates.png', '3. Print the parts',
                   'PETG, 0.2 mm layers, 4 walls. Split the file to objects and print them the way they lie. No supports.',
                   [Panel(1, 'Swap: four parts, about 2½ hours and 36 g.', s1, labels=l1),
                    Panel(2, 'Sealed: two parts, about 1½ hours and 22 g.', s2, labels=l2)], cols=2, pic_h=520)


# ---------- 4. dry fit ----------------------------------------------------

def step_dry_fit():
    lb, pod = bb('swap', 'lid'), bb('swap', 'pod')
    p1 = Panel(1, 'Lid, without its O-ring: it pushes in with light pressure and stops flush on four tabs.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'lid'], move={'lid': (0, 0, -14)}), **BACK),
               arrows=[(ctr(lb, -16), ctr(lb, -6))],
               labels=[('Notch to notch: that\'s\nwhere you lever it out', (lb[3], 0, lb[2] - 14), (-60, 100)),
                       ('If it\'s tight, sand the\nlid\'s skirt, not the pod', (lb[0] + 4, lb[1] + 6, -14 + 5), (-120, 40))])
    bl = bb('swap', 'barrel')
    p2 = Panel(2, 'Barrel: it drops into its trough from the back, thread end into the corner notch.',
               Scene(items('swap', ['pod', 'barrel'], move={'barrel': (0, 0, -18)}), **BACK),
               arrows=[(ctr(bl, -20), ctr(bl, -8))],
               labels=[('Flat side toward\nthe outer face', ((bl[0] + bl[3]) / 2, 0, bl[5] - 18), (-130, 40)),
                       ('Only one way round: groove\ntoward the compartment,\n+ and − into the pocket',
                        ((bl[0] + bl[3]) / 2, bl[1], bl[2] - 18), (40, 110))])
    xb = bb('swap', 'xiao')
    mv = {k: (0, 0, -14) for k in ('xiao', 'l76k', 'patch', 'fpc')}
    p3 = Panel(3, 'Boards: sit each one in its place, no tape yet. Nothing may stand past the rim.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'xiao', 'l76k', 'patch', 'fpc'], move=mv), **BACK),
               arrows=[(ctr(xb, -2), ctr(xb, 10))],
               labels=[('XIAO kit', ctr(xb, xb[2] - 14), (60, 120)),
                       ('Patch in its well,\nL76K behind it', ctr(bb('swap', 'l76k'), bb('swap', 'l76k')[2] - 14), (-170, 40))])
    return compose('step-dry-fit.png', '4. Dry-fit everything', 'Before any glue goes near it.', [p1, p2, p3], cols=3)


# ---------- 6. magnetic connector ----------------------------------------

def step_connector():
    pg = bb('swap', 'pogo')
    c = ctr(pg)

    def find(ax, w, h):
        ax.add_patch(FancyBboxPatch((70, 170), 170, 80, boxstyle='round,pad=0,rounding_size=12', fc='#222222'))
        for x in (120, 190):
            ax.add_patch(Circle((x, 210), 13, fc='#D4AF37', ec='#7A6110'))
        ax.add_patch(FancyBboxPatch((70, 252), 170, 80, boxstyle='round,pad=0,rounding_size=12', fc='#3A3A3A'))
        lead(ax, [(155, 332), (155, 390)], '#111111', 7)
        say(ax, 155, 292, 'cable half, plugged\ninto a USB charger', fs=10.5, col='white')
        mx, my = 330, 200
        draw_meter(ax, mx, my, '5.02')
        lead(ax, [(mx + 35, my), (mx + 35, 120), (120, 120), (120, 197)], RED, 2.5)
        lead(ax, [(mx + 85, my), (mx + 85, 95), (190, 95), (190, 197)], BLK, 2.5)
        say(ax, 100, 150, '+', fs=20, weight='bold', col=RED)
        say(ax, w / 2, 415, 'The probe on + reads 5 V. Mark + on the back of the flat half.', fs=11.5)

    def solder(ax, w, h):
        ax.add_patch(FancyBboxPatch((70, 110), 170, 80, boxstyle='round,pad=0,rounding_size=12', fc='#222222'))
        say(ax, 155, 92, 'back of the flat half', fs=11)
        for x in (120, 190):
            ax.add_patch(Rectangle((x - 3, 190), 6, 16, fc='#B0B0B0'))
            ax.add_patch(Rectangle((x - 8, 204), 16, 26, fc='#555555', alpha=0.85))
        lead(ax, [(120, 230), (120, 300), (200, 330), (300, 330)], RED)
        lead(ax, [(190, 230), (190, 280), (240, 300), (300, 300)], BLK)
        say(ax, 312, 300, '8 cm, 30 AWG', fs=11.5, ha='left')
        say(ax, 312, 330, 'heat shrink on each joint', fs=11.5, ha='left')
        say(ax, w / 2, 400, 'Turned over, the magnets must push the halves apart.\n'
                            'If they connect either way: a 1N5817 diode in +.', fs=11, col='#555555')

    near = [((0, 1, 0), pg[1] - 7), ((1, 0, 0), pg[0] - 9), ((-1, 0, 0), -(pg[3] + 9)), ((0, 0, 1), -0.5)]
    tape = box(pg[0] - 2, pg[3] + 2, pg[4], pg[4] + 0.4, pg[2] - 2, pg[5] + 2)
    sc3 = Scene(items('swap', ['pod', 'pogo'], move={'pogo': (0, -9, 0)}, extra=[(tape, TAPE)]), cut=near,
                az=-110, el=22, margin=50)
    p3 = Panel(3, 'Tape over the opening outside. From inside, push the flat half through onto the tape.', sc3,
               arrows=[((c[0], c[1] - 15, c[2]), (c[0], c[1] - 5, c[2]))],
               labels=[('Tape on the outside,\nsticky side in', (c[0] - 3, pg[4] + 0.2, pg[5] + 0.3), (130, -110)),
                       ('Swap: the end wall\nbeside the cap', (pg[0] - 4, pg[1], pg[5] + 6), (-110, -60))])
    ep = [(box(pg[0] - 1.6, pg[0], pg[1], pg[4] - 0.5, pg[2] + 0.4, pg[5] + 0.8), EPOXY),
          (box(pg[3], pg[3] + 1.6, pg[1], pg[4] - 0.5, pg[2] + 0.4, pg[5] + 0.8), EPOXY),
          (box(pg[0] - 1.6, pg[3] + 1.6, pg[1], pg[4] - 0.5, pg[5], pg[5] + 1.6), EPOXY)]
    bore_tape = box(pg[0] - 2, pg[3] + 2, pg[4] - 2.8, pg[4] - 2.4, 0.2, pg[2] - 0.2)
    sc4 = Scene(items('swap', ['pod', 'pogo'], extra=ep + [(bore_tape, TAPE)]), cut=near, az=-110, el=22, margin=50)
    p4 = Panel(4, 'Tape the bore below it. Thick epoxy round its sides and the side toward the outer face.', sc4,
               labels=[('Epoxy: sides and top only', (pg[3] + 1, pg[1] + 1, pg[5] + 1.2), (120, -60)),
                       ('Tape here: the lid\'s skirt\nslides and seals on it', (c[0], pg[4] - 2.6, 2), (60, 110))])
    sc5 = Scene(items('swap', ['pod', 'barrel', 'cap', 'pogo'], extra=ep), rot=(-90, 0, 0), az=-60, el=20, margin=50)
    p5 = Panel(5, 'Stand the pod on its end wall, connector face down on the tape, while it sets.', sc5,
               draw=lambda ax, f, w, h: ax.plot([20, w - 20], [h - 40, h - 40], color='#888888', lw=3))
    lb = bb('swap', 'lid')
    p6 = Panel(6, 'Once it\'s stiff, push the lid in (cling film round its skirt) to check it clears. Take it out.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'pogo', 'lid'], move={'lid': (0, 0, -10)}, extra=ep), **BACK),
               arrows=[(ctr(lb, -14), ctr(lb, -3))],
               labels=[('The skirt passes\n0.3 mm under it', (c[0], pg[1], pg[2]), (-60, 120))])
    return compose('step-connector.png', '6. Set the magnetic connector',
                   'Do this first, so nothing hangs off the pod while the epoxy sets. Sealed: the same, in the outer face.',
                   [Panel(1, 'Snap the halves together and find + (5 V) on the flat half.', Flat(find)),
                    Panel(2, 'Solder a red wire to +, a black one to −, before it\'s potted.', Flat(solder)),
                    p3, p4, p5, p6], cols=3)


# ---------- 7. barrel contacts --------------------------------------------

def step_contacts():
    bl, sp, sn = bb('swap', 'barrel'), bb('swap', 'strip_pos'), bb('swap', 'strip_neg')
    cx, cz = cap_axis()
    yf = bl[1] + 2.0
    half = ((0, 0, -1), -cz)

    def bend(ax, w, h):
        ax.add_patch(Rectangle((100, 160), 240, 34, fc='#C9CCD1', ec='#666666'))
        ax.add_patch(Rectangle((340, 160), 34, 160, fc='#C9CCD1', ec='#666666'))
        ax.add_patch(Rectangle((340, 280), 34, 40, fc='#9AA0A6', ec='#666666'))
        ax.annotate('', xy=(100, 130), xytext=(374, 130), arrowprops=dict(arrowstyle='<->'))
        say(ax, 237, 112, '6 mm flat leg', fs=11.5)
        ax.annotate('', xy=(400, 194), xytext=(400, 320), arrowprops=dict(arrowstyle='<->'))
        say(ax, 410, 257, '6 mm\nleg', fs=11.5, ha='left')
        say(ax, 357, 345, 'tinned end', fs=10.5)
        say(ax, w / 2, 410, '12 mm of 5 mm pure nickel strip, bent at a right angle', fs=11.5)

    sc2 = Scene(items('swap', ['barrel', 'strip_pos']), cut=[half, ((0, -1, 0), -(yf + 9))], az=-60, el=60, margin=50)
    p2 = Panel(2, 'From inside, push the leg through the slot inside the ring. Glue under the flat leg.', sc2,
               labels=[('Flat leg inside the ring,\n2 mm short of it', ctr(sp, sp[5]), (-100, -120)),
                       ('Ring: keeps a reversed\ncell off the contact', (cx + 5.9, yf + 0.3, cz), (130, -60)),
                       ('Tail out the back', (sp[0], sp[1] + 0.5, cz), (-120, 80))])

    def cut(ax, w, h):
        ax.add_patch(Rectangle((40, 190), 420, 30, fc='#C9CCD1', ec='#666666'))
        ax.annotate('', xy=(40, 160), xytext=(460, 160), arrowprops=dict(arrowstyle='<->'))
        say(ax, 250, 142, '51 mm (54 mm for an 18350)', fs=12)
        for x in (40, 460):
            ax.add_patch(Polygon([(x - 6, 230), (x + 6, 230), (x, 250)], fc=OR))
        say(ax, 250, 300, 'Smooth both cut edges with a file:\nthe strip lies against the cell\'s wrap.', fs=12)

    sc4 = Scene(items('swap', ['barrel', 'strip_neg']), cut=half, az=-60, el=55, margin=40)
    p4 = Panel(4, 'Down the groove from the open end and out through the floor. Fold the top over the end face.', sc4,
               labels=[('Groove down the bore:\nthe strip lies flat in it', ((sn[0] + sn[3]) / 2, 0, cz), (-150, -60)),
                       ('Fold 1.5 mm over the end,\ntrim it level with the edge', ((sn[0] + sn[3]) / 2, sn[4], cz),
                        (-200, 40)),
                       ('Tail out the back', ((sn[0] + sn[3]) / 2, sn[1] + 0.3, cz), (130, -40))])
    sc5 = Scene(items('swap', ['barrel', 'strip_pos', 'strip_neg']), cut=[half, ((0, -1, 0), -(yf + 9))],
                az=-60, el=60, margin=50)
    p5 = Panel(5, 'Seal both slots from inside with a drop of gel superglue, so potting epoxy can\'t seep in.', sc5,
               labels=[('Glue where each strip\ngoes through the floor', (sp[0] + 0.3, yf, cz), (-110, -100)),
                       ('', ((sn[0] + sn[3]) / 2, yf, cz), (-200, -100))])
    tp, tn = (sp[0] + 0.1, sp[1], cz), ((sn[0] + sn[3]) / 2, sn[1], cz)
    wr = [(wire([tp, (tp[0], tp[1] - 4, tp[2]), (tp[0] - 4, tp[1] - 22, tp[2] - 3)]), RED),
          (wire([tn, (tn[0], tn[1] - 4, tn[2]), (tn[0] + 4, tn[1] - 22, tn[2] - 3)]), BLK)]
    sc6 = Scene(items('swap', ['barrel', 'strip_pos', 'strip_neg'], extra=wr), az=-125, el=20, margin=40)
    p6 = Panel(6, 'Red to the + tail, black to the − tail, quickly. Heat shrink, then fold the tails flat.', sc6,
               labels=[('+ tail, red', tp, (-150, -60)), ('− tail, black', tn, (60, -130)),
                       ('Hold the tail with tweezers:\nthey take the heat, not the floor', ctr(bl, bl[5]), (-60, -110))])
    return compose('step-contacts.png', '7. Fit the contacts in the barrel (swap)',
                   'Pure nickel strip, 5 mm wide. Tin the end of each strip that will stick out of the floor before you fit it.',
                   [Panel(1, '+ strip: 12 mm, with the last 6 mm bent down.', Flat(bend)), p2,
                    Panel(3, '− strip: 51 mm, edges smoothed.', Flat(cut)), p4, p5, p6], cols=3)


# ---------- 8. cap ---------------------------------------------------------

def step_cap():
    cx, cz = cap_axis()
    cb, wb, sp, cu = bb('swap', 'cap'), bb('swap', 'washer'), bb('swap', 'spring'), bb('swap', 'cushion')
    INTO = dict(az=-115, el=28, margin=40)
    capset = ['cap', 'cushion', 'washer', 'spring']

    def into(n, text, show, moving, d, labels=(), curves=False):
        mv = {k: (0, -d, 0) for k in moving}
        sc = Scene(items('swap', show, move=mv), **INTO)
        k = moving[0]
        b = bb('swap', k, mv[k])
        ar = [] if curves else [((cx, b[1] - 4, cz), (cx, b[1] + d - 6, cz))]
        cv = [arc_y(cx, b[1] - 1, cz, 7, -20, -200)] if curves else []
        return Panel(n, text, sc, arrows=ar, curves=cv, labels=labels)

    p1 = into(1, 'Press the 12 × 1.5 O-ring into the round groove in the bottom of the cap.', ['cap', 'cushion'],
              ['cushion'], 12, labels=[('Groove round the post', (cx + 7.5, cb[4] - 2.8, cz), (120, -80))])
    p2 = into(2, 'Washer over the post, onto it, burr side down. It must sit loose and rock.', ['cap', 'cushion', 'washer'],
              ['washer'], 12, labels=[('Scrape the pocket wall\nif it binds', (cx + 10, wb[1], cz + 2), (120, -80))])
    p3 = into(3, 'Screw the spring\'s narrow end over the post\'s head, until it sits on the washer.', capset,
              ['spring'], 9, curves=True, labels=[('Whichever way\nit threads on', (cx, sp[1] - 9, cz + 6), (-120, -90))])
    half = ((0, 0, -1), -cz)
    sc4 = Scene(items('swap', capset), cut=half, az=-60, el=65, margin=60)

    def iron(ax, to_px, w, h):
        tip = to_px((cx, sp[4] - 1.9, cz))
        x, y = tip
        ax.add_patch(Polygon([(x - 3, y - 3), (x - 60, y - 140), (x - 40, y - 150)], fc='#9E9E9E', ec='#555555'))
        ax.add_patch(Polygon([(x - 60, y - 140), (x - 40, y - 150), (x - 90, y - 260), (x - 120, y - 245)],
                             fc='#2F5E9E', ec='#1C3B66'))
    p4 = Panel(4, 'Lock it on: a hot iron on the post\'s tip for a second or two, so it spreads over the head.', sc4,
               draw=iron, labels=[('Post', (cx, sp[4] - 2.5, cz), (130, 40)),
                                  ('Spring\'s end turn,\nunder the head', (cx + 2.8, sp[4] - 0.6, cz), (130, -60)),
                                  ('Washer on the\nsmall O-ring', (cx + 8, (wb[1] + wb[4]) / 2, cz), (-150, 120))],
               note='Or a dab of thick epoxy on the tip, kept off the spring.')
    bl = bb('swap', 'barrel'); o = bb('swap', 'cap_oring')
    sc5 = Scene(items('swap', ['barrel', 'cap_oring'], move={'cap_oring': (0, 12, 0)}), cut=[((0, 1, 0), cb[1] - 10)],
                **CAPV)
    p5 = Panel(5, 'Roll the big O-ring (20 × 1.5) over the thread into the groove by the step. Grease it.', sc5,
               arrows=[((cx, o[1] + 15, o[5] + 2), (cx, o[1] + 4, o[5] + 2))],
               labels=[('Groove next to\nthe step', (cx, o[1] + 1, cz - 9.5), (-130, 60))])
    sc6 = Scene(items('swap', ['barrel', 'cell', 'strip_neg', 'strip_pos', 'cap_oring', 'cap']), az=-60, el=25, margin=40)

    def meter(ax, to_px, w, h):
        a, b = draw_meter(ax, 20, 20, '4.05')
        tp = to_px((bl[0] + 6, bl[1], cz)); tn = to_px((bl[3] - 1, bl[1], cz))
        lead(ax, [a, (a[0], a[1] + 60), tp], RED, 2.5)
        lead(ax, [b, (b[0], b[1] + 30), tn], BLK, 2.5)
    p6 = Panel(6, 'Cell in, cap on until it stops: the cell\'s voltage between red and black.', sc6, draw=meter,
               note='Back the cap off about 1.5 mm at its edge: it should still read.')
    return compose('step-cap.png', '8. Fit the cap\'s washer and spring (swap)',
                   'The washer is the cap\'s half of the − contact. It floats on a small O-ring, and the post keeps it in.',
                   [p1, p2, p3, p4, p5, p6], cols=3)


# ---------- 10. glue the barrel in ---------------------------------------

def step_barrel_in():
    info = {}
    import json
    for line in open(os.path.join(ROOT, 'build', 'swap', 'info.echo')):
        if 'r2check' in line:
            info = json.loads(line.split('r2check: ', 1)[1].rstrip().rstrip('"'))
    XB, YE, PK, XD, WZ = info['X_B'], info['Y_E'], info['POCKET'], info['X_D'], info['WIRE_HOLE_Z']
    bl, sp, sn = bb('swap', 'barrel'), bb('swap', 'strip_pos'), bb('swap', 'strip_neg')
    cx, cz = cap_axis()
    ys = YE - PK / 2

    def wires(dz):
        tp, tn = (sp[0] + 0.1, sp[1] + 0.5, cz + dz), ((sn[0] + sn[3]) / 2, sn[1] + 0.5, cz + dz)
        out = []
        for t, col, dy in ((tp, RED, -0.5), (tn, BLK, 0.5)):
            pts = [t, (t[0], ys + dy, max(WZ, t[2] - 3)), (XB, ys + dy, WZ), (XD + 4, ys + dy, WZ), (XD + 9, ys + dy - 3, 2)]
            out.append((wire(pts, 0.4), col))
        return out
    p1 = Panel(1, 'Thread the barrel\'s wires through the slot in the side of the pocket, into the compartment.',
               Scene(items('swap', ['pod', 'barrel', 'strip_pos', 'strip_neg'],
                           move={'barrel': (0, 0, -12), 'strip_pos': (0, 0, -12), 'strip_neg': (0, 0, -12)},
                           extra=wires(-12)), **BACK),
               arrows=[(ctr(bl, -14), ctr(bl, -5))],
               labels=[('Wire slot', (XD + 0.5, ys, WZ), (100, 70)),
                       ('Epoxy along the trough\'s\nflat side first', ((bl[0] + bl[3]) / 2, 0, bl[5] - 1), (-140, -80))])
    blob = M.sphere(1.3, 16).scale((0.6, 1.6, 1.0)).translate((XD + 0.3, ys, WZ))
    p2 = Panel(2, 'Press it home. From inside, a small blob of thick epoxy round the wires in the slot. Let it set.',
               Scene(items('swap', ['pod', 'barrel', 'strip_pos', 'strip_neg'], extra=wires(0) + [(blob, EPOXY)]),
                     cut=[((1, 0, 0), XB + 2), ((0, -1, 0), 2), ((-1, 0, 0), -(XD + 14))], az=-25, el=-45, margin=40),
               labels=[('No more than 1 mm proud;\nlead the wires down along\nthe end wall, not up',
                        (XD + 0.4, ys, WZ), (150, -110))])
    RT = (bl[3] - bl[0]) / 2 + 0.15
    fill = box(XB - RT + 0.06, XB + RT - 0.06, YE - PK + 0.06, YE - 0.06, 0.02, 20)
    p3 = Panel(3, 'Fill the pocket with epoxy, level with the back. It covers the floor, the tails and the slot.',
               Scene(items('swap', ['pod', 'barrel', 'cap'], extra=wires(0) + [(fill, EPOXY)]), **BACK),
               labels=[('Potting pocket, full', (XB, YE - PK / 2, 0), (-120, 90))],
               note='Before it sets: cell in, cap on, wires taped apart. It still reads the cell\'s voltage.')

    def join(ax, w, h):
        lead(ax, [(40, 140), (190, 140)], RED); lead(ax, [(250, 140), (440, 140)], RED)
        ax.add_patch(FancyBboxPatch((190, 126), 60, 28, boxstyle='round,pad=0,rounding_size=6', fc='#F4C430', ec='#8A6D00'))
        say(ax, 220, 108, 'PTC fuse', fs=11)
        lead(ax, [(40, 280), (440, 280)], BLK)
        ax.add_patch(Rectangle((330, 180), 36, 60, fc='#2D3E50', ec='#111'))
        ax.add_patch(Rectangle((330, 225), 36, 15, fc='#BBBBBB'))
        lead(ax, [(348, 180), (348, 140)], RED, 2); lead(ax, [(348, 240), (348, 280)], BLK, 2)
        say(ax, 380, 205, '220 µF\n− stripe to black', fs=10.5, ha='left')
        say(ax, 40, 170, 'from the\nbarrel', fs=10.5, ha='left'); say(ax, 440, 170, 'BAT+', fs=11, ha='right', weight='bold')
        say(ax, 440, 310, 'BAT−', fs=11, ha='right', weight='bold')
        say(ax, w / 2, 390, 'Every joint in heat shrink. The full picture\nis the wiring diagram at the end of the guide.', fs=11.5)
    return compose('step-barrel-in.png', '10. Glue the barrel in (swap)',
                   'Lay the pod outer face down. The barrel is glued in for good, so check the contacts work first.',
                   [p1, p2, p3, Panel(4, 'Once it\'s cured: join the barrel\'s wires to the XIAO\'s leads, with the fuse '
                                         'and the capacitor.', Flat(join))], cols=2, pic_h=470)


# ---------- 11. bench test -----------------------------------------------

def step_bench():
    def phone(ax, x, y, lines):
        ax.add_patch(FancyBboxPatch((x, y), 150, 270, boxstyle='round,pad=0,rounding_size=18', fc='#222222'))
        ax.add_patch(Rectangle((x + 10, y + 22), 130, 226, fc='white'))
        for i, (t, col) in enumerate(lines):
            say(ax, x + 75, y + 50 + i * 34, t, fs=10.5, col=col)


    def boot(ax, w, h):
        phone(ax, 170, 60, [('MeshCore', '#111111'), ('Contacts', '#777777'), ('● dog tracker', '#2E7D32'),
                            ('battery 4.05 V', '#555555')])
        say(ax, w / 2, 380, 'Swap: cell in, cap on. Sealed: it starts as soon\nas the LiPo is soldered on.', fs=11.5)

    def led(ax, w, h):
        ax.add_patch(Rectangle((140, 120), 200, 150, fc='#2F7D3A', ec='#1B4D22'))
        say(ax, 240, 160, 'XIAO', fs=13, col='white', weight='bold')
        ax.add_patch(Circle((300, 240), 9, fc='#7CFC00', ec='#2E7D32'))
        for a in range(0, 360, 45):
            t = np.radians(a)
            ax.plot([300 + 14 * np.cos(t), 300 + 24 * np.cos(t)], [240 + 14 * np.sin(t), 240 + 24 * np.sin(t)],
                    color='#7CFC00', lw=2)
        say(ax, 300, 290, 'charge LED', fs=11)
        lead(ax, [(140, 200), (60, 200), (60, 340)], '#111', 6)
        say(ax, 60, 360, 'magnetic cable', fs=11)
        say(ax, w / 2, 400, 'You won\'t see it once the pod is closed.', fs=11.5)

    def zero(ax, w, h):
        ax.add_patch(FancyBboxPatch((70, 230), 170, 80, boxstyle='round,pad=0,rounding_size=12', fc='#222222'))
        for x in (120, 190):
            ax.add_patch(Circle((x, 270), 13, fc='#D4AF37', ec='#7A6110'))
        a, b = draw_meter(ax, 300, 40, '0.00', ok=False)
        lead(ax, [a, (a[0], 205), (120, 205), (120, 257)], RED, 2.5)
        lead(ax, [b, (b[0], 228), (190, 228), (190, 257)], BLK, 2.5)
        say(ax, w / 2, 390, 'The contacts are bare on the outside of the pod:\nthey must never carry the battery.', fs=11.5)

    def ma(ax, w, h):
        draw_cell(ax, 60, 220, 150, 50, None, end_text=False)
        a, b = draw_meter(ax, 300, 40, '7.8 mA')
        lead(ax, [(53, 245), (30, 245), (30, 205), (a[0], 205), a], RED, 2.5)
        lead(ax, [b, (b[0], 315), (470, 315)], RED, 2.5)
        say(ax, 478, 315, 'BAT+', fs=11, ha='left', weight='bold')
        lead(ax, [(213, 245), (240, 245), (240, 345), (470, 345)], BLK, 2.5)
        say(ax, 478, 345, 'BAT−', fs=11, ha='left', weight='bold')
        say(ax, w / 2, 400, 'A few mA is right. About 45 mA: the L76K is running.', fs=11.5)
    return compose('step-bench-test.png', '11. Test it on the bench',
                   'Before anything goes in the pod, on both versions.',
                   [Panel(1, 'It boots, and the MeshCore app finds it.', Flat(boot)),
                    Panel(2, 'Clip the magnetic cable on: the XIAO\'s charge LED lights.', Flat(led)),
                    Panel(3, 'Cable off: 0 V between the connector\'s two contacts.', Flat(zero)),
                    Panel(4, 'If your meter has a mA range, check the draw.', Flat(ma))], cols=2, pic_h=420)


# ---------- 12. electronics -------------------------------------------------

def step_electronics():
    def scene(v, names, k, d=14, extra_names=()):
        mv = {k: (0, 0, -d)}
        base = ['pod'] + (['barrel', 'cap'] if v == 'swap' else [])
        return Scene(items(v, base + list(extra_names) + names, move=mv), **BACK), bb(v, k, (0, 0, -d))
    s1, b1 = scene('swap', ['patch'], 'patch')
    p1 = Panel(1, 'GNSS patch into its square well, ceramic side against the outer face, lead out the back.', s1,
               arrows=[(ctr(b1, b1[2] - 3), ctr(b1, b1[2] + 9))], labels=[('Patch, up to 19 mm square', ctr(b1, b1[2]), (110, 80))])
    s2, b2 = scene('swap', ['l76k'], 'l76k', extra_names=['patch'])
    p2 = Panel(2, 'L76K stacked behind it. Plug the patch\'s lead into its U.FL.', s2,
               arrows=[(ctr(b2, b2[2] - 3), ctr(b2, b2[2] + 9))], labels=[('L76K', ctr(b2, b2[2]), (110, 80))])
    s3, b3 = scene('swap', ['xiao'], 'xiao', extra_names=['patch', 'l76k'])
    p3 = Panel(3, 'XIAO kit into its four corner posts, flat against the face. Thin tape under each board.', s3,
               arrows=[(ctr(b3, b3[2] - 3), ctr(b3, b3[2] + 9))],
               labels=[('Either way round: pick the one\nwhere the LoRa lead reaches\nwithout crossing the patch',
                        ctr(b3, b3[2]), (120, 100))])
    s4, b4 = scene('swap', ['fpc'], 'fpc', d=10, extra_names=['patch', 'l76k', 'xiao', 'pogo'])
    p4 = Panel(4, 'LoRa antenna flat on the side wall away from the barrel, clear of the boards.', s4,
               arrows=[(ctr(b4, b4[2] - 3), ctr(b4, b4[2] + 7))], labels=[('FPC antenna', ctr(b4, b4[2]), (-120, 90))],
               note='Wires tucked into the gaps at the edges. Nothing past the rim.')
    s5 = Scene(items('sealed', ['pod', 'patch', 'l76k', 'xiao', 'fpc', 'pogo']), **BACK)
    p5 = Panel(5, 'Sealed: the same boards, the antenna on the long wall the arrow points to.', s5,
               labels=[('Magnetic connector\nin the outer face', ctr(bb('sealed', 'pogo')), (-60, -120)),
                       ('FPC antenna', ctr(bb('sealed', 'fpc')), (120, -60))])
    return compose('step-electronics.png', '12. Put the electronics in',
                   'Everything sits against the inside of the outer face, located by little L-shaped posts. Seen from the back.',
                   [p1, p2, p3, p4, p5], cols=3)


# ---------- 13. close ----------------------------------------------------

def step_close():
    lb, ob, pod = bb('swap', 'lid'), bb('swap', 'oring'), bb('swap', 'pod')
    sb = bb('sealed', 'cell')
    kap = box(sb[0] + 1, sb[3] - 1, sb[1] + 1, sb[4] - 1, sb[5] + 0.3, sb[5] + 0.5)
    p1 = Panel(1, 'Sealed only: Kapton over the backs of the boards, then the LiPo, tape on its lid side.',
               Scene(items('sealed', ['pod', 'xiao', 'l76k', 'patch', 'fpc', 'pogo', 'cell'], move={'cell': (0, 0, -12)},
                           extra=[(kap, '#D9902A')]), **BACK),
               arrows=[(ctr(sb, sb[2] - 15), ctr(sb, sb[2] - 4))],
               labels=[('Kapton: nothing may\nrub through the pouch', (sb[3] - 3, sb[1] + 3, sb[5] + 0.5), (-60, -150)),
                       ('LiPo, under 1 mm to spare', ctr(sb, sb[2] - 12), (-110, 90))])
    p2 = Panel(2, 'Stretch the O-ring into the lid\'s groove (41 × 1.5 swap, 48 × 1.5 sealed). Not twisted. Grease it.',
               Scene(items('swap', ['lid', 'oring'], move={'oring': (0, 0, 7)}), az=-118, el=35, margin=60),
               arrows=[((ob[3] - 2, 0, ob[5] + 6), (ob[3] - 2, 0, ob[5] + 1))],
               labels=[('Groove round the skirt', (lb[3], 6, 3), (100, 80))])

    def line(ax, to_px, w, h, pulled=False):
        a = to_px((lb[0] - 6, lb[4] - 14, 0)); b = to_px((lb[0] + 14, lb[4] + 6, 0))
        if pulled:
            ax.plot([a[0], (a[0] + b[0]) / 2], [a[1], (a[1] + b[1]) / 2], color='#1565C0', lw=2)
        else:
            ax.plot([a[0], b[0]], [a[1], b[1]], color='#1565C0', lw=2)
    p3 = Panel(3, 'Lay 15 cm of fishing line across one corner, away from the stop tabs, ends hanging out.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'xiao', 'l76k', 'patch', 'fpc', 'pogo']), **BACK),
               draw=line, labels=[('Fishing line', (lb[0] + 4, lb[4] - 4, 0), (-120, 70))])
    p4 = Panel(4, 'Push the lid in straight, notch to notch, until it\'s flush on its stops. Don\'t pinch a wire.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'lid', 'oring'], move={'lid': (0, 0, -9), 'oring': (0, 0, -9)}),
                     **BACK),
               draw=line, arrows=[(ctr(lb, -14), ctr(lb, -4))],
               labels=[('Notch', (lb[3], 0, -9), (80, 60))])
    p5 = Panel(5, 'Pull the line out. The trapped air goes with it, so the lid doesn\'t creep back out.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'lid']), **BACK),
               draw=lambda ax, f, w, h: line(ax, f, w, h, pulled=True),
               arrows=[((lb[0] + 4, lb[4] - 4, 0), (lb[0] - 10, lb[4] - 18, 0))])
    return compose('step-close.png', '13. Close the pod', 'The lid\'s O-ring presses sideways against the pod\'s bore. '
                   'The collar lies across the lid, so it can\'t come out on the dog.', [p1, p2, p3, p4, p5], cols=3)


# ---------- 14. soak and shake ---------------------------------------------

def step_soak():
    sc = lambda: Scene(items('swap', ['pod', 'lid', 'barrel', 'cap', 'pogo']), **CAPV, margin=70)

    def tap(ax, to_px, w, h):
        ax.add_patch(Rectangle((w / 2 - 30, 0), 60, 40, fc='#9E9E9E'))
        for i in range(9):
            x = w / 2 - 22 + i * 5.5
            ax.plot([x, x + (i - 4) * 4], [40, 200], color='#4FA3E0', lw=2, alpha=0.8)

    def bowl(ax, to_px, w, h):
        ax.add_patch(Rectangle((40, 120), w - 80, h - 150, fc='#4FA3E0', alpha=0.35, zorder=4))
        ax.add_patch(Polygon([(30, 110), (w - 30, 110), (w - 70, h - 20), (70, h - 20)], fc='none', ec='#555555', lw=3,
                             zorder=4))

    def shake(ax, to_px, w, h):
        for r, a0 in ((180, 200), (200, 20)):
            ax.add_patch(Arc((w / 2, h / 2), r * 2, r * 1.4, theta1=a0, theta2=a0 + 50, color=OR, lw=4))
    open_ = Scene(items('swap', ['pod', 'barrel', 'cap', 'lid'], move={'lid': (0, 0, -12), 'cap': (0, 14, 0)}),
                  az=-30, el=-30, margin=50)
    return compose('step-soak.png', '14. Test it, soak it, shake it',
                   'Swap: with the cell out and the cap on. Find a leak now, not on the dog.',
                   [Panel(1, 'A minute under a running tap, turning it over.', sc(), draw=tap),
                    Panel(2, 'Then ten minutes in a bowl of water.', sc(), draw=bowl),
                    Panel(3, 'Dry it, open the lid and the cap: there must be no water inside.', open_,
                          note='If there is, it\'s nearly always an O-ring: twisted, dry, or not home.'),
                    Panel(4, 'Shake it hard in your fist for half a minute and tap it on a table. It must not restart.',
                          sc(), draw=shake, note='Check in the app that the node stayed up.')], cols=4, pic_h=380)


# ---------- 15. collar -------------------------------------------------------

def step_collar():
    st, pod = bb('swap', 'strap'), bb('swap', 'pod')
    p1 = Panel(1, 'Collar off the dog. Thread it through the bridge at one end, under the pod, out the other.',
               Scene(items('swap', ['pod', 'lid', 'barrel', 'cap', 'pogo', 'strap'], move={'strap': (-30, 0, 0)}), **CAPV),
               arrows=[((st[3] - 34, 0, -1.5), (st[3] - 18, 0, -1.5))],
               labels=[('Collar bridge', (pod[3] - 3, 0, -3), (90, 90))])
    p2 = Panel(2, 'Outer face out, away from the dog. Swap: cap toward the shoulders, where paws reach it less.',
               Scene(items('swap', ['pod', 'lid', 'barrel', 'cap', 'pogo', 'strap']), **CAPV),
               labels=[('Battery sign: outer face', (-5, 0, pod[5]), (-110, -90)),
                       ('Cap: toward the shoulders', ctr(bb('swap', 'cap')), (-40, -150))])
    p3 = Panel(3, 'Sealed: the arrow on the outer face shows the side with the LoRa antenna.',
               Scene(items('sealed', ['pod', 'lid', 'pogo', 'strap']), **CAPV),
               labels=[('Magnetic connector', ctr(bb('sealed', 'pogo'), bb('sealed', 'pogo')[5]), (-100, -100)),
                       ('Arrow', (6, -5, bb('sealed', 'pod')[5]), (-60, 110))])
    return compose('step-collar.png', '15. Put it on the collar',
                   'Two fingers\' room, as usual. The GNSS works best on top of the neck, worst under the chin.',
                   [p1, p2, p3], cols=3)


# ---------- 17. opening ---------------------------------------------------

def step_open():
    lb, xb = bb('swap', 'lid'), bb('swap', 'xiao')
    cn = (lb[3], 0.0, 0.0)
    p1 = Panel(1, 'Off the collar. Lever the lid out gently at the notch in the rim.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'lid'], rot={'lid': ((lb[0], 0, 0), (0, -6, 0))}), **BACK),
               labels=[('Notch', cn, (90, 70))], arrows=[((lb[3] + 3, 0, 4), (lb[3] + 3, 0, -6))])
    p2 = Panel(2, 'To reach the XIAO\'s USB-C port, peel it off the face and lift it out on its wires.',
               Scene(items('swap', ['pod', 'barrel', 'cap', 'patch', 'l76k', 'fpc', 'pogo', 'xiao'],
                           move={'xiao': (0, 0, -16)}), **BACK),
               arrows=[(ctr(xb, xb[2] - 4), ctr(xb, xb[2] - 15))],
               labels=[('USB-C', (xb[0] + 11, xb[4], xb[2] - 12), (100, 70))])
    p3 = Panel(3, 'Closing again: check the O-ring, fresh grease, and let the air out with the line.',
               Scene(items('swap', ['lid', 'oring']), az=-118, el=35, margin=70),
               labels=[('O-ring', (lb[3], 0, 3), (90, 60))], note='As in step 13.')
    return compose('step-open.png', '17. Opening it later',
                   'The lid is held by its O-ring, and by the collar when it\'s on. The barrel is glued in for good.',
                   [p1, p2, p3], cols=3)


# ---------- README pictures ---------------------------------------------

def readme_features():
    pod, cb, pg = bb('swap', 'pod'), bb('swap', 'cap'), bb('swap', 'pogo')
    a = Panel(None, '', Scene(items('swap', ['pod', 'lid', 'barrel', 'cap', 'pogo', 'strap']), **CAPV),
              labels=[('Battery sign: + end first', (-6, 2, pod[5]), (-160, -110)),
                      ('Screw cap with an O-ring', ctr(cb, cb[5]), (110, -120)),
                      ('Magnetic charge port', ctr(pg), (90, 110)),
                      ('Collar bridges: the strap\nruns under the pod', (pod[3] - 3, 0, -3), (-130, 40))])
    lb = bb('swap', 'lid')
    b = Panel(None, '', Scene(items('swap', ['pod', 'barrel', 'cap', 'lid', 'patch', 'l76k', 'xiao', 'fpc', 'pogo'],
                                    move={'lid': (0, 0, -14)}), **BACK),
              labels=[('Push-in lid with its\nown O-ring', ctr(lb, -14), (110, 110)),
                      ('Pry notch', (lb[3], 0, -14), (100, -40)),
                      ('Boards against the\nouter face', ctr(bb('swap', 'xiao'), 12), (-120, -110))])
    return compose('features-swap.png', '', '', [a, b], cols=2, pic_h=520, head_h=10)


def readme_open():
    a = Panel(None, '', Scene(items('swap', ['pod', 'barrel', 'cap', 'lid', 'patch', 'l76k', 'xiao', 'fpc', 'pogo', 'oring'],
                                    move={'lid': (0, 0, -16), 'oring': (0, 0, -16)}), **BACK))
    b = Panel(None, '', Scene(items('sealed', ['pod', 'lid', 'cell', 'patch', 'l76k', 'xiao', 'fpc', 'pogo', 'oring'],
                                    move={'lid': (0, 0, -18), 'oring': (0, 0, -18), 'cell': (0, 0, -8)}), **BACK))
    return (compose('open-swap.png', '', '', [a], cols=1, pic_h=520, W=620, head_h=10),
            compose('open-sealed.png', '', '', [b], cols=1, pic_h=520, W=620, head_h=10))


def readme_seal():
    cx, cz = cap_axis()
    lb = bb('swap', 'lid')
    a = Panel(None, 'The lid: its O-ring presses sideways on the pod\'s bore.',
              Scene(items('swap', ['pod', 'lid', 'oring', 'xiao', 'l76k', 'patch', 'strap']), cut=((0, -1, 0), -2.0),
                    az=90, el=0.5, margin=40),
              labels=[('O-ring', (lb[3], 2, 3.0), (-120, -100)), ('Lid', ((lb[0] + lb[3]) / 2, 2, 1.5), (40, 100)),
                      ('Collar: holds the lid in', (-10, 2, -1.5), (120, 80))])
    b = Panel(None, 'The cap: the same, on the barrel. The thread only holds it on.',
              Scene(items('swap', ['pod', 'barrel', 'cap', 'cap_oring', 'cell', 'washer', 'spring', 'cushion', 'strip_neg']),
                    cut=[((0, 0, -1), -cz), ((0, 1, 0), 8)], az=-90, el=89.9, margin=40),
              labels=[('O-ring', (cx - 10.7, bb('swap', 'cap_oring')[1] + 0.7, cz), (-110, 60))])
    return compose('seal.png', '', '', [a, b], cols=2, pic_h=420, head_h=40)


STEPS = {'cells': step_cells, 'fit_test': step_fit_test, 'plates': step_plates, 'dry_fit': step_dry_fit,
         'connector': step_connector, 'contacts': step_contacts, 'cap': step_cap, 'barrel_in': step_barrel_in,
         'bench': step_bench, 'electronics': step_electronics, 'close': step_close, 'soak': step_soak,
         'collar': step_collar, 'swap': step_swap, 'open': step_open,
         'features': readme_features, 'open_lid': readme_open, 'seal': readme_seal}

if __name__ == '__main__':
    names = sys.argv[1:] or list(STEPS)
    for n in names:
        print(STEPS[n]())
