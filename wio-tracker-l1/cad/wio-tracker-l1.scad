// ======================= Wio Tracker L1 case: E-ink version =======================
// One shared back shell; each screen version adds its own tray, front and caps, and both sit
// in the same dock. Built from ../PLAN.md. Every number says where it came from:
// "PLAN 2" = the plan's section 2; "ref" = measured on the check meshes in ../ref/.
//
// Frame, as in the plan: x across the width, y along the length from the dock end (y = 0),
// z through the depth from the back face (z = 0) forward. Millimetres. OpenSCAD 2021.01 or later.
//
// Built so far: the constants, the cores of the shell, tray and front, and the fit-test coupon
// cut from them (PART = "fit_test"). Not built yet: side openings, SMA bulkhead, GPS seat,
// cell ribs, caps, pogo plug, gasket groove (PLAN 7, steps 6 and 7).

PART = "fit_test";   // [fit_test, fit_view, assembly]  (a_*, d_*, e_*, s_* are for check_case.py)

// ---------------- measured (calipers, 2026-10-12) ----------------
PCB_T        = 1.57;            // board thickness
BOARD        = [47.96, 52.24];  // board outline, x by y (the plan guessed 50 x 54)
PANEL        = [29.29, 59.26, 1.14];   // e-ink module ZJY122250-0213BAAMFGN, x by y by thickness
ADAPTER      = [18.47, 10.31, 3.0];  // ribbon adapter board: the ribbons plug into its two long edges; 3 thick with its connectors
IRON_D       = 7.0;             // widest part of the heat-set tip on the soldering iron
// ---------------- still to measure (PLAN 8): planned values until the calipers say otherwise ----------------
BOARD_HOLES  = [43.0, 47.0];    // mounting-hole pattern, x by y (PLAN 2: the old board bosses; 2.5 in from each edge)
BOARD_HOLE_D = 2.2;             // mounting-hole diameter: the 2.0 mm pins fitted on the first coupon
SOLAR_H      = 4.8;             // solar socket's height above the board. It sits under the screen, so it sets how far back the board
                                //   goes. About 4.7 on the edge-on photo (scaled from the 3.5 battery socket); measure it
TOP_TALL     = 5.6;             // tallest part anywhere else on top of the board. Not measured: the old case leaves 5.9 there (ref)
USB_H        = 3.3;             // USB-C socket's height above the board (a standard part)
SO_H         = 3.0;             // standoff height. The battery socket under the board is about 3.5 tall: the tray is cut away there
BAT_NOTCH    = [5, 14, -9, 9];  // that cut, in board coordinates [u0, u1, v0, v1] from the bottom-left corner seen from the front.
                                //   Placed from Seeed's photo of the underside; the cell's lead comes up through it
CELL_MAX     = [10.5, 37, 68];  // [T, W, L] the biggest cell the bay takes: 103665 = 10 x 36 x 65, plus tolerance and its PCM
STRAP        = true;            // a 1/2 in hook-and-loop strap holds the cell to the back of the case (below). No foam, no extra depth
STRAP_T      = 1.2;             // the strap's thickness, one layer
STRAP_W      = 12.7;            // its width
UNDER = [["buzzer", 36.2, 48.8, 9.7, 22.5, 3.3],              // tall parts under the board: [name, u0, u1, v0, v1, height]. u, v from the board's
         ["LoRa antenna plug", 33.0, 40.0, 28.5, 35.5, 3.6]];  //   bottom-left corner seen from the front; each box is the part plus 1.5 all round.
                                //   Placed from Seeed's photo of the underside. Buzzer: about 3 (measured); the plug is a guess. The tray is pocketed under any taller than SO_H
UNDER_CLR    = 0.3;             // tray to those parts
PANEL_ACTIVE = [23.70, 48.55];  // the panel's active area (PLAN 1)
DEPTH        = 0;               // the shell's depth. 0 = as shallow as the cell in CELL_MAX allows, so a thinner cell gives a slimmer
                                //   case. 24 = the old shell (PLAN 2), the only depth the old docks take: that fits a cell up to 9.2 thick
CELL_SPARE   = 0.3;             // room behind the cell, for swelling

// ---------------- reference numbers (PLAN 2 and ref) ----------------
REF_SHELL = [55.0, 91.9, 24.0];     // PLAN 2: back shell's bounding box
X0 = 1.0; X1 = 55.0;                // ref: the body itself is 54 wide. x 0..1 is only a 1 mm bump on the old shell at y ~60
BODY_L = REF_SHELL[1];
OLD_DEPTH = REF_SHELL[2];
W  = X1 - X0;
XC = (X0 + X1)/2;
WALL    = 2.0;                      // PLAN 2: walls ~2
OLD_BACK_CH = 6.3;                  // ref: all four back edges are 45 deg chamfers this big (PLAN 2: section at y 0.5 starts at z 5.8)
END_R   = 3.5;                      // ref: corner radius seen from the front (PLAN 2: section at y 0.5 spans x 2.7..53.3)
REBATE  = [1.1, 1.0];               // ref: the rim's inner 1.1 mm stops 1.0 short, for the front plate's tongue
FRONT_H = 2.5;                      // ref: the old front plate, outer face to the face on the rim. Docked depth = 24 + 2.5 = 26.5
OLD_SCREWS   = [[6.5, 5.5], [49.5, 5.5], [6.5, 79.1], [49.5, 79.1]];     // PLAN 2: old case-screw bosses, pattern 43.0 x 73.6
OLD_BOARD    = [[6.5, 25.4], [49.5, 25.4], [6.5, 72.4], [49.5, 72.4]];   // PLAN 2: old board bosses, pattern 43 x 47
POGO_WIN = [22.9, 4.5];             // PLAN 2: pogo pocket on the dock-end face (ref: it goes right through the end wall)
POGO_C   = [27.4, 18.8];            // PLAN 2: its centre, x and z
SIDE_OPEN_Y = [[30.5, 32.8], [34, 37.5], [44.7, 48.3], [58.3, 62.4]];    // PLAN 2: openings in the x ~0 wall. Not cut yet:
SIDE_OPEN_Z = [18, 21];             //   check them against the board first
SMA_X = 29.3;                       // PLAN 2: antenna feature at the top end. Not built yet
// front plate: the plan's numbers are in the reference mesh's own frame (printed face down, turned end for end)
function fx(x) = x + 1.0;           // ref: reference-front x to this file's x (its four posts land on the old bosses)
function fy(y) = 91.8 - y;          // ref: and y
WIN       = [25.4, 50.4];           // PLAN 2: display window
WIN_C     = [fx(16.55), fy(51.27)]; // ref: its centre (PLAN 2 says 16.8, 51.5; the mesh section gives 16.55, 51.27)
POCKET    = [29.4, 60.0];           // PLAN 2: panel pocket behind the window
POCKET_C  = [fx(16.70), fy(48.72)]; // ref: its centre: the window sits 2.55 off it, toward the end away from the FPC
JOY       = [fx(45.0), fy(51.3), 8.9];   // PLAN 2: joystick hole, x, y, diameter
BTN       = [fx(34.9), fy(51.3), 5.6];   // PLAN 2: button hole
// docks (both the same pocket)
DOCK_POCKET = [54.85, 27.17, 20];   // PLAN 2: pocket, and how deep
DOCK_SLOT   = [36.74, 12.46];       // PLAN 2: pogo slot in its floor
DOCK_KEEP   = 22;                   // PLAN 2, dock rule: the bottom 22 mm keeps the old profile exactly

// ---------------- design ----------------
FRONT_T  = 1.6;                     // PLAN 3: front skin
TRAY_T   = 2.0;                     // PLAN 3: tray
BACK_T   = 2.2;                     // PLAN 3: back wall
TRAY_CLR = 0.2;                     // tray (and the front's posts) to the shell's walls
FRONT_EDGE = 2.2;                   // chamfer round the front plate's outer edge: the docks' front corners are cut 2.24 (ref)
TG_W = 0.8; TG_H = 0.8; TG_CLR = 0.15;   // the front's tongue in the rim's rebate
GASKET = false;                     // PLAN 6: TPU groove. Not built yet
// case screws (PLAN 6)
INSERT_OD = 5.0;  INSERT_L = 6.0;
INSERT_HOLE_D = 4.0;                // tune (3.8-4.2) to your printer
INSERT_DEPTH = INSERT_L + 1;  INSERT_CHAMFER = 0.4;
BOSS_D = 9;                         // >= insert OD + 2 x 2 wall
SCREW_CLR_D = 3.4;  HEAD_D = 5.6;  HEAD_H = 3.2;   // counterbore. 5.6: the one that fits your socket heads on the XIAO case screw test (PLAN 6 had 6.0)
SCREWS_FROM = "front";              // "front" | "back" (only "front" is built)
CB_SKIN = 0.2;                      // one layer left across each screw hole under its counterbore, so the seat prints as a bridge: push through it
SCREW_IN = 7.0;                     // screw axes this far in from the outside, both ways. The old bosses (PLAN 2) are 5.5 in;
                                    //   7 leaves the iron 1.5 mm off the walls, and keeps the top pair clear of a 68 mm cell
SCREWS = [for (y = [SCREW_IN, BODY_L - SCREW_IN], x = [X0 + SCREW_IN, X1 - SCREW_IN]) [x, y]];
// cell bay (PLAN 4)
// The strap goes right round the cell: behind it in a groove across the shell's floor, up both sides, and across its
// front through a window in the tray, where it closes on itself. Beside the cell it passes under two bars that
// bridge the groove, so the strap, and the cell in it, are tied to the back of the case.
STRAP_YC     = 41.8;            // the strap's centre line. Here the parts under the board are low (the MCU's corner), so the
                                //   strap's doubled-up closure has room; and it's 4 mm from the middle of the cell
STRAP_GROOVE = 1.0;             // groove in the floor: the strap stands 0.2 proud of it, inside the room left for the cell to swell
STRAP_BAR    = [1.7, 2.0, 0.5]; // the bars: width, height, and how far their underside is above the floor
STRAP_WALL   = 0.9;             // least wall left where the groove runs out into the back's chamfer
CELL_Y0 = SCREWS[0][1] + BOSS_D/2 + 0.3;   // the cell starts just above the dock-end bosses
CELL_YC = CELL_Y0 + CELL_MAX[2]/2;
// board position (PLAN 2: where the old board bosses put it)
BOARD_YC = (OLD_BOARD[0][1] + OLD_BOARD[2][1])/2;
BOARD_Y0 = BOARD_YC - BOARD[1]/2;
HOLES = [for (sy = [-1, 1], sx = [-1, 1]) [XC + sx*BOARD_HOLES[0]/2, BOARD_YC + sy*BOARD_HOLES[1]/2]];
SO_D  = 4.4;                        // standoff diameter (clear of the raised outline, which is MK_W inside the edge)
PIN_D = BOARD_HOLE_D - 0.4;         // pins in the two top mounting holes: slack, so the guides and stops take sideways loads first
                                    //   (a tighter pin snapped on the first test)
GUIDE_GAP    = 0.15;                // side guides to the board's edges
GUIDE_UP     = 0.6;                 // they stand this far above the board, chamfered to lead it in
BOARD_RELIEF = 0.5;                 // the shell's side walls are this much thinner beside the board, so the guides can be 1.2 thick
RELIEF_Y     = [BOARD_YC - BOARD[1]/2 - 2.5, BOARD_YC + BOARD[1]/2 + 2.5];
// lid lock (PLAN 5)
BLOCK_GAP = 0.3;                    // latch blocker: the front's rib to the end of the latch's pull tab
BLOCK_T   = 2.4;                    // rib thickness
BLOCK_Z0  = 1.0;                    // the rib stops this far above the tray
PAD_GAP   = 0.3;                    // hold-down pads stop this far above the board
PADS = [[HOLES[1][0], HOLES[1][1], 4.0],             // over the bottom-right mounting hole (right of the battery socket)
        [HOLES[3][0], HOLES[3][1] + 0.6, 3.0]        // over the top-right one, kept off the E-INK connector below it
        ];                                           // (none on the left: the panel and its door are in the way; two latches hold that edge)
BAY_LIP_STRONG = true;              // PLAN 5, optional: hook and latch lips 1.0 instead of 0.8 (first print: 0.8 held too little)
// e-ink panel (PLAN 5)
PANEL_CLR    = 0.6;                 // pocket = the plan's pocket + this (first print: +0.2 was too tight)
PANEL_RECESS = 0.6;                 // the pocket is sunk this far into the skin; the rest of the skin is the bezel
PANEL_PAD    = 0;                   // foam between the panel and its lips, if you fit any
WIN_BEVEL = 0.4;
// panel door: the screen lies loose in its pocket and a solid cover closes over its whole back, so nothing
// grips the glass. The door's left edge is bevelled and tucks under a rail that runs the length of the
// pocket; two turn buttons (as on the Tahoe sled) swing over its right edge.
DOOR_T   = 0.8;                     // door thickness
DOOR_GAP = 0.2;                     // door to the back of the glass (room for a thin foam pad)
DOOR_SLIDE = 0.9;                   // the door goes in this far to the right, then slides left under the rail
RAIL_CLR = 0.2;                     // door's bevel to the rail, measured straight up
RAIL_GAP_Y = [36.8, 47.7];          // the USB-C socket is under the rail here (placed from the photo): the rail is left out if they'd touch
RIBBON_X = [18.5, 31.5];            // notch for the panel's ribbon (photo: 2 to 13 mm in from the panel's right edge, seen from the front)
TB_POS   = [[39.5, 16.0], [39.5, 49.0]];   // turn buttons: below the board's bottom edge, and on bare board above the menu button
TB_T     = 1.6;                     // turn button thickness (Tahoe: 2.4; there's less room here)
TB_HUB   = 8;  TB_ARM = 3.2;  TB_L = 8;    // hub and arm, as the Tahoe's but 2 mm longer
TB_POST  = 6;  TB_SHANK = 4.0;  TB_HEAD = [4.8, 1.0];   // post, as the Tahoe's with a lower head
AD_CLR = 0.2; AD_WALL = 1.0; AD_H = 1.2;   // ribbon adapter's seat: clearance, corner walls
AD_PAD = [12, 4, 0.5];              // post on the tray that keeps the adapter in its seat: size, and its gap to the adapter (the ribbon passes there)

// fit-test coupon (PLAN 7 step 4)
FIT_CORNER = [17.0, 72.0];          // shell and front corner (top left): from the left edge to this x, from this y to the top
FIT_FRONT  = 44.0;                  // front, panel side: from the left edge to this x, full length

// ---------------- derived: the stack, front to back (PLAN 3) ----------------
// the board goes far enough back that the solar socket clears the panel's door, and the tallest part clears the skin
TOP_CLR = max(TOP_TALL + 0.3, SOLAR_H + 0.2 + DOOR_T + DOOR_GAP + PANEL[2] + PANEL_PAD - PANEL_RECESS);
STACK   = TRAY_T + SO_H + PCB_T + TOP_CLR - (FRONT_H - FRONT_T);   // back of the tray to the shell's rim
RIM_Z   = DEPTH > 0 ? DEPTH : ceil(10*(BACK_T + CELL_MAX[0] + CELL_SPARE + STACK) - 0.001)/10;   // the shell's rim; the front plate sits on it
Z_FRONT = RIM_Z + FRONT_H;          // outer face of the front
Z_SKIN  = Z_FRONT - FRONT_T;        // inside of the front skin
Z_BT    = Z_SKIN - TOP_CLR;         // board, top face
Z_BB    = Z_BT - PCB_T;             // board, underside
Z_TF    = Z_BB - SO_H;              // tray, front face
Z_TB    = Z_TF - TRAY_T;            // tray, back face = top of the shell's bosses = front of the cell
BACK_CH = DEPTH > 0 ? OLD_BACK_CH : max(1.5, min(OLD_BACK_CH, Z_TB - 4.4));   // a slim shell gets smaller chamfers, so they stay off the insert bosses
STRAP_E = 0;                        // the strap adds no depth: it's let into the floor
STRAP_Y = [STRAP_YC - STRAP_W/2 - 1.1, STRAP_YC + STRAP_W/2 + 1.1];   // the band the groove, bars and tray window take
CELL_X  = [XC - CELL_MAX[1]/2, XC + CELL_MAX[1]/2];
HUMP    = max(0, CELL_MAX[0] + STRAP_E + BACK_T - Z_TB);   // PLAN 4: only above the dock line
HUMP_HW = max(W/2 - BACK_CH - HUMP, CELL_MAX[1]/2 + STRAP_E + 0.5 + WALL*sqrt(2) - BACK_T);   // half-width of the hump's face
SG_Z    = BACK_T - HUMP - STRAP_GROOVE;                               // groove's floor
SG_X    = X0 + BACK_CH + STRAP_WALL*sqrt(2) - SG_Z;                    // where it has to start climbing the chamfer, left side
Z_SEAT  = Z_FRONT - HEAD_H;         // under the screw heads
SCREW_MAX = Z_SEAT - Z_TB + INSERT_DEPTH - 0.5;
SCREW_L = max([for (l = [6, 8, 10, 12, 14, 16, 18, 20, 22, 25, 30]) if (l <= SCREW_MAX) l]);
Z_PB    = Z_SKIN + PANEL_RECESS - PANEL[2] - PANEL_PAD;    // the panel's back face
PKT_X   = [max(X0 + WALL, POCKET_C[0] - (POCKET[0] + PANEL_CLR)/2), POCKET_C[0] + (POCKET[0] + PANEL_CLR)/2];
PKT_Y   = [POCKET_C[1] - (POCKET[1] + PANEL_CLR)/2, POCKET_C[1] + (POCKET[1] + PANEL_CLR)/2];   // the FPC end is the high-y end
assert(SCREWS_FROM == "front", "only SCREWS_FROM = \"front\" is built so far");

$fn = 40;
EPS = 0.01;

// ---------------- helpers ----------------
module rrect(x0, x1, y0, y1, r = 0) {
  if (r <= 0.02) translate([x0, y0]) square([x1 - x0, y1 - y0]);
  else hull() for (x = [x0 + r, x1 - r], y = [y0 + r, y1 - r]) translate([x, y]) circle(r = r);
}
module slab(z, t = EPS) translate([0, 0, z]) linear_extrude(height = t) children();
module box(x0, x1, y0, y1, z0, z1) translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, z1 - z0]);
module yz_prof(x0, x1, pts) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = x1 - x0) polygon(pts);   // a (y, z) profile along x
module inner2d(d) rrect(X0 + d, X1 - d, d, BODY_L - d, max(END_R - d, 0.3));   // the body's outline, inset d
// raised marks on the tray, as on the Tahoe sled (the bay block needs these)
MK_H = 0.6;           // raised 0.6 mm: three 0.2 mm layers
MK_W = 1.0;           // outline width, inside the board's edge
MK_FONT = "Liberation Sans:style=Bold";
module mk_text(t, x, z, size, rot = 0, sp = 1)
  translate([x, z]) rotate(rot) text(t, size = size, font = MK_FONT, halign = "center", valign = "center", spacing = sp);
SL_T = TRAY_T;        // the bay block's name for the thickness of the plate it stands on

// The block below is copied from ../../tahoe-repeater/cad/tahoe-repeater.scad as it stood on 2026-10-12 (the sideways-pull
// latch with its ear and pull tab), apart from three parameters: BAY_SLOT_H follows PCB_T, BAY_LIP follows
// BAY_LIP_STRONG (PLAN 5) and BAY_PAD_L is shorter.
// ============================ BOARD BAYS ============================
// Tool-less board holders, built from plain features standing on a plate. A board sits on
// standoffs (supports only; they needn't line up with its holes). Along one edge, two fixed
// hooks: a shelf under the board's edge and a lip 0.8 mm over it. On the opposite edge, one
// latch: a pillar on a tongue cut into the plate. The tongue flexes sideways in the plate's
// own plane, along the print layers. Two stops on the other two edges locate the board.
// To fit: slide the board's edge under the hooks, press the other edge down; the latch's ramp
// pushes it out and it snaps over the edge. To remove: pull the latch outward by its ear or the
// pull tab beyond it (never by the pillar's top), lift.
// Bay frame: u, v in the board's own frame (corner at 0), h up from the plate's face; the
// plate occupies h -SL_T..0. A bay: [size, standoff height, standoffs, hooks, latch, stops, labels]
//   standoffs [[u, v, d, (pin d), (keep u >= this)], ...]: an optional locating pin on top, and
//   an optional cut so a standoff only reaches this far under the board; hooks [[edge, t0, t1], ...]; latch [edge, t0, t1, dir];
//   stops [[edge, t0, t1], ...]; labels [[text, u, v, size, rotation, spacing], ...]: every bay
//   gets a raised outline and at least one label, so it's always clear which board goes where.
//   Edges "L", "R", "B", "T"; t runs along the edge in +v (L, R)
//   or +u (B, T); the tongue runs from the pillar in direction dir (+1 or -1) along t.
BAY_SLOT_H = PCB_T + 0.15;   // board thickness + 0.15: the slot under each lip
BAY_GAP    = 0.2;     // the board's edge to a hook's or stop's wall
BAY_LIP    = BAY_LIP_STRONG ? 1.0 : 0.8;    // how far lips reach over the board
BAY_LIP_T  = 1.4;     // lip and ramp height above the slot
BAY_TILT   = 18;      // hook lips rise inward so the board can be tilted in under them
BAY_SHELF  = 1.2;     // shelves reach this far under the board
BAY_WALL   = 2.6;     // hook wall thickness
BAY_BUTT   = 2.0;     // buttress on the outside of each hook's wall, at its foot
BAY_STOP_W = 2.0;     // stop thickness
BAY_STOP_UP = 1.8;    // stops rise this far above the board's underside (a little above its top)
BAY_PRE    = -0.05;   // latch fit: no preload, 0.05 mm clear once the board is pushed against its hooks (0.15 was too tight)
BAY_PW     = 2.4;     // latch pillar and tongue width (in its bending direction); 2.6 was stiff
BAY_TL     = 22;      // tongue length, pillar to root (17 was stiffer)
BAY_TSLOT  = 2.4;     // slot outside the tongue and the paddle: how far the latch can be pulled back (1.4 was a stretch)
BAY_ISLOT  = 0.8;     // slot inside the tongue
BAY_ESLOT  = 1.0;     // slot across the tongue's free end
BAY_RAMP_N = 0.6;     // the latch's ramp tops out this far past the board's edge
BAY_PIN_H  = 1.3;     // locating pins: less than the board's thickness
BAY_PAD_W  = 5;       // pull tab: a flat paddle on the tongue's free end, reaching outward past the ear,
BAY_PAD_L  = 7.5;     // ... this far from the tongue's outer face (Tahoe: 9; here it has to stop short of the tray's top edge),
BAY_GRIP_H = 4.5;     // ... with a low grip at its outer end, its top overhanging toward the board for a fingertip or tool. The pillar sits at the very end of the tongue.
BAY_GRIP_T = 1.6;     // grip thickness at its foot
BAY_GRIP_O = 1.0;     // the grip's top overhangs this far toward the board, on a 45 degree underside
BAY_EAR    = 3.5;     // finger tab: an ear on the latch's outer face, away from the board. Pull it outward to open.
BAY_EAR_H  = [1.0, 6.0];   // its underside starts here and rises at 45 degrees; its top
// edge frame (t along the edge, n outward from the board's edge, h up) to the bay frame
function bay_ef(e, sz) = e == "L" ? [[0, -1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
  : e == "R" ? [[0, 1, 0, sz[0]], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
  : e == "B" ? [[1, 0, 0, 0], [0, -1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]
  :            [[1, 0, 0, 0], [0, 1, 0, sz[1]], [0, 0, 1, 0], [0, 0, 0, 1]];
module bay_prof(t0, t1, pts) translate([t0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = t1 - t0) polygon(pts);  // (n, h) profile along t
module bay_hook(t0, t1, so) {
  sh = so + BAY_SLOT_H; top = sh + BAY_LIP_T;
  translate([t0, -BAY_SHELF, 0]) cube([t1 - t0, BAY_SHELF + BAY_GAP + 0.01, so]);           // shelf
  translate([t0, BAY_GAP, 0]) cube([t1 - t0, BAY_WALL, top]);                                // wall
  bay_prof(t0, t1, [[BAY_GAP + BAY_WALL - 0.01, 0], [BAY_GAP + BAY_WALL + BAY_BUTT, 0],        // buttress
                    [BAY_GAP + BAY_WALL - 0.01, so]]);
  bay_prof(t0, t1, [[BAY_GAP + 0.01, sh], [0, sh], [-BAY_LIP, sh + BAY_LIP*tan(BAY_TILT)],    // lip
                    [-BAY_LIP, top], [BAY_GAP + 0.01, top]]);
}
module bay_stop(t0, t1, so) {
  top = so + BAY_STOP_UP;
  translate([t0, -0.8, 0]) cube([t1 - t0, 0.8 + BAY_GAP + 0.01, so]);
  bay_prof(t0, t1, [[BAY_GAP, 0], [BAY_GAP + BAY_STOP_W, 0], [BAY_GAP + BAY_STOP_W, top], [BAY_GAP + 0.5, top], [BAY_GAP, top - 0.5]]);
}
function bay_tongue(t0, t1, dir) = dir > 0 ? [t0, t0 + BAY_TL] : [t1 - BAY_TL, t1];   // t range: pillar at the free end, root
function bay_pad(t0, t1, dir) = let(w = max(t1 - t0, BAY_PAD_W)) dir > 0 ? [t0, t0 + w] : [t1 - w, t1];   // t range of the paddle
module bay_pillar(t0, t1, so) {
  sh = so + BAY_SLOT_H; top = sh + BAY_LIP_T; p = BAY_GAP + BAY_PRE; n0 = -p + BAY_PW;
  bay_prof(t0, t1, [[-p, 0], [n0, 0], [n0, top], [BAY_RAMP_N, top],
                    [-p - BAY_LIP, sh + 0.4], [-p - BAY_LIP, sh], [-p, sh]]);
  bay_prof(t0, t1, [[n0 - 0.01, BAY_EAR_H[0]], [n0 + BAY_EAR, BAY_EAR_H[0] + BAY_EAR],             // the ear: printable,
                    [n0 + BAY_EAR, max(BAY_EAR_H[1], BAY_EAR_H[0] + BAY_EAR + 1.2)], [n0 - 0.01, max(BAY_EAR_H[1], BAY_EAR_H[0] + BAY_EAR + 1.2)]]);   // 45 degree underside
}
module bay_grip(t0, t1, dir) let(n0 = -BAY_GAP - BAY_PRE + BAY_PW, g = bay_pad(t0, t1, dir), n1 = n0 + BAY_PAD_L)   // low grip on the paddle's outer end
  let(a = n1 - BAY_GRIP_T, o = BAY_GRIP_O, h = BAY_GRIP_H)
  bay_prof(g[0], g[1], [[a, 0], [n1, 0], [n1, h - 0.4], [n1 - 0.4, h], [a - o, h], [a - o, h - 0.8], [a, h - 0.8 - o]]);
module bay_tongue_cut(t0, t1, dir) {
  p = BAY_GAP + BAY_PRE; tr = bay_tongue(t0, t1, dir); n0 = -p + BAY_PW;
  fe = dir > 0 ? [tr[0] - BAY_ESLOT, tr[0]] : [tr[1], tr[1] + BAY_ESLOT];       // free end slot
  ta = min(tr[0], fe[0]); tb = max(tr[1], fe[1]);
  g = bay_pad(t0, t1, dir); ga = dir > 0 ? fe[0] : g[0] - BAY_ESLOT; gb = dir > 0 ? g[1] + BAY_ESLOT : fe[1];
  difference() {
    union() {
      translate([ta, -p - BAY_ISLOT, -SL_T - 1]) cube([tb - ta, BAY_ISLOT, SL_T + 1.01]);           // inside
      translate([ta, n0, -SL_T - 1]) cube([tb - ta, BAY_TSLOT, SL_T + 1.01]);                        // outside
      translate([fe[0], -p - BAY_ISLOT, -SL_T - 1]) cube([fe[1] - fe[0], BAY_ISLOT + BAY_PW + BAY_PAD_L + BAY_TSLOT, SL_T + 1.01]);
      translate([ga, n0, -SL_T - 1]) cube([gb - ga, BAY_PAD_L + BAY_TSLOT, SL_T + 1.01]);           // round the paddle
    }
    translate([g[0], n0 - 0.02, -SL_T - 2]) cube([g[1] - g[0], BAY_PAD_L + 0.02, SL_T + 3]);        // the paddle stays, joined to the tongue
  }
}
// the tongue and its slots, in the bay frame, so the outline stays off the moving part
module bay_tongue2d(b) let(l = b[4], tr = bay_tongue(l[1], l[2], l[3]), p = BAY_GAP + BAY_PRE)
  multmatrix(bay_ef(l[0], b[0])) translate([tr[0] - BAY_ESLOT - 0.2, -p - BAY_ISLOT - 0.2])
    square([tr[1] - tr[0] + 2*BAY_ESLOT + 0.4, BAY_ISLOT + BAY_PW + BAY_PAD_L + BAY_TSLOT + 0.4]);
module bay_marks2d(b) difference() {
  union() {
    difference() { square(b[0]); offset(delta = -MK_W) square(b[0]); }    // outline just inside the board's edge
    for (t = b[6]) mk_text(t[0], t[1], t[2], t[3], rot = t[4], sp = t[5]);
  }
  bay_tongue2d(b);
  for (g = len(b) > 7 ? b[7] : []) translate([-1, g[0]]) square([b[0][0] + 2, g[1] - g[0]]);   // gaps, e.g. under a strap
}
module bay_add(b) {
  sz = b[0]; so = b[1];
  assert(len(b[6]) > 0, "every bay needs a label");
  translate([0, 0, -0.01]) linear_extrude(height = MK_H + 0.01) bay_marks2d(b);
  for (s = b[2]) intersection() {
    translate([s[0], s[1], 0]) {
      cylinder(d = s[2], h = so, $fn = 36);
      if (len(s) > 3 && s[3] > 0) translate([0, 0, so - 0.01]) cylinder(d1 = s[3], d2 = s[3] - 0.6, h = BAY_PIN_H, $fn = 24);
    }
    if (len(s) > 4) translate([s[4], s[1] - s[2], -1]) cube([2*s[2], 2*s[2], so + BAY_PIN_H + 2]);
  }
  for (k = b[3]) multmatrix(bay_ef(k[0], sz)) bay_hook(k[1], k[2], so);
  for (k = b[5]) multmatrix(bay_ef(k[0], sz)) bay_stop(k[1], k[2], so);
  let(l = b[4]) multmatrix(bay_ef(l[0], sz)) { bay_pillar(l[1], l[2], so); bay_grip(l[1], l[2], l[3]); }
}
module bay_cut(b) let(l = b[4]) multmatrix(bay_ef(l[0], b[0])) bay_tongue_cut(l[1], l[2], l[3]);
// footprint of everything a bay needs on its plate, for the test pieces
module bay_foot2d(b) {
  l = b[4]; tr = bay_tongue(l[1], l[2], l[3]);
  offset(delta = 5) square(b[0]);
  multmatrix(bay_ef(l[0], b[0])) translate([tr[0] - BAY_ESLOT - 3, -BAY_GAP - BAY_PRE - BAY_ISLOT - 3])
    square([tr[1] - tr[0] + 2*BAY_ESLOT + 6, BAY_ISLOT + BAY_PW + BAY_PAD_L + BAY_TSLOT + 4]);
}
module bay_test(b) difference() {
  union() { translate([0, 0, -SL_T]) linear_extrude(height = SL_T) bay_foot2d(b); bay_add(b); }
  bay_cut(b);
}

// ---------------- the E-ink board's bay ----------------
// Board as it sits in the case, seen from the front: battery and solar sockets along the bottom edge,
// USB-C, switch and reset down the left edge, E-INK connector up the right edge, OLED connector near
// the top. There's 1 mm between it and each side wall, so nothing can hold its long edges.
// The board drops straight in and two latches snap over it, one on each of its short edges:
//   top edge: latch right of the OLED connector; its tongue runs left and its pull tab points at the top wall
//   bottom edge: latch between the solar and Grove sockets; its tongue runs right and its pull tab points at the dock end
// Each latch needs 22 mm of tongue and 10 mm for its pull tab, so two won't go side by side on one 48 mm edge
// (and the top corners are taken by the case screws); one on each edge they both fit whole.
//   stops near all four corners, on the top and bottom edges, set the board's place along the case
//   guides, two on each long edge, set it across the case (the walls beside the board are relieved to make room)
//   pins in the two top mounting holes are only a rough guide now
// The frame is the board with BAY_GAP added top and bottom: with a latch on both edges that puts each latch
// -BAY_PRE clear of the board, as on the Tahoe sled.
BAY_SZ = [BOARD[0], BOARD[1] + 2*BAY_GAP];
BAY_O  = [XC - BOARD[0]/2, BOARD_Y0 - BAY_GAP];
HU = (BOARD[0] - BOARD_HOLES[0])/2;
HV = (BOARD[1] - BOARD_HOLES[1])/2 + BAY_GAP;
LATCH  = ["T", 34, 39, -1];
LATCH2 = ["B", 17, 22, 1];
STOPS  = [["B", 0.6, 3.2], ["B", 44.5, 47.5], ["T", 1.5, 6.5], ["T", 41.5, 46.5]];   // [edge, t0, t1]: clear of the sockets and the latches' slots
GUIDES = [["L", 2.0, 6.5], ["L", 8.0, 12.5],       // [side, v0, v1] from the board's bottom edge. Left: both below the USB-C socket,
          ["R", 2.5, 8.5], ["R", 40.0, 48.0]];     //   the only stretch of that edge with nothing hanging over it. Right: nothing overhangs
BAY_EINK = [BAY_SZ, SO_H,
  [[HU, HV, SO_D], [BOARD[0] - HU, HV, SO_D],
   [HU, HV + BOARD_HOLES[1], SO_D - 1.1, PIN_D], [BOARD[0] - HU, HV + BOARD_HOLES[1], SO_D - 1.1, PIN_D]],
  [],                                    // no hooks: a latch on each edge instead
  LATCH,                                 // the block takes one latch; the second is added beside it in tray_eink()
  [],                                    // the block's stops stand BAY_GAP off the frame; ours are set against the board itself, below
  [["WIO L1", 24, 9, 3.5, 0, 1]]];
BAY_EINK2 = [BAY_SZ, SO_H, [], [], LATCH2, [], BAY_EINK[6]];
PAD_T = bay_pad(LATCH[1], LATCH[2], LATCH[3]);                 // the top latch's pull tab: its span along the edge ...
PAD_N = -BAY_GAP - BAY_PRE + BAY_PW + BAY_PAD_L;               // ... and how far out from the frame's edge it ends
module side_guides() for (g = GUIDES) let(sd = g[0] == "L" ? -1 : 1, xb = XC + sd*(BOARD[0]/2 + GUIDE_GAP),
                                          xe = XC + sd*(W/2 - WALL + BOARD_RELIEF - TRAY_CLR), h = SO_H + PCB_T + GUIDE_UP)
  translate([0, BOARD_Y0 + g[2], 0]) rotate([90, 0, 0]) linear_extrude(height = g[2] - g[1])   // tray's front face at z = 0
    polygon([[xe, -EPS], [xb, -EPS], [xb, h - GUIDE_UP], [xb + sd*GUIDE_UP, h], [xe, h]]);
module bay_place() translate([BAY_O[0], BAY_O[1], Z_TF]) children();

// =============================== SHELL (shared) ===============================
// the body as a solid, inset w on the sides and f on the back: (0, 0) is the outside, (WALL, BACK_T) the cavity
module body_solid(w, f, ztop) {
  c  = BACK_CH + w*sqrt(2) - f;     // the chamfer's foot on the back
  zc = BACK_CH + w*sqrt(2) - w;     // where the chamfer meets the side
  hull() {
    slab(f) rrect(X0 + c, X1 - c, c, BODY_L - c, max(END_R - w, 0.3));   // ref: the corners keep their radius all the way down the chamfer
    slab(zc, ztop - zc) inner2d(w);
  }
}
// the hump: the back steps out above the dock line, 45 deg all round, for the cell and its strap
module hump_solid(w, f) {
  k    = w*sqrt(2) - f;
  zf   = -HUMP + f;
  hw   = HUMP_HW - k;
  wide = HUMP_HW + HUMP > W/2 - BACK_CH + 0.001;   // its flanks lie outside the body's own chamfer: run them out to the side walls
  rise = wide ? (W/2 - w) - hw : HUMP + 1;      // otherwise they carry on the chamfer's own slope, a hair inside it so the two join cleanly
  e    = wide ? 0 : 0.005;
  y1   = BODY_L - BACK_CH - HUMP - k;
  intersection() {
    hull() {
      slab(zf) rrect(XC - hw + e, XC + hw - e, 0, y1 - e);
      slab(zf + rise) rrect(XC - hw - rise + e, XC + hw + rise - e, 0, y1 + rise - e);
    }
    yz_prof(X0 - 1, X1 + 1, [[DOCK_KEEP + k, f], [DOCK_KEEP + k + HUMP, zf - EPS], [BODY_L + 1, zf - EPS],
                              [BODY_L + 1, RIM_Z], [DOCK_KEEP + k, RIM_Z]]);
  }
}
module shell_outer() { body_solid(0, 0, RIM_Z); if (HUMP > 0) hump_solid(0, 0); }
module shell_cavity() { body_solid(WALL, BACK_T, RIM_Z + 1); if (HUMP > 0) hump_solid(WALL, BACK_T); }
module insert_hole() {   // top at z = 0
  translate([0, 0, -INSERT_DEPTH]) cylinder(d = INSERT_HOLE_D, h = INSERT_DEPTH + EPS, $fn = 36);
  translate([0, 0, -INSERT_CHAMFER]) cylinder(d1 = INSERT_HOLE_D, d2 = INSERT_HOLE_D + 2*INSERT_CHAMFER, h = INSERT_CHAMFER + EPS, $fn = 36);
}
module strap_groove() for (m = [0, 1]) translate([m*(X0 + X1), 0, 0]) mirror([m, 0, 0])   // each half, mirrored about the centre line
  yz_swap() linear_extrude(height = STRAP_Y[1] - STRAP_Y[0])
    polygon([[SG_X - 1.4, SG_Z + 1.4], [SG_X, SG_Z], [XC + 0.01, SG_Z], [XC + 0.01, BACK_T - HUMP + 0.01], [SG_X + 2.3, BACK_T - HUMP + 0.01],
             [SG_X + 2.3, SG_Z + 6], [SG_X - 1.4, SG_Z + 6]]);
module yz_swap() translate([0, STRAP_Y[1], 0]) rotate([90, 0, 0]) children();   // an (x, z) profile along y, across the strap's band
module strap_bars() for (m = [0, 1]) translate([m*(X0 + X1), 0, 0]) mirror([m, 0, 0]) difference() {
  zf = BACK_T - HUMP;
  box(CELL_X[0] - 0.3 - STRAP_BAR[0], CELL_X[0] - 0.3, STRAP_Y[0] - 1.6, STRAP_Y[1] + 1.6, zf - 0.3, zf + STRAP_BAR[2] + STRAP_BAR[1]);
  box(CELL_X[0] - 3, CELL_X[0], STRAP_Y[0], STRAP_Y[1], zf - 1, zf + STRAP_BAR[2]);       // the strap passes under here
}
module shell(bosses = SCREWS, holes = true) {
  difference() {
    union() {
      difference() { shell_outer(); shell_cavity(); }
      intersection() {   // insert bosses, up to the tray
        shell_outer();
        for (p = bosses) translate([p[0], p[1], -HUMP - 1]) cylinder(d = BOSS_D, h = Z_TB + HUMP + 1, $fn = 48);
      }
    }
    slab(RIM_Z - REBATE[1], REBATE[1] + 1) inner2d(WALL - REBATE[0]);    // rebate for the front's tongue
    if (holes) for (p = bosses) translate([p[0], p[1], Z_TB]) insert_hole();
    if (RIM_Z >= POGO_C[1] + POGO_WIN[1]/2 + 2.5)                               // pogo window, where the shell is deep enough for it
    box(POGO_C[0] - POGO_WIN[0]/2, POGO_C[0] + POGO_WIN[0]/2, -1, WALL + 1,
        POGO_C[1] - POGO_WIN[1]/2, POGO_C[1] + POGO_WIN[1]/2);
    if (STRAP) strap_groove();
    for (m = [0, 1]) translate([m*(X0 + X1), 0, 0]) mirror([m, 0, 0])                       // thinner walls beside the board, from the tray up
      box(X0 + WALL - BOARD_RELIEF, X0 + WALL + 0.01, RELIEF_Y[0], RELIEF_Y[1], Z_TB - 0.3, RIM_Z + 1);
  }
  if (STRAP) strap_bars();
}

// =============================== TRAY (E-ink) ===============================
module tray_outline2d() {
  rrect(X0 + WALL + TRAY_CLR, X1 - WALL - TRAY_CLR, WALL + TRAY_CLR, BODY_L - WALL - TRAY_CLR, 1.2);
  translate([X0 + WALL - BOARD_RELIEF + TRAY_CLR, RELIEF_Y[0] + 0.3])                       // wider beside the board, into the walls' relief
    square([W - 2*(WALL - BOARD_RELIEF + TRAY_CLR), RELIEF_Y[1] - RELIEF_Y[0] - 0.6]);
}
module tray2d() difference() {
  tray_outline2d();
  for (p = SCREWS) translate(p) circle(d = SCREW_CLR_D, $fn = 32);
  if (STRAP) translate([CELL_X[0] - 1.5, STRAP_Y[0]]) square([CELL_X[1] - CELL_X[0] + 3, STRAP_Y[1] - STRAP_Y[0]]);   // the strap crosses the cell's front here, inside the tray's thickness
  translate([XC - BOARD[0]/2 + BAT_NOTCH[0], BOARD_Y0 + BAT_NOTCH[2]]) square([BAT_NOTCH[1] - BAT_NOTCH[0], BAT_NOTCH[3] - BAT_NOTCH[2]]);   // battery socket and lead
}
module tray_eink() translate([0, 0, Z_TF]) difference() {   // built with its front face at z = 0, as the bay block expects
  union() {
    slab(-TRAY_T, TRAY_T) tray2d();
    box(AD_C[0] - AD_PAD[0]/2, AD_C[0] + AD_PAD[0]/2, AD_C[1] - AD_PAD[1]/2, AD_C[1] + AD_PAD[1]/2, -EPS, Z_SKIN - ADAPTER[2] - AD_PAD[2] - Z_TF);   // keeps the ribbon adapter in its seat
    intersection() {
      union() {
        translate(BAY_O) {
          difference() {   // the block keeps its outline marks off its own latch; keep them off the second one too
            bay_add(BAY_EINK);
            translate([0, 0, -0.02]) linear_extrude(height = MK_H + 0.2) bay_tongue2d(BAY_EINK2);
          }
          multmatrix(bay_ef(LATCH2[0], BAY_SZ)) { bay_pillar(LATCH2[1], LATCH2[2], SO_H); bay_grip(LATCH2[1], LATCH2[2], LATCH2[3]); }
          for (k = STOPS) multmatrix(bay_ef(k[0], BAY_SZ)) translate([0, -BAY_GAP, 0]) bay_stop(k[1], k[2], SO_H);   // BAY_GAP from the board's own edge
        }
        side_guides();
      }
      slab(-1, 14) tray_outline2d();
    }
  }
  translate(BAY_O) { bay_cut(BAY_EINK); bay_cut(BAY_EINK2); }
  translate([XC - BOARD[0]/2 + BAT_NOTCH[0], BOARD_Y0 + BAT_NOTCH[2], -EPS]) cube([BAT_NOTCH[1] - BAT_NOTCH[0], BAT_NOTCH[3] - BAT_NOTCH[2], MK_H + 1]);   // no outline across the battery notch
  for (q = UNDER) let(d = q[5] + UNDER_CLR - SO_H) if (d > 0)   // pockets under the tall parts on the board's underside (right through, if little would be left)
    translate([XC - BOARD[0]/2 + q[1], BOARD_Y0 + q[3], d > TRAY_T - 0.5 ? -TRAY_T - 1 : -d]) cube([q[2] - q[1], q[4] - q[3], TRAY_T + 2]);
}

// =============================== FRONT (E-ink) ===============================
module front_env() hull() {   // the plate's outside: sits on the rim, outer edge chamfered
  slab(RIM_Z, FRONT_H - FRONT_EDGE) inner2d(0);
  slab(Z_FRONT - EPS) inner2d(FRONT_EDGE);
}
module win2d(d) rrect(WIN_C[0] - WIN[0]/2 - d, WIN_C[0] + WIN[0]/2 + d, WIN_C[1] - WIN[1]/2 - d, WIN_C[1] + WIN[1]/2 + d, 1.0 + d);
// latch blocker: a rib that drops in just beyond the end of the top latch's pull tab, so that latch can't be pulled back.
// (The bottom latch's pull tab ends under the panel, where no rib can reach; the hold-down pads cover it.)
module latch_blocker() bay_place() multmatrix(bay_ef(LATCH[0], BAY_SZ))
  translate([PAD_T[0] + 0.3, PAD_N + BLOCK_GAP, BLOCK_Z0]) cube([PAD_T[1] - PAD_T[0] - 0.6, BLOCK_T, Z_SKIN - Z_TF - BLOCK_Z0 + EPS]);
module pads() for (p = PADS)
  translate([p[0], p[1], Z_BT + PAD_GAP]) cylinder(d = p[2], h = Z_SKIN - Z_BT - PAD_GAP + EPS, $fn = 24);
// ---- panel door ----
// heights here are measured back from the inside of the front skin
HD0 = Z_SKIN - Z_PB + DOOR_GAP;     // door, face toward the glass
HD1 = HD0 + DOOR_T;                 // door, back
H_TONGUE = Z_SKIN - RIM_Z + TG_H;   // the tongue's end: the rail can't go further back than this without meeting the shell
DX0 = X0 + WALL + 0.15;             // door's left edge (at its face; the bevel leans in from here)
DX1 = TB_POS[0][0] - TB_HUB/2 - 0.4 - DOOR_SLIDE;   // its ears stop short of the turn buttons' hubs, even before it's slid home
DY0 = PKT_Y[0] - 1.0;  DY1 = PKT_Y[1] + 1.4;
EARS = [[DY0, 20.5], [44.8, 56.0]]; // ears beside the pocket, under the turn buttons: clear of the menu button and the Grove socket
module xz_prof(y0, y1, pts) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(height = y1 - y0) polygon(pts);   // an (x, z) profile along y
module door2d() difference() {
  union() {
    translate([DX0, DY0]) square([PKT_X[1] - 0.2 - DX0, DY1 - DY0]);
    for (e = EARS) translate([PKT_X[1] - 0.3, e[0]]) square([DX1 - PKT_X[1] + 0.3, e[1] - e[0]]);
  }
  translate([RIBBON_X[0], PKT_Y[1] - 4]) square([RIBBON_X[1] - RIBBON_X[0], 8]);   // ribbon
}
module door() {
  zf = Z_SKIN - HD0; zb = Z_SKIN - HD1;
  difference() {
    slab(zb, DOOR_T) door2d();
    xz_prof(DY0 - 1, DY1 + 1, [[DX0 - 1, zb - EPS], [DX0 + DOOR_T + EPS, zb - EPS], [DX0 - EPS, zf + EPS], [DX0 - 1, zf + EPS]]);   // bevel
  }
  // feet onto the skin, outside the pocket: bottom end, top left, and the two ears
  box(DX0 + 1.2, PKT_X[1] - 0.2, DY0, PKT_Y[0] - 0.3, zf - EPS, Z_SKIN);
  box(DX0 + 1.2, RIBBON_X[0] - 0.5, PKT_Y[1] + 0.3, DY1, zf - EPS, Z_SKIN);
  for (e = EARS) box(PKT_X[1] + 0.5, DX1, e[0], e[1], zf - EPS, Z_SKIN);
}
// on the front: the rail along the left, grown from the tongue, 45 deg underneath so it prints
module door_rail() {
  ha = HD0 - (DX0 - X0 - WALL) + RAIL_CLR;   // its edge at the wall
  usb = Z_BT + USB_H + 0.2 > Z_SKIN - H_TONGUE;
  for (y = usb ? [[DY0 - 0.3, RAIL_GAP_Y[0]], [RAIL_GAP_Y[1], DY1 + 0.3]] : [[DY0 - 0.3, DY1 + 0.3]])
    xz_prof(y[0], y[1], [[X0 + WALL - 0.45, Z_SKIN - ha], [X0 + WALL, Z_SKIN - ha], [X0 + WALL + H_TONGUE - ha, Z_SKIN - H_TONGUE], [X0 + WALL - 0.45, Z_SKIN - H_TONGUE]]);
}
// turn buttons: a C-shaped hub that snaps over the post's head, and an arm that swings over the door's ear
TB_H0 = HD1 + 0.1;                  // the posts' collar: the buttons turn on it, just clear of the door
module tb_posts() for (q = TB_POS) translate([q[0], q[1], 0]) {
  translate([0, 0, Z_SKIN - TB_H0]) cylinder(d = TB_POST, h = TB_H0 + EPS, $fn = 36);
  translate([0, 0, Z_SKIN - TB_H0 - TB_T - 0.12]) cylinder(d = TB_SHANK, h = TB_T + 0.13, $fn = 32);
  translate([0, 0, Z_SKIN - TB_H0 - TB_T - 0.12 - TB_HEAD[1]]) cylinder(d1 = TB_SHANK - 0.6, d2 = TB_HEAD[0], h = TB_HEAD[1] + EPS, $fn = 32);
}
module tb2d() difference() {   // hub at the origin, arm along +x
  union() {
    circle(d = TB_HUB, $fn = 40);
    hull() { circle(d = TB_ARM, $fn = 24); translate([TB_L - TB_ARM/2, 0]) circle(d = TB_ARM, $fn = 24); }
  }
  circle(d = TB_SHANK - 0.1, $fn = 32);
  translate([-5, -0.5]) square([5, 1.0]);
}
module turn_buttons(open = false) for (i = [0 : len(TB_POS) - 1]) let(q = TB_POS[i])   // shut: arms over the door. Open: lower one swung down, upper one up
  translate([q[0], q[1], Z_SKIN - TB_H0 - TB_T]) rotate(open ? (i == 0 ? -90 : 90) : 180) linear_extrude(height = TB_T) tb2d();
// ribbon adapter: sits on the inside of the front above the door, in line with the panel's ribbon. The panel's
// short ribbon comes up into its lower edge; the 50 mm extension leaves its upper edge, folds back toward the
// case's back and runs down and across to the board's E-INK connector. Four corners locate it; a post on the
// tray stops it leaving them once the case is shut.
AD_C  = [(RIBBON_X[0] + RIBBON_X[1])/2, PKT_Y[1] + 4.0 + ADAPTER[1]/2 + AD_CLR];
module adapter_seat() for (sx = [-1, 1], sy = [-1, 1]) translate([AD_C[0] + sx*(ADAPTER[0]/2 + AD_CLR), AD_C[1] + sy*(ADAPTER[1]/2 + AD_CLR), Z_SKIN - AD_H])
  linear_extrude(height = AD_H + EPS) polygon([[0, 0], [sx*AD_WALL, 0], [sx*AD_WALL, sy*AD_WALL], [-sx*3, sy*AD_WALL], [-sx*3, 0], [0, 0], [0, -sy*3], [sx*AD_WALL, -sy*3], [sx*AD_WALL, 0]]);
module adapter_dummy() color([0.2, 0.5, 0.3])
  box(AD_C[0] - ADAPTER[0]/2, AD_C[0] + ADAPTER[0]/2, AD_C[1] - ADAPTER[1]/2, AD_C[1] + ADAPTER[1]/2, Z_SKIN - ADAPTER[2], Z_SKIN);
module front_eink() difference() {
  union() {
    difference() { front_env(); slab(RIM_Z - 1, Z_SKIN - RIM_Z + 1) inner2d(WALL); }   // skin, and a skirt on the rim
    slab(RIM_Z - TG_H, TG_H + EPS) difference() {                                       // tongue
      inner2d(WALL - REBATE[0] + TG_CLR); inner2d(WALL - REBATE[0] + TG_CLR + TG_W);
    }
    intersection() {   // posts down onto the tray, kept off the shell's walls
      for (p = SCREWS) translate([p[0], p[1], Z_TF]) cylinder(d = BOSS_D, h = Z_SKIN - Z_TF + EPS, $fn = 48);
      union() {
        slab(Z_TF - 1, RIM_Z - TG_H - Z_TF + 1) inner2d(WALL + TRAY_CLR);
        slab(RIM_Z - TG_H - EPS, Z_SKIN - RIM_Z + TG_H + 1) inner2d(WALL - REBATE[0] + TG_CLR);
      }
    }
    latch_blocker();
    pads();
    door_rail();
    tb_posts();
    adapter_seat();
  }
  slab(Z_SKIN - EPS, FRONT_T + 1) win2d(0);                                             // display window
  hull() { slab(Z_FRONT - WIN_BEVEL) win2d(0); slab(Z_FRONT + EPS) win2d(WIN_BEVEL + EPS); }
  slab(Z_SKIN - EPS, PANEL_RECESS + EPS) rrect(PKT_X[0], PKT_X[1], PKT_Y[0], PKT_Y[1]);   // panel pocket
  for (h = [JOY, BTN]) translate([h[0], h[1], Z_SKIN - EPS]) cylinder(d = h[2], h = FRONT_T + 1);
  for (p = SCREWS) translate([p[0], p[1], 0]) {
    translate([0, 0, Z_TF - 1]) cylinder(d = SCREW_CLR_D, h = Z_SEAT - CB_SKIN - Z_TF + 1, $fn = 32);
    translate([0, 0, Z_SEAT]) cylinder(d = HEAD_D, h = HEAD_H + 1, $fn = 40);
  }
}

// =============================== stand-ins ===============================
module board_dummy() color([0.1, 0.45, 0.2]) difference() {
  box(XC - BOARD[0]/2, XC + BOARD[0]/2, BOARD_Y0, BOARD_Y0 + BOARD[1], Z_BB, Z_BT);
  for (h = HOLES) translate([h[0], h[1], Z_BB - 1]) cylinder(d = BOARD_HOLE_D, h = PCB_T + 2, $fn = 24);
}
module panel_dummy(dy = 0) color([0.85, 0.85, 0.8])   // pushed home under the lips; dy slides it toward the snap bar
  box(PKT_X[0] + 0.1, PKT_X[0] + 0.1 + PANEL[0], PKT_Y[1] - PANEL[1] - dy, PKT_Y[1] - dy, Z_PB, Z_PB + PANEL[2]);
module cell_dummy() color([0.3, 0.4, 0.8])
  box(XC - CELL_MAX[1]/2, XC + CELL_MAX[1]/2, CELL_Y0, CELL_Y0 + CELL_MAX[2], Z_TB - CELL_MAX[0], Z_TB);
module under_dummy() color([0.25, 0.25, 0.25]) {   // the tall parts under the board, and the battery socket
  for (q = concat(UNDER, [["battery socket", BAT_NOTCH[0] + 1.5, BAT_NOTCH[1] - 1.5, 1.0, 7.5, 3.5]])) let(m = q[0] == "battery socket" ? 0 : 1.5)
    box(XC - BOARD[0]/2 + q[1] + m, min(XC + BOARD[0]/2, XC - BOARD[0]/2 + q[2] - m), BOARD_Y0 + q[3] + m, BOARD_Y0 + q[4] - m, Z_BB - q[5], Z_BB);
}
module strap_dummy() color([0.15, 0.15, 0.15]) if (STRAP) {
  y = [STRAP_YC - STRAP_W/2, STRAP_YC + STRAP_W/2];
  box(SG_X, X0 + X1 - SG_X, y[0], y[1], SG_Z, SG_Z + STRAP_T);                           // behind the cell, in the groove and under the bars
  box(CELL_X[0], CELL_X[1], y[0], y[1], Z_TB, Z_TB + STRAP_T);                           // across its front, in the tray's window
  box(CELL_X[0], CELL_X[0] + 22, y[0], y[1], Z_TB, Z_TB + 2*STRAP_T);                    // doubled where it closes on itself, on the left
}

// =============================== FIT TEST (PLAN 7 step 4) ===============================
// Second coupon. Three pieces, each cut from the real part, so what fits here fits there:
//   tray   the whole tray: both latches, stops, side guides, pockets, the strap's window: snap the board in
//   boss   the shell's top-left corner, full height, with its insert boss: can the iron get in?
//   corner the front's top-left corner over that boss: screw, counterbore, tongue, a latch blocker
//   strap  a strip of the shell's back with the strap's groove and bars: thread your strap through
// They stack: boss, tray, corner, one M3 screw.
//   front  the front's panel side: pocket, window, the door's rail, turn-button posts, the ribbon adapter's seat
//   door   the cover behind the panel, and three turn buttons (two and a spare)
module fit_tray() tray_eink();   // the whole tray, as it will be
module fit_boss() intersection() { shell([SCREWS[2]]); box(X0 - 1, FIT_CORNER[0], FIT_CORNER[1], BODY_L + 1, -HUMP - 1, RIM_Z + 1); }
module fit_corner() intersection() { front_eink(); box(X0 - 1, FIT_CORNER[0], FIT_CORNER[1], BODY_L + 1, Z_TF - 1, Z_FRONT + 1); }
module fit_front() intersection() {   // takes in the corner piece, so that isn't printed twice
  front_eink();
  box(X0 - 1, FIT_FRONT, -1, BODY_L + 1, Z_TF - 1, Z_FRONT + 1);
}
module fit_strap() intersection() { shell([]); box(X0 - 1, X1 + 1, STRAP_Y[0] - 3.5, STRAP_Y[1] + 3.5, -HUMP - 1, BACK_T + 7); }
module fit_test() {   // print layout: each piece the way its real part prints, no supports
  translate([0, 0, -Z_TB]) fit_tray();                                                       // cell side down
  translate([58, -FIT_CORNER[1] + 16, HUMP]) fit_boss();                                     // back down
  if (STRAP) translate([0, -STRAP_Y[1] - 9, HUMP]) fit_strap();                              // back down, below the tray on the bed
  translate([76, BODY_L + 4, Z_FRONT]) rotate([180, 0, 0]) fit_front();                      // outer face down
  translate([122, 16 - DY0, -(Z_SKIN - HD1)]) door();                                        // back down, feet up
  for (i = [0 : 2]) translate([163, 20 + i*13, 0]) rotate(90) linear_extrude(height = TB_T) tb2d();
}
module fit_view() {   // put together, with the board and the panel
  color([0.75, 0.75, 0.78]) fit_boss();
  color([0.9, 0.6, 0.2]) fit_tray();
  color([0.35, 0.55, 0.8], 0.5) fit_front();
  color([0.9, 0.3, 0.3]) door();
  color([0.95, 0.8, 0.2]) turn_buttons();
  adapter_dummy();
  board_dummy();
  panel_dummy(0.4);
}
module assembly() {   // the cores of the full parts: not the finished case yet
  color([0.75, 0.75, 0.78]) shell();
  color([0.9, 0.6, 0.2]) tray_eink();
  color([0.35, 0.55, 0.8], 0.6) front_eink();
  board_dummy(); panel_dummy(); cell_dummy(); strap_dummy();
}

if (PART == "fit_test") fit_test();
else if (PART == "fit_view") fit_view();
else if (PART == "fit_cut") difference() { fit_view(); box(BAY_O[0] + PAD_T[0] + 2.5, 99, -9, 199, -9, 99); }   // cut through the latch's pull tab
else if (PART == "assembly") assembly();
// for check_case.py: parts where they sit when the case is together
else if (PART == "a_boss") fit_boss();
else if (PART == "a_strap") fit_strap();
else if (PART == "a_tray") fit_tray();
else if (PART == "a_corner") fit_corner();
else if (PART == "a_front") fit_front();
else if (PART == "a_door") door();
else if (PART == "a_tb") turn_buttons();
else if (PART == "a_tb_open") turn_buttons(true);
else if (PART == "d_adapter") adapter_dummy();
else if (PART == "a_shell") shell();
else if (PART == "a_tray_full") tray_eink();
else if (PART == "a_front_full") front_eink();
else if (PART == "a_pads") pads();
else if (PART == "a_blocker") latch_blocker();
else if (PART == "e_case") { shell_outer(); front_env(); }
else if (PART == "d_board") board_dummy();
else if (PART == "d_panel") panel_dummy();
else if (PART == "d_panel_low") panel_dummy(PKT_Y[1] - PKT_Y[0] - PANEL[1] - 0.02);
else if (PART == "d_cell") cell_dummy();
else if (PART == "d_strap") strap_dummy();
else if (PART == "d_under") under_dummy();
else if (PART == "s_boss") projection(cut = true) translate([0, 0, -(Z_TB - INSERT_L/2)]) fit_boss();
else if (PART == "s_boss_low") projection(cut = true) translate([0, 0, -(Z_TB - INSERT_DEPTH + 0.3)]) fit_boss();

echo(str("wtl: stack: front ", Z_FRONT, ", board ", Z_BB, " to ", Z_BT, ", tray ", Z_TB, " to ", Z_TF,
         ", cell bay ", Z_TB - BACK_T, " deep in the dock zone, hump ", HUMP,
         "; top of the board to the front skin ", TOP_CLR));
echo(str("wtl: shell ", RIM_Z, " deep, case ", Z_FRONT, " front to back", DEPTH > 0 ? " (set by DEPTH)" : str(" (fitted to a ", CELL_MAX[0], " mm cell)"),
         ". The old shell is ", OLD_DEPTH, ": at that depth the cell could be ", OLD_DEPTH - BACK_T - CELL_SPARE - STACK, " thick"));
echo(str("wtl: ribbon adapter seat: x ", AD_C[0] - ADAPTER[0]/2, " to ", AD_C[0] + ADAPTER[0]/2, ", y ", AD_C[1] - ADAPTER[1]/2, " to ", AD_C[1] + ADAPTER[1]/2,
         "; ", BODY_L - WALL - AD_C[1] - ADAPTER[1]/2, " mm above it for the extension to fold"));
echo(str("wtl: case screws: 4 x M3 x ", SCREW_L, " socket head, into M3 x ", INSERT_L, " heat-set inserts"));
echo(str("wtl-chk: {",
  "\"X0\": ", X0, ", \"X1\": ", X1, ", \"BODY_L\": ", BODY_L, ", \"RIM_Z\": ", RIM_Z, ", \"OLD_DEPTH\": ", OLD_DEPTH, ", \"TOP_CLR\": ", TOP_CLR, ", \"SOLAR_H\": ", SOLAR_H, ", \"WALL\": ", WALL, ", \"BACK_T\": ", BACK_T,
  ", \"Z_FRONT\": ", Z_FRONT, ", \"Z_SKIN\": ", Z_SKIN, ", \"Z_BT\": ", Z_BT, ", \"Z_BB\": ", Z_BB, ", \"Z_TF\": ", Z_TF, ", \"Z_TB\": ", Z_TB,
  ", \"HUMP\": ", HUMP, ", \"DOCK_KEEP\": ", DOCK_KEEP, ", \"DOCK_POCKET\": ", DOCK_POCKET, ", \"DOCK_SLOT\": ", DOCK_SLOT,
  ", \"POGO_C\": ", POGO_C, ", \"POGO_WIN\": ", POGO_WIN,
  ", \"BAY_O\": ", BAY_O, ", \"BOARD\": ", BOARD, ", \"BOARD_Y0\": ", BOARD_Y0, ", \"PCB_T\": ", PCB_T, ", \"SO_H\": ", SO_H,
  ", \"LATCH\": ", LATCH, ", \"PAD_T\": ", PAD_T, ", \"PAD_N\": ", PAD_N, ", \"BAY_TSLOT\": ", BAY_TSLOT, ", \"LATCH2\": ", LATCH2, ", \"BAY_SZ\": ", BAY_SZ, ", \"STOPS\": ", STOPS, ", \"GUIDES\": ", GUIDES, ", \"GUIDE\": ", [GUIDE_GAP, W/2 - WALL + BOARD_RELIEF - TRAY_CLR - BOARD[0]/2 - GUIDE_GAP, (BOARD_HOLE_D - PIN_D)/2], ", \"IRON_D\": ", IRON_D, ", \"BAY_GAP\": ", BAY_GAP, ", \"BAY_PRE\": ", BAY_PRE,
  ", \"BAY_PW\": ", BAY_PW, ", \"BAY_TL\": ", BAY_TL, ", \"BAY_LIP_T\": ", BAY_LIP_T, ", \"BAY_LIP\": ", BAY_LIP, ", \"BAY_SLOT_H\": ", BAY_SLOT_H,
  ", \"BLOCK_GAP\": ", BLOCK_GAP, ", \"PAD_GAP\": ", PAD_GAP, ", \"PADS\": ", PADS,
  ", \"INSERT_OD\": ", INSERT_OD, ", \"INSERT_HOLE_D\": ", INSERT_HOLE_D, ", \"INSERT_L\": ", INSERT_L, ", \"INSERT_DEPTH\": ", INSERT_DEPTH,
  ", \"BOSS_D\": ", BOSS_D, ", \"SCREWS\": ", SCREWS, ", \"SCREW_L\": ", SCREW_L, ", \"Z_SEAT\": ", Z_SEAT,
  ", \"CELL_MAX\": ", CELL_MAX, ", \"CELL_Y0\": ", CELL_Y0, ", \"STRAP\": ", STRAP ? [STRAP_T, STRAP_GROOVE, STRAP_BAR[2], STRAP_WALL, BACK_T - STRAP_GROOVE] : [], ", \"UNDER\": ", [for (q = UNDER) [q[0], q[5]]],
  ", \"PANEL\": ", PANEL, ", \"PANEL_ACTIVE\": ", PANEL_ACTIVE, ", \"WIN\": ", WIN, ", \"PKT_X\": ", PKT_X, ", \"PKT_Y\": ", PKT_Y,
  ", \"DOOR\": ", [Z_SKIN - HD1, DOOR_GAP, Z_SKIN - TB_H0 - TB_T - 0.12 - TB_HEAD[1], AD_PAD[2], DOOR_SLIDE], ", \"TB_POS\": ", TB_POS, "}"));
