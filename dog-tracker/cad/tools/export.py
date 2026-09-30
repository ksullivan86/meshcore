#!/usr/bin/env python3
"""Export parts from cad/dog-tracker.scad with the OpenSCAD command line.

    python3 cad/tools/export.py                 # the release STLs into stl/
    python3 cad/tools/export.py --parts         # every part, assembled pose, into build/ (for checks and renders)

Needs OpenSCAD on the PATH. Each call to OpenSCAD renders one part; they run
two at a time.
"""
import argparse, hashlib, json, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCAD = os.path.join(ROOT, 'cad', 'dog-tracker.scad')

# The release files: one STL per build, every printed part laid out for the printer.
RELEASE = [
    ('dog-tracker-swap-16340-3-4in.stl',    dict(PART='kit', VERSION='swap', CELL='16340', COLLAR='3/4in')),
    ('dog-tracker-swap-16340-1in.stl',      dict(PART='kit', VERSION='swap', CELL='16340', COLLAR='1in')),
    ('dog-tracker-swap-16340-1-1-2in.stl',  dict(PART='kit', VERSION='swap', CELL='16340', COLLAR='1-1/2in')),
    ('dog-tracker-swap-18350-1in.stl',      dict(PART='kit', VERSION='swap', CELL='18350', COLLAR='1in')),
    ('dog-tracker-swap-18350-1-1-2in.stl',  dict(PART='kit', VERSION='swap', CELL='18350', COLLAR='1-1/2in')),
    ('dog-tracker-sealed-603040-3-4in.stl', dict(PART='kit', VERSION='sealed', BATTERY='603040', COLLAR='3/4in')),
    ('dog-tracker-sealed-603040-1in.stl',   dict(PART='kit', VERSION='sealed', BATTERY='603040', COLLAR='1in')),
    ('dog-tracker-sealed-803040-1in.stl',   dict(PART='kit', VERSION='sealed', BATTERY='803040', COLLAR='1in')),
    ('fit-test-16340.stl',                  dict(PART='fit_test', VERSION='swap', CELL='16340')),
    ('fit-test-18350.stl',                  dict(PART='fit_test', VERSION='swap', CELL='18350')),
]

SWAP_PARTS = ['pod', 'lid', 'barrel', 'cap']
SEALED_PARTS = ['pod', 'lid']
SWAP_DUMMIES = ['xiao', 'patch', 'l76k', 'pogo', 'fpc', 'cell', 'washer', 'spring', 'cushion', 'strip_neg', 'strip_pos',
                'cap_oring', 'oring', 'strap']
SEALED_DUMMIES = ['xiao', 'patch', 'l76k', 'pogo', 'fpc', 'cell', 'oring', 'strap']


def defs(params):
    out = []
    for k, v in params.items():
        out += ['-D', f'{k}="{v}"' if isinstance(v, str) else f'{k}={v}']
    return out


def run(out_path, params, cache_dir=None):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    key = hashlib.sha1((open(SCAD, 'rb').read().hex() + json.dumps(params, sort_keys=True)).encode()).hexdigest()[:16]
    stamp = os.path.join(ROOT, 'build', '.cache', os.path.relpath(out_path, ROOT).replace(os.sep, '_') + '.key')
    os.makedirs(os.path.dirname(stamp), exist_ok=True)
    if os.path.exists(out_path) and os.path.exists(stamp) and open(stamp).read() == key:
        return out_path, 'cached'
    cmd = ['openscad', '-o', out_path] + defs(params) + [SCAD]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if 'top level object is empty' in r.stderr:
        if os.path.exists(out_path):
            os.remove(out_path)
        return out_path, 'empty'
    if r.returncode != 0 or not os.path.exists(out_path):
        raise RuntimeError(f'{out_path}: {r.stderr[-2000:]}')
    if os.path.basename(os.path.dirname(out_path)) == 'stl':
        import trimesh
        trimesh.load(out_path, force='mesh').export(out_path)       # binary STL
    open(stamp, 'w').write(key)
    return out_path, 'built'


def jobs_parts(variant, base):
    """Every part and stand-in of one variant, in the assembled pose."""
    jobs = []
    d = os.path.join(ROOT, 'build', variant)
    swap = base.get('VERSION') == 'swap'
    for p in (SWAP_PARTS if swap else SEALED_PARTS):
        jobs.append((os.path.join(d, p + '.stl'), dict(base, PART=p, POSE='assembled')))
    for m in (SWAP_DUMMIES if swap else SEALED_DUMMIES):
        jobs.append((os.path.join(d, 'dummy_' + m + '.stl'), dict(base, DUMMY=m)))
    jobs.append((os.path.join(d, 'info.echo'), dict(base, PART='lid')))       # the console numbers, for check.py
    return jobs


VARIANTS = {
    # the release files
    'swap': dict(VERSION='swap'),                                           # 16340, 1 in
    'swap-16340-3-4in': dict(VERSION='swap', CELL='16340', COLLAR='3/4in'),
    'swap-16340-1-1-2in': dict(VERSION='swap', CELL='16340', COLLAR='1-1/2in'),
    'swap-18350-1in': dict(VERSION='swap', CELL='18350', COLLAR='1in'),
    'swap-18350-1-1-2in': dict(VERSION='swap', CELL='18350', COLLAR='1-1/2in'),
    'sealed': dict(VERSION='sealed'),                                       # 603040, 1 in
    'sealed-603040-3-4in': dict(VERSION='sealed', BATTERY='603040', COLLAR='3/4in'),
    'sealed-803040-1in': dict(VERSION='sealed', BATTERY='803040', COLLAR='1in'),
    # other combinations people might export
    'swap-18350-1-1-4in': dict(VERSION='swap', CELL='18350', COLLAR='1-1/4in'),
    'sealed-803040-1-1-4in': dict(VERSION='sealed', BATTERY='803040', COLLAR='1-1/4in'),
    'sealed-503040-3-4in': dict(VERSION='sealed', BATTERY='503040', COLLAR='3/4in'),
}

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--parts', action='store_true', help='export parts + stand-ins for checks')
    ap.add_argument('--variant', action='append', help='limit --parts to these variants')
    ap.add_argument('--release', action='store_true', help='export the release STLs')
    ap.add_argument('--extra', nargs=2, action='append', metavar=('OUT', 'JSON'), help='one-off export')
    a = ap.parse_args()
    jobs = []
    if a.parts:
        for v in (a.variant or VARIANTS):
            jobs += jobs_parts(v, VARIANTS[v])
    if a.release or not (a.parts or a.extra):
        jobs += [(os.path.join(ROOT, 'stl', f), p) for f, p in RELEASE]
    for out, js in (a.extra or []):
        jobs.append((out, json.loads(js)))
    with ThreadPoolExecutor(max_workers=2) as ex:
        for path, status in ex.map(lambda j: run(*j), jobs):
            print(f'{status:6s} {os.path.relpath(path, ROOT)}', flush=True)
