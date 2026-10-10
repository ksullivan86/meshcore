# Roadmap

Planned changes to the Tahoe repeater.

## Print files

- [ ] **Per-plate STLs, zipped.** For each of the nine versions, export one STL per print plate (test pieces, top, base with sled and clamps, bracket, and so on, matching "What goes on each plate" in the build guide). Name each file after its plate and pause height, and zip them per version, e.g. `tahoe-repeater-A-tree-screw-plates.zip`. Keep the current all-in-one STL for each version as well.

## Sled

- [x] **Board outlines on the sled.** A 0.6 mm raised outline just inside each board's footprint, with its name (CHARGER, RAK19003, BOOST) and "USB-C" at the end where each board's USB-C socket goes. The charger's outline is broken where the battery strap crosses. Done in the CAD and STLs.
- [x] **Clamp posts shaped differently from standoffs.** Done, but the clamps and posts go away with the board bays below.
- [ ] **Redraw the sled pictures** to show the outlines, labels and six-sided posts: the sled steps (part 1 and 2), putting it in, opening it, `inside-A.png` and `sled.png`.

## Tool-less board bays (replacing the swing clamps)

The swing clamps don't work: their feet land 1.8 mm short of the mounting holes on the charger and MiniBoost (posts 7.8 mm from the hole centres, arms 6.0 mm), and the post heads snap off when a clip is pried off, because they're the last few layers on top of a thin stem. The MiniBoost also rocks on its one standoff and rest.

The replacement is a **board bay** (`BOARD BAYS` in the CAD): standoffs for support, two fixed hooks on one edge (a shelf under the board and a 0.8 mm lip over it), one snap latch on the opposite edge (a pillar on a tongue cut into the plate, flexing sideways along the print layers), and two stops on the other edges. Slide one edge under the hooks, press the other edge down until the latch clicks; push the latch outward to lift the board out. No inserts, no loose parts, and it works for boards with no holes. A bay is one line of settings per board, so it carries over to other builds.

- [x] **Bay design and four single-board test plates:** `stl/tahoe-repeater-board-bay-tests.stl` (charger, RAK19003, MiniBoost, INA219). Checked by `cad/check_bays.py`: one piece each, nothing touches a board except the latch's 0.15 mm preload, each tongue is free to its root, and each board tilts in under its hooks.
- [ ] **Print the test plates and try each board.** If boards are loose or tight in the hooks, change `BAY_SLOT_H` (1.75). If the latch is too stiff or too weak, change `BAY_TL` (17, longer is softer). Check the INA219's terminal block faces the right-hand edge and that nothing on its underside lands on a standoff.
- [ ] **Put the bays on the sled** once the test plates work. Map each bay onto the front face with `multmatrix([[1,0,0,X0],[0,0,-1,0],[0,1,0,Z0],[0,0,0,1]])` (u to x, v to z, h to -y) and subtract its `bay_cut` from the plate. Positions (bay corner on the sled):
  - Charger `BAY_BQ` at `BQ0` (-15.9, 64). Hooks on the bottom edge either side of the JST sockets, latch on the top edge right of the USB-C, tongue running right (clear of the battery, which touches the plate along x = -5). Stops above the battery strap.
  - RAK19003 `BAY_RAK` at `RAK0` (-17, 20). Hooks on the right edge, latch on the left edge below the USB-C. The half-hole standoff stays.
  - MiniBoost `BAY_MB` at `MB0` (8, 99). Hooks on the left edge, latch on the right edge, tongue running up.
  - INA219 `BAY_INA` at (-27, 95) on the front, where the protection board is now. It can't go on the back: the sled prints with its back on the bed.
  - Move the protection board to the back, zip-tied flat at about x 6 to 28, z 30 to 44 (beside the battery, clear of every tongue). Replace the zip slots at (-20, 100) and (-4, 100) with four at (14, 22.5), (24, 22.5), (14, 39.5), (24, 39.5).
  - Remove the swing clamps, their nine posts and the clamp spine from the sled and the kit STLs. Add an outline and "INA219" label for the new bay.
  - Re-run `check.py asm sled` and `check.py pose`, and a sled version of `check_bays.py`, then re-export the nine kits.
- [ ] **Docs for the bays:** build guide step 10 (fitting and removing boards, the protection board's new place, the INA219 in its bay instead of foam tape), the parts list (no foam tape), and the wiring routes.

## Names in the docs and pictures

- [ ] **"Cell strap" becomes "battery strap"**: on first mention, "a ½ in Velcro One-Wrap (hook-and-loop) strap, 8 in long, that holds the battery to the back of the sled", plus a note that a zip tie through the same two slots works too but has to be cut to get the battery out.
- [ ] **Decide: "cell" or "battery" throughout.** Possibly use "battery" everywhere and keep "LiFePO4 cell" only in the parts list.
- [ ] **Label the USB-C cable clearly** in the sled pictures: "Radio power: MiniBoost to RAK19003 (not the panel)". The panel is bare wires through the gland.
- [ ] **Cold-test caption:** say the USB-C supply is a phone charger for this test only, and that the panel comes in later through the gland.

## Later

- [ ] **Sleds for other boards**, e.g. Heltec T114 and XIAO with the Wio-SX1262.
