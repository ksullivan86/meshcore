#!/usr/bin/env python3
"""Preview renders from the exported parts (cad/tools/export.py --parts first).

    python3 cad/tools/render.py sheet swap        # quick preview sheet -> build/preview_swap.png
    python3 cad/tools/render.py images            # the README/doc images -> images/

A small numpy z-buffer rasterizer (orthographic, CAD-style edges), so it
needs nothing beyond numpy, trimesh, manifold3d and matplotlib.
"""
import os, sys
import numpy as np
import trimesh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import manifold3d as m3
from manifold3d import Manifold as M

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

COL = dict(pod='#F07F2A', lid='#4F5D6B', barrel='#E9E3D2', cap='#2E6F95',
           xiao='#2F7D3A', patch='#D8C7A4', l76k='#1F5FB0', pogo='#1B1B1B', fpc='#E3A21A',
           cell='#AEB6BF', washer='#7F8A95', spring='#5E666E', cushion='#111111', strip_neg='#3A3A3A', strip_pos='#C0392B',
           cap_oring='#111111', oring='#111111', strap='#27435F', kit='#F07F2A')


def hexrgb(h):
    h = h.lstrip('#')
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float) / 255.0


def load(path):
    tm = trimesh.load(path, force='mesh')
    return M(m3.Mesh(vert_properties=np.asarray(tm.vertices, np.float32), tri_verts=np.asarray(tm.faces, np.uint32)))


def arrays(man):
    m = man.to_mesh()
    return np.asarray(m.vert_properties)[:, :3].astype(float), np.asarray(m.tri_verts).astype(int)


def camera(az, el):
    az, el = np.radians(az), np.radians(el)
    f = -np.array([np.cos(el) * np.cos(az), np.cos(el) * np.sin(az), np.sin(el)])
    up = np.array([0, 0, 1.0])
    if abs(np.dot(f, up)) > 0.99:
        up = np.array([0, 1.0, 0])
    r = np.cross(f, up); r /= np.linalg.norm(r)
    u = np.cross(r, f)
    return f, r, u


def render(objs, az=-60, el=30, size=(1100, 800), ss=2, margin=40, bg=(1, 1, 1), proj=False):
    """objs: list of (manifold, hexcolor). Returns an RGB float image, and with
    proj=True also a function mapping model points to output-image pixels."""
    W, H = size[0] * ss, size[1] * ss
    f, r, u = camera(az, el)
    data, allp = [], []
    for oid, (man, col) in enumerate(objs):
        if man is None or man.is_empty():
            continue
        V, F = arrays(man)
        data.append((oid, V, F, hexrgb(col)))
        allp.append(V)
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
            m = (w0 >= -1e-6) & (w1 >= -1e-6) & (w2 >= -1e-6)
            if not m.any():
                continue
            z = w0 * az_ + w1 * bz + w2 * cz
            sub = zbuf[ymin:ymax + 1, xmin:xmax + 1]
            upd = m & (z < sub)
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


def parts(variant):
    d = os.path.join(ROOT, 'build', variant)
    out = {}
    for f in os.listdir(d):
        if f.endswith('.stl'):
            k = f[:-4].replace('dummy_', '')
            m = load(os.path.join(d, f))
            if not m.is_empty():
                out[k] = m
    return out


def objs(p, names, move=None):
    move = move or {}
    return [(p[k].translate(move.get(k, (0, 0, 0))), COL[k]) for k in names if k in p]


INSIDE = ['xiao', 'patch', 'l76k', 'pogo', 'fpc']
CELLPARTS = ['cell', 'washer', 'spring', 'cushion', 'strip_neg', 'strip_pos', 'cap_oring']


def axis(p):
    """The barrel's axis (x, z) and the Y of the barrel's floor (inside face)."""
    lo, hi = np.array(p['cap'].bounding_box()[:3]), np.array(p['cap'].bounding_box()[3:])
    bl = p['barrel'].bounding_box()
    return (lo[0] + hi[0]) / 2, (lo[2] + hi[2]) / 2, bl[1] + 2.0


def labelled(img, to_px, labels, fn, size, title=None, fs=11):
    """labels: list of (text, model point, (dx, dy) offset of the text in pixels)."""
    fig, ax = plt.subplots(figsize=(size[0] / 100, size[1] / 100), dpi=100)
    ax.imshow(np.clip(img, 0, 1)); ax.axis('off')
    for t, pt, off in labels:
        x, y = to_px(pt)
        ax.annotate(t, xy=(x, y), xytext=(x + off[0], y + off[1]), fontsize=fs, ha='center', va='center',
                    color='#1A1A1A', bbox=dict(boxstyle='round,pad=0.25', fc=(1, 1, 1, 0.85), ec='#999999', lw=0.6),
                    arrowprops=dict(arrowstyle='-', color='#333333', lw=0.9, shrinkA=0, shrinkB=2))
    if title:
        ax.text(size[0] / 2, 8, title, ha='center', va='top', fontsize=10, color='#666666')
    plt.subplots_adjust(0, 0, 1, 1)
    out = os.path.join(ROOT, 'images', fn)
    fig.savefig(out, facecolor='white')
    plt.close(fig)
    return out


def views_swap(p):
    ax_, az_, yf = axis(p)
    out = {}
    out['collar'] = render(objs(p, ['pod', 'lid', 'barrel', 'cap', 'pogo', 'strap']), az=-58, el=34)
    mv = {k: (0, 34, 0) for k in ('cap', 'washer', 'spring', 'cushion')}
    mv['cell'] = (0, 17, 0)
    out['cap_off'] = render(objs(p, ['pod', 'lid', 'barrel', 'cap', 'cell', 'washer', 'spring', 'cushion', 'cap_oring', 'pogo', 'strap'],
                                 move=mv), az=152, el=30)
    return out


def section_swap(p, fn='section-swap.png', size=(1300, 900)):
    """Cut 1.5 mm below the barrel's axis, looking down: the cell, both contacts, the cap."""
    ax_, az_, yf = axis(p)
    zc = az_ - 1.45
    keep = lambda m: m.trim_by_plane((0, 0, -1), -zc)
    names = ['pod', 'lid', 'barrel', 'cap'] + CELLPARTS + INSIDE
    sec = [(keep(m), c) for m, c in objs(p, names)]
    img, to_px = render(sec, az=-90, el=89.9, size=size, margin=(150), proj=True)
    bl = p['barrel'].bounding_box(); cp = p['cap'].bounding_box(); cl = p['cell'].bounding_box()
    wb = p['washer'].bounding_box(); sp = p['spring'].bounding_box(); cu = p['cushion'].bounding_box()
    xd = p['xiao'].bounding_box()
    r_cell = (cl[3] - cl[0]) / 2
    L = [('cap', (ax_ - 11.8, cp[4] - 4.0, zc), (-130, -60)),
         ('thread: two starts,\nabout 1 1/4 turns to close', (ax_ - 10.4, cp[1] + 6.2, zc), (-250, 30)),
         ('O-ring', (ax_ - 10.7, cp[1] + 2.2, zc), (-210, 60)),
         ('spring', (ax_ - 3.0, (sp[1] + sp[4]) / 2, zc), (-330, 120)),
         ('post: keeps the spring\nand washer in the cap', (ax_, wb[1] - 1.8, zc), (330, -150)),
         ('washer: lands on the - strip\nwhere it folds over the end', (ax_ + 8.0, (wb[1] + wb[4]) / 2, zc), (560, -70)),
         ('small O-ring: the washer\nfloats on it', (ax_ + 6.5, (cu[1] + cu[4]) / 2, zc), (570, 30)),
         ('cell, + end first', (ax_ - 3, (cl[1] + cl[4]) / 2, zc), (-260, 0)),
         ('- strip in a groove\ndown the bore', (ax_ + r_cell + 0.5, (cl[1] + cl[4]) / 2 - 6, zc), (540, 40)),
         ('+ contact: nickel strip on the\nfloor, 0.4 mm below a ring', (ax_ + 0.5, yf + 0.1, zc), (-310, 40)),
         ('potting pocket: the strips\' tails\nand their wires, in epoxy', (ax_ - 5, bl[1] - 2.0, zc), (-260, 110))]
    return labelled(img, to_px, L, fn, size, None)


def parts_swap(p, fn='barrel-parts.png', size=(1300, 700)):
    """The barrel and everything that goes in it, pulled apart along the axis."""
    ax_, az_, yf = axis(p)
    mv = {'cell': (0, 48, 0), 'spring': (0, 55, 0), 'washer': (0, 61, 0), 'cushion': (0, 67, 0), 'cap': (0, 84, 0)}
    names = ['barrel', 'strip_neg', 'strip_pos', 'cap_oring', 'cell', 'spring', 'washer', 'cushion', 'cap']
    img, to_px = render(objs(p, names, move=mv), az=-8, el=18, size=size, margin=120, proj=True)
    bb = lambda k: np.array(p[k].bounding_box()) + np.array(list(mv.get(k, (0, 0, 0))) * 2)
    ctr = lambda b: ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, (b[2] + b[5]) / 2)
    bl, cl, cp, wb, sp, o, cu, sn, spos = (bb(k) for k in ('barrel', 'cell', 'cap', 'washer', 'spring', 'cap_oring',
                                                               'cushion', 'strip_neg', 'strip_pos'))
    L = [('barrel, printed standing\non its closed end', (ax_, bl[1] + 10, bl[5] - 1), (-40, -150)),
         ('O-ring', (ax_, (o[1] + o[4]) / 2, o[5]), (-60, -110)),
         ('- strip, folded\nover the end', (sn[3], sn[4] - 0.2, sn[5]), (40, -170)),
         ('+ strip', (spos[0], spos[1] + 0.5, (spos[2] + spos[5]) / 2), (20, 140)),
         ('16340 cell,\n+ end first', (ax_, (cl[1] + cl[4]) / 2, cl[5]), (0, -120)),
         ('spring', ctr(sp), (-20, 150)),
         ('washer', (ax_, (wb[1] + wb[4]) / 2, wb[5] - 0.3), (-60, -130)),
         ('small O-ring', (ax_, (cu[1] + cu[4]) / 2, cu[5]), (10, -150)),
         ('cap, with the\npost inside', (ax_ + 8, (cp[1] + cp[4]) / 2, cp[5] - 2), (60, 140))]
    return labelled(img, to_px, L, fn, size)


def views_sealed(p):
    out = {}
    out['collar'] = render(objs(p, ['pod', 'lid', 'pogo', 'strap']), az=-58, el=34)
    out['open'] = render(objs(p, ['pod', 'cell'] + INSIDE, move={'cell': (0, 0, -16)}), az=-122, el=-38)
    return out


def plate(stl, az=-60, el=45, size=(1100, 800)):
    return render([(load(stl), COL['kit'])], az=az, el=el, size=size)


def save(img, name):
    os.makedirs(os.path.join(ROOT, 'images'), exist_ok=True)
    fn = os.path.join(ROOT, 'images', name)
    plt.imsave(fn, np.clip(img, 0, 1))
    return fn


def layout(variant, fn):
    """Looking into the pod from the back, lid off, with the boards labelled."""
    p = parts(variant)
    names = ['pod'] + INSIDE + (['barrel'] if variant.startswith('swap') else [])
    size = (1100, 950)
    img, to_px = render(objs(p, names), az=-90, el=-89.9, size=size, margin=140, proj=True)
    ctr = lambda k, dz=0: (lambda b: ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, b[2] + dz))(p[k].bounding_box())
    if variant.startswith('swap'):
        ax_, az_, yf = axis(p)
        bl = p['barrel'].bounding_box()
        L = [('XIAO + Wio-SX1262', ctr('xiao'), (0, 0)),
             ('L76K, with the\nGNSS patch under it\n(ceramic side to the face)', ctr('l76k'), (0, 0)),
             ('magnetic connector\nin the end wall', ctr('pogo'), (0, -70)),
             ('LoRa antenna (FPC)\non the side wall', ctr('fpc'), (-115, -40)),
             ('barrel', (ax_, (bl[1] + bl[4]) / 2, 0), (0, 0)),
             ('battery wires come in here', (ax_ + 17.0, bl[1] - 2.0, 0), (60, 80))]
        note = 'looking into the pod from the back, lid off'
    else:
        L = [('XIAO + Wio-SX1262', ctr('xiao'), (0, 0)),
             ('L76K, with the GNSS\npatch under it\n(ceramic side to the face)', ctr('l76k'), (0, 0)),
             ('magnetic\nconnector', ctr('pogo'), (0, 0)),
             ('LoRa antenna (FPC)\non the long wall the\narrow points to', ctr('fpc'), (0, -70))]
        note = 'looking into the pod from the back, lid off; the LiPo goes in last, over everything'
    fig_fn = labelled(img, to_px, L, fn, size, note, fs=12)
    return fig_fn


def sheet(variant):
    p = parts(variant)
    if variant.startswith('swap'):
        v = views_swap(p)
        panels = [('On the collar', v['collar']), ('Cap off, cell coming out', v['cap_off'])]
    else:
        v = views_sealed(p)
        panels = [('On the collar', v['collar']), ('Inside, from the back', v['open'])]
    fig, axs = plt.subplots(1, 2, figsize=(16, 6), dpi=100)
    for a, (t, im) in zip(axs.ravel(), panels):
        a.imshow(im); a.set_title(t, fontsize=13); a.axis('off')
    plt.tight_layout()
    fn = os.path.join(ROOT, 'build', f'preview_{variant}.png')
    fig.savefig(fn, facecolor='white')
    plt.close(fig)
    return fn


KITS = ['dog-tracker-swap-16340-3-4in', 'dog-tracker-swap-16340-1in', 'dog-tracker-swap-16340-1-1-2in',
        'dog-tracker-swap-18350-1in', 'dog-tracker-swap-18350-1-1-2in',
        'dog-tracker-sealed-603040-3-4in', 'dog-tracker-sealed-603040-1in', 'dog-tracker-sealed-803040-1in',
        'fit-test-16340']


def images():
    """The README and doc images."""
    out = []
    p = parts('swap')
    v = views_swap(p)
    out.append(save(v['collar'], 'hero-swap.png'))
    out.append(save(v['cap_off'], 'swap-cap-off.png'))
    out.append(section_swap(p))
    out.append(parts_swap(p))
    s = parts('sealed')
    vs = views_sealed(s)
    out.append(save(vs['collar'], 'hero-sealed.png'))
    out.append(save(vs['open'], 'inside-sealed.png'))
    for f in KITS:
        out.append(save(plate(os.path.join(ROOT, 'stl', f + '.stl'), size=(800, 600)), 'kit-' + f.replace('dog-tracker-', '') + '.png'))
    return out


if __name__ == '__main__':
    what = sys.argv[1] if len(sys.argv) > 1 else 'sheet'
    if what == 'sheet':
        for v in sys.argv[2:] or ['swap', 'sealed']:
            print(sheet(v))
    elif what == 'images':
        for f in images():
            print(f)
    elif what == 'layout':
        print(layout('swap', 'layout-swap.png'))
        print(layout('sealed', 'layout-sealed.png'))
