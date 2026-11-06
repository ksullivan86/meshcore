# Changing the design

Everything is in one OpenSCAD file, [`cad/wio-tracker-l1.scad`](../cad/wio-tracker-l1.scad), and every dimension is a named setting near the top, each with a note saying where its number came from. It was written for OpenSCAD 2021.01 and works in newer versions.

## Export and check

1. Install [OpenSCAD](https://openscad.org) and open `cad/wio-tracker-l1.scad`. The preview (F5) shows the fit test laid out to print.
2. Set **PART** at the top: `fit_test` (the fit test as printed), `fit_view` (its pieces put together, with a stand-in board and screen) or `assembly` (all the parts drawn so far, put together, with the board, screen and cell).
3. Render (F6) and **File > Export > Export as STL.**

From a terminal, with Python and `pip install trimesh manifold3d numpy rtree ezdxf shapely networkx pillow`:

```sh
python cad/check_case.py
```

checks every fit (about 35 checks: see [What the checks do](#what-the-checks-do)). Then

```sh
python cad/export.py --fit
```

writes [`stl/wio-tracker-l1-eink-fit-test.stl`](../stl), and

```sh
python cad/render.py
```

redraws the pictures in [`images/`](../images). All three take OpenSCAD settings the same way, for example `-D PCB_T=1.6`, and find OpenSCAD on the PATH, in its usual install folder or from an `OPENSCAD` environment variable. Run `check_case.py` with your changes before you export.

## Measurements

These are the board, screen and parts as they came off the calipers, or as close as I could get without them.

| Setting | Default | What it is |
|---|---|---|
| `BOARD` | `[47.96, 52.24]` | The board's outline, across by along the case. Measured. |
| `PCB_T` | 1.57 | Board thickness. The latches' slot is this plus 0.15. Measured. |
| `BOARD_HOLES`, `BOARD_HOLE_D` | `[43, 47]`, 2.2 | Mounting-hole pattern and diameter. The pins fit on the first test. |
| `PANEL` | `[29.29, 59.26, 1.14]` | The e-ink screen. Measured. |
| `ADAPTER` | `[18.47, 10.31, 3.0]` | Seeed's ribbon adapter board, with its connectors. Measured. |
| `SOLAR_H` | 4.8 | **Still a guess.** The solar socket's height above the board. It sits under the screen, so it sets how far back the board goes, and so the case's depth. |
| `TOP_TALL` | 5.6 | **Still a guess.** The tallest part anywhere else on top of the board. The original case leaves 5.9 there. |
| `UNDER` | buzzer 3.3, antenna plug 3.6 | Tall parts under the board, where they are and how tall. The tray is pocketed under any taller than the standoffs. The buzzer is about 3 mm by eye; the plug **is a guess**. |
| `BAT_NOTCH` | `[5, 14, -9, 9]` | The cut-out round the battery socket under the board. Placed from Seeed's photo. |
| `SO_H` | 3.0 | Standoff height under the board. |
| `IRON_D` | 7.0 | The widest part of your soldering iron's heat-set tip. |

## Depth and the cell

| Setting | Default | What it is |
|---|---|---|
| `CELL_MAX` | `[10.5, 37, 68]` | The biggest cell the bay takes: thickness, width, length. A 103665 is 10 × 36 × 65 plus its protection board. |
| `DEPTH` | 0 | The shell's depth. 0 makes it as shallow as `CELL_MAX` allows. A number fixes it. |
| `CELL_SPARE` | 0.3 | Room left behind the cell, for it to swell. |

With the defaults the shell is 25.3 mm deep and the case 27.8 mm front to back. When you open the file, the console says how deep it is and how thick a cell would fit at the original 24 mm. The original dock only takes the original depth, so for that, set `DEPTH = 24` and a cell up to about 9.2 mm thick in `CELL_MAX`. The checks then test the case against both dock meshes, if you have them in `ref/`.

A thinner cell gives a slimmer case: `CELL_MAX = [6, 37, 68]` gives 23.3 mm. The back's chamfers get smaller on a slim case so they stay clear of the insert bosses.

## Fits for your hardware

| Setting | Default | What it is |
|---|---|---|
| `INSERT_HOLE_D` | 4.0 | Holes for the M3 heat-set inserts (5 mm wide, 6 mm long). Tune between 3.8 and 4.2 from the shell corner on the fit test. |
| `HEAD_D`, `HEAD_H` | 5.6, 3.2 | Counterbores for the M3 socket heads. 5.6 is the one that fit on the XIAO case's screw test. |
| `SCREW_IN` | 7.0 | How far in from the outside the screws sit. Less brings the bosses closer to the walls, and your iron may not reach. |
| `PIN_D` | hole − 0.4 | Pins in the board's two top holes. They're loose on purpose: the guides and stops should take any sideways push before the pins do. |
| `GUIDE_GAP`, `BOARD_RELIEF` | 0.15, 0.5 | The side guides' gap to the board, and how much the shell's walls are thinned beside the board to make room for them. |
| `BAY_LIP_STRONG` | true | The latches' lips reach 1.0 mm over the board instead of 0.8. |
| `PANEL_CLR`, `PANEL_RECESS` | 0.6, 0.6 | Extra room round the screen in its pocket, and how deep the pocket is sunk into the front. |

## The board's bay

The tray uses the Tahoe repeater's board-bay block, copied in as it is (only the slot height, lip and pull-tab length are set for this case). The board's own layout is a few lines below it:

| Setting | What it is |
|---|---|
| `LATCH`, `LATCH2` | The two latches: `[edge, from, to, direction]`. The top one is right of the OLED connector, the bottom one between the solar and Grove sockets. Each needs about 23 mm of edge for its tongue. |
| `STOPS` | Stops near the corners, on the top and bottom edges, 0.2 mm off the board. |
| `GUIDES` | Two guides on each long edge. Both left ones are below the USB-C socket, the only stretch of that edge with nothing hanging over it. |
| `PADS`, `PAD_GAP` | Pads on the front that stop 0.3 mm above the board, over the right-hand mounting holes. |
| `BLOCK_GAP` | The rib on the front that sits 0.3 mm behind the top latch's pull tab when the case is shut, so it can't open. |

Positions along an edge are measured from the board's bottom-left corner, seen from the front. If anything on your board sits where a latch, stop or guide is, move it here.

## The screen and its cover

| Setting | Default | What it is |
|---|---|---|
| `DOOR_T`, `DOOR_GAP` | 0.8, 0.2 | The cover's thickness, and its gap to the glass (room for a thin foam pad). |
| `RAIL_CLR`, `DOOR_SLIDE` | 0.2, 0.9 | The cover's bevel to the rail along the pocket, and how far it slides to get under it. |
| `TB_POS`, `TB_T` | | The two turn buttons and their thickness. The lower one is below the board; the upper one over bare board, clear of the E-INK ribbon. |
| `RIBBON_X` | `[18.5, 31.5]` | The notch in the cover for the screen's ribbon. |

## The strap

| Setting | Default | What it is |
|---|---|---|
| `STRAP` | true | The cell strap, its groove, bars and the tray's window. |
| `STRAP_T`, `STRAP_W` | 1.2, 12.7 | One layer of your strap, and its width. |
| `STRAP_YC` | 41.8 | Where the strap crosses the cell. It closes on itself on the left of the cell's front, where the parts under the board are low; move it and check those parts again. |
| `STRAP_GROOVE`, `STRAP_BAR` | 1.0, `[1.7, 2.0, 0.5]` | The groove in the floor, and the bars beside the cell that the strap passes under. |

## What the checks do

`cad/check_case.py` renders every part where it sits, with stand-ins for the board, screen, cell, strap, adapter and the tall parts under the board, then checks:

- every fit-test piece is one solid piece, and the boss, tray and front corner stack with one screw
- the wall round each insert, that your iron reaches every boss, and the screw length
- the shell, tray, front and board don't overlap
- both latches close 0.05 mm clear of the board, come free to their roots, pull back far enough without straining, and that the tray stays joined across them
- the top latch's blocker, the board dropping straight in, and that guides and stops hold it sideways before the pins do
- the tall parts under the board clear the tray, and the hold-down pads stop 0.3 mm above the board
- the cell at `CELL_MAX` fits, and the strap goes round it, under the bars, clear of everything
- the screen drops into its pocket, the cover goes on and off and is held by the rail and both turn buttons, and the ribbon adapter sits in its seat
- at the original depth, the case against both dock meshes

`cad/render.py` draws the pictures from the same parts. Its labels are placed by hand, so if you move a camera, move its labels too.

## Other ideas

- **The OLED version.** The shell is shared. It needs its own front (a window for the 1.3" OLED instead of the e-ink pocket and cover), tray and button caps.
- **Screws from the back.** `SCREWS_FROM = "back"` is planned, with the inserts in the front's posts, but isn't built.
- **A TPU gasket** in the rim (`GASKET`) is planned, but isn't built.
