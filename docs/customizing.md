# Changing the design

Everything is in one OpenSCAD file, [`cad/tahoe-repeater.scad`](../cad/tahoe-repeater.scad), and every dimension is a named setting near the top. It was written for OpenSCAD 2021.01 and works in newer versions.

## Export a part

1. Install [OpenSCAD](https://openscad.org) and open `cad/tahoe-repeater.scad`. The preview (F5) shows the assembled repeater with a stand-in panel.
2. Open the Customizer (**Window > Customizer**) and set:
   - **PART**: `upper` (A top or B lid), `lower` (A base or B can), `bracket`, `sled`, `thread_test_male`, `thread_test_female`, `fit_test`, `wing_spacers` (B wing-nut only), or `kit` for everything laid out.
   - **VERSION**: `A` or `B`.
   - **MOUNT**: `tree` (tree-screw), `bolt` (bolt-on) or `wing` (wing-nut). Only the bracket uses it.
   - **POSE**: `print` puts the part the way it prints. `assembled` puts it where it sits on the tree.
3. Render (F6). Parts with the thread take a minute or two, and `kit` takes several minutes.
4. **File > Export > Export as STL.**

From a terminal, the same thing looks like this:

```sh
openscad -o bracket-A-bolt.stl -D 'PART="bracket"' -D 'VERSION="A"' -D 'MOUNT="bolt"' cad/tahoe-repeater.scad
```

The files in [`stl/`](../stl) were laid out by a script, so `kit` gives you the same parts in a slightly different arrangement.

## The panel mount's holes

This is the one most people will need. The brackets are drawn for a round mount with three holes, 36 mm apart center to center, evenly spaced, with one at 12 o'clock.

To measure yours, take the mount off the panel and measure between the centers of two holes with calipers. Or measure edge to edge and add one hole's width. Then set:

| Setting | Default | What it is |
|---|---|---|
| `MOUNT_HOLE_SPACING` | 36 | Center to center between two of the three holes, in mm. |
| `MOUNT_HOLE_ANG` | `[90, 210, 330]` | Where the holes sit, in degrees counterclockwise from 3 o'clock, seen from the front. 90 is 12 o'clock. If yours aren't evenly spaced, measure the angles and put them here. The tree-screw mount's long screw always uses the hole at 90, so keep one there. |
| `MOUNT_D` | 55.6 | The pocket the mount's round base sits in. Make it about 0.5 mm bigger than the base. |

Export the bracket again. Nothing else changes.

## Fits for your hardware

The fit-test bar tells you which of these to change.

| Setting | Default | What it is |
|---|---|---|
| `INSERT_D` | 4.3 | Hole for the M3 heat-set inserts (the sled's feet). |
| `M2_INSERT_D` | 3.1 | Holes for the M2 inserts (the board standoffs). |
| `NUT_AF` | 5.8 | Hex pockets for the sealed M3 nuts, across flats. |
| `NUT_H` | 2.8 | Depth of those pockets. It must stay a bit more than the nut's 2.4 mm, so the nozzle clears it after the pause. |
| `BOLT_HEAD_AF` | 5.7 | Hex pockets for the wing-nut mount's bolt heads. |
| `M3_CLEAR` | 3.4 | M3 clearance holes. |
| `TREE_SCREW_D` | 4.8 | The tree-screw mount's hole for the long wood screw. |

If you change `BOLT_HEAD_AF`, the B wing-nut spacers change with it. Export them with **PART** set to `wing_spacers` and **VERSION** set to `B`.

## What the file checks for you

When you open the file, OpenSCAD prints a few lines in its console starting with `v7:`. They give:

- the O-ring's stretch, squeeze and groove fill
- the pause heights
- the length of B's wing-nut spacers
- each bracket's length against the bed

It also stops with an error if the O-ring's stretch, squeeze or fill goes out of range, if a nut pocket no longer lands on a 0.2 mm layer, if the mount's holes don't fit on the pad, or if a bracket gets too long for a 256 mm bed.

**Pause heights.** The printed numbers are the height of the top of each nut pocket; pause at the next layer up. They move if you change the bracket's plate, feet or pad (`PL_T`, `RIB_D`, `PAD_RAISE_B`, `MOUNT_POCKET`, `NUT_BACK`) or the lock tab (`FL_T`, `LOCK_NUT_TOP`, `ZJ_B`). The defaults put the pockets exactly on 0.2 mm layers.

**The O-ring.** `R_G` (the groove floor), `R_B` (the bore) and `G0`/`GW` (where the groove sits and how wide it is) are set for an AS568-153. If you use a different O-ring, aim for about 2% stretch, 20 to 25% squeeze and no more than 85% groove fill.

**The thread.** `TH_SEG` holds the widths of the eight ridges, and those widths are why it only fits one way. If you change them, it may start fitting at more than one angle. `TH_LEAD` and `TH_H` together give the quarter turn.

## Other ideas

- **A bigger or different panel mount.** Besides the three settings above, `PAD_D` is the round pad behind the mount (64 mm). The file checks that the mount's holes and nuts stay inside it.
- **Poles and posts.** The three tree screws all sit on the bracket's center line, so an adapter plate for a pole or post could bolt to those same three holes. There isn't one yet.
- **Another cell or board.** The cell cup (`CELL_P`, `CUP_RI`), the sled (`SL_*`) and the board positions (`BQ0`, `MB0`, `RAK0`) are all settings. Keep everything inside a 42 mm radius of the center, so it can pass through the opening in the lower part.
