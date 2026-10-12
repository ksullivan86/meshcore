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

// ---------------- still to measure (PLAN 8): planned values until the calipers say otherwise ----------------
PCB_T        = 1.6;             // board thickness
BOARD        = [50.0, 54.0];    // board outline, x by y
BOARD_HOLES  = [43.0, 47.0];    // mounting-hole pattern, x by y (PLAN 2: the old board bosses)
BOARD_HOLE_D = 2.2;             // mounting-hole diameter (the old bosses took M2 screws)
TOP_CLR      = 5.0;             // board's top face to the inside of the front skin: joystick, tallest top-side part
SO_H         = 3.0;             // standoff height: tallest bottom-side part. The cell strap also passes here
CELL_MAX     = [10.5, 37, 68];  // [T, W, L] the biggest cell the bay takes: 103665 = 10 x 36 x 65, plus tolerance and its PCM
STRAP_T      = 1.2;             // one layer of 1/2 in hook-and-loop strap, behind the cell (not in the plan's stack-up)
PANEL        = [29.2, 59.2, 1.2];   // e-ink module, x by y by thickness (PLAN 1)
PANEL_ACTIVE = [23.70, 48.55];      // its active area (PLAN 1)

// ---------------- reference numbers (PLAN 2 and ref) ----------------
REF_SHELL = [55.0, 91.9, 24.0];     // PLAN 2: back shell's bounding box
X0 = 1.0; X1 = 55.0;                // ref: the body itself is 54 wide. x 0..1 is only a 1 mm bump on the old shell at y ~60
BODY_L = REF_SHELL[1];
RIM_Z  = REF_SHELL[2];              // the shell's rim; the front plate sits on it
W  = X1 - X0;
XC = (X0 + X1)/2;
WALL    = 2.0;                      // PLAN 2: walls ~2
BACK_CH = 6.3;                      // ref: all four back edges are 45 deg chamfers this big (PLAN 2: section at y 0.5 starts at z 5.8)
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
SCREW_CLR_D = 3.4;  HEAD_D = 6.0;  HEAD_H = 3.2;   // counterbore
SCREWS_FROM = "front";              // "front" | "back" (only "front" is built)
CB_SKIN = 0.2;                      // one layer left across each screw hole under its counterbore, so the seat prints as a bridge: push through it
SCREW_X = [OLD_SCREWS[0][0], OLD_SCREWS[1][0]];
SCREW_Y_TOP = BODY_L - OLD_SCREWS[0][1];   // PLAN 2 has 79.1. Moved to the top end: at 79.1 the bosses leave 64.6 mm for a 68 mm cell
SCREWS = [for (y = [OLD_SCREWS[0][1], SCREW_Y_TOP], x = SCREW_X) [x, y]];
// cell bay (PLAN 4)
CS_W = 2.6; CS_LEN = 14;            // strap slots, as on the Tahoe repeater
CS_X = CELL_MAX[1]/2 + 0.6 + CS_W/2;
CELL_Y0 = SCREWS[0][1] + BOSS_D/2 + 0.3;   // the cell starts just above the dock-end bosses
CELL_YC = CELL_Y0 + CELL_MAX[2]/2;
// board position (PLAN 2: where the old board bosses put it)
BOARD_YC = (OLD_BOARD[0][1] + OLD_BOARD[2][1])/2;
BOARD_Y0 = BOARD_YC - BOARD[1]/2;
HOLES = [for (sy = [-1, 1], sx = [-1, 1]) [XC + sx*BOARD_HOLES[0]/2, BOARD_YC + sy*BOARD_HOLES[1]/2]];
SO_D  = 4.4;                        // standoff diameter (clear of the raised outline, which is MK_W inside the edge)
PIN_D = BOARD_HOLE_D - 0.2;         // locating pins in the two mounting holes by the latch
// lid lock (PLAN 5)
BLOCK_GAP = 0.3;                    // latch blocker: the front's rib to the latch's grip tab
BLOCK_T   = 2.4;                    // rib thickness
BLOCK_Z0  = 1.0;                    // the rib stops this far above the tray
PAD_GAP   = 0.3;                    // hold-down pads stop this far above the board
PADS = [[HOLES[1][0], HOLES[1][1], 4.0],       // over the two right-hand mounting holes ...
        [HOLES[3][0], HOLES[3][1], 4.0],
        [HOLES[2][0], HOLES[2][1] + 1.9, 2.0]]; // ... and beside the top-left one (the hole itself is under the panel)
BAY_LIP_STRONG = false;             // PLAN 5, optional: hook and latch lips 1.0 instead of 0.8
// e-ink panel (PLAN 5)
PANEL_CLR    = 0.2;                 // pocket = the plan's pocket + this
PANEL_RECESS = 0.6;                 // the pocket is sunk this far into the skin; the rest of the skin is the bezel
PANEL_PAD    = 0;                   // foam between the panel and its lips, if you fit any
WIN_BEVEL = 0.4;
LIP_W = 5.0; LIP_REACH = 1.5; LIP_T = 1.2; LIP_CLR = 0.3; LIP_WALL = 1.4;   // two lips at the FPC end
SNAP_T = 1.4; SNAP_TOP = 0.7; SNAP_H = 1.6;   // snap bar at the other end: thickness at its nose and at its far edge, height
SNAP_BITE = 0.3;                    // the bar reaches this far over the panel's end
SNAP_LIFT = 0.4;                    // the panel can lift this far before it meets the bar: nothing presses on the glass
SNAP_ANCHOR = 2.2;                  // the bar's ends are solid to the skin for this length ...
PANEL_PLAY = 0.5;                   // ... and stop the panel sliding more than this from under the lips (room for the FPC's fold)
// fit-test coupon (PLAN 7 step 4)
FIT_DOCK_L = DOCK_KEEP - 0.2;       // length of the dock-end slice: stops just short of where the hump starts
FIT_CORNER = [39.5, 28.5];          // front corner: from this x to the edge, from the dock end to this y
FIT_FRAME  = [35.2, 10.5, 76.8];    // panel frame: from the left edge to this x, between these y

// ---------------- derived: the stack, front to back (PLAN 3) ----------------
Z_FRONT = RIM_Z + FRONT_H;          // outer face of the front
Z_SKIN  = Z_FRONT - FRONT_T;        // inside of the front skin
Z_BT    = Z_SKIN - TOP_CLR;         // board, top face
Z_BB    = Z_BT - PCB_T;             // board, underside
Z_TF    = Z_BB - SO_H;              // tray, front face
Z_TB    = Z_TF - TRAY_T;            // tray, back face = top of the shell's bosses = front of the cell
HUMP    = max(0, CELL_MAX[0] + STRAP_T + BACK_T - Z_TB);   // PLAN 4: only above the dock line
HUMP_HW = max(W/2 - BACK_CH - HUMP, CELL_MAX[1]/2 + STRAP_T + 0.5 + WALL*sqrt(2) - BACK_T);   // half-width of the hump's face
Z_SEAT  = Z_FRONT - HEAD_H;         // under the screw heads
SCREW_MAX = Z_SEAT - Z_TB + INSERT_DEPTH - 0.5;
SCREW_L = max([for (l = [6, 8, 10, 12, 14, 16, 18, 20, 22, 25, 30]) if (l <= SCREW_MAX) l]);
Z_PB    = Z_SKIN + PANEL_RECESS - PANEL[2] - PANEL_PAD;    // the panel's back face
PKT_X   = [max(X0 + WALL, POCKET_C[0] - (POCKET[0] + PANEL_CLR)/2), POCKET_C[0] + (POCKET[0] + PANEL_CLR)/2];
PKT_Y   = [POCKET_C[1] - (POCKET[1] + PANEL_CLR)/2, POCKET_C[1] + (POCKET[1] + PANEL_CLR)/2];   // the FPC end is the high-y end
SNAP_Y  = PKT_Y[1] - PANEL[1];      // the panel's far end when it's pushed home under the lips
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

// The block below is copied from ../../tahoe-repeater/cad/tahoe-repeater.scad as it is, apart from
// two parameters: BAY_SLOT_H follows PCB_T and BAY_LIP follows BAY_LIP_STRONG (PLAN 5).
// ============================ BOARD BAYS ============================
// Tool-less board holders, built from plain features standing on a plate. A board sits on
// standoffs (supports only; they needn't line up with its holes). Along one edge, two fixed
// hooks: a shelf under the board's edge and a lip 0.8 mm over it. On the opposite edge, one
// latch: a pillar on a tongue cut into the plate. The tongue flexes sideways in the plate's
// own plane, along the print layers. Two stops on the other two edges locate the board.
// To fit: slide the board's edge under the hooks, press the other edge down; the latch's ramp
// pushes it out and it snaps over the edge. To remove: push the latch's top outward, lift.
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
BAY_PRE    = 0.15;    // latch preload: it sits this far into the board once the board is home
BAY_PW     = 2.6;     // latch pillar and tongue width (in its bending direction)
BAY_TL     = 17;      // tongue length, free end to root
BAY_TSLOT  = 1.4;     // slot outside the tongue: room for it to flex 1.1 mm
BAY_ISLOT  = 0.8;     // slot inside the tongue
BAY_ESLOT  = 1.0;     // slot across the tongue's free end
BAY_RAMP_N = 0.6;     // the latch's ramp tops out this far past the board's edge
BAY_PIN_H  = 1.3;     // locating pins: less than the board's thickness
BAY_TAB    = 5;       // finger tab: the tongue runs on past the pillar's free end ...
BAY_GRIP_H = 3;       // ... with a low grip on it. Push the grip outward to open the latch.
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
function bay_tongue(t0, t1, dir) = dir > 0 ? [t0 - BAY_TAB, t0 + BAY_TL] : [t1 - BAY_TL, t1 + BAY_TAB];   // t range: finger tab, pillar, root
module bay_pillar(t0, t1, so) {
  sh = so + BAY_SLOT_H; top = sh + BAY_LIP_T; p = BAY_GAP + BAY_PRE;
  bay_prof(t0, t1, [[-p, 0], [-p + BAY_PW, 0], [-p + BAY_PW, top], [BAY_RAMP_N, top],
                    [-p - BAY_LIP, sh + 0.4], [-p - BAY_LIP, sh], [-p, sh]]);
}
module bay_grip(t0, t1, dir) let(p = BAY_GAP + BAY_PRE, g = dir > 0 ? [t0 - BAY_TAB + 0.5, t0] : [t1, t1 + BAY_TAB - 0.5])
  bay_prof(g[0], g[1], [[-p, 0], [-p + BAY_PW, 0], [-p + BAY_PW, BAY_GRIP_H - 0.5], [-p + BAY_PW - 0.5, BAY_GRIP_H], [-p, BAY_GRIP_H]]);
module bay_tongue_cut(t0, t1, dir) {
  p = BAY_GAP + BAY_PRE; tr = bay_tongue(t0, t1, dir);
  fe = dir > 0 ? [tr[0] - BAY_ESLOT, tr[0]] : [tr[1], tr[1] + BAY_ESLOT];       // free end slot
  ta = min(tr[0], fe[0]); tb = max(tr[1], fe[1]);
  translate([ta, -p - BAY_ISLOT, -SL_T - 1]) cube([tb - ta, BAY_ISLOT, SL_T + 1.01]);           // inside
  translate([ta, -p + BAY_PW, -SL_T - 1]) cube([tb - ta, BAY_TSLOT, SL_T + 1.01]);             // outside
  translate([fe[0], -p - BAY_ISLOT, -SL_T - 1]) cube([fe[1] - fe[0], BAY_ISLOT + BAY_PW + BAY_TSLOT, SL_T + 1.01]);
}
// the tongue and its slots, in the bay frame, so the outline stays off the moving part
module bay_tongue2d(b) let(l = b[4], tr = bay_tongue(l[1], l[2], l[3]), p = BAY_GAP + BAY_PRE)
  multmatrix(bay_ef(l[0], b[0])) translate([tr[0] - BAY_ESLOT - 0.2, -p - BAY_ISLOT - 0.2])
    square([tr[1] - tr[0] + 2*BAY_ESLOT + 0.4, BAY_ISLOT + BAY_PW + BAY_TSLOT + 0.4]);
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
    square([tr[1] - tr[0] + 2*BAY_ESLOT + 6, BAY_ISLOT + BAY_PW + BAY_TSLOT + 6]);
}
module bay_test(b) difference() {
  union() { translate([0, 0, -SL_T]) linear_extrude(height = SL_T) bay_foot2d(b); bay_add(b); }
  bay_cut(b);
}

// ---------------- the E-ink board's bay ----------------
// The board is as wide as the cavity, so there's no room for hooks or stops on its long edges.
// Hooks are on the top (short) edge, the latch on the bottom one, and pins in the two bottom
// mounting holes do the stops' job. The frame's origin is BAY_GAP below the board's corner:
// the latch holds the board against the hooks' walls, and that's where PLAN 2 puts it.
BAY_O = [XC - BOARD[0]/2, BOARD_Y0 - BAY_GAP];
HU = (BOARD[0] - BOARD_HOLES[0])/2;
HV = (BOARD[1] - BOARD_HOLES[1])/2 + BAY_GAP;
BAY_EINK = [BOARD, SO_H,
  [[HU, HV, SO_D, PIN_D], [BOARD[0] - HU, HV, SO_D, PIN_D],
   [HU, HV + BOARD_HOLES[1], SO_D], [BOARD[0] - HU, HV + BOARD_HOLES[1], SO_D]],
  [["T", 5, 9], ["T", 41, 45]],          // hooks near the top corners
  ["B", 34, 38, -1],                     // latch on the bottom edge, right of the panel; the tongue runs left, the tab right
  [],                                    // no stops: the pins and the shell's walls locate the board sideways
  [["WIO L1", 25, 14, 4, 0, 1]]];
function bay_grip_t(l) = l[3] > 0 ? [l[1] - BAY_TAB + 0.5, l[1]] : [l[2], l[2] + BAY_TAB - 0.5];   // the grip tab's span along its edge
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
  wide = HUMP_HW + HUMP > W/2 - BACK_CH;        // its flanks lie outside the body's own chamfer: run them out to the side walls
  rise = wide ? (W/2 - w) - hw : HUMP;
  y1   = BODY_L - BACK_CH - HUMP - k;
  intersection() {
    hull() {
      slab(zf) rrect(XC - hw, XC + hw, 0, y1);
      slab(zf + rise) rrect(XC - hw - rise, XC + hw + rise, 0, y1 + rise);
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
module shell(bosses = SCREWS, holes = true) difference() {
  union() {
    difference() { shell_outer(); shell_cavity(); }
    intersection() {   // insert bosses, up to the tray
      shell_outer();
      for (p = bosses) translate([p[0], p[1], -HUMP - 1]) cylinder(d = BOSS_D, h = Z_TB + HUMP + 1, $fn = 48);
    }
  }
  slab(RIM_Z - REBATE[1], REBATE[1] + 1) inner2d(WALL - REBATE[0]);    // rebate for the front's tongue
  if (holes) for (p = bosses) translate([p[0], p[1], Z_TB]) insert_hole();
  box(POGO_C[0] - POGO_WIN[0]/2, POGO_C[0] + POGO_WIN[0]/2, -1, WALL + 1,   // pogo window
      POGO_C[1] - POGO_WIN[1]/2, POGO_C[1] + POGO_WIN[1]/2);
}

// =============================== TRAY (E-ink) ===============================
module tray_outline2d() rrect(X0 + WALL + TRAY_CLR, X1 - WALL - TRAY_CLR, WALL + TRAY_CLR, BODY_L - WALL - TRAY_CLR, 1.2);
module tray2d() difference() {
  tray_outline2d();
  for (p = SCREWS) translate(p) circle(d = SCREW_CLR_D, $fn = 32);
  for (s = [-1, 1]) translate([XC + s*CS_X - CS_W/2, CELL_YC - CS_LEN/2]) square([CS_W, CS_LEN]);   // cell strap
}
module tray_eink() translate([0, 0, Z_TF]) difference() {   // built with its front face at z = 0, as the bay block expects
  union() {
    slab(-TRAY_T, TRAY_T) tray2d();
    intersection() { translate(BAY_O) bay_add(BAY_EINK); slab(-1, 14) tray_outline2d(); }
  }
  translate(BAY_O) bay_cut(BAY_EINK);
}

// =============================== FRONT (E-ink) ===============================
module front_env() hull() {   // the plate's outside: sits on the rim, outer edge chamfered
  slab(RIM_Z, FRONT_H - FRONT_EDGE) inner2d(0);
  slab(Z_FRONT - EPS) inner2d(FRONT_EDGE);
}
module win2d(d) rrect(WIN_C[0] - WIN[0]/2 - d, WIN_C[0] + WIN[0]/2 + d, WIN_C[1] - WIN[1]/2 - d, WIN_C[1] + WIN[1]/2 + d, 1.0 + d);
// latch blocker: a rib that drops in just outside the latch's grip tab, so the tongue can't flex open
module latch_blocker() let(l = BAY_EINK[4], g = bay_grip_t(l))
  bay_place() multmatrix(bay_ef(l[0], BAY_EINK[0]))
    translate([g[0] + 0.3, -BAY_GAP - BAY_PRE + BAY_PW + BLOCK_GAP, BLOCK_Z0])
      cube([g[1] - g[0] - 0.6, BLOCK_T, Z_SKIN - Z_TF - BLOCK_Z0 + EPS]);
module pads() for (p = PADS)
  translate([p[0], p[1], Z_BT + PAD_GAP]) cylinder(d = p[2], h = Z_SKIN - Z_BT - PAD_GAP + EPS, $fn = 24);
// the panel's FPC end goes under two lips; the FPC folds back between them
module panel_lips() for (x = [[PKT_X[0] + 0.2, PKT_X[0] + 0.2 + LIP_W], [PKT_X[1] - LIP_W, PKT_X[1]]]) {
  box(x[0], x[1], PKT_Y[1], PKT_Y[1] + LIP_WALL, Z_PB - LIP_CLR - LIP_T, Z_SKIN + EPS);
  box(x[0], x[1], PKT_Y[1] - LIP_REACH, PKT_Y[1] + EPS, Z_PB - LIP_CLR - LIP_T, Z_PB - LIP_CLR);
}
// the other end snaps past a bar that bridges the pocket's end clear of the skin and flexes along its length
module panel_snap() {
  zu = Z_PB - SNAP_LIFT;            // the bar's face nearest the skin
  xa = PKT_X[0] + 0.2; xb = PKT_X[1] + SNAP_ANCHOR;
  yn = SNAP_Y + SNAP_BITE;          // its nose
  yz_prof(xa, xb, [[yn - SNAP_T, zu], [yn, zu], [yn, zu - 0.3], [yn - SNAP_T + SNAP_TOP, zu - SNAP_H], [yn - SNAP_T, zu - SNAP_H]]);
  for (x = [xa, PKT_X[1] - SNAP_ANCHOR]) box(x, x + SNAP_ANCHOR, yn - SNAP_T, SNAP_Y - PANEL_PLAY, zu - SNAP_H, Z_SKIN + EPS);   // end stops for the panel
  box(PKT_X[1], xb, yn - SNAP_T, yn, zu - SNAP_H, Z_SKIN + EPS);
}
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
    panel_lips();
    panel_snap();
  }
  slab(Z_SKIN - EPS, FRONT_T + 1) win2d(0);                                             // display window
  hull() { slab(Z_FRONT - WIN_BEVEL) win2d(0); slab(Z_FRONT + EPS) win2d(WIN_BEVEL + EPS); }
  slab(Z_SKIN - EPS, PANEL_RECESS + EPS) rrect(PKT_X[0], PKT_X[1], PKT_Y[0], PKT_Y[1], 0.3);   // panel pocket
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
module strap_dummy() color([0.15, 0.15, 0.15])
  box(XC - CELL_MAX[1]/2 - STRAP_T, XC + CELL_MAX[1]/2 + STRAP_T, CELL_YC - 6.85, CELL_YC + 6.85, Z_TB - CELL_MAX[0] - STRAP_T, Z_TB);

// =============================== FIT TEST (PLAN 7 step 4) ===============================
// Four small pieces, each cut from the real part, so what fits here fits there:
//   dock   the shell's dock end with the pogo window and one insert boss: try it in the dock
//   tray   one hook, the latch, the two pins and three standoffs on a skeleton of the tray: snap the board in
//   corner the front's corner over that boss: screw, counterbore, tongue, latch blocker, one hold-down pad
//   frame  the panel pocket with its lips and snap bar: try the panel
module fit_dock() difference() {
  intersection() { shell([SCREWS[1]]); box(X0 - 1, X1 + 1, -1, FIT_DOCK_L, -1, RIM_Z + 1); }
  box(XC - 16, XC + 16, 9.5, FIT_DOCK_L + 1, -1, BACK_T + 1);     // open floor: less plastic
}
module fit_tray_mask2d() {
  l = BAY_EINK[4]; tr = bay_tongue(l[1], l[2], l[3]);
  xr = X1 - WALL; ox = BAY_O[0]; oy = BAY_O[1];
  translate([ox + tr[0] - 3.5, oy - 6.4]) square([xr - ox - tr[0] + 3.5, 12.7]);              // the latch, its tongue and the right pin
  translate([X0 + WALL, oy + HV - 2.8]) square([ox + tr[0] - X0 - WALL, 5.6]);                 // out to the left pin
  translate([xr - 6.2, oy]) square([6.2, BOARD[1] + 4]);                                       // up the right side
  translate([ox + BAY_EINK[3][1][1] - 1.5, oy + BOARD[1] - 4.7]) square([xr, 13]);             // the right hook and its standoff
  translate([xr - 8.5, 0]) square([8.5, oy]);                                                  // down to the case screw
}
module fit_tray() intersection() { tray_eink(); slab(Z_TB - 1, 16) fit_tray_mask2d(); }
module fit_corner() intersection() { front_eink(); box(FIT_CORNER[0], X1 + 1, -1, FIT_CORNER[1], Z_TF - 1, Z_FRONT + 1); }
module fit_frame() intersection() { front_eink(); box(X0 - 1, FIT_FRAME[0], FIT_FRAME[1], FIT_FRAME[2], Z_TF - 1, Z_FRONT + 1); }
module fit_test() {   // print layout: each piece the way its real part prints, no supports
  fit_dock();                                                                    // back down
  translate([58, 0, -Z_TB]) fit_tray();                                          // cell side down
  translate([0, FIT_CORNER[1] + 28, Z_FRONT]) rotate([180, 0, 0]) fit_corner();  // outer face down
  translate([0, FIT_FRAME[2] + 26, Z_FRONT]) rotate([180, 0, 0]) fit_frame();
}
module fit_view() {   // put together, with the board and the panel
  color([0.75, 0.75, 0.78]) fit_dock();
  color([0.9, 0.6, 0.2]) fit_tray();
  color([0.35, 0.55, 0.8]) fit_corner();
  color([0.35, 0.55, 0.8]) fit_frame();
  board_dummy();
  panel_dummy();
}
module assembly() {   // the cores of the full parts: not the finished case yet
  color([0.75, 0.75, 0.78]) shell();
  color([0.9, 0.6, 0.2]) tray_eink();
  color([0.35, 0.55, 0.8], 0.6) front_eink();
  board_dummy(); panel_dummy(); cell_dummy(); strap_dummy();
}

if (PART == "fit_test") fit_test();
else if (PART == "fit_view") fit_view();
else if (PART == "fit_cut") difference() { fit_view(); box(BAY_O[0] + bay_grip_t(BAY_EINK[4])[0] + 2, 99, -9, 199, -9, 99); }   // cut through the latch's grip tab
else if (PART == "assembly") assembly();
// for check_case.py: parts where they sit when the case is together
else if (PART == "a_dock") fit_dock();
else if (PART == "a_tray") fit_tray();
else if (PART == "a_corner") fit_corner();
else if (PART == "a_frame") fit_frame();
else if (PART == "a_shell") shell();
else if (PART == "a_tray_full") tray_eink();
else if (PART == "a_front_full") front_eink();
else if (PART == "a_pads") pads();
else if (PART == "a_blocker") latch_blocker();
else if (PART == "e_case") { shell_outer(); front_env(); }
else if (PART == "d_board") board_dummy();
else if (PART == "d_panel") panel_dummy();
else if (PART == "d_panel_low") panel_dummy(PANEL_PLAY - 0.02);
else if (PART == "d_cell") cell_dummy();
else if (PART == "d_strap") strap_dummy();
else if (PART == "s_boss") projection(cut = true) translate([0, 0, -(Z_TB - INSERT_L/2)]) fit_dock();
else if (PART == "s_boss_low") projection(cut = true) translate([0, 0, -(Z_TB - INSERT_DEPTH + 0.3)]) fit_dock();

echo(str("wtl: stack: front ", Z_FRONT, ", board ", Z_BB, " to ", Z_BT, ", tray ", Z_TB, " to ", Z_TF,
         ", cell bay ", Z_TB - BACK_T, " deep in the dock zone, hump ", HUMP));
echo(str("wtl: case screws: 4 x M3 x ", SCREW_L, " socket head, into M3 x ", INSERT_L, " heat-set inserts"));
echo(str("wtl-chk: {",
  "\"X0\": ", X0, ", \"X1\": ", X1, ", \"BODY_L\": ", BODY_L, ", \"RIM_Z\": ", RIM_Z, ", \"WALL\": ", WALL, ", \"BACK_T\": ", BACK_T,
  ", \"Z_FRONT\": ", Z_FRONT, ", \"Z_SKIN\": ", Z_SKIN, ", \"Z_BT\": ", Z_BT, ", \"Z_BB\": ", Z_BB, ", \"Z_TF\": ", Z_TF, ", \"Z_TB\": ", Z_TB,
  ", \"HUMP\": ", HUMP, ", \"DOCK_KEEP\": ", DOCK_KEEP, ", \"DOCK_POCKET\": ", DOCK_POCKET, ", \"DOCK_SLOT\": ", DOCK_SLOT,
  ", \"POGO_C\": ", POGO_C, ", \"POGO_WIN\": ", POGO_WIN,
  ", \"BAY_O\": ", BAY_O, ", \"BOARD\": ", BOARD, ", \"BOARD_Y0\": ", BOARD_Y0, ", \"PCB_T\": ", PCB_T, ", \"SO_H\": ", SO_H,
  ", \"LATCH\": ", BAY_EINK[4], ", \"GRIP\": ", bay_grip_t(BAY_EINK[4]), ", \"BAY_GAP\": ", BAY_GAP, ", \"BAY_PRE\": ", BAY_PRE,
  ", \"BAY_PW\": ", BAY_PW, ", \"BAY_TL\": ", BAY_TL, ", \"BAY_LIP_T\": ", BAY_LIP_T, ", \"BAY_LIP\": ", BAY_LIP, ", \"BAY_SLOT_H\": ", BAY_SLOT_H,
  ", \"BLOCK_GAP\": ", BLOCK_GAP, ", \"PAD_GAP\": ", PAD_GAP, ", \"PADS\": ", PADS,
  ", \"INSERT_OD\": ", INSERT_OD, ", \"INSERT_HOLE_D\": ", INSERT_HOLE_D, ", \"INSERT_L\": ", INSERT_L, ", \"INSERT_DEPTH\": ", INSERT_DEPTH,
  ", \"BOSS_D\": ", BOSS_D, ", \"SCREWS\": ", SCREWS, ", \"SCREW_L\": ", SCREW_L, ", \"Z_SEAT\": ", Z_SEAT,
  ", \"CELL_MAX\": ", CELL_MAX, ", \"CELL_Y0\": ", CELL_Y0, ", \"STRAP_T\": ", STRAP_T,
  ", \"PANEL\": ", PANEL, ", \"PANEL_ACTIVE\": ", PANEL_ACTIVE, ", \"WIN\": ", WIN, ", \"PKT_X\": ", PKT_X, ", \"PKT_Y\": ", PKT_Y,
  ", \"LIP_REACH\": ", LIP_REACH, ", \"SNAP_BITE\": ", SNAP_BITE, ", \"SNAP_T\": ", SNAP_T, ", \"SNAP_TOP\": ", SNAP_TOP,
  ", \"SNAP_SPAN\": ", PKT_X[1] - PKT_X[0] - 0.2 - 2*SNAP_ANCHOR, ", \"PANEL_PLAY\": ", PANEL_PLAY, "}"));
