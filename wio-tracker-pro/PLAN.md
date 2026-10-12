# Wio Tracker L1 E-ink case: build plan

This is the hand-off for a build session. Everything needed is in this file and in `ref/`. **Don't reopen the 3mf or STEP files in `stl files/`.** They're 15 to 19 MB each, and every number taken from them is already below.

Scope for now: **E-ink version only.** The design has to stay ready for a tool-less OLED version that uses the same shell and the same dock.

## 1. The hardware

- **Board: Seeed Wio Tracker L1 E-ink**, about 50 × 54 mm.
  - Top side: 5-way joystick, user button, USB-C, JST 1.25 battery socket, JST 2.0 solar socket (5 V / 1 A in), IPEX connectors for the LoRa pigtail (to an SMA bulkhead) and the GPS patch, and a small slide switch on one edge.
  - The ~18 × 18 × 4.5 mm GPS patch is on a lead, so it can be placed anywhere.
- **Display:** 2.13" e-ink module, 59.2 × 29.2 × ~1.2 mm (active area 48.55 × 23.70). It connects through its own FPC, a small adapter and an FFC jumper to a connector on the board's top edge. That forces the panel to run **lengthwise (portrait)** in a 55 mm-wide case. This is settled; don't revisit it.
- **Battery: Meshnology 103665**, 3.7 V 3000 mAh, 10 × 36 × 65 mm, with PCM and JST 1.25. Supplies change, so the bay must take a range of cell sizes (section 4).
- **Heat-set inserts: METERXITY M3, 6 mm long, 5 mm OD** (the user owns these).
- The user also owns M2 inserts (3 L × 3 OD and 8 L × 3.5 OD), but this design doesn't use them.

## 2. Reference numbers (measured from the existing meshes)

Coordinates are in mm, origin at the part's min corner. Check meshes are in `ref/`.

**Back shell.** The E-ink and OLED cases have the same outside. Reference mesh: `ref/ref-eink-back-shell.stl`.

| Feature | Value |
|---|---|
| Outer size | **55.0 × 91.9 × 24.0** (x = width, y = length with the dock end at y = 0, z = depth with the back face at z = 0) |
| Walls | ~2 mm |
| Dock end | Back edges rounded. At y = 0.5 the section spans x 2.7 to 53.3, z 5.8 to 24. |
| Case-screw bosses (old: Ø2 self-tap) | (6.5, 5.5), (49.5, 5.5), (6.5, 79.1), (49.5, 79.1). **Pattern 43.0 × 73.6.** |
| Board bosses (old: Ø1.7, M2) | (6.5, 25.4), (49.5, 25.4), (6.5, 72.4), (49.5, 72.4). **Board hole pattern 43 × 47.** |
| Pogo pocket on the dock-end face | **22.9 × 4.5** opening, centred at x 27.4, z 18.8 (5.2 mm from the front face) |
| Openings in one long wall (x ≈ 0) | y 30.5–32.8, 34–37.5, 44.7–48.3, 58.3–62.4, all at z 18–21. Probably switch, button and USB. Check against the board before copying. |
| Antenna/SMA feature | Top end, around x 29.3 |

**Front plate.** Reference mesh: `ref/ref-eink-front.stl`, aligned. It's printed face down, so these coordinates are mirrored as seen from outside.

| Feature | Value |
|---|---|
| Size | 54 × 91.8, with a 2 mm skin and corner posts up to 9.9 |
| Display window | **25.4 × 50.4**, centred (16.8, 51.5) |
| Panel pocket behind the window | **29.4 × 60.0** |
| Joystick hole | Ø8.9 at (45.0, 51.3) |
| Button hole | Ø5.6 at (34.9, 51.3) |
| Case posts | (5.5, 12.7), (48.5, 12.7), (5.5, 86.3), (48.5, 86.3) |

**Docks.** Reference meshes: `ref/ref-dock-eink.stl` and `ref/ref-dock-oled.stl`. Both have the same case pocket.

| Feature | Value |
|---|---|
| Pocket | **54.85 × 27.17**, about 20 mm deep |
| Pogo slot in the pocket floor | 36.74 × 12.46 |
| Outer size | 64.85 × 64.17 (E-ink) or 59.17 (OLED) × 45 |

**Dock rule.** The bottom ~22 mm of the case keeps exactly the 55 × 24 profile, the same end rounding and the same pogo-pocket position. Then the user's existing dock takes both versions and no new dock is needed. Check this with a collision/clearance test against both dock meshes.

## 3. Architecture: a shared shell with per-screen inserts

Each part, and whether it's shared between screen versions:

- **`shell` (shared):** back shell with the dock end, M3 insert bosses, battery bay and hump, SMA bulkhead, pogo pocket and side openings.
- **`tray_eink` (per screen):** an inner plate between the board and the battery. It carries the tool-less board bay on its front face and the battery strap slots on its back face.
- **`front_eink` (per screen):** front plate with the display window, panel pocket, joystick and button holes, and the lid-lock features (section 5).
- **`caps` (per screen):** flanged, captive joystick and button caps.
- **`pogo_plug` (shared):** blanking plug for the pogo pocket. Default until pogo pins are fitted.
- **`fit_test`:** a minimal test coupon (section 7).

Later, the OLED version adds only `front_oled`, `tray_oled` and `caps_oled`.

**Stack-up, front to back, about 26 mm total:**
- front skin 1.6
- joystick and panel clearance to the board's top face ~5.0
- PCB 1.6
- bottom-side parts on standoffs ~3.0
- tray 2.0
- cell 10.5
- back wall 2.2

That's more than the 24 mm dock profile allows, hence the hump in section 4.

## 4. Battery bay: sized for a range of cells, with a strap

- Put a `CELL_MAX = [T, W, L]` parameter at the top of the file. Default: [10.5, 37, 68], which is the 103665 with tolerance and the PCM bump.
- **Above the dock line** (y ≳ 22) the back gets a hump. Its depth is derived from `CELL_MAX[0]`, so a thicker cell gets a deeper hump without touching anything else. The bottom 22 mm never changes.
- **Strap, as on the Tahoe repeater:** one ½ in hook-and-loop strap round the cell's middle. It threads through two slots in the tray, CS_W 2.6 × 14 long (see the `CS_*` parameters in `tahoe-repeater.scad`).
- Smaller cells are taken up by the strap plus an optional foam pad. Add low side ribs on the shell floor to stop sliding. The ribs are set back from the `CELL_MAX` walls so a smaller cell can still be centred.
- Route the cell lead along one side to the JST 1.25 socket.

## 5. Tool-less board mount: Tahoe bay plus a lid lock

**Use the Tahoe BOARD BAYS block exactly as it is.** It's in `../tahoe-repeater/cad/tahoe-repeater.scad`, about lines 820–930: the `BAY_*` parameters, `bay_ef`, `bay_prof`, `bay_hook`, `bay_stop`, `bay_tongue`, `bay_pillar`, `bay_grip`, `bay_tongue_cut`, `bay_tongue2d` and `bay_marks2d`. Copy it into this project's SCAD file, because projects in this repo must stand alone.

Bay on `tray_eink`:
- Board facing front (joystick up), sitting on standoffs of about 3 mm.
- Two **hooks** on one long edge, the **finger latch** (tongue, pillar and grip tab) on the opposite edge, and **stops** on the short edges.
- `BAY_SLOT_H` = measured PCB thickness + 0.15.
- The tongue flexes in the tray's own plane. Its slot runs through the tray only, never through the outer shell.

**Ruggedness for a portable device.** The latch is the only part that can let go in a drop, so the closed case locks it. This adds no extra parts:
1. **Latch blocker:** a rib on `front_eink` drops in just outside the latch's grip tab (gap about 0.3) once the case is closed. The tongue then can't flex out and the latch can't open. With the front off it works exactly as on the Tahoe.
2. **Hold-down pads:** 3 or 4 small pads on `front_eink` stop about 0.3 above the board's top face, near the hook and latch edges, clear of parts. The board then can't rise out from under the lips even if a hook flexes.
3. **Optional:** `BAY_LIP` 0.8 → 1.0, behind a parameter. Everything else stays as on the Tahoe.

**Tray location:** the tray's corners have clearance holes that drop over the four case-screw bosses. The case screws pass through the front plate and the tray and clamp the tray. The board itself is never screwed.

**E-ink panel:** it sits in the `front_eink` pocket, 29.4 × 60 plus about 0.2 clearance. One end goes under two small lips, the other end is held by a gentle snap, with an optional 0.5–1 mm foam pad behind it. The panel is glass, so nothing presses hard on it. Leave a path for the FPC fold to the adapter and FFC.

## 6. Case screws: M3 heat-set inserts

Parameters at the top of the file:

```
INSERT_OD = 5.0;  INSERT_L = 6.0;
INSERT_HOLE_D = 4.0;           // the user tunes this (3.8–4.2) to their printer
INSERT_DEPTH = INSERT_L + 1;   INSERT_CHAMFER = 0.4;
BOSS_D = 9;                    // ≥ insert OD + 2 × 2 wall
SCREW_CLR_D = 3.4;  HEAD_D = 6.0;  HEAD_H = 3.2;   // counterbore
SCREWS_FROM = "front";         // "front" | "back"
```

- **Default:** inserts in the shell bosses, pressed straight down into the open shell. Screws go in from the front through the front plate and tray, with heads recessed in the four corners.
- Keep the 43.0 × 73.6 pattern so the boss positions match the original.
- `echo()` the required screw length (M3 × N) and list it in the parts list.
- Use a tongue-and-groove joint between the front and the shell, with an optional `GASKET=true` TPU groove.

## 7. Build order

1. **Folder.** Suggest renaming this folder to `wio-tracker-l1/` (it's the L1 E-ink, not the L1 Pro) and updating the root README's "Planned" line. Use the repo layout: `cad/`, `stl/`, `images/`, `docs/`, `README.md`. Copy `export.py` and `check_case.py` from `../xiao-node-case/cad/` as the template.
2. **`.gitignore`.** Ignore `stl files/` (third-party reference downloads) and `ref/`. They must not be committed or copied into the design.
3. **Constants.** Every number from section 2 becomes a named constant, each with a comment saying where it came from.
4. **Fit-test coupon first, with as little plastic as possible:** only the features under test, never the whole shell.
   - one M3 insert boss with a front-plate corner and the screw;
   - one tray edge with a hook and the finger latch, plus a stop, sized to the board;
   - a ~22 mm slice of the shell's dock end with the pogo pocket, to test in the real dock;
   - a frame-only panel pocket.
5. **Checks in `check_case.py`:**
   - clearance from the shell to both dock meshes, with the hump clearing the dock's back rest;
   - the latch blocker gap;
   - the hold-down pad gaps;
   - insert wall thickness;
   - the cell fitting at `CELL_MAX`.
6. **Release STL.** Once the fit test passes: **one combined STL per version** holding every printed part, e.g. `stl/wio-tracker-l1-eink.stl`. The user wants a single STL per design, not many files.
7. **Images and docs.** 2 or 3 check renders only, not a full image set. Then the README, parts list (inserts, M3 screws, ½ in strap, optional foam, optional pogo pins) and a short build guide.

## 8. Still to confirm by caliper

Use a planned value until the user supplies these, and note them in the fit test:

- PCB outline and thickness, and the hole pattern (expected 43 × 47).
- Height of the joystick and the tallest top-side part. Height of the tallest bottom-side part.
- Actual cell thickness (often 9.6–10.3) and its length including the PCM.
- Where the `stl files/` 3mf references came from (MakerWorld?). That decides whether the README links to that dock or the dock is later redrawn in SCAD to the section 2 numbers.
