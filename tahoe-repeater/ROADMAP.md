# Roadmap

Planned changes to the Tahoe repeater.

## Print files

- [ ] **Per-plate STLs, zipped.** For each of the nine versions, export one STL per print plate (test pieces, top, base with sled and clamps, bracket, and so on, matching "What goes on each plate" in the build guide). Name each file after its plate and pause height, and zip them per version, e.g. `tahoe-repeater-A-tree-screw-plates.zip`. Keep the current all-in-one STL for each version as well.

## Sled

- [x] **Board outlines on the sled.** A 0.6 mm raised outline just inside each board's footprint, with its name (CHARGER, RAK19003, BOOST) and "USB-C" at the end where each board's USB-C socket goes. The charger's outline is broken where the battery strap crosses. Done in the CAD and STLs.
- [x] **Clamp posts shaped differently from standoffs.** The posts are now six-sided; the standoffs stay round. Done in the CAD and STLs.
- [ ] **Redraw the sled pictures** to show the outlines, labels and six-sided posts: the sled steps (part 1 and 2), putting it in, opening it, `inside-A.png` and `sled.png`.

## Names in the docs and pictures

- [ ] **"Buttons" become "swing clamps"**, and the posts they turn on become "clamp posts". "Standoff" only ever means what a board rests on.
- [ ] **"Cell strap" becomes "battery strap"**: on first mention, "a ½ in Velcro One-Wrap (hook-and-loop) strap, 8 in long, that holds the battery to the back of the sled", plus a note that a zip tie through the same two slots works too but has to be cut to get the battery out.
- [ ] **Decide: "cell" or "battery" throughout.** Possibly use "battery" everywhere and keep "LiFePO4 cell" only in the parts list.
- [ ] **Label the USB-C cable clearly** in the sled pictures: "Radio power: MiniBoost to RAK19003 (not the panel)". The panel is bare wires through the gland.
- [ ] **Cold-test caption:** say the USB-C supply is a phone charger for this test only, and that the panel comes in later through the gland.

## Later

- [ ] **Sleds for other boards**, e.g. Heltec T114 and XIAO with the Wio-SX1262.
