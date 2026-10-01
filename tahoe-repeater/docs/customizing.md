# Changing the design

Everything is in one OpenSCAD file, [`cad/tahoe-repeater.scad`](../cad/tahoe-repeater.scad), and every dimension is a named setting near the top. It was written for OpenSCAD 2021.01 and works in newer versions.

## Export a part

1. Install [OpenSCAD](https://openscad.org) and open `cad/tahoe-repeater.scad`. The preview (F5) shows the assembled repeater with a stand-in panel.
2. Open the Customizer (**Window > Customizer**) and set:
   - **PART**: `upper` (A top, or B and C lid), `lower` (A and C base, or B can), `sleeve` (C), `bracket`, `sled`, `buttons`, `lock_pin`, `thread_test_male`, `thread_test_female`, `fit_test`, `mount_test`, `wing_spacers` (B and C wing-nut only), or `kit` for everything laid out.
   - **VERSION**: `A`, `B` or `C`. C uses B's brackets and spacers.
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

To measure yours, take the mount off the panel and measure between the centers of two holes with calipers. Or measure edge to edge and add one hole's width.

**No calipers?** Lay the mount face down on a sheet of paper with a ruler flat beside it, and take a photo from straight above. Stand back and zoom in rather than holding the phone close, so the picture isn't distorted. On a computer, measure from the center of one hole to the center of another in pixels, measure a known length on the ruler in pixels, and scale. That gets you within about half a millimetre, and the mount test disc will tell you if that's close enough. Phone measuring apps, even the ones that use the LiDAR on newer iPhones, aren't nearly accurate enough for this.

Then set:

| Setting | Default | What it is |
|---|---|---|
| `MOUNT_HOLE_SPACING` | 36 | Center to center between two of the three holes, in mm. |
| `MOUNT_HOLE_ANG` | `[90, 210, 330]` | Where the holes sit, in degrees counterclockwise from 3 o'clock, seen from the front. 90 is 12 o'clock. If yours aren't evenly spaced, measure the angles and put them here. The tree-screw mount's long screw always uses the hole at 90, so keep one there. |
| `MOUNT_D` | 55.6 | The pocket the mount's round base sits in. Make it about 0.5 mm bigger than the base. |

Export the mount test disc first (**PART** `mount_test`), print it (17 minutes) and check your mount drops in with all three holes lined up. When it does, export the bracket with the same settings. Nothing else changes.

## Fits for your hardware

The fit-test bar tells you which of these to change.

| Setting | Default | What it is |
|---|---|---|
| `INSERT_D` | 4.3 | Hole for the M3 heat-set inserts (the sled's feet). |
| `M2_INSERT_D` | 3.1 | Holes for the M2 inserts (the board standoffs). |
| `NUT_AF` | 5.8 | Hex pockets for the sealed M3 nuts, across flats. |
| `NUT_H` | 2.8 | Depth of the lock tab's pocket, for a plain 2.4 mm M3 nut. It must stay a bit more than the nut, so the nozzle clears it after the pause. |
| `LOCKNUT_H` | 4.4 | Depth of the bracket's pockets, for 4 mm M3 nylon-insert lock nuts. A plain nut fits too; it just sits deeper. |
| `BOLT_HEAD_AF` | 5.7 | Hex pockets for the wing-nut mount's bolt heads. |
| `M3_CLEAR` | 3.4 | M3 clearance holes. |
| `TREE_SCREW_D` | 5.2 | The tree-screw mount's top hole, a clearance hole for the #10 wood screw into the tree. |
| `GLAND_POCKET` | 5.6 | Depth of the round pocket inside the floor for the cable gland's lock nut. It leaves room for a gland with an 8 mm thread; a longer thread fits too. |

If you change `BOLT_HEAD_AF`, the B and C wing-nut spacers change with it. Export them with **PART** set to `wing_spacers` and **VERSION** set to `B`.

## The lock

Each joint's tabs carry the latch, the lock pin and the lock screw. Angles are measured round from the front, counterclockwise seen from above, and the joint closes clockwise.

| Setting | Default | What it is |
|---|---|---|
| `LOCK_TIGHT` | 2.5 | How far the upper part's thread is turned back, in degrees. The thread has some play, so hand-tight comes a few degrees past the point where its ridges line up. This moves hand-tight to about 1° past the drawn position, where the locks line up. |
| `LUG_D` | `[-20, 8]` | The angles the tabs span. |
| `LOCK_SLOT`, `PIN_SLOT` | 3.5, 3 | How far either side of center the screw and pin slots in the upper tab reach, in degrees. |
| `LT_POST`, `LT_HOOK` | `[-12, -4]`, `[-17.5, -14.5]` | The latch post on the lower tab, and the hook on the arm. The hook catches when its second angle reaches the post's first, 2.5° before the drawn position. |
| `LT_POST_R`, `LT_HOOK_R` | `[65, 68]`, 66.8 | The post's radii and how far in the hook reaches. The difference, 1.2 mm, is how far the arm flexes and how much the hook holds by. |
| `LT_ARM_R`, `LT_ARM_H` | `[68.5, 71.3]`, 10 | The arm's radii (its thickness) and height. A thicker arm clicks harder. |
| `PIN_D`, `PIN_GROOVE`, `PIN_GROOVE_D` | 5.4, `[2.6, 4.6]`, 6.6 | The pin's hole, and the groove in the lower tab that its barbs click into. |

**If the test rings stop before the latch clicks,** your thread has less play than mine. Make `LOCK_TIGHT` smaller, say 1.5, and print the female ring again. It changes only the upper part's thread. **If they turn well past the tabs lining up,** so the pin won't go in, make it bigger.

## What the file checks for you

When you open the file, OpenSCAD prints a few lines in its console starting with `v9:`. They give:

- the O-ring's stretch, squeeze and groove fill, and the turn from drop-in to closed
- the pause heights
- the range of screw lengths for the panel mount, as the mount's base thickness plus so many millimetres
- where the strap channels are
- the length of the wing-nut spacers
- each bracket's length against the bed
- where the latch catches, how deep its hook is, and the slots for the pin and screw

It also stops with an error if the O-ring's stretch, squeeze or fill goes out of range, if a nut pocket no longer lands on a 0.2 mm layer or gets too shallow for its nut, if there's no longer room behind A's lock nuts for the screw tips, if the mount's holes don't fit on the pad, if a strap channel runs into the rail, the pad, another channel or a zip-tie slot, if a bracket gets too long for a 256 mm bed, or if the latch post crowds the tab or the arm, or the pin slot runs into the screw slot or the end of the tab.

**Pause heights.** The printed numbers are the height of the top of each nut pocket; pause at the next layer up. They move if you change the bracket's plate, feet or pad (`PL_T`, `RIB_D`, `PAD_RAISE_B`, `MOUNT_POCKET`, `NUT_BACK`) or the lock tab (`FL_T`, `LOCK_NUT_TOP`, `ZJ_B`). The defaults put the pockets exactly on 0.2 mm layers.

**Straps.** `STRAPS_A` and `STRAPS_B` hold the bottom edge of each strap channel, in mm up the bracket. `STRAP_W` (27) and `STRAP_REC` (2) are each channel's height and depth. Keep `STRAP_REC` at 2 or more, so the enclosure can still slide down over a strap. `ZIPS_A` and `ZIPS_B` are the zip-tie slots for the panel cable, which sit between the channels.

**The O-ring.** `R_G` (the groove floor), `R_B` (the bore) and `G0`/`GW` (where the groove sits and how wide it is) are set for an AS568-153. If you use a different O-ring, aim for about 2% stretch, 20 to 25% squeeze and no more than 85% groove fill.

**The thread.** `TH_SEG` holds the widths of the eight ridges, and those widths are why it only fits one way. If you change them, it may start fitting at more than one angle. `TH_LEAD` and `TH_H` together give the quarter turn.

## Other ideas

- **A bigger or different panel mount.** Besides the three settings above, `PAD_D` is the round pad behind the mount (64 mm). The file checks that the mount's holes and nuts stay inside it.
- **Poles and posts.** The three tree screws all sit on the bracket's center line, so an adapter plate for a pole or post could bolt to those same three holes. There isn't one yet.
- **Another cell or board.** The cell cup (`CELL_P`, `CUP_RI`), the sled (`SL_*`), the board positions (`BQ0`, `MB0`, `RAK0`) and the turn buttons' posts and feet (`BUTTONS`) are all settings. Keep everything inside a 42 mm radius of the center, so it can pass through the opening at the top of B's can and C's sleeve. The cell strap (`CS_Z`) has to cross the front of the sled in a band that's clear of every standoff and post, so check it again if you move a board.
