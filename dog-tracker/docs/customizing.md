# Changing the design

Everything is in one OpenSCAD file, [`cad/dog-tracker.scad`](../cad/dog-tracker.scad), and every dimension is a named setting. It was written for OpenSCAD 2021.01 and works in newer versions.

## Export a part

1. Install [OpenSCAD](https://openscad.org) and open `cad/dog-tracker.scad`. The preview (F5) shows the parts laid out for printing.
2. Open the Customizer (**Window > Customizer**) and set:
   - **PART**: `kit` for every printed part of one build in one file (what's in [`stl/`](../stl)), or `pod`, `lid`, `barrel`, `cap`, `fit_test`, `assembly` or `exploded`.
   - **VERSION**: `swap` or `sealed`.
   - **CELL** (swap): `16340`, `18350` or `custom`.
   - **BATTERY** (sealed): `503040`, `603040`, `803040` or `custom`.
   - **COLLAR**: `3/4in`, `1in`, `1-1/4in`, `1-1/2in` or `custom`.
   - **POSE**: `print` puts a part the way it prints. `assembled` puts it where it sits on the collar.
3. Render (F6). The thread makes the barrel and cap take a minute or so.
4. **File > Export > Export as STL.**

From a terminal, the same thing looks like this:

```sh
openscad -o my-tracker.stl -D 'PART="kit"' -D 'VERSION="swap"' -D 'CELL="16340"' -D 'COLLAR="1-1/4in"' cad/dog-tracker.scad
```

## Your cell

The swap version's barrel is drawn round three numbers for each cell size. With **CELL** set to `custom`, you set them yourself:

| Setting | Default (16340) | What it is |
|---|---|---|
| `CUSTOM_CELL` | `[17.0, 36.6, 33.5]` | The largest diameter, the longest length and the shortest length of the cells you'll use, in mm, button included. The 18350 files use `[19.1, 39.9, 38.3]`. |
| `WASHER_D` | 0 | The washer in the cap, across. 0 means 20 mm for a 16340 and 22.2 mm for an 18350. The barrel's thread and the cap are drawn round the washer, so a bigger one makes them bigger, and the console gives the cap O-ring size to buy. If you use a washer other than the one in the parts list, set this to its size: a smaller washer in the standard cap sits loose and can miss the strip. The file stops with an error if a washer is too small to reach the − strip. |
| `WASHER_T` | 1.2 | Its thickness. |
| `WASHER_HOLE` | 5.0 | The size of its hole. It has to clear the post in the cap, and be small enough that the spring's narrow end can't drop through. The file stops with an error if it's outside that range. |
| `SPRING` | `[5.6, 10.0, 0.7, 12.0]` | The conical spring: the outside diameter of its narrow end and of its wide end, its wire, and its length when free, in mm. The post in the cap is sized to fit inside the narrow end. |
| `KEEPER` | 0.4 | How far the + contact sits below the ring round it. A button top has to stick out further than this to reach it. 0 makes it flush, so flat-top cells work, but then a cell put in backwards connects too, and reverse power can kill the XIAO. |

The barrel is made long enough that the longest cell squeezes the spring to half its free length. A shorter cell squeezes it less. The file stops with an error if the shortest cell would squeeze it less than 2.5 mm, which with the default spring means the cells can differ in length by up to 3.5 mm.

## Your pouch cell

For the sealed version with **BATTERY** set to `custom`, `CUSTOM_POUCH` is the cell's thickness, width and length in mm, including its protection board and any tape. The pod grows round it. A bigger footprint cell, like a 603450 (about 1100 mAh), gives the sealed version more runtime without making it taller.

## Your collar

**COLLAR** sets the strap tunnels' width, 1 mm more than the strap. For a strap between the standard sizes, set **COLLAR** to `custom` and `CUSTOM_STRAP_W` to its width in mm. `STRAP_T` is the room for the strap's thickness, 4.2 mm by default. Most collars are 2 to 4 mm thick.

On the swap version, the cap sits beyond the strap's edge, so on wide straps the barrel moves out and the pod grows across the collar. For the 16340 it's 54.2 mm across the collar for ¾ in, 55.1 for 1 in, 58.2 for 1¼ in and 61.4 for 1½ in. The sealed pod takes straps up to 1¼ in.

## Fits for your hardware

The fit test tells you which of these to change.

| Setting | Default | What it is |
|---|---|---|
| `THREAD_GAP` | 0.25 | Clearance between the cap's thread and the barrel's, per side. If the fit test's cap binds, make it 0.3. If it rocks, 0.2. It changes the cap only, so you only need to reprint the cap. |
| `LID_GAP` | 0.20 | Clearance between the lid's skirt and the pod, per side. |
| `POGO_FACE` | `[11.5, 5.0]` | The opening for the magnetic connector, width × height. Anything up to this size fits; a smaller one is potted in flush. The opening's bottom edge stays just above the lid's skirt. The file stops with an error if it's so tall the connector could reach the XIAO: the 16340 pod has room for 5.4 mm, the 18350 pod for 7.5. |
| `POGO_BODY` | `[10.2, 4.6, 6.0]` | The connector's body, for the stand-in in the checks only. |

## What the file checks for you

When you open the file, OpenSCAD prints a few lines in its console starting with `r2:`. They give:

- the pod's size, and the cap's
- the barrel's length, its bore, the washer, and how tall the spring is, and how much it's squeezed, with the longest and the shortest cell
- each O-ring's size, stretch, squeeze and groove fill

It stops with an error if an O-ring's stretch, squeeze or fill goes out of range, the strap is too wide for the pod, the washer is too small for the strip or the small O-ring, the spring's narrow end is too big for the washer's hole, the cells are too different in length for the spring, or the magnetic connector's opening is too tall.

**The O-rings.** All three are 1.5 mm cross-section. The lid's groove (`G_Z`, `G_D`) and the cap's (`OR_W`, `OR_GLAND`) are set for 1.5 to 3% stretch, 23% squeeze and less than 85% fill. The cap's is sized to fit the washer through the thread and then rounded to a whole millimetre, so it changes with the washer. The small one under the washer, 12 × 1.5, is squeezed 20% when the cap is tight: its groove (`CU_DEPTH`) is a whole number of 0.2 mm layers deep, so it prints the depth it's drawn. The console tells you the sizes to buy after any change.

**The thread.** `TH_D`, `TH_P` and `TH_N` are its depth, the spacing between ridges and the number of starts: 0.7 mm, 2 mm and 2, which gives a 4 mm lead and about 1¼ turns to close. The ridges have 45° flanks, so they print standing up without support.

## Checking your changes

The scripts in [`cad/tools/`](../cad/tools) export every part in its assembled position, check the parts against each other and against stand-ins for the boards, cell, spring, washer, strips and strap, and draw the pictures. They need Python 3:

```sh
pip install manifold3d trimesh numpy scipy matplotlib
python3 cad/tools/export.py --parts     # parts and stand-ins, assembled, into build/
python3 cad/tools/check.py              # PASS or FAIL for each combination
python3 cad/tools/export.py --release   # the files in stl/
```

The checks include:

- whether the cap screws off along its thread without touching the barrel or the pod
- whether the cell slides out of the barrel, and the washer goes into the cap
- whether the barrel drops into its trough from the back
- whether the battery wires' slot from the potting pocket opens fully into the compartment, clear of the boards
- whether the magnetic connector clears the lid and the XIAO wherever it sits in its opening
- whether the lid and its O-ring push in without hitting anything

[`cad/tools/README.md`](../cad/tools/README.md) has the details.

## Other ideas

- **A bigger sealed battery.** A 603450 or 604050 pouch fits a longer pod at the same height. Set `CUSTOM_POUCH`.
- **A harness.** The collar bridges take any flat strap. A harness strap up to 1½ in works on the swap version, and up to 1¼ in on the sealed one.
- **Switching the L76K off completely.** Seeed's module draws 0.36 mA on standby, a big share of the budget for a battery that lasts weeks. A small load switch on its 3V3, driven by D0 instead of its standby line, would cut that to almost nothing. There's room for one in the compartment, but it isn't drawn.
