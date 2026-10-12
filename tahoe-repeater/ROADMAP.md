# Roadmap

Planned changes to the Tahoe repeater.

## Print files

- [ ] **Per-plate STLs, zipped.** For each of the nine versions, export one STL per print plate (test pieces, top, base with sled and clamps, bracket, and so on, matching "What goes on each plate" in the build guide). Name each file after its plate and pause height, and zip them per version, e.g. `tahoe-repeater-A-tree-screw-plates.zip`. Keep the current all-in-one STL for each version as well.

## Sled

- [x] **Board outlines on the sled.** A 0.6 mm raised outline just inside each board's footprint, with its name (CHARGER, RAK19003, BOOST) and "USB-C" at the end where each board's USB-C socket goes. The charger's outline is broken where the battery strap crosses. Done in the CAD and STLs.
- [x] **Clamp posts shaped differently from standoffs.** Done, but the clamps and posts go away with the board bays below.
- [ ] **Redraw the sled pictures** (also: `step-sled-2.png` still shows the leads being soldered on the sled, which now happens in step 4) to show the outlines, labels and six-sided posts: the sled steps (part 1 and 2), putting it in, opening it, `inside-A.png` and `sled.png`.

## Tool-less board bays (replacing the swing clamps)

The swing clamps don't work: their feet land 1.8 mm short of the mounting holes on the charger and MiniBoost (posts 7.8 mm from the hole centres, arms 6.0 mm), and the post heads snap off when a clip is pried off, because they're the last few layers on top of a thin stem. The MiniBoost also rocks on its one standoff and rest.

The replacement is a **board bay** (`BOARD BAYS` in the CAD): standoffs for support, two fixed hooks on one edge (a shelf under the board and a 0.8 mm lip over it), one snap latch on the opposite edge (a pillar on a tongue cut into the plate, flexing sideways along the print layers), and two stops on the other edges. Slide one edge under the hooks, press the other edge down until the latch clicks. To lift the board out, push the low finger tab beside the latch outward (never the top of the latch's pillar, which snaps off). Hooks have a thicker wall with a buttress at its foot; stops are 2 mm thick and stand a little above the board. No inserts, no loose parts, and it works for boards with no holes. A bay is one line of settings per board, so it carries over to other builds.

- [x] **Bay design and four single-board test plates:** `stl/tahoe-repeater-board-bay-tests.stl` (charger, RAK19003, MiniBoost, INA219). Checked by `cad/check_bays.py`: one piece each, nothing touches a board except the latch's 0.15 mm preload, each tongue is free to its root, and each board tilts in under its hooks.
- [ ] **Print the test plates and try each board.** If boards are loose or tight in the hooks, change `BAY_SLOT_H` (1.75). If the latch is too stiff or too weak, change `BAY_TL` (17, longer is softer). Check the INA219's terminal block faces the right-hand edge and that nothing on its underside lands on a standoff.
- [ ] **Put the bays on the sled** once the test plates work. Map each bay onto the front face with `multmatrix([[1,0,0,X0],[0,0,-1,0],[0,1,0,Z0],[0,0,0,1]])` (u to x, v to z, h to -y) and subtract its `bay_cut` from the plate. Positions (bay corner on the sled):
  - Charger `BAY_BQ` at `BQ0` (-15.9, 64). Hooks on the bottom edge either side of the JST sockets, latch on the top edge right of the USB-C, tongue running right (clear of the battery, which touches the plate along x = -5). Stops above the battery strap.
  - RAK19003 `BAY_RAK` at `RAK0` (-17, 20). Hooks on the right edge, latch on the left edge below the USB-C. The half-hole standoff stays.
  - MiniBoost `BAY_MB` at `MB0` (8, 99). Hooks on the left edge, latch on the right edge, tongue running up.
  - INA219 `BAY_INA` at (-27, 95) on the front, where the protection board is now. It can't go on the back: the sled prints with its back on the bed.
  - Move the protection board to the back, zip-tied flat at about x 6 to 28, z 30 to 44 (beside the battery, clear of every tongue). Replace the zip slots at (-20, 100) and (-4, 100) with four at (14, 22.5), (24, 22.5), (14, 39.5), (24, 39.5).
  - Remove the swing clamps, their nine posts and the clamp spine from the sled and the kit STLs. Every bay now carries its own raised outline and labels (the seventh entry in its settings, required), so drop the separate `sled_marks2d` labels for these four boards when the bays go on.
  - Re-run `check.py asm sled` and `check.py pose`, and a sled version of `check_bays.py`, then re-export the nine kits.
- [ ] **Docs for the bays:** build guide step 10 (fitting and removing boards, the protection board's new place, the INA219 in its bay instead of foam tape), the parts list (no foam tape), and the wiring routes.

## Build guide: one soldering session for board prep

- [x] **Add a "Board prep" step** (done: step 4 is now "Prep the boards", with `step-prep-station.png` and `step-prep-boards.png`; steps 5 and 10 point back to it instead of repeating the soldering) that does all the simple soldering in one sitting, while the station is set up. Put it right before the battery harness (step 5): do the fine board work first with a small tip at a lower temperature, then swap to the big chisel tip and go hotter for the battery tabs. The cold-cutoff test (step 6) then follows with everything ready. It gathers jobs now spread across steps 4, 5 and 10:
  - Charger: cut TH and VS on the front, bridge 3.65V on the back, solder the thermistor to TH and a − pad (step 4 as it is now).
  - Charger DC in: a JST-PH **male** lead to DCIN + and −. The panel's cut cable plugs into it later.
  - Charger LOAD to MiniBoost: a JST-PH lead from the charger's LOAD socket to the MiniBoost's VIN and GND.
  - MiniBoost to RAK19003: the short USB-C cable (USB-A end cut off), red to 5V, black to GND.
  - INA219 (optional): four wires from VIN, GND, SCL and SDA to the RAK19003's J6 pads, while the RAK19003 is loose on the bench, and two leads on the VIN+ / VIN− terminals for the cell's red wire.
  - Optional 1000 µF capacitor on the RAK19003's BAT socket.
  - Adhesive heat shrink on every joint, and a label on each lead (masking tape and a pen is fine).
  - Not in this step: the panel cable's JST-PH lead, because the cable has to go through the gland first (step 8). The battery tabs stay in step 5.
  - Cut and strip every lead to length first. The doc pass should give the lengths, measured off the sled layout.
- [x] **Station example in that step**, with what's recommended and what you can get away with:

  | Item | Recommended | On a budget |
  |---|---|---|
  | Iron | Temperature-controlled, 60 W or more, interchangeable tips (e.g. Pinecil V2 on a 65 W USB-C PD supply, or a Hakko FX-888D) | An adjustable 60 W kit iron. Avoid unregulated irons: they can't hold the heat the battery tabs need |
  | Tips | A small conical or 1 to 1.6 mm chisel for the boards; a 3 to 5 mm chisel for the battery tabs | One medium chisel for both, if it gets the tabs hot in 2 to 3 seconds |
  | Solder | 63/37 leaded rosin core, 0.6 to 0.8 mm | 60/40 works; lead-free works but needs about 30 °C more |
  | Flux | No-clean flux pen | The rosin in the solder, plus a little paste for the tabs |
  | Holding | PCB holder or helping hands with a heavy base; Kapton tape to hold wires | Blu-Tack or tape on a scrap of wood |
  | Tip cleaning | Brass wool | A damp (not wet) sponge |
  | Heat shrink | Heat gun on low | A hair dryer won't shrink adhesive-lined tube; never use a lighter near the battery |
  | Cutting and stripping | Flush cutters and an adjustable wire stripper for 22 to 28 AWG | Flush cutters and careful thumbnail stripping |
  | Checking | Multimeter with continuity beep | Any cheap meter with continuity |
  | Safety | Fume extractor, safety glasses, a silicone mat | A fan blowing the fumes away across an open window, glasses |
  | Cleanup | Isopropyl alcohol and an old toothbrush | Same |

  Lay it out once and leave it: boards in the holder in the middle, iron and its stand on your strong-hand side, tip cleaner and flux next to it, the pre-cut labelled leads in order of use, the heat gun parked behind. Temperatures: about 330 to 350 °C for the boards, about 400 °C for the battery tabs.

## Names in the docs and pictures

- [ ] **"Cell strap" becomes "battery strap"**: on first mention, "a ½ in Velcro One-Wrap (hook-and-loop) strap, 8 in long, that holds the battery to the back of the sled", plus a note that a zip tie through the same two slots works too but has to be cut to get the battery out.
- [ ] **Decide: "cell" or "battery" throughout.** Possibly use "battery" everywhere and keep "LiFePO4 cell" only in the parts list.
- [ ] **Label the USB-C cable clearly** in the sled pictures: "Radio power: MiniBoost to RAK19003 (not the panel)". The panel is bare wires through the gland.
- [ ] **Cold-test caption:** say the USB-C supply is a phone charger for this test only, and that the panel comes in later through the gland.

## Later

- [ ] **Sleds for other boards**, e.g. Heltec T114 and XIAO with the Wio-SX1262.
