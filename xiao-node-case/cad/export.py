"""Exports the release STLs into stl/: one file per version, every printed part in it.

    python3 cad/export.py          # xiao-node-case-1bay.stl, -2bay.stl, -3bay.stl
    python3 cad/export.py --fit    # xiao-node-case-fit-test.stl (one bay, no base plate)
    python3 cad/export.py -D 'LABELS=["HA","OBS","RELAY"]'   # any OpenSCAD override

Needs OpenSCAD on the PATH and: pip install trimesh. Run it from the xiao-node-case folder.
Writes binary STLs. Run cad/check_case.py with the same overrides first.
"""
import argparse, os, subprocess, sys, tempfile
import trimesh

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, 'xiao-node-case.scad')
OUT = os.path.join(HERE, '..', 'stl')

def export(part, bays, name, defs):
    with tempfile.TemporaryDirectory() as t:
        tmp = os.path.join(t, 'out.stl')
        r = subprocess.run(['openscad', '-o', tmp, '-D', f'PART="{part}"', '-D', f'BAYS={bays}'] +
                           sum([['-D', d] for d in defs], []) + [SCAD], capture_output=True, text=True)
        if r.returncode or 'ERROR' in r.stderr: sys.exit(f'OpenSCAD failed on {name}:\n{r.stderr[-2000:]}')
        m = trimesh.load(tmp, force='mesh')
    os.makedirs(OUT, exist_ok=True)
    m.export(os.path.join(OUT, name), file_type='stl')
    print(f'{name}: {len(m.split(only_watertight=False))} parts, {m.extents.round(1).tolist()} mm')

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--fit', action='store_true')
    ap.add_argument('-D', action='append', default=[])
    a = ap.parse_args()
    if a.fit: export('fit_test', 1, 'xiao-node-case-fit-test.stl', a.D)
    else:
        for n in (1, 2, 3): export('kit', n, f'xiao-node-case-{n}bay.stl', a.D)
