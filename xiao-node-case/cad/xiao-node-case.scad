// =====================================================================
// XIAO node case, design revision 3
// https://github.com/ksullivan86/meshcore (folder xiao-node-case)
// Licensed CC BY-NC-SA 4.0 (see LICENSE). No commercial use without
// written permission from the author.
// ---------------------------------------------------------------------
// A desk case for one, two or three Seeed XIAO ESP32S3 + Wio-SX1262 kits
// side by side. In the kit the XIAO is at the bottom, with its USB-C,
// boot (B) and reset (R) buttons and WiFi U.FL on its top face, and the
// Wio-SX1262 board rides 4.5 mm above it on a board-to-board connector,
// with its LoRa module, LoRa U.FL, user button and user LED on top. The
// header pins hang below the XIAO.
//
// Each kit has its own bay: a USB-C opening in the front wall with a
// debossed label, a pocket for its stock WiFi FPC antenna on the bay's
// right-hand wall (a thin divider, or the case's side wall for the last
// bay), and its antenna bulkheads standing straight up out of the lid: an
// SMA for the LoRa pigtail, labelled LoRa, over the alley left of the
// board, and with WIFI = "rpsma" an RP-SMA for WiFi, labelled WiFi, over
// the right one, instead of the FPC. The FPC's cable spool sits between.
//
// Parts (every one prints flat, no supports):
//   BODY   floor, walls and the bays. Each bay is the Tahoe repeater's
//          tool-less board bay, holding the XIAO (the bottom board): it
//          rests on four standoffs, clear of its header pins; two hooks on
//          the front wall reach 0.8 mm over its front corners; a latch on a
//          tongue cut into the floor snaps over its left edge; rails and
//          stops locate it. Slide the front edge under the hooks and press
//          the back down until it clicks. To lift it out, push the low
//          finger tab beside the latch toward the side wall.
//   LID    one piece, hinged at the back: its two knuckles clip onto pins
//          on the back of the body. Hold the lid upright over them and
//          press it down to fit it; pull it straight up the same way to
//          take it off. It opens to about 100 degrees and rests there on
//          the hinge cheeks. Two sprung tabs at its front corners click
//          into the front wall; lift the tab in the middle of the front
//          edge to open it. It carries a flexure plunger over each Wio
//          user button, a window over its user LED, and the antennas.
//   PLATE  the base plate, an open tray. M6 fender washers stack on pins in
//          a chamber at each end (on a one-bay case, two chambers at the
//          front), and the chamber between is open for any other weight;
//          the partitions carry the body's floor. It slides on from the
//          back: a lip up each side runs in a V-groove along the bottom of
//          the body's side walls, and the grooves stop it at the front. A
//          sprung tooth in the middle clicks up through a slot in the
//          body's floor. To take it off, open the lid, press the tooth
//          down and slide the plate back. No screws anywhere.
//
// Frame: X across the case, +Y from the front (USB-C) toward the back,
// Z up. Origin at the front-left inside corner on the floor's top face.
// Each kit has its own board frame: u across, v back from the XIAO's
// front edge, h up from the XIAO's underside. Units mm. OpenSCAD 2021.01.
// =====================================================================

/* [What to make] */
PART = "assembly";   // [assembly, kit, fit_test, body, lid, plate, section, bay_view]
BAYS = 2;            // [1, 2, 3]
LABELS = ["HA", "OBS", "RELAY"];   // debossed under each USB-C opening, left to right
WIFI = "fpc";        // [fpc, rpsma]  stock FPC antenna on the bay's right wall, or an RP-SMA bulkhead on the lid per kit

/* [Measured on the kit] */
STACK_H = 9.32;       // the two boards: the XIAO's underside to the top of the Wio's LoRa module
PIN_BELOW = 9.0;      // the header (plastic and pins) below the XIAO's underside
FPC = [38, 18];       // stock WiFi FPC antenna: length, height
FPC_CABLE = 60;       // its cable
PIGTAIL = 85;         // LoRa U.FL-to-SMA pigtail cable

/* [From Seeed's STEP file and drawings] */
// Wio-SX1262 for XIAO (Seeed's 3D file): 17.78 x 21.44 x 1.6, its front edge 0.04 ahead of the XIAO's
WIO = [17.78, 21.44, 1.6]; WIO_V0 = -0.04;
MODULE = [3.39, 14.39, 9.48, 21.08, 2.2];   // LoRa module on the Wio: u range, v range, height above the Wio
B2B = [2.43, 11.03, 17.65, 21.08];          // board-to-board connector between them: u range, v range
WIO_BTN = [9.3, 8.2]; WIO_SW = [2.6, 2.6, 1.5];   // Wio user button: (u, v), size and height (from Seeed's photo: check)
WIO_LED = [13.2, 8.1];                      // Wio user LED
LORA_UFL = [5.0, 19.3]; LORA_UFL_H = 3.3;   // LoRa U.FL on the module's back corner; top of its plug above the Wio
// XIAO ESP32S3
KIT = [17.8, 21.0];   // the XIAO: across the pin rows (u), USB-C end to the far end (v)
XIAO_T = 1.0;         // its PCB
USB = [8.94, 3.26, 1.3, 7.35];   // USB-C socket: width, height, overhang past the front edge, length
USB_U = KIT[0]/2;
BTN_B = [3.15, 1.4];  // boot button (u, v) on the XIAO's top face, left of the USB-C (seen from the front), close to the front edge
BTN_R = [14.25, 1.4]; // reset button, right of it. Placed to agree with the prints: front hooks ending at u 1.9 and
                      // starting at 15.9 cleared them, but 2.2 and 15.6 landed on them and held the board back
SW = [2.6, 1.6, 0.8]; // those buttons: size across, along, height
WIFI_UFL = [14.2, 18.5];  // WiFi U.FL, on the XIAO's top face at its back right
PIN_PITCH = 2.54; PIN_N = 7; PIN_SPAN = 15.24;   // header: 7 pins a side, rows 15.24 apart
HDR = [2.54, 2.5];    // header plastic under the XIAO: width, thickness

/* [Hidden] */
// ------------------------------ case ------------------------------
P = 42;               // bay pitch
D_IN = 44;            // inside depth, front wall to back wall
WALL = 2.4;           // front and back walls
SIDE_W = 3.2;         // side walls: they carry the base plate's grooves
FLOOR_T = 3.0;        // the latch tongues are cut into it (the Tahoe sled's plate is 3 mm)
LID_T = 2.4;
CRN_R = 1.5;          // the outside's upright corners are rounded (sharp corners are the first to lift off the bed)
USB_HOLE = [9.6, 3.8, 0.8];    // the hole through the wall: the socket sits in it (8.94 x 3.26), the plug's shell goes through
USB_BOOT = [12.6, 7.2, 2.0];   // shallow recess round it outside, for a normal cable's boot: width, height, corner radius
BOOT_REACH = 0.45;    // a USB-C plug's boot stops about this far short of the socket's face
WIO_RELIEF = 1.0;     // the front wall is this much thinner where the Wio board's front edge swings while the kit tilts in
WALL_ABOVE = 1.6;     // front wall above the openings
LID_CLR = 0.6;        // lid above the stack's tallest part
DIV_T = 2.0;          // divider between bays, carrying the FPC
FPC_Z0 = 0.8;         // FPC pocket starts this far above the floor
FPC_REC = 0.5;        // pocket depth into the wall (the FPC is about 0.2 thick)
LABEL_D = 0.6; LABEL_SIZE = 4.5;
LABEL_FONT = "Liberation Sans:style=Bold";
SMA_HOLE = 6.7;       // SMA / RP-SMA bulkhead, 1/4"-36 thread
SMA_NUT = 8.0;        // its nut across flats
// lid
RIM = [1.2, 2.0, 0.25];      // locating rim under the lid, just inside the walls: thickness, depth, clearance
ANT_Y = 36;                  // the antenna bulkheads on the lid, y: behind the boards
ANT_DX = 9;                  // over the alleys either side of the spool: the LoRa SMA this far left of the bay's centre (its U.FL's side), the WiFi RP-SMA (WIFI = "rpsma") this far right
SMA_DEPTH = 13;              // a pigtail's bulkhead jack reaches this far under the lid (jack, crimp and heat-shrink); its cable needs room below that to bend
ANT_LABEL = 3.2;             // their labels
LIFT = [16, 1.5, 1.6];       // tab in the middle of the lid's front edge, to lift it by: width, reach, thickness
DET = [6, 1.0, 8, 0.7, 6.5, 0.3];   // sprung tabs at the lid's front corners, outside the front wall: width, thickness, length below the lid; bump reach, bump centre below the lid, gap to the wall
DET_IN = 2.0;                // in from the inside faces of the side walls
HINGE = [3.0, 0.2, 1.6, 7.0];   // pin diameter, clearance round it, the lid's knuckle ring, knuckle width
HINGE_CHEEK = 2.4;           // the body's cheeks either side of each knuckle, which carry its pin
HINGE_XCLR = 0.3;            // knuckle to cheeks
HINGE_IN = 10;               // knuckle centres, in from the inside faces of the side walls
HINGE_MOUTH = 0.8;           // the knuckle's clip mouth, as a fraction of the pin
HINGE_OPEN = 100;            // the lid opens this far (degrees) and rests on the cheeks
// base plate: side lips in V-grooves, a sprung catch in the middle
GROOVE = [1.2, 1.2, 2.0, 3.0];   // V-groove in each side wall's outside face: depth, half-height, centre above the body's underside, stops short of the front face
FLANGE_T = 2.0;       // the plate's side lips
PL_CLR = 0.2;         // lips to the walls, and the V to its groove
WASHER = [6.4, 18, 1.6];     // M6 fender washer: hole, outside diameter, thickness
BALLAST_N = 4;               // washers per stack
PLATE_FL = 1.2;              // the plate's floor
PL_IN = 0.3;                 // its chambers start this far in from the body's inside walls
PL_PART = 1.6;               // partitions between chambers
CATCH = [8, 4.4, 0.8, 0.6, 0.8];   // catch tooth: width, length, how far it stands up out of the body's floor, floor left over the channel it rides in, slot round its tongue
// bays: the XIAO's front corners under hooks in the front wall. The latch is on its left edge
// behind the last header pin, and springs sideways, so plugging a cable in doesn't load it:
// the push goes into a solid rail along the back edge, and pulling the cable out into the
// hooks' walls. A rail along the right edge (the latch's preload pushes the board against it)
// and a stop at each front corner keep it from sliding sideways.
STANDOFFS = [[5.2, 3.6, 3], [12.6, 3.6, 3], [5.2, 17.4, 3], [12.6, 17.4, 3]];   // under the XIAO, between the header rows
HOOKS = [["B", 0.2, 1.9], ["B", 15.9, 17.6]];   // short of the B and R buttons beside the USB-C (see BTN_B)
LATCH = ["L", 19.6, 21.2, -1];   // the tongue runs forward along the left edge, in the floor; the finger tab is beside the back-left corner
STOPS = [["L", 0.0, 1.0], ["R", 0.0, 1.0]];
RAIL_BACK = 0;        // extra room in front of the back rail (none: the fit test's bay was right)
// rails: [edge, t0, t1, top above the board's underside, extra room]; no shelf under the board (the header plastic is there)
RAILS = [["R", 1.4, 19.8, 1.8, 0], ["T", 0.5, 17.3, XIAO_T - 0.1, RAIL_BACK]];   // the right one as tall as a stop (BAY_STOP_UP); the back one stays under the board-to-board connector
MK_H = 0.6;           // raised marks on the floor: three 0.2 mm layers
MK_W = 1.0;           // outline width, inside the board's edge
MK_FONT = "Liberation Sans:style=Bold";
// plunger (Wio user button)
TAB_L = 10;           // flexure tab length, root to free end
TAB_W = 3.0;          // its width
TAB_T = 1.2;          // its thickness
TAB_SLOT = 0.6;       // slot round it
NUB_D = 2.0;          // nub that presses the button
NUB_GAP = 0.3;        // nub to button at rest
LED_WIN = 1.8;
// spool for the FPC cable's slack: behind the board, in the middle of the bay, so the alleys either side stay clear
SPOOL = [3.5, 4.5];   // core and lip radius
SPOOL_P = [KIT[0]/2, 37.8];   // its centre, in the board frame

FN = 64;

// ------------------------------ derived ------------------------------
W_IN = BAYS*P;
WIO_TOP = STACK_H - MODULE[4];     // the Wio's top face, above the XIAO's underside
GAP = WIO_TOP - WIO[2] - XIAO_T;   // between the boards
BY = 0.2;                          // every XIAO's front edge, y: BAY_GAP behind the front wall, so its USB-C socket sits in the wall
USB_FACE = BY - USB[2];            // the socket's face, y (inside the wall)
function BX(i) = i*P + (P - KIT[0])/2;   // board i's left edge, x
function bxy(i, p) = [BX(i) + p[0], BY + p[1]];             // board frame to the case's, the bay's nominal position
function kxy(i, p) = [BX(i) + BAY_GAP + p[0], BY + p[1]];   // ... and where the kit really sits: pushed against the right rail
function xc(i) = BX(i) + BAY_GAP + USB_U;                   // the bay's centre line (its USB-C), x
FPC_TOP = FPC_Z0 + FPC[1] + 0.4;
ZB = max(PIN_BELOW + 1.0, 0.5);    // the XIAO's underside, above the floor
ZX = ZB + XIAO_T;                  // XIAO top face
ZW = ZB + WIO_TOP;                 // Wio top face
ZUC = ZX + USB[1]/2;               // USB-C centre
BOOT_Z = [ZUC - USB_BOOT[1]/2, ZUC + USB_BOOT[1]/2];
Z_LU = max(ZB + STACK_H + LID_CLR, ZW + LORA_UFL_H + 0.4, BOOT_Z[1] + WALL_ABOVE);   // the lid's underside
Z_TOP = Z_LU + LID_T;
SL_T = FLOOR_T;                    // the board bays' plate is the floor
function kit_bay(i) = [KIT, ZB, STANDOFFS, HOOKS, LATCH, STOPS, [[LABELS[i], KIT[0]/2, KIT[1]/2, 4, 90, 1]]];
DIV_H = FPC_TOP + 0.8;
Y_BACK = D_IN + WALL;              // the back face
PLATE_T = PLATE_FL + BALLAST_N*WASHER[2] + 0.4;
PL_X = [-SIDE_W - PL_CLR - FLANGE_T, W_IN + SIDE_W + PL_CLR + FLANGE_T];      // the plate, x range
FLANGE_H = GROOVE[2] + GROOVE[1] + 0.8;   // lips' height above the plate's top face
// antennas: [x, label], every bay's
function lora_x(i) = xc(i) - ANT_DX;
function wifi_x(i) = xc(i) + ANT_DX;
function ants() = [for (i = [0 : BAYS - 1]) each concat([[lora_x(i), "LoRa"]], WIFI == "rpsma" ? [[wifi_x(i), "WiFi"]] : [])];
function pin_uv() = [for (s = [-1, 1]) for (k = [0 : PIN_N - 1])
  [KIT[0]/2 + s*PIN_SPAN/2, KIT[1]/2 - (PIN_N - 1)*PIN_PITCH/2 + k*PIN_PITCH]];
function hdr_v() = [KIT[1]/2 - PIN_SPAN/2 - HDR[0]/2, KIT[1]/2 + PIN_SPAN/2 + HDR[0]/2];
function plungers() = [[WIO_BTN, -1, "U", WIO_TOP + WIO_SW[2]]];   // (u, v), which way the tab's root goes, letter, button top (h)
function fpc_wall_x(i) = i == BAYS - 1 ? W_IN : (i + 1)*P - DIV_T/2;   // the bay's right wall, its inside face
FPC_Y = (D_IN - FPC[0])/2;
// hinge: the axis runs along x behind the back face, its knuckles' tops flush with the lid's
H_R = HINGE[0]/2 + HINGE[1] + HINGE[2];   // knuckle's outer radius
HA = [Y_BACK + H_R + 0.4, Z_TOP - H_R];   // the axis, (y, z)
HINGE_XS = [HINGE_IN, W_IN - HINGE_IN];
// the lid's sprung tabs: x ranges, and the bump's centre
DET_XS = [[DET_IN, DET_IN + DET[0]], [W_IN - DET_IN - DET[0], W_IN - DET_IN]];
DET_Z = Z_LU - DET[4];

assert(BAYS >= 1 && BAYS <= 3, "BAYS is 1, 2 or 3");
assert(GAP >= USB[1] + 0.3, "the boards are too close together for the XIAO's USB-C socket: check STACK_H");
assert(len(LABELS) >= BAYS, "one label per bay");
assert(WIFI != "fpc" || DIV_H <= Z_LU - 0.4, "FPC too tall for the case");
assert(WIFI != "fpc" || FPC[0] + 2 <= D_IN, "FPC too long for the bay wall");
assert(HINGE_MOUTH*HINGE[0] < HINGE[0] - 0.4, "the hinge clip's mouth is too wide to hold its pin");
assert(DET[3] > DET[5] + 0.2, "the lid's tabs' bumps don't reach into the front wall");
assert(DET[4] + DET[3] < DET[2], "the lid's tab bump is past the tab's end");

// ============================== HELPERS ==============================
module box(x0, x1, y0, y1, z0, z1) translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, z1 - z0]);
module rbox(x0, x1, y0, y1, z0, z1, r = CRN_R) translate([x0, y0, z0]) linear_extrude(height = z1 - z0)   // upright corners rounded
  translate([r, r]) offset(r = r, $fn = 24) square([x1 - x0 - 2*r, y1 - y0 - 2*r]);
module rrect(w, h, r) offset(r = r, $fn = 48) offset(delta = -r) square([w, h], center = true);
module bay_frame(i) translate([BX(i), BY, ZB]) children();   // board frame: u, v, h
module yz(x0, w) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = w) children();   // a (y, z) outline, extruded along x from x0

// ------------- board bays (from tahoe-repeater.scad, design revision 9 working copy) -------------
module mk_text(t, x, z, size, rot = 0, sp = 1)
  translate([x, z]) rotate(rot) text(t, size = size, font = MK_FONT, halign = "center", valign = "center", spacing = sp);
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
BAY_SLOT_H = XIAO_T + 0.15;   // board thickness + 0.15: the slot under each lip (1.75 on the Tahoe, for 1.6 mm boards)
BAY_GAP    = 0.2;     // the board's edge to a hook's or stop's wall
BAY_LIP    = 0.8;     // how far lips reach over the board
LATCH_LIP  = 1.2;     // how far the latch's lip reaches over it (0.8 on the Tahoe: the XIAO pulled out from under it)
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
BAY_TSLOT  = 1.9;     // slot outside the tongue: room for it to flex (1.4 on the Tahoe; wider here for the deeper latch lip)
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
                    [-p - LATCH_LIP, sh + 0.4], [-p - LATCH_LIP, sh], [-p, sh]]);
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

// a rail: a stop with no shelf under the board, as tall as asked
module bay_rail(t0, t1, so, up) let(top = so + up)
  bay_prof(t0, t1, [[BAY_GAP, 0], [BAY_GAP + BAY_STOP_W, 0], [BAY_GAP + BAY_STOP_W, top], [BAY_GAP + 0.5, top], [BAY_GAP, top - 0.5]]);

// ================================ HINGE ================================
// Outlines in (y, z). The lid opens by turning about HA; a degrees open:
module about_hinge(a) translate(HA) rotate(-a) translate(-HA) children();
// the lid's back edge beside a knuckle (over a cheek)
module lid_edge2d() translate([Y_BACK - 9, Z_LU]) square([9, LID_T]);
// everything that edge passes through on its way open
module lid_sweep2d(a1) for (a = [0 : 4 : a1 - 0.01]) hull() { about_hinge(a) lid_edge2d(); about_hinge(min(a + 4, a1)) lid_edge2d(); }
// a cheek: round the pin, down the back wall at 45 degrees, and back to where the lid's back
// edge comes to rest when it's open HINGE_OPEN; less what the lid sweeps through (and 0.3 mm)
module cheek2d() difference() {
  translate(HA) polygon([[Y_BACK - HA[0] - 0.01, -9.2], [Y_BACK - HA[0] - 0.01, 0.3], [0, H_R], [4.2, H_R], [4.2, -1.0]]);
  offset(r = 0.3, $fn = 16) lid_sweep2d(HINGE_OPEN);
}
// the lid's knuckle: a ring round the pin, its top flush with the lid's, a 45 degree chamfer
// behind; it clips onto the pin through a mouth that faces down and back when the lid is shut
// (the rim stops the lid moving forward, so it can't come off then) and down and forward when
// it's open. Printed upside down, the face over the mouth is 45 degrees.
module knuckle2d() let(rh = HINGE[0]/2 + HINGE[1]) translate(HA) difference() {
  union() {
    hull() { circle(r = H_R, $fn = 48); translate([-H_R, H_R - 0.01]) square([H_R*1.414, 0.01]); }
    translate([Y_BACK - HA[0] - 1, Z_LU - HA[1]]) square([HA[0] - Y_BACK + 1, LID_T]);   // into the lid
  }
  circle(r = rh, $fn = 32);   // the pin's hole (its top, printed upside down, is mostly the mouth)
  rotate(-45) translate([0, -HINGE[0]*HINGE_MOUTH/2]) square([H_R + 1, HINGE[0]*HINGE_MOUTH]);   // the mouth
}

// ================================ BODY ================================
module kit_bay_add(i, fit = false) {
  // the bay, kept inside the case (the front hooks' walls and buttresses merge into the front wall)
  intersection() {
    translate([BX(i), BY, 0]) {
      bay_add(kit_bay(i));
      for (r = RAILS) multmatrix(bay_ef(r[0], KIT)) translate([0, r[4], 0]) bay_rail(r[1], r[2], ZB, r[3]);
    }
    box(0, W_IN, -WALL, D_IN, -1, Z_LU);
  }
  if (WIFI == "fpc" && !fit) {
    // spool for the FPC cable's slack, behind the board
    let(c = bxy(i, SPOOL_P)) translate([c[0], c[1], 0]) {
      cylinder(r = SPOOL[0], h = ZB - 1.2, $fn = FN);
      translate([0, 0, ZB - 1.2 - (SPOOL[1] - SPOOL[0])]) cylinder(r1 = SPOOL[0], r2 = SPOOL[1], h = SPOOL[1] - SPOOL[0] + 0.01, $fn = FN);
      translate([0, 0, ZB - 1.2]) cylinder(r = SPOOL[1], h = 0.8, $fn = FN);
    }
    // the divider to the next bay, which carries this bay's FPC
    if (i < BAYS - 1) box((i + 1)*P - DIV_T/2, (i + 1)*P + DIV_T/2, -0.01, D_IN + 0.01, -0.01, DIV_H);
  }
}
// the shell: floor and walls, open at the top
module shell() difference() {
  rbox(-SIDE_W, W_IN + SIDE_W, -WALL, Y_BACK, -FLOOR_T, Z_LU);
  box(0, W_IN, 0, D_IN, 0, Z_LU + 1);
}
// the hinge's cheeks and pins, on the back wall
module hinge_body() for (c = HINGE_XS) {
  for (s = [-1, 1]) yz(s < 0 ? c - HINGE[3]/2 - HINGE_XCLR - HINGE_CHEEK : c + HINGE[3]/2 + HINGE_XCLR, HINGE_CHEEK) cheek2d();
  translate([c - HINGE[3]/2 - HINGE_XCLR - 0.5, HA[0], HA[1]]) rotate([0, 90, 0]) cylinder(d = HINGE[0], h = HINGE[3] + 2*HINGE_XCLR + 1, $fn = 32);
}
module body_cuts(fit) {
  for (i = [0 : BAYS - 1]) {
    translate([BX(i), BY, 0]) bay_cut(kit_bay(i));   // the latch's tongue
    // USB-C opening
    translate([xc(i), -WALL - 1, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = WALL + 2) rrect(USB_HOLE[0], USB_HOLE[1], USB_HOLE[2]);
    translate([xc(i), -WALL - 1, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = USB_FACE - BOOT_REACH + 0.3 + WALL + 1)
      rrect(USB_BOOT[0], USB_BOOT[1], USB_BOOT[2]);   // the boot's recess
    // label underneath it
    zl = BOOT_Z[0] - 0.9 - LABEL_SIZE/2;
    translate([xc(i), -WALL - 0.01, zl]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(height = LABEL_D + 0.01)
      text(LABELS[i], size = LABEL_SIZE, font = LABEL_FONT, halign = "center", valign = "center");
    // relief in the front wall's inside face for the Wio board's front edge as the kit tilts in
    let(a = bay_pt(i, [-0.6, 0, max(WIO_TOP - WIO[2] - 0.6, XIAO_T + USB[1]/2 + USB_HOLE[1]/2 + 0.85)]), b = bay_pt(i, [KIT[0] + 0.6, 0, 0]))
      box(a[0], b[0], -WIO_RELIEF, 0.01, a[2], Z_LU + 0.01);
    // FPC pocket on the bay's right wall
    if (WIFI == "fpc") let(x = fpc_wall_x(i)) box(x - 0.01, x + FPC_REC, FPC_Y - 0.3, FPC_Y + FPC[0] + 0.3, FPC_Z0, FPC_TOP);
  }
  if (!fit) {
    // V-grooves along the bottom of the side walls, for the base plate's lips; open at the back
    for (m = [0, 1]) translate([m == 0 ? 0 : W_IN, 0, 0]) mirror([m, 0, 0])
      translate([-SIDE_W, -WALL + GROOVE[3], -FLOOR_T + GROOVE[2]]) rotate([-90, 0, 0]) linear_extrude(height = D_IN + 2*WALL)
        polygon([[-1, -GROOVE[1] - 1], [GROOVE[0], 0], [-1, GROOVE[1] + 1]]);
    // the base plate's catch: a slot through the floor for its tooth, and a channel under the floor it rides in from the back
    box(CATCH_X - CATCH[0]/2 - 0.5, CATCH_X + CATCH[0]/2 + 0.5, CT[0] - 2.0, CT[1] + 0.2, -FLOOR_T - 1, 1);
    box(CATCH_X - CATCH[0]/2 - 0.5, CATCH_X + CATCH[0]/2 + 0.5, CT[1] + 0.2, Y_BACK + 1, -FLOOR_T - 1, -FLOOR_T + CH_D);
    // where the lid's tabs click in: a recess in the front wall's outside face, and a chamfer on its top edge to ride over
    for (d = DET_XS) {
      box(d[0] - 0.3, d[1] + 0.3, -WALL - 1, -WALL + DET[3] - DET[5] + 0.2, DET_Z - DET[3] - 0.25, DET_Z + DET[3] + 0.25);
      yz(d[0] - 0.3, d[1] - d[0] + 0.6) polygon([[-WALL - 0.01, Z_LU - 0.8], [-WALL - 0.01, Z_LU + 0.01], [-WALL + 0.8, Z_LU + 0.01]]);
    }
  }
}
function bay_pt(i, p) = [BX(i) + BAY_GAP + p[0], BY + p[1], ZB + p[2]];   // board frame to the case's
module body(fit = false) difference() {
  union() {
    shell();
    for (i = [0 : BAYS - 1]) kit_bay_add(i, fit);
    if (!fit) hinge_body();
  }
  body_cuts(fit);
}

// ================================ LID ================================
// flexure plunger in the lid: a tab along x (dir: which way its root goes), a nub under its free end
function ptab_x(x, dir) = dir < 0 ? [x - TAB_L + NUB_D/2 + 0.5, x + NUB_D/2 + 0.5] : [x - NUB_D/2 - 0.5, x + TAB_L - NUB_D/2 - 0.5];
// a sprung tab at a front corner, (y, z): hanging outside the front wall, a bump on its inside
module det2d() {
  y0 = -WALL - DET[5];
  translate([y0 - DET[1], Z_LU - DET[2]]) square([DET[1], DET[2] + LID_T]);
  translate([y0 - 0.01, Z_LU]) square([DET[5] + 0.02, LID_T]);   // joined to the lid's edge
  polygon([[y0 - 0.01, DET_Z - DET[3]], [y0 + DET[3], DET_Z], [y0 - 0.01, DET_Z + DET[3]]]);   // 45 degrees either side
}
module lid(fit = false) {
  difference() {
    union() {
      rbox(-SIDE_W, W_IN + SIDE_W, -WALL, Y_BACK, Z_LU, Z_TOP);
      if (!fit) {
        // locating rim, just inside the walls, with gaps for the dividers
        difference() {
          box(RIM[2], W_IN - RIM[2], RIM[2], D_IN - RIM[2], Z_LU - RIM[1], Z_LU + 0.01);
          box(RIM[2] + RIM[0], W_IN - RIM[2] - RIM[0], RIM[2] + RIM[0], D_IN - RIM[2] - RIM[0], Z_LU - RIM[1] - 1, Z_LU + 1);
          if (WIFI == "fpc") for (i = [0 : BAYS - 2]) box((i + 1)*P - DIV_T/2 - 0.4, (i + 1)*P + DIV_T/2 + 0.4, -1, D_IN + 1, Z_LU - RIM[1] - 1, Z_LU);
        }
        for (d = DET_XS) yz(d[0], d[1] - d[0]) det2d();
        rbox(W_IN/2 - LIFT[0]/2, W_IN/2 + LIFT[0]/2, -WALL - LIFT[1], -WALL + 2, Z_TOP - LIFT[2], Z_TOP, 1.0);   // lift tab
        for (c = HINGE_XS) yz(c - HINGE[3]/2, HINGE[3]) knuckle2d();
      }
    }
    for (i = [0 : BAYS - 1]) {
      for (p = plungers()) let(c = kxy(i, p[0]), x = ptab_x(c[0], p[1]), y = [c[1] - TAB_W/2, c[1] + TAB_W/2], s = TAB_SLOT) {
        difference() {   // slot round three sides
          box(x[0] - s, x[1] + s, y[0] - s, y[1] + s, Z_LU - 1, Z_TOP + 1);
          box(p[1] < 0 ? x[0] - s - 1 : x[0], p[1] < 0 ? x[1] : x[1] + s + 1, y[0], y[1], Z_LU - 2, Z_TOP + 2);
        }
        box(x[0] - s, x[1] + s, y[0] - s, y[1] + s, Z_LU - 1, Z_TOP - TAB_T);   // thin the tab from below
        // its letter, over the front wall
        translate([c[0], -WALL/2 + 0.2, Z_TOP - 0.6]) linear_extrude(height = 1)
          text(p[2], size = 2.8, font = LABEL_FONT, halign = "center", valign = "center");
      }
      let(c = kxy(i, WIO_LED)) translate([c[0], c[1], Z_LU - 1]) cylinder(d = LED_WIN, h = LID_T + 2, $fn = 24);   // LED window
    }
    // antenna bulkheads, standing straight up, and their labels in front of them
    if (!fit) for (a = ants()) {
      translate([a[0], ANT_Y, Z_LU - 1]) cylinder(d = SMA_HOLE, h = LID_T + 2, $fn = 48);
      translate([a[0], ANT_Y - SMA_NUT/cos(30)/2 - 0.6 - ANT_LABEL/2, Z_TOP - LABEL_D]) linear_extrude(height = 1)
        text(a[1], size = ANT_LABEL, font = LABEL_FONT, halign = "center", valign = "center");
    }
  }
  // nubs, hanging from the tabs' free ends
  for (i = [0 : BAYS - 1]) for (p = plungers()) let(c = kxy(i, p[0]))
    translate([c[0], c[1], ZB + p[3] + NUB_GAP]) cylinder(d = NUB_D, h = Z_TOP - TAB_T - (ZB + p[3] + NUB_GAP) + 0.01, $fn = 24);
}

// ============================== BASE PLATE ==============================
// plate frame: its top face at z = 0, same x, y as the body
// the bays' latch tongues flex in the body's floor; nothing under them may touch
function tongue_x(i) = [BX(i) - BAY_GAP - BAY_PRE - BAY_PW - BAY_TSLOT - 1.2, BX(i) - BAY_GAP - BAY_PRE + BAY_ISLOT + 1.2 + 2*BAY_GAP];
TONGUE_Y = [BY + LATCH[2] - BAY_TL - BAY_ESLOT - 1.2, BY + LATCH[2] + BAY_TAB + BAY_ESLOT + 1.2];
// chambers [x0, x1, y0, y1, washers?]: washers at each end, open between; a one-bay case has
// room for two washer chambers across, so they go at the front and the open one behind
PX = [PL_IN, W_IN - PL_IN]; PY = [PL_IN, D_IN - PL_IN];
WC = WASHER[1] + 1.4;
CHAMBERS = PX[1] - PX[0] >= 2*WC + 2*PL_PART + 12
  ? [[PX[0], PX[0] + WC, PY[0], PY[1], 1], [PX[0] + WC + PL_PART, PX[1] - WC - PL_PART, PY[0], PY[1], 0], [PX[1] - WC, PX[1], PY[0], PY[1], 1]]
  : [[PX[0], W_IN/2 - PL_PART/2, PY[0], PY[0] + WC, 1], [W_IN/2 + PL_PART/2, PX[1], PY[0], PY[0] + WC, 1], [PX[0], PX[1], PY[0] + WC + PL_PART, PY[1], 0]];
function ballast_pins() = let(pt = WASHER[1] + 0.8) [for (r = CHAMBERS) if (r[4] == 1)
  let(nx = floor((r[1] - r[0] + 0.8) / pt), ny = floor((r[3] - r[2] + 0.8) / pt), x0 = (r[0] + r[1])/2 - (nx - 1)*pt/2, y0 = (r[2] + r[3])/2 - (ny - 1)*pt/2)
  for (a = [0 : nx - 1]) for (b = [0 : ny - 1]) [x0 + a*pt, y0 + b*pt]];
// The catch: a tongue in the open chamber's floor, its root at the back, a riser on its free end
// carrying a tooth. Sliding the plate on, the tooth's ramp meets the body's back edge and the
// tongue bends down; the tooth rides forward in a channel under the floor and springs up through
// a slot just behind the middle bay's board (left of the middle divider on an even number).
CATCH_X = BAYS % 2 == 1 ? W_IN/2 : W_IN/2 - 6;
CT = let(y0 = BY + KIT[1] + BAY_GAP + RAIL_BACK + BAY_STOP_W + 0.5 + 2.0) [y0, y0 + CATCH[1]];   // the tooth's y range (2 mm of slot ahead of it, for it to tip into)
CH_D = FLOOR_T - CATCH[3];        // the channel's depth into the floor's underside
CATCH_TOP = FLOOR_T + CATCH[2];   // the tooth's top, above the plate's top face
assert(len([for (r = CHAMBERS) if (r[4] == 0 && r[0] < CATCH_X - CATCH[0]/2 - CATCH[4] - 0.8 && r[1] > CATCH_X + CATCH[0]/2 + CATCH[4] + 0.8 && r[2] < CT[0] - CATCH[4] - 0.8) 1]) == 1,
  "the base plate's catch isn't in its open chamber");
// one side's lip, in x-z (plate frame), the V pointing in toward the wall at x = -SIDE_W
module lip2d() {
  translate([PL_X[0], -PLATE_T]) square([FLANGE_T, PLATE_T + FLANGE_H]);
  intersection() {
    translate([0, GROOVE[2]]) offset(delta = -PL_CLR) polygon([[-SIDE_W - 2, -GROOVE[1] - 2], [-SIDE_W + GROOVE[0], 0], [-SIDE_W - 2, GROOVE[1] + 2]]);
    translate([PL_X[0], -1]) square([FLANGE_T + PL_CLR + GROOVE[0], FLANGE_H + 1]);
  }
}
module plate() difference() {
  union() {
    difference() {
      rbox(PL_X[0], PL_X[1], -WALL, Y_BACK, -PLATE_T, 0);
      for (r = CHAMBERS) box(r[0], r[1], r[2], r[3], -PLATE_T + PLATE_FL, 1);
      for (i = [0 : BAYS - 1]) box(tongue_x(i)[0], tongue_x(i)[1], TONGUE_Y[0], TONGUE_Y[1], -0.3, 1);   // so the tongues don't rub
    }
    for (p = ballast_pins()) translate([p[0], p[1], -PLATE_T + PLATE_FL - 0.01]) cylinder(d = WASHER[0] - 0.4, h = BALLAST_N*WASHER[2], $fn = 32);
    // the side lips: the V runs from the back to just short of the grooves' front end, which stops the plate
    intersection() {
      for (m = [0, 1]) translate([m == 0 ? 0 : W_IN, 0, 0]) mirror([m, 0, 0]) {
        translate([0, Y_BACK, 0]) rotate([90, 0, 0]) linear_extrude(height = Y_BACK + WALL - GROOVE[3] - PL_CLR) lip2d();
        translate([0, Y_BACK, 0]) rotate([90, 0, 0]) linear_extrude(height = Y_BACK + WALL) translate([PL_X[0], -PLATE_T]) square([FLANGE_T, PLATE_T + FLANGE_H]);
      }
      rbox(PL_X[0], PL_X[1], -WALL, Y_BACK, -PLATE_T - 1, FLANGE_H + 1);
    }
    // catch: the riser, then the tooth (a 45 degree ramp in front, square behind)
    box(CATCH_X - CATCH[0]/2, CATCH_X + CATCH[0]/2, CT[0], CT[1], -PLATE_T + PLATE_FL - 0.01, 0.01);
    yz(CATCH_X - CATCH[0]/2, CATCH[0]) polygon([[CT[0], 0], [CT[0], CH_D - 0.2], [CT[0] + CATCH_TOP - CH_D + 0.2, CATCH_TOP], [CT[1], CATCH_TOP], [CT[1], 0]]);
  }
  // the slot that frees the tongue: down each side and across its free end
  difference() {
    box(CATCH_X - CATCH[0]/2 - CATCH[4], CATCH_X + CATCH[0]/2 + CATCH[4], CT[0] - CATCH[4], PY[1], -PLATE_T - 1, -PLATE_T + PLATE_FL + 0.01);
    box(CATCH_X - CATCH[0]/2, CATCH_X + CATCH[0]/2, CT[0], PY[1] + 1, -PLATE_T - 2, -PLATE_T + PLATE_FL + 1);
  }
}

// ============================== PREVIEW DUMMIES ==============================
// the kit as the checks see it, in bay i (board frame)
module kit_dummy(i, part = "all") translate([BAY_GAP, 0, 0]) bay_frame(i) {   // home: pushed against the right rail by the latch
  if (part == "all" || part == "boards") {
    color([0.15, 0.15, 0.15]) cube([KIT[0], KIT[1], XIAO_T]);                                          // XIAO
    color([0.1, 0.1, 0.1]) translate([0, WIO_V0, WIO_TOP - WIO[2]]) cube(WIO);                         // Wio
  }
  if (part == "all" || part == "parts") {
    color("Silver") translate([USB_U - USB[0]/2, -USB[2], XIAO_T]) cube([USB[0], USB[3], USB[1]]);      // USB-C socket
    color("Silver") translate([2.4, 7.0, XIAO_T]) cube([KIT[0] - 4.8, 9.5, min(2.2, GAP - 0.3)]);         // ESP32-S3 can
    color("WhiteSmoke") for (b = [BTN_B, BTN_R]) translate([b[0] - SW[0]/2, b[1] - SW[1]/2, XIAO_T]) cube(SW);
    color("Gold") translate([WIFI_UFL[0] - 1.3, WIFI_UFL[1] - 1.3, XIAO_T]) cube([2.6, 2.6, 2.4]);        // WiFi U.FL plug
    color([0.2, 0.2, 0.2]) translate([B2B[0], B2B[2], XIAO_T]) cube([B2B[1] - B2B[0], B2B[3] - B2B[2], GAP]);
    color("Silver") translate([MODULE[0], MODULE[2], WIO_TOP]) cube([MODULE[1] - MODULE[0], MODULE[3] - MODULE[2], MODULE[4]]);
    color("Gold") translate([LORA_UFL[0] - 1.4, LORA_UFL[1] - 1.4, WIO_TOP]) cube([2.8, 2.8, LORA_UFL_H]);   // LoRa U.FL plug
    color("WhiteSmoke") translate([WIO_BTN[0] - WIO_SW[0]/2, WIO_BTN[1] - WIO_SW[1]/2, WIO_TOP]) cube(WIO_SW);
    color("Lime") translate([WIO_LED[0] - 0.8, WIO_LED[1] - 0.4, WIO_TOP]) cube([1.6, 0.8, 0.6]);
    color([0.1, 0.1, 0.1]) for (s = [-1, 1]) translate([KIT[0]/2 + s*PIN_SPAN/2 - HDR[0]/2, hdr_v()[0], -HDR[1]])
      cube([HDR[0], hdr_v()[1] - hdr_v()[0], HDR[1]]);                                                  // header plastic
  }
  if (part == "all" || part == "pins")   // header pins below the XIAO
    color("Gold") for (p = pin_uv()) translate([p[0] - 0.32, p[1] - 0.32, -PIN_BELOW]) cube([0.64, 0.64, PIN_BELOW - HDR[1] + 0.01]);
}
module fpc_dummy(i) color([0.8, 0.55, 0.1]) let(x = fpc_wall_x(i)) box(x + 0.05, x + 0.25, FPC_Y, FPC_Y + FPC[0], FPC_Z0 + 0.2, FPC_Z0 + 0.2 + FPC[1]);
// a USB-C cable plugged in: the boot (an ordinary 11.5 x 6.5 mm one) and the plug's shell
module plug_dummy(i) color([0.1, 0.1, 0.1]) let(yf = USB_FACE - BOOT_REACH) {
  translate([xc(i), yf - 20, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = 20) rrect(11.5, 6.5, 2);
  translate([xc(i), yf, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = 6.2) rrect(8.25, 2.4, 1.1);
}
// the bulkheads in the lid: thread, jack and crimp (inside and out), the nut under the lid, and room under
// the jack for the pigtail's cable to bend away
module sma_dummy() color("Gold") for (a = ants()) translate([a[0], ANT_Y, 0]) {
  translate([0, 0, Z_LU - SMA_DEPTH]) cylinder(d = 6.6, h = SMA_DEPTH + LID_T + 6, $fn = 32);
  translate([0, 0, Z_LU - SMA_DEPTH - 5]) cylinder(d = 4, h = 5.01, $fn = 24);
  translate([0, 0, Z_LU - 2.5]) cylinder(d = SMA_NUT/cos(30), h = 2.49, $fn = 6);
}

// ================================ LAYOUTS ================================
CLR = [0.93, 0.92, 0.88];
LID_A = 0;   // preview: the lid this far open (degrees)
module lid_at(a) translate([0, HA[0], HA[1]]) rotate([-a, 0, 0]) translate([0, -HA[0], -HA[1]]) children();
module assembly() {
  color(CLR) body();
  color([0.85, 0.84, 0.8]) lid_at(LID_A) { lid(); sma_dummy(); }
  color([0.5, 0.5, 0.5]) translate([0, 0, -FLOOR_T]) plate();
  for (i = [0 : BAYS - 1]) { kit_dummy(i); if (WIFI == "fpc") fpc_dummy(i); plug_dummy(i); }
}
// print poses
module body_print(fit = false) translate([0, 0, FLOOR_T]) body(fit);
module lid_print() translate([0, 0, Z_TOP]) rotate([180, 0, 0]) lid();   // top face down, everything else up (turned over, not mirrored)
module plate_print() translate([0, 0, PLATE_T]) plate();
// Every printed part of one version, laid out apart. In Bambu Studio:
// right-click > Split > To objects.
BODY_BACK = HA[0] + 4.2;   // the hinge cheeks' back face
module kit() {
  body_print();                                                     // y -WALL .. BODY_BACK
  translate([0, BODY_BACK + 8 + HA[0] + H_R, 0]) lid_print();        // turned over, 8 mm behind the body
  translate([0, -(Y_BACK + WALL + 8), 0]) plate_print();             // 8 mm in front of the body
}

// ============================== FIT TEST ==============================
// Just enough of one bay to try the kit before printing a case: the floor under it with the
// standoffs, stops and latch; the stretch of front wall with the USB-C opening and the
// hooks; two columns that carry a short strip of the lid with the Wio button's plunger and
// the LED window.
FIT_D = 14;   // the lid strip reaches this far back from the front wall's inside face
FX = [BX(0) - 6.4, BX(0) + KIT[0] + BAY_GAP + BAY_STOP_W + 1.0];   // across: the latch's tongue to the right rail
FY = BY + KIT[1] + BAY_GAP + RAIL_BACK + BAY_STOP_W + 1.0;         // back to just behind the back rail
module fit_body() {
  difference() {
    intersection() {
      body(true);
      box(FX[0], FX[1], -WALL - 1, FY, -FLOOR_T - 1, Z_LU);
    }
    // a window in the floor under the board, between the standoffs (plastic the test doesn't need)
    let(a = bxy(0, [2.6, STANDOFFS[0][1] + STANDOFFS[0][2]/2 + 0.8]), b = bxy(0, [KIT[0] - 1.0, STANDOFFS[2][1] - STANDOFFS[2][2]/2 - 0.8]))
      box(a[0], b[0], a[1], b[1], -FLOOR_T - 1, 1);
  }
  for (x = [FX[0], FX[1] - BAY_STOP_W - 1.0]) box(x, x + 2, FIT_D - 3, FIT_D, -0.01, Z_LU);   // columns under the strip's back corners: left of the tongue, and on the right rail
}
module fit_lid() intersection() {
  lid(true);
  box(FX[0], FX[1], -WALL - 1, FIT_D, Z_LU - 5, Z_TOP + 1);
}
module fit_test() {
  translate([0, 0, FLOOR_T]) fit_body();
  translate([0, FY + 8 + FIT_D, Z_TOP]) rotate([180, 0, 0]) fit_lid();   // turned over, behind the body
}

// ================================ DISPATCH ================================
assert(PART != "fit_test" || BAYS == 1, "the fit test is one bay: set BAYS = 1");
if (PART == "assembly") assembly();
else if (PART == "kit") kit();
else if (PART == "fit_test") fit_test();
else if (PART == "body") body_print();
else if (PART == "lid") lid_print();
else if (PART == "plate") plate_print();
else if (PART == "bay_view") { color(CLR) fit_body(); color(CLR) fit_lid(); kit_dummy(0); }
// assembled poses, for the checks (check_case.py)
else if (PART == "a_body") { if (FIT) fit_body(); else body(); }
else if (PART == "a_lid") { if (FIT) fit_lid(); else lid(); }
else if (PART == "a_plate") { if (!FIT) translate([0, 0, -FLOOR_T]) plate(); }
else if (PART == "d_boards") for (i = [0 : BAYS - 1]) kit_dummy(i, "boards");
else if (PART == "d_parts") for (i = [0 : BAYS - 1]) kit_dummy(i, "parts");
else if (PART == "d_pins") for (i = [0 : BAYS - 1]) kit_dummy(i, "pins");
else if (PART == "d_fpc") { if (WIFI == "fpc" && !FIT) for (i = [0 : BAYS - 1]) fpc_dummy(i); }
else if (PART == "d_plug") for (i = [0 : BAYS - 1]) plug_dummy(i);
else if (PART == "d_sma") { if (!FIT) sma_dummy(); }
// sections for the checks: the front wall's inner half, the lid at the plungers' tab level
else if (PART == "s_front") projection(cut = true) translate([0, 0, -0.6]) rotate([-90, 0, 0]) { if (FIT) fit_body(); else body(); }
else if (PART == "s_lid") projection(cut = true) translate([0, 0, -(Z_TOP - 0.9)]) { if (FIT) fit_lid(); else lid(); }
// a cut through bay 0's centre, for the pictures
else if (PART == "section") intersection() { assembly(); box(PL_X[0] - 1, xc(0), -WALL - 21, BODY_BACK + 1, -FLOOR_T - PLATE_T - 1, Z_TOP + 20); }
FIT = false;

echo(str("xnc: bays ", BAYS, ", outside ", PL_X[1] - PL_X[0], " x ", D_IN + 2*WALL, " (", BODY_BACK + WALL, " with the hinge) x ", PLATE_T + FLOOR_T + Z_TOP,
         " mm (body ", FLOOR_T + Z_LU, ", lid ", LID_T, ", plate ", PLATE_T, "); XIAO's underside ", ZB, " above the floor; lid underside ", Z_LU,
         "; gap between the boards ", GAP));
function jn(l, i = 0) = i >= len(l) ? "" : str(i > 0 ? ", " : "", l[i], jn(l, i + 1));
echo(str("xnc: antennas ", jn([for (a = ants()) str(a[1], " at x ", a[0])]), ", y ", ANT_Y, "; ballast ", len(ballast_pins()), " stacks of ", BALLAST_N,
         " washers; plate catch at x ", CATCH_X, ": press its tooth ", CATCH[3], " mm below the floor's top to slide the plate off"));
// numbers for check_case.py
echo(str("xnc-chk: {",
  "\"ZB\": ", ZB, ", \"ZX\": ", ZX, ", \"ZW\": ", ZW, ", \"Z_LU\": ", Z_LU, ", \"Z_TOP\": ", Z_TOP, ", \"BY\": ", BY, ", \"BXN\": ", BX(0), ", \"BAY_GAP\": ", BAY_GAP, ", \"BAY_PRE\": ", BAY_PRE, ", \"LATCH\": ", LATCH, ", \"LATCH_LIP\": ", LATCH_LIP, ", \"BAY_TSLOT\": ", BAY_TSLOT, ", \"BAY_TL\": ", BAY_TL, ", \"XIAO_T\": ", XIAO_T,
  ", \"BX0\": ", BX(0) + BAY_GAP, ", \"P\": ", P, ", \"D_IN\": ", D_IN, ", \"WALL\": ", WALL, ", \"KIT\": ", KIT, ", \"RAIL_BACK\": ", RAIL_BACK,
  ", \"USB_U\": ", USB_U, ", \"FPC\": ", FPC, ", \"FPC_Z0\": ", FPC_Z0, ", \"FPC_Y\": ", FPC_Y, ", \"FPC_CABLE\": ", FPC_CABLE,
  ", \"FPC_X0\": ", fpc_wall_x(0), ", \"PIGTAIL\": ", PIGTAIL, ", \"WIFI_UFL\": ", WIFI_UFL, ", \"LORA_UFL\": ", LORA_UFL,
  ", \"LORA_UFL_H\": ", LORA_UFL_H, ", \"SPOOL\": ", SPOOL, ", \"SPOOL_P\": ", SPOOL_P,
  ", \"LORA_X\": ", [for (i = [0 : BAYS - 1]) lora_x(i)], ", \"ANT_Y\": ", ANT_Y, ", \"SMA_DEPTH\": ", SMA_DEPTH, ", \"PLUNGERS\": ", [for (p = plungers()) [p[0][0], p[0][1], p[3]]],
  ", \"NUB_GAP\": ", NUB_GAP, ", \"TAB_L\": ", TAB_L, ", \"TAB_T\": ", TAB_T, ", \"WIFI\": \"", WIFI, "\"",
  ", \"HA\": ", HA, ", \"HINGE\": ", HINGE, ", \"H_R\": ", H_R, ", \"HINGE_OPEN\": ", HINGE_OPEN, ", \"HINGE_MOUTH\": ", HINGE_MOUTH,
  ", \"DET_XS\": ", DET_XS, ", \"DET\": ", DET, ", \"DET_Z\": ", DET_Z,
  ", \"CATCH_X\": ", CATCH_X, ", \"CT\": ", CT, ", \"CATCH\": ", CATCH, ", \"CH_D\": ", CH_D, ", \"CATCH_TOP\": ", CATCH_TOP, ", \"Y_BACK\": ", Y_BACK, ", \"FLOOR_T\": ", FLOOR_T,
  ", \"BAYS\": ", BAYS, "}"));
