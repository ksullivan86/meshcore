# Tools

Scripts for rebuilding and checking the design. You don't need them to build a tracker, only if you change the OpenSCAD file and want to make new release files or check your changes. Run them from the `dog-tracker` folder.

They need Python 3 and OpenSCAD on the PATH:

```sh
pip install manifold3d trimesh numpy scipy matplotlib
```

| Script | What it does |
|---|---|
| `export.py` | Renders the release STLs into `stl/` (the default), as binary STLs. `--parts` exports every part and every stand-in (boards, cell, washer, spring, the O-rings, nickel strips, strap) in the assembled pose into `build/<variant>/`, with the console output in `info.echo`, for the checks and pictures. It checks every release combination and a few others. It runs two OpenSCAD processes at a time and skips files whose inputs haven't changed. |
| `check.py` | Loads `build/<variant>/` and reports, for each combination of version, cell or pouch and collar: overlaps between parts, parts against the stand-ins, the gaps that matter, and whether the cap screws off along its thread, the cell slides out, the washer goes into the cap, the barrel drops into its trough, the battery wires' slot opens into the compartment and misses the boards, the magnetic connector clears the lid and the XIAO anywhere in its opening, and the lid pushes in without hitting anything. It prints PASS or FAIL for each, and the details, with the console lines, as JSON. |
| `render.py` | Draws the pictures in `images/` (`images`, `layout`) and a quick preview (`sheet swap`, `sheet sealed`) with a small built-in renderer. |
| `wiring.py` | Draws `images/wiring.png`. |

A full check after a change:

```sh
python3 cad/tools/export.py --parts
python3 cad/tools/check.py > build/check.json
python3 cad/tools/export.py --release
python3 cad/tools/render.py images && python3 cad/tools/render.py layout
python3 cad/tools/wiring.py
```

The OpenSCAD file checks the things these scripts can't see, like the O-rings' stretch and squeeze and the spring's squeeze, and stops with an error if one is out of range.

`build/` is ignored by git.
