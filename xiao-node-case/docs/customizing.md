# Changing the design

Everything is in one OpenSCAD file, [`cad/xiao-node-case.scad`](../cad/xiao-node-case.scad), and every dimension is a named setting near the top. It was written for OpenSCAD 2021.01 and works in newer versions.

## Export a part

1. Install [OpenSCAD](https://openscad.org) and open `cad/xiao-node-case.scad`. The preview (F5) shows the assembled case with stand-in boards.
2. Open the Customizer (**Window > Customizer**) and set:
   - **PART**: `body`, `lid`, `plate`, `kit` (all three, laid out to print), `fit_test`, or `assembly` and `section` to look at.
   - **BAYS**: 1, 2 or 3.
   - **LABELS**: the text under each USB-C opening, left to right.
   - **WIFI**: `fpc` or `rpsma` (below).
3. Render (F6), then **File > Export > Export as STL**.

From a terminal, run these from the `xiao-node-case` folder. They need Python 3 and OpenSCAD on the PATH, and `pip install trimesh manifold3d numpy matplotlib`:

```sh
python3 cad/export.py                      # the three release files, into stl/
python3 cad/export.py --fit                # the fit test
python3 cad/export.py -D 'LABELS=["HOME","MESH","LAB"]'
```

Any setting can be overridden with `-D` the same way.

## Labels

`LABELS = ["HA", "OBS", "RELAY"]` sets the text debossed under each USB-C opening and raised on each bay's floor, left to right. Short words fit best: up to about five capital letters.

## WiFi antenna

`WIFI = "fpc"` (the default) gives each bay a pocket for the kit's stock FPC antenna on its back wall and a spool for its cable.

`WIFI = "rpsma"` drops the pockets, spools and dividers and puts an RP-SMA bulkhead hole on the lid for each kit, labelled **WiFi**, between the LoRa ones. You'll need a U.FL to RP-SMA pigtail and a 2.4 GHz antenna per kit.

## Ballast

`BALLAST_N = 4` sets how many washers stack on each pin, and so how deep the base is. `WASHER = [6.4, 18, 1.6]` is the washer's hole, outside diameter and thickness; change it for a different washer.

## The board bay

These came from fitting real kits, so change them only if yours fit differently.

| Setting | Default | What it is |
|---|---|---|
| `HOOKS` | `[["B", 0.2, 1.9], ["B", 15.9, 17.6]]` | The two front hooks, as ranges along the board's front edge in mm. They must stop short of the XIAO's B and R buttons; longer ones hold the board back so it rides up onto the back rail. |
| `LATCH_LIP` | 1.2 | How far the latch's lip reaches over the board's left edge. |
| `RAIL_BACK` | 0 | Extra room in front of the back rail. |
| `STANDOFFS` | four, 3 mm | The posts the XIAO sits on, between its header rows. |
| `PIN_BELOW` | 9.0 | How far the header pins stick out under the XIAO. The floor is set this far below the board, plus 1 mm. |
| `XIAO_T` | 1.0 | The XIAO's board thickness. |

If you change one, print the fit test (`PART` `fit_test`, `BAYS` 1) before a whole case.

## Checks and pictures

Two scripts in `cad/` go with the design:

| Script | What it does |
|---|---|
| `check_case.py` | Builds every part in its assembled place, with stand-ins for the kits, the cables and the antennas, into `cad/build/`. Then it checks that nothing overlaps; the kit goes into each bay under the hooks and clicks past the latch; a USB-C cable fits and its push lands on a rail; each plunger sits just over its button; the antenna cables reach, shut and open; the lid swings open without hitting anything and stops at about 100°; its tabs hold it shut; and the base slides on, catches and stops. It prints PASS or FAIL for each. `--bays 2`, `--fit` and `-D` work as they do for `export.py`. |
| `render.py` | Draws the pictures in `images/` from what `check_case.py` built. |

After a change:

```sh
python3 cad/check_case.py
python3 cad/check_case.py --fit
python3 cad/export.py && python3 cad/export.py --fit
python3 cad/render.py
```

`cad/build/` is ignored by git.
