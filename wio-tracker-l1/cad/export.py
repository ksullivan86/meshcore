"""Exports the STLs into stl/: one file per version, every printed part in it.

    python cad/export.py --fit    # wio-tracker-l1-eink-fit-test.stl (the four coupon pieces, laid out to print)
    python cad/export.py --fit -D PCB_T=1.2   # any OpenSCAD override

The release kit (wio-tracker-l1-eink.stl) comes once the fit test has passed on the bench.

Needs OpenSCAD (on the PATH, or set OPENSCAD to its executable) and: pip install trimesh networkx.
Run it from the project folder. Writes binary STLs. Run cad/check_case.py with the same overrides first.
"""
import argparse, os, shutil, subprocess, sys, tempfile
import trimesh

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, 'wio-tracker-l1.scad')
OUT = os.path.join(HERE, '..', 'stl')

def openscad():
    for c in (os.environ.get('OPENSCAD'), shutil.which('openscad'), r'C:\Program Files\OpenSCAD\openscad.com',
              '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD'):
        if c and os.path.exists(c): return c
    sys.exit('OpenSCAD not found: put it on the PATH or set OPENSCAD')

def export(part, name, defs):
    with tempfile.TemporaryDirectory() as t:
        tmp = os.path.join(t, 'out.stl')
        r = subprocess.run([openscad(), '-o', tmp, '-D', f'PART="{part}"'] +
                           sum([['-D', d] for d in defs], []) + [SCAD], capture_output=True, text=True)
        log = r.stdout + r.stderr
        if r.returncode or 'ERROR' in log: sys.exit(f'OpenSCAD failed on {name}:\n{log[-2000:]}')
        m = trimesh.load(tmp, force='mesh')
    os.makedirs(OUT, exist_ok=True)
    m.export(os.path.join(OUT, name), file_type='stl')
    print(f'{name}: {len(m.split(only_watertight=False))} parts, {m.extents.round(1).tolist()} mm, {abs(m.volume) / 1000:.1f} cm3')

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--fit', action='store_true')
    ap.add_argument('-D', action='append', default=[])
    a = ap.parse_args()
    if a.fit: export('fit_test', 'wio-tracker-l1-eink-fit-test.stl', a.D)
    else: sys.exit('Only the fit test is built so far: python cad/export.py --fit')
