// =====================================================================
// XIAO node case, design revision 2 (fit test)
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
// debossed label and two paperclip holes either side for B and R, an SMA
// bulkhead for its LoRa pigtail in the back wall, and a pocket for its
// stock WiFi FPC antenna on the bay's right-hand wall (a thin divider, or
// the case's side wall for the last bay), or an RP-SMA bulkhead instead
// (WIFI = "rpsma").
//
// Parts (every one prints flat, no supports):
//   BODY   floor, walls and the bays. Each bay is the Tahoe repeater's
//          tool-less board bay, holding the XIAO (the bottom board): it
//          rests on four standoffs, clear of its header pins; two hooks on
//          the front wall reach 0.8 mm over its front corners; a latch on a
//          tongue cut into the floor snaps over its back edge; two stops
//          locate its sides. Slide the front edge under the hooks and press
//          the back down until it clicks. To lift it out, push the low
//          finger tab right of the board toward the back wall.
//   CAP    a strip across the top front. It drops onto the front wall and
//          carries a flexure plunger over each Wio user button, a window
//          over its user LED, and the latch post.
//   LID    slides in from the back in dovetail grooves along the side
//          walls, over the back edge of the cap, which it holds down. A
//          flexure latch (the Tahoe repeater's arm and post, laid out
//          straight) clicks shut at the end. Push the latch grip toward
//          the side wall and slide the lid back to open.
//   PLATE  the base plate. Its pocket takes M6 fender washers on pins, or
//          steel or lead shot; the body's floor closes it. Four M3
//          socket-head screws from underneath into nuts in the body's
//          corner bosses hold the two together. Optional magnet pockets.
//
// Frame: X across the case, +Y from the front (USB-C) toward the back,
// Z up. Origin at the front-left inside corner on the floor's top face.
// Each kit has its own board frame: u across, v back from the XIAO's
// front edge, h up from the XIAO's underside. Units mm. OpenSCAD 2021.01.
// =====================================================================

/* [What to make] */
PART = "assembly";   // [assembly, kit, fit_test, body, cap, lid, plate, screw_test, section, bay_view]
BAYS = 2;            // [1, 2, 3]
LABELS = ["HA", "OBS", "RELAY"];   // debossed under each USB-C opening, left to right
WIFI = "fpc";        // [fpc, rpsma]  stock FPC antenna on the bay's right wall, or an RP-SMA bulkhead per kit
MAGNETS = false;     // four magnet pockets under the base plate
LID_SCREW = false;   // an M3 screw down through the lid into a nut, as well as the latch

/* [Measured on the kit] */
STACK_H = 9.32;       // the two boards: the XIAO's underside to the top of the Wio's LoRa module
PIN_BELOW = 9.0;      // the header (plastic and pins) below the XIAO's underside
FPC = [38, 18];       // stock WiFi FPC antenna: length, height
FPC_CABLE = 60;       // its cable
PIGTAIL = 85;         // LoRa U.FL-to-SMA pigtail cable
SCREW_HEAD = [5.0, 3.0];  // M3 socket head: diameter, height

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
BTN_B = [3.0, 2.2];   // boot button (u, v) on the XIAO's top face, left of the USB-C (seen from the front)
BTN_R = [14.8, 2.2];  // reset button, right of it
SW = [2.6, 1.6, 0.8]; // those buttons: size across, along, height
WIFI_UFL = [14.2, 18.5];  // WiFi U.FL, on the XIAO's top face at its back right
PIN_PITCH = 2.54; PIN_N = 7; PIN_SPAN = 15.24;   // header: 7 pins a side, rows 15.24 apart
HDR = [2.54, 2.5];    // header plastic under the XIAO: width, thickness

/* [Hidden] */
// ------------------------------ case ------------------------------
P = 42;               // bay pitch
D_IN = 44;            // inside depth, front wall to back wall
WALL = 2.4;           // front and back walls
SIDE_W = 3.2;         // side walls: they carry the lid's grooves
FLOOR_T = 3.0;        // the latch tongues are cut into it (the Tahoe sled's plate is 3 mm)
LID_T = 2.4;          // lid and cap
DT = 1.2; DT_B = 0.8; DT_C = 0.25;   // dovetail: reach into the wall, straight part at its foot, clearance
USB_Y = 0.3;          // the USB-C socket's face, behind the front wall's inside face
USB_BOOT = [12.6, 7.2, 2.0];   // opening for a normal cable's boot: width, height, corner radius
WALL_ABOVE = 1.6;     // front wall above the openings
CAP_CLR = 0.6;        // cap above the stack's tallest part
CAP_D = 14.0;         // cap reaches this far back from the front wall's inside face
CAP_RAB = 1.2;       // 45 deg wedge along the cap's back edge, under a matching chamfer on the lid's front edge: prints without supports either way up
DIV_T = 2.0;          // divider between bays, carrying the FPC
FPC_Z0 = 0.8;         // FPC pocket starts this far above the floor
FPC_REC = 0.5;        // pocket depth into the wall (the FPC is about 0.2 thick)
LABEL_D = 0.6; LABEL_SIZE = 4.5;
LABEL_FONT = "Liberation Sans:style=Bold";
SMA_HOLE = 6.7;       // SMA / RP-SMA bulkhead, 1/4"-36 thread
SMA_NUT = 8.0;        // its nut across flats
M3_CLEAR = 3.4;
NUT_AF = 5.8; NUT_H = 2.6;   // pocket for an M3 nut (5.5 x 2.4)
BOSS_R = 4.0; BOSS_H = 4.2;  // corner bosses for the base plate's screws
BOSS_P = [2.6, 3.4];         // their centres, in from each inside corner
// base plate and ballast
WASHER = [6.4, 18, 1.6];     // M6 fender washer: hole, outside diameter, thickness
BALLAST_N = 4;               // washers per stack
BALLAST_M = 8.6;             // pocket margin from the inside walls
PLATE_FL = 1.2;              // plate under the pocket
MAGNET = [10, 3];            // magnet pockets, diameter and depth
// bays: the XIAO's front corners under hooks on the front wall, the latch on its back edge right
// of the board-to-board connector, stops on its long edges in front of the header plastic
STANDOFFS = [[5.2, 3.6, 3], [12.6, 3.6, 3], [5.2, 17.4, 3], [12.6, 17.4, 3]];   // under the XIAO, between the header rows
HOOKS = [["B", 0.2, 1.9], ["B", 15.9, 17.6]];   // short: the paperclips pass just inside them
LATCH = ["T", 15.0, 17.6, -1];   // the tongue runs left along the back edge; the finger tab is right of the board
STOPS = [["L", 0.0, 1.0], ["R", 0.0, 1.0]];
MK_H = 0.6;           // raised marks on the floor: three 0.2 mm layers
MK_W = 1.0;           // outline width, inside the board's edge
MK_FONT = "Liberation Sans:style=Bold";
// paperclip holes for B and R: from outside the USB-C opening, down onto each button
CLIP_D = 1.4;         // the hole (a paperclip is 0.8 to 1.0)
CLIP_U = [-0.5, KIT[0] + 0.5];   // where they enter the front wall's outside face (u), for B and R
CLIP_RISE = 7.2;      // and how far above the button's top (steep enough to pass over the front hooks)
// plunger (Wio user button)
TAB_L = 10;           // flexure tab length, root to free end
TAB_W = 3.0;          // its width
TAB_T = 1.2;          // its thickness
TAB_SLOT = 0.6;       // slot round it
NUB_D = 2.0;          // nub that presses the button
NUB_GAP = 0.3;        // nub to button at rest
LED_WIN = 1.8;
// spool beside each bay for the FPC cable's slack
SPOOL = [3.5, 4.5];   // core and lip radius
SPOOL_P = [23.2, 10.4];   // its centre, in the board frame (right of the board)
// latch (copied from tahoe-repeater.scad, laid out straight): latch frame n across
// (+x, outward from the post), t along the lid's slide (+y), t = 0 at the cap's back face
LT_POST = [4.8, 11.8];    // latch post, on a bar from the cap; its catch face is at the first t
LT_POST_N = [-3, 0];
LT_BAR_N = [-6, -1.6];    // the bar that carries it, clear of the hook
LT_RAMP = 2.0;            // the post's last 2 mm slope down, so the hook rides up onto it
LT_ARM = [0.6, 24];       // latch arm on the lid: free end, root
LT_ARM_N = [0.5, 3.3];
LT_HOOK = [1.5, 4.5];     // hook on the free end; it catches 0.3 mm short of the drawn position
LT_HOOK_N = -1.2;         // and reaches in to here
LT_SLOT = 1.6;            // slot outside the arm: room to flex 1.6
LT_ISLOT = 0.8;           // slot inside the arm, past the post
LT_CLR = 0.4;             // round the bar and post
LT_GRIP = [0.9, 4.9, 2.0];   // grip on the arm's free end: t range, height
LID_GAP = 0.2;            // lid's front face to the cap's back face

FN = 64;

// ------------------------------ derived ------------------------------
W_IN = BAYS*P;
WIO_TOP = STACK_H - MODULE[4];     // the Wio's top face, above the XIAO's underside
GAP = WIO_TOP - WIO[2] - XIAO_T;   // between the boards
BY = USB_Y + USB[2];               // every XIAO's front edge, y
function BX(i) = i*P + (P - KIT[0])/2;   // board i's left edge, x
function bxy(i, p) = [BX(i) + p[0], BY + p[1]];             // board frame to the case's, the bay's nominal position
function kxy(i, p) = [BX(i) + p[0], BY - BAY_GAP + p[1]];   // ... and where the kit really sits: pushed against the hooks
FPC_TOP = FPC_Z0 + FPC[1] + 0.4;
ZB = max(PIN_BELOW + 1.0, 0.5);    // the XIAO's underside, above the floor
ZX = ZB + XIAO_T;                  // XIAO top face
ZW = ZB + WIO_TOP;                 // Wio top face
ZUC = ZX + USB[1]/2;               // USB-C centre
BOOT_Z = [ZUC - USB_BOOT[1]/2, ZUC + USB_BOOT[1]/2];
Z_LU = max(ZB + STACK_H + CAP_CLR, ZW + LORA_UFL_H + 0.4, BOOT_Z[1] + WALL_ABOVE);   // lid and cap undersides
SL_T = FLOOR_T;                    // the board bays' plate is the floor
function kit_bay(i) = [KIT, ZB, STANDOFFS, HOOKS, LATCH, STOPS, [[LABELS[i], KIT[0]/2, KIT[1]/2, 4, 90, 1]]];
Z_TOP = Z_LU + LID_T;
DIV_H = FPC_TOP + 0.8;
SMA_Z = max(SMA_NUT/cos(30)/2 + 0.8, Z_LU/2);
LX = W_IN - LT_ARM_N[1] - LT_SLOT - 4;   // latch frame origin, x
PLATE_T = PLATE_FL + BALLAST_N*WASHER[2] + 0.4;
CB = [SCREW_HEAD[0] + 0.8, SCREW_HEAD[1] + 0.3];   // counterbore for a socket head, flush
SCREW_L = PLATE_T - CB[1] + FLOOR_T + BOSS_H - 0.6;   // longest M3 screw that stays under the nut's top
function lora_slots() = let(m = WIFI == "rpsma" ? 2*BAYS : BAYS)
  [for (k = [0 : m - 1]) m == 1 ? W_IN/2 : 8 + k*(W_IN - 16)/(m - 1)];
function lora_idx() = WIFI == "rpsma" ? [for (i = [0 : BAYS - 1]) BAYS == 1 ? 0 : round(i*(2*BAYS - 1)/(BAYS - 1))] : [for (i = [0 : BAYS - 1]) i];
function wifi_idx() = [for (k = [0 : 2*BAYS - 1]) if (len([for (j = lora_idx()) if (j == k) 1]) == 0) k];
function lora_x(i) = lora_slots()[lora_idx()[i]];
function wifi_x(i) = lora_slots()[wifi_idx()[i]];
function pin_uv() = [for (s = [-1, 1]) for (k = [0 : PIN_N - 1])
  [KIT[0]/2 + s*PIN_SPAN/2, KIT[1]/2 - (PIN_N - 1)*PIN_PITCH/2 + k*PIN_PITCH]];
function hdr_v() = [KIT[1]/2 - PIN_SPAN/2 - HDR[0]/2, KIT[1]/2 + PIN_SPAN/2 + HDR[0]/2];
function plungers() = [[WIO_BTN, -1, "U", WIO_TOP + WIO_SW[2]]];   // (u, v), which way the tab's root goes, letter, button top (h)
function clip_target(k) = let(b = k == 0 ? BTN_B : BTN_R) [b[0], b[1], XIAO_T + SW[2]];          // board frame
function clip_entry(k) = [CLIP_U[k], -BY + BAY_GAP - WALL, XIAO_T + SW[2] + CLIP_RISE];   // on the front wall's outside face
function fpc_wall_x(i) = i == BAYS - 1 ? W_IN : (i + 1)*P - DIV_T/2;   // the bay's right wall, its inside face
FPC_Y = (D_IN - FPC[0])/2;

echo(str("xnc: bays ", BAYS, ", outside ", W_IN + 2*SIDE_W, " x ", D_IN + 2*WALL, " x ", PLATE_T + FLOOR_T + Z_TOP,
         " mm (body ", FLOOR_T + Z_TOP, ", plate ", PLATE_T, "); XIAO's underside ", ZB, " above the floor; lid underside ", Z_LU,
         "; gap between the boards ", GAP));
echo(str("xnc: base plate screws: M3 x ", floor(SCREW_L), " or shorter (", SCREW_L, " max), socket head ", SCREW_HEAD));
echo(str("xnc: LoRa SMA x ", [for (i = [0 : BAYS - 1]) lora_x(i)], WIFI == "rpsma" ? str(", RP-SMA x ", [for (i = [0 : BAYS - 1]) wifi_x(i)]) : ""));
assert(BAYS >= 1 && BAYS <= 3, "BAYS is 1, 2 or 3");
assert(GAP >= USB[1] + 0.3, "the boards are too close together for the XIAO's USB-C socket: check STACK_H");
assert(DT_B + DT <= LID_T, "dovetail taller than the lid");
assert(SIDE_W - DT - DT_C >= 1.4, "side wall too thin behind the lid's groove");
assert(LT_ARM_N[0] - LT_POST_N[1] >= 0.4, "latch post too close to the arm");
assert(LT_SLOT >= LT_POST_N[1] - LT_HOOK_N + 0.3, "latch arm can't flex far enough to let the hook past the post");
assert(LT_HOOK[1] < LT_POST[0] && LT_POST[1] < LT_ARM[1] - 6, "latch hook, post and root out of order");
assert(LT_BAR_N[1] - LT_HOOK_N <= -0.3, "latch bar runs into the hook");
assert(len(LABELS) >= BAYS, "one label per bay");
assert(WIFI != "fpc" || DIV_H <= Z_LU - 0.4, "FPC too tall for the case");
assert(WIFI != "fpc" || FPC[0] + 2 <= D_IN, "FPC too long for the bay wall");

// ============================== HELPERS ==============================
module box(x0, x1, y0, y1, z0, z1) translate([x0, y0, z0]) cube([x1 - x0, y1 - y0, z1 - z0]);
module rrect(w, h, r) offset(r = r) offset(delta = -r) square([w, h], center = true);
module bay_frame(i) translate([BX(i), BY, ZB]) children();   // board frame: u, v, h
module rod(a, b, d) let(v = b - a, l = norm(b - a))   // a cylinder from point a to point b
  translate(a) rotate([0, acos(v[2]/l), atan2(v[1], v[0])]) cylinder(d = d, h = l, $fn = 24);

// --------------------- latch (from tahoe-repeater.scad) ---------------------
// The Tahoe latch is drawn round the joint in polar (r, d). Here the lid slides,
// so the same outlines are drawn with straight helpers: n for r, t for d.
function lpol(n, t) = [n, t];
module lsector2d(n0, n1, t0, t1) polygon([lpol(n0, t0), lpol(n1, t0), lpol(n1, t1), lpol(n0, t1)]);
// the latch arm: a spring along the outside of the post, a hook on its free end
// (45 deg lead-in, square catch face). Tahoe's pull tab is a grip on top here.
module latch_arm2d() {
  d0 = LT_ARM[0];
  lsector2d(LT_ARM_N[0], LT_ARM_N[1], d0 + 1, LT_ARM[1] + 0.5);
  hull() {   // rounded free end
    translate(lpol(LT_ARM_N[0] + 1, d0 + 1)) circle(r = 1, $fn = 16);
    translate(lpol(LT_ARM_N[1] - 1, d0 + 1)) circle(r = 1, $fn = 16);
    lsector2d(LT_ARM_N[0], LT_ARM_N[1], d0 + 1, d0 + 2.8);
  }
  dl = LT_ARM_N[0] - LT_HOOK_N;   // lead-in: as far along as it is deep
  polygon([lpol(LT_ARM_N[0] + 0.1, LT_HOOK[0]), lpol(LT_HOOK_N, LT_HOOK[0] + dl),
           lpol(LT_HOOK_N, LT_HOOK[1]), lpol(LT_ARM_N[0] + 0.1, LT_HOOK[1])]);
}
// the latch post: catch face at its -t end, outer face sloping down over its +t end
module latch_post2d() {
  n = 12; d0 = LT_POST[0]; d1 = LT_POST[1]; dr = d1 - LT_RAMP; r1 = LT_POST_N[1]; re = LT_HOOK_N - 0.3;
  polygon(concat([for (i = [0 : n]) lpol(r1, d0 + (dr - d0)*i/n)],
                 [for (i = [1 : n]) lpol(r1 - (r1 - re)*i/n, dr + (d1 - dr)*i/n)],
                 [for (i = [n : -1 : 0]) lpol(LT_POST_N[0], d0 + (d1 - d0)*i/n)]));
}
// the bar from the cap's back face to the post
module latch_bar2d() lsector2d(LT_BAR_N[0], LT_BAR_N[1], -0.01, LT_POST[1]);
// what the lid loses round the arm: the notch the bar and post ride in, and the slots
module latch_cut2d() {
  lsector2d(LT_BAR_N[0] - LT_CLR, LT_ARM_N[0], -5, LT_POST[1] + LT_CLR);           // notch, open at the front
  lsector2d(LT_ARM_N[0] - LT_ISLOT, LT_ARM_N[0], -5, LT_ARM[1]);                   // inside the arm, to the root
  lsector2d(LT_ARM_N[1], LT_ARM_N[1] + LT_SLOT, -5, LT_ARM[1]);                    // outside the arm
}
module latch_frame() translate([LX, CAP_D, 0]) children();

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

// ================================ BODY ================================
// the lid's cross-section (x, z from Z_LU), c = clearance; the side walls' grooves are c = 0
module lid_prof2d(c) polygon([[-DT + c, 0], [W_IN + DT - c, 0], [W_IN + DT - c, DT_B], [W_IN - c, DT_B + DT],
                              [W_IN - c, LID_T + 1], [c, LID_T + 1], [c, DT_B + DT], [-DT + c, DT_B]]);
module kit_bay_add(i, fit = false) {
  // the bay, kept inside the case (the front hooks' walls and buttresses merge into the front wall)
  intersection() {
    translate([BX(i), BY, 0]) bay_add(kit_bay(i));
    box(0, W_IN, -WALL, D_IN, -1, Z_LU);
  }
  if (WIFI == "fpc" && !fit) {
    // spool for the FPC cable's slack, right of the board
    let(c = bxy(i, SPOOL_P)) translate([c[0], c[1], 0]) {
      cylinder(r = SPOOL[0], h = ZB - 1.2, $fn = FN);
      translate([0, 0, ZB - 1.2 - (SPOOL[1] - SPOOL[0])]) cylinder(r1 = SPOOL[0], r2 = SPOOL[1], h = SPOOL[1] - SPOOL[0] + 0.01, $fn = FN);
      translate([0, 0, ZB - 1.2]) cylinder(r = SPOOL[1], h = 0.8, $fn = FN);
    }
    // the divider to the next bay, which carries this bay's FPC
    if (i < BAYS - 1) box((i + 1)*P - DIV_T/2, (i + 1)*P + DIV_T/2, 1.4, D_IN + 0.01, -0.01, DIV_H);   // short of the front wall: the cap's rib
  }
}
// the shell: floor and walls, open at the top, with the lid's grooves
module shell() difference() {
  box(-SIDE_W, W_IN + SIDE_W, -WALL, D_IN + WALL, -FLOOR_T, Z_TOP);
  box(0, W_IN, 0, D_IN, 0, Z_TOP + 1);                                  // the inside
  box(0, W_IN, -WALL - 1, D_IN + WALL + 1, Z_LU, Z_TOP + 1);             // front and back walls stop at the lid
  translate([0, CAP_D, Z_LU]) rotate([90, 0, 0]) mirror([0, 0, 1])      // the lid's grooves, from the cap back
    linear_extrude(height = D_IN + WALL + 1 - CAP_D) lid_prof2d(0);
}
module body_cuts(fit) {
  for (i = [0 : BAYS - 1]) {
    xc = BX(i) + USB_U;
    translate([BX(i), BY, 0]) bay_cut(kit_bay(i));   // the latch's tongue
    // USB-C opening
    translate([xc, -WALL - 1, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = WALL + 2) rrect(USB_BOOT[0], USB_BOOT[1], USB_BOOT[2]);
    // label underneath it
    zl = BOOT_Z[0] - 0.9 - LABEL_SIZE/2;
    translate([xc, -WALL - 0.01, zl]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(height = LABEL_D + 0.01)
      text(LABELS[i], size = LABEL_SIZE, font = LABEL_FONT, halign = "center", valign = "center");
    // FPC pocket on the bay's right wall
    if (WIFI == "fpc") let(x = fpc_wall_x(i)) box(x - 0.01, x + FPC_REC, FPC_Y - 0.3, FPC_Y + FPC[0] + 0.3, FPC_Z0, FPC_TOP);
    // paperclip holes for B and R, a countersink outside, and their letters above
    for (k = [0, 1]) let(a = bay_pt(i, clip_entry(k)), b = bay_pt(i, clip_target(k)), d = (b - a)/norm(b - a)) {
      rod(a - 3*d, a + (WALL + 1.0)/d[1]*d, CLIP_D);   // through the wall, and a little past it
      translate([a[0], -WALL - 0.01, a[2]]) rotate([-90, 0, 0]) cylinder(d1 = 3.2, d2 = CLIP_D, h = 0.9, $fn = 24);
      translate([a[0], -WALL - 0.01, a[2] + 2.9]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(height = LABEL_D + 0.01)
        text(k == 0 ? "B" : "R", size = 2.6, font = LABEL_FONT, halign = "center", valign = "center");
    }
    // LoRa SMA, and the RP-SMA if fitted
    for (x = concat([lora_x(i)], WIFI == "rpsma" ? [wifi_x(i)] : []))
      translate([x, D_IN - 1, SMA_Z]) rotate([-90, 0, 0]) cylinder(d = SMA_HOLE, h = WALL + 2, $fn = 48);
  }
  if (!fit) for (p = boss_xy()) translate([p[0], p[1], 0]) {   // base plate screws into nuts
    translate([0, 0, -FLOOR_T - 1]) cylinder(d = M3_CLEAR, h = FLOOR_T + BOSS_H + 2, $fn = 24);
    translate([0, 0, BOSS_H - NUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = NUT_H + 1, $fn = 6);
  }
  if (LID_SCREW) let(x = lid_screw_x()) {   // slot in the back wall's top for the lid's boss, nut below
    box(x - 4.7, x + 4.7, D_IN - 5, D_IN + WALL + 1, Z_LU - 1.8, Z_LU + 1);
    translate([x, D_IN - 2.5, Z_LU - 1.8 - NUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = NUT_H + 0.01, $fn = 6);
    translate([x, D_IN - 2.5, Z_LU - 12]) cylinder(d = M3_CLEAR, h = 12, $fn = 24);
  }
}
function bay_pt(i, p) = [BX(i) + p[0], BY - BAY_GAP + p[1], ZB + p[2]];   // board frame to the case's
function boss_xy() = [[BOSS_P[0], BOSS_P[1]], [W_IN - BOSS_P[0], BOSS_P[1]], [BOSS_P[0], D_IN - BOSS_P[1]], [W_IN - BOSS_P[0], D_IN - BOSS_P[1]]];
function lid_screw_x() = W_IN/2 + (BAYS == 1 ? 12 : P/2);
module body(fit = false) difference() {
  union() {
    shell();
    for (i = [0 : BAYS - 1]) kit_bay_add(i, fit);
    if (!fit) for (p = boss_xy()) intersection() {
      translate([p[0], p[1], -0.01]) cylinder(r = BOSS_R, h = BOSS_H + 0.01, $fn = 40);
      box(0, W_IN, 0, D_IN, -1, BOSS_H + 1);
    }
    if (LID_SCREW) let(x = lid_screw_x()) box(x - 4.5, x + 4.5, D_IN - 6, D_IN, -0.01, Z_LU - 1.8);
  }
  body_cuts(fit);
}

// ================================ CAP ================================
// flexure plunger in the cap: a tab along x (dir: which way its root goes), a nub under its free end
function ptab_x(x, dir) = dir < 0 ? [x - TAB_L + NUB_D/2 + 0.5, x + NUB_D/2 + 0.5] : [x - NUB_D/2 - 0.5, x + TAB_L - NUB_D/2 - 0.5];
module cap() {
  difference() {
    union() {
      box(0.2, W_IN - 0.2, -WALL, CAP_D, Z_LU, Z_TOP);
      difference() {   // wedge under the lid's front edge, cut away under the latch arm
        translate([0.2, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = W_IN - 0.4)
          polygon([[CAP_D - 0.01, Z_LU], [CAP_D + CAP_RAB, Z_LU], [CAP_D - 0.01, Z_LU + CAP_RAB + 0.01]]);
        latch_frame() translate([0, 0, Z_LU - 1]) linear_extrude(height = 5) lsector2d(LT_HOOK_N - 0.4, LT_ARM_N[1] + LT_SLOT, -1, CAP_RAB + 1);
      }
      box(0.2, W_IN - 0.2, 0.1, 1.0, Z_LU - 1.5, Z_LU + 0.01);   // rib inside the front wall
      latch_frame() translate([0, 0, Z_LU]) linear_extrude(height = LID_T) { latch_bar2d(); latch_post2d(); }
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
  }
  // nubs, hanging from the tabs' free ends
  for (i = [0 : BAYS - 1]) for (p = plungers()) let(c = kxy(i, p[0]))
    translate([c[0], c[1], ZB + p[3] + NUB_GAP]) cylinder(d = NUB_D, h = Z_TOP - TAB_T - (ZB + p[3] + NUB_GAP) + 0.01, $fn = 24);
}

// ================================ LID ================================
module lid() difference() {
  union() {
    translate([0, D_IN + WALL, Z_LU]) rotate([90, 0, 0]) linear_extrude(height = D_IN + WALL - CAP_D - LID_GAP)
      intersection() { lid_prof2d(DT_C); translate([-10, 0]) square([W_IN + 20, LID_T]); }
    latch_frame() translate([LT_ARM_N[0], LT_GRIP[0], Z_TOP - 0.01])   // grip on the arm's free end
      cube([LT_ARM_N[1] - LT_ARM_N[0], LT_GRIP[1] - LT_GRIP[0], LT_GRIP[2] + 0.01]);
    if (LID_SCREW) let(x = lid_screw_x()) translate([x, D_IN - 2.5, Z_LU - 1.6]) cylinder(d = 9, h = 1.61, $fn = 48);
  }
  // chamfer over the cap's wedge, 0.1 mm clear of it
  translate([-5, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = W_IN + 10)
    polygon([[CAP_D - 1, Z_LU - 1], [CAP_D + CAP_RAB + 1.1, Z_LU - 1], [CAP_D - 1, Z_LU + CAP_RAB + 1.1]]);
  // latch: notch, slots; the arm is what's left between them
  latch_frame() translate([0, 0, Z_LU - 1]) linear_extrude(height = LID_T + 5) latch_cut2d();
  if (LID_SCREW) let(x = lid_screw_x()) translate([x, D_IN - 2.5, 0]) {
    translate([0, 0, Z_LU - 3]) cylinder(d = M3_CLEAR, h = 10, $fn = 24);
    translate([0, 0, Z_TOP - CB[1]]) cylinder(d = CB[0], h = CB[1] + 1, $fn = 40);
  }
}
// the lid with its arm, both in place: the arm is part of the lid
module lid_with_arm() union() {
  lid();
  latch_frame() translate([0, 0, Z_LU]) linear_extrude(height = LID_T) intersection() {
    latch_arm2d();
    lsector2d(LT_HOOK_N - 1, LT_ARM_N[1], LID_GAP, LT_ARM[1] + 0.5);
  }
}

// ============================== BASE PLATE ==============================
// plate frame: its top face at z = 0, same x, y as the body
// two ballast pockets, in front of and behind the latch tongues, which mustn't sit over a pocket
TONGUE_Y = [BY + KIT[1] - BAY_GAP - BAY_PRE - BAY_ISLOT - 1.2, BY + KIT[1] - BAY_GAP - BAY_PRE + BAY_PW + BAY_TSLOT + 1.2];
BALS = [[BALLAST_M, W_IN - BALLAST_M, -WALL + 1.6, TONGUE_Y[0] - 1.6], [BALLAST_M, W_IN - BALLAST_M, TONGUE_Y[1] + 1.6, D_IN + WALL - 1.6]];
function ballast_pins() = let(pt = WASHER[1] + 0.8) [for (r = BALS) let(nx = floor((r[1] - r[0]) / pt), ny = floor((r[3] - r[2]) / pt),
  x0 = (r[0] + r[1])/2 - (nx - 1)*pt/2, y0 = (r[2] + r[3])/2 - (ny - 1)*pt/2) if (nx > 0 && ny > 0)
  for (a = [0 : nx - 1]) for (b = [0 : ny - 1]) [x0 + a*pt, y0 + b*pt]];
function magnet_xy() = [for (x = [3.2, W_IN - 3.2]) for (y = [D_IN*0.3, D_IN*0.7]) [x, y]];
module plate() difference() {
  union() {
    difference() {
      box(-SIDE_W, W_IN + SIDE_W, -WALL, D_IN + WALL, -PLATE_T, 0);
      for (r = BALS) box(r[0], r[1], r[2], r[3], -PLATE_T + PLATE_FL, 1);
      box(0, W_IN, TONGUE_Y[0], TONGUE_Y[1], -0.3, 1);   // so the tongues don't rub
    }
    for (p = ballast_pins()) translate([p[0], p[1], -PLATE_T + PLATE_FL - 0.01]) cylinder(d = WASHER[0] - 0.4, h = BALLAST_N*WASHER[2], $fn = 32);
  }
  for (p = boss_xy()) translate([p[0], p[1], 0]) {
    // counterbore from underneath, then a 0.2 mm skin (one layer) the printer can bridge across in one go,
    // then the hole: the screw pushes through the skin. No supports needed.
    translate([0, 0, -PLATE_T + CB[1] + 0.2]) cylinder(d = M3_CLEAR, h = PLATE_T + 1, $fn = 24);
    translate([0, 0, -PLATE_T - 0.01]) cylinder(d = CB[0], h = CB[1] + 0.01, $fn = 40);
  }
  if (MAGNETS) for (p = magnet_xy()) translate([p[0], p[1], -PLATE_T - 0.01]) cylinder(d = MAGNET[0] + 0.3, h = MAGNET[1] + 0.2, $fn = 48);
}

// ============================== SCREW TEST ==============================
// Three counterbores for your M3 socket heads (the plate's size in the middle, 0.2 either
// side). Pick the one where the head sits flush.
module screw_test() {   // a small bar, counterbores up so nothing overhangs: the sizes are on its front face
  cbs = [CB[0] - 0.2, CB[0], CB[0] + 0.2]; h = CB[1] + 1.2;
  pt = CB[0] + 2.4; w = CB[0] + 2.8;
  difference() {
    translate([-pt/2, -w/2, 0]) cube([3*pt, w, h]);
    for (k = [0 : 2]) translate([k*pt, 0, 0]) {
      translate([0, 0, -1]) cylinder(d = M3_CLEAR, h = h + 2, $fn = 24);
      translate([0, 0, h - CB[1]]) cylinder(d = cbs[k], h = CB[1] + 1, $fn = 40);
      translate([0, -w/2 - 0.01, h/2]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(height = 0.5)
        text(str(cbs[k]), size = 2.0, font = LABEL_FONT, halign = "center", valign = "center");
    }
  }
}

// ============================== PREVIEW DUMMIES ==============================
// the kit as the checks see it, in bay i (board frame)
module kit_dummy(i, part = "all") translate([0, -BAY_GAP, 0]) bay_frame(i) {   // home: pushed against the hooks
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
  if (part == "clips")   // a paperclip in each hole, its tip on the button
    for (k = [0, 1]) let(a = clip_entry(k), b = clip_target(k), d = (b - a)/norm(b - a)) rod(a - 10*d, b - 0.8*d, 0.9);   // stops 0.8 short
}
module fpc_dummy(i) color([0.8, 0.55, 0.1]) let(x = fpc_wall_x(i)) box(x + 0.05, x + 0.25, FPC_Y, FPC_Y + FPC[0], FPC_Z0 + 0.2, FPC_Z0 + 0.2 + FPC[1]);
// a USB-C cable plugged in: the boot (an ordinary 11.5 x 6.5 mm one) and the plug's shell
module plug_dummy(i) color([0.1, 0.1, 0.1]) let(xc = BX(i) + USB_U, yf = USB_Y - 0.4) {
  translate([xc, yf - 20, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = 20) rrect(11.5, 6.5, 2);
  translate([xc, yf, ZUC]) rotate([-90, 0, 0]) linear_extrude(height = 6.2) rrect(8.25, 2.4, 1.1);
}
module sma_dummy() color("Gold") for (i = [0 : BAYS - 1]) for (x = concat([lora_x(i)], WIFI == "rpsma" ? [wifi_x(i)] : []))
  translate([x, D_IN + WALL, SMA_Z]) rotate([90, 0, 0]) {
    translate([0, 0, -12]) cylinder(d = 6.35, h = 12 + WALL + 6.5);   // thread, outside and in
    translate([0, 0, WALL + 0.01]) cylinder(d = SMA_NUT/cos(30), h = 2.5, $fn = 6);   // nut inside
  }

// ================================ LAYOUTS ================================
CLR = [0.93, 0.92, 0.88];
module assembly() {
  color(CLR) body();
  color(CLR) cap();
  color([0.85, 0.84, 0.8]) lid_with_arm();
  color([0.5, 0.5, 0.5]) translate([0, 0, -FLOOR_T]) plate();
  for (i = [0 : BAYS - 1]) { kit_dummy(i); if (WIFI == "fpc") fpc_dummy(i); plug_dummy(i); }
  sma_dummy();
}
// print poses
module body_print(fit = false) translate([0, 0, FLOOR_T]) body(fit);
module cap_print() translate([0, 0, Z_TOP]) rotate([180, 0, 0]) cap();      // top face down, nubs up (turned over, not mirrored)
module lid_print() translate([0, 0, -Z_LU]) lid_with_arm();                    // underside down
module plate_print() translate([0, 0, PLATE_T]) plate();
// Every printed part of one version, laid out apart. In Bambu Studio:
// right-click > Split > To objects.
module kit() {
  body_print();                                                    // y -WALL .. D_IN + WALL
  translate([0, D_IN + WALL + 8 + CAP_D + LT_POST[1], 0]) cap_print();   // turned over, 8 mm behind the body
  translate([0, 2*D_IN + 4*WALL + 16 + LT_POST[1] - LID_GAP, 0]) lid_print();   // 8 mm behind the cap's latch bar
  translate([0, -(D_IN + 2*WALL + 8), 0]) plate_print();            // in front of the body
}

// ============================== FIT TEST ==============================
// Just enough of one bay to try the kit before printing a case: the floor under it with the
// standoffs, stops and latch; the stretch of front wall with the USB-C opening, the B and R
// paperclip holes and the hooks; two columns that carry a short piece of the cap with the
// Wio button's plunger and the LED window; and the screw-head test bar.
FX = [BX(0) - 3.5, BX(0) + KIT[0] + 6.5];   // across: the stops to the latch's finger tab
FY = BY + KIT[1] + BAY_PW + BAY_TSLOT + 2;   // back to just behind the latch's tongue
module fit_body() {
  difference() {
    intersection() {
      body(true);
      box(FX[0], FX[1], -WALL - 1, FY, -FLOOR_T - 1, Z_LU);
    }
    // a window in the floor under the board, between the standoffs (plastic the test doesn't need)
    let(a = bxy(0, [1.0, STANDOFFS[0][1] + STANDOFFS[0][2]/2 + 0.8]), b = bxy(0, [KIT[0] - 1.0, STANDOFFS[2][1] - STANDOFFS[2][2]/2 - 0.8]))
      box(a[0], b[0], a[1], b[1], -FLOOR_T - 1, 1);
  }
  for (x = [FX[0], FX[1] - 3]) box(x, x + 3, CAP_D - 3, CAP_D, -0.01, Z_LU);   // columns under the cap's back corners
}
module fit_cap() intersection() {
  cap();
  box(FX[0], FX[1], -WALL - 1, CAP_D, Z_LU - 5, Z_TOP + 1);
}
module fit_test() {
  translate([0, 0, FLOOR_T]) fit_body();
  translate([0, FY + 8 + CAP_D, Z_TOP]) rotate([180, 0, 0]) fit_cap();   // turned over, behind the body
  translate([FX[1] + 8, 0, 0]) screw_test();
}

// ================================ DISPATCH ================================
assert(PART != "fit_test" || BAYS == 1, "the fit test is one bay: set BAYS = 1");
if (PART == "assembly") assembly();
else if (PART == "kit") kit();
else if (PART == "fit_test") fit_test();
else if (PART == "body") body_print();
else if (PART == "cap") cap_print();
else if (PART == "lid") lid_print();
else if (PART == "plate") plate_print();
else if (PART == "screw_test") screw_test();
else if (PART == "bay_view") { color(CLR) fit_body(); color(CLR) fit_cap(); kit_dummy(0); }
// assembled poses, for the checks (check_case.py)
else if (PART == "a_body") { if (FIT) fit_body(); else body(); }
else if (PART == "a_cap") { if (FIT) fit_cap(); else cap(); }
else if (PART == "a_lid") { if (!FIT) translate([0, LID_DY, 0]) lid_with_arm(); }
else if (PART == "a_plate") translate([0, 0, -FLOOR_T]) plate();
else if (PART == "d_boards") for (i = [0 : BAYS - 1]) kit_dummy(i, "boards");
else if (PART == "d_parts") for (i = [0 : BAYS - 1]) kit_dummy(i, "parts");
else if (PART == "d_pins") for (i = [0 : BAYS - 1]) kit_dummy(i, "pins");
else if (PART == "d_clips") for (i = [0 : BAYS - 1]) kit_dummy(i, "clips");
else if (PART == "d_fpc") { if (WIFI == "fpc" && !FIT) for (i = [0 : BAYS - 1]) fpc_dummy(i); }
else if (PART == "d_plug") for (i = [0 : BAYS - 1]) plug_dummy(i);
else if (PART == "d_sma") { if (!FIT) sma_dummy(); }
// sections for the checks: the front wall's inner half, the cap's tabs, the lid at mid-thickness
else if (PART == "s_front") projection(cut = true) translate([0, 0, -0.6]) rotate([-90, 0, 0]) { if (FIT) fit_body(); else body(); }
else if (PART == "s_cap") projection(cut = true) translate([0, 0, -(Z_TOP - 0.9)]) { if (FIT) fit_cap(); else cap(); }
else if (PART == "s_lid") projection(cut = true) translate([0, 0, -(Z_LU + LID_T/2)]) lid_with_arm();
// a cut through bay 0's centre, for the pictures
else if (PART == "section") intersection() { assembly(); box(-SIDE_W - 1, BX(0) + USB_U, -WALL - 21, D_IN + WALL + 1, -FLOOR_T - PLATE_T - 1, Z_TOP + LT_GRIP[2] + 1); }
FIT = false;
LID_DY = 0;
// numbers for check_case.py
echo(str("xnc-chk: {",
  "\"ZB\": ", ZB, ", \"ZX\": ", ZX, ", \"ZW\": ", ZW, ", \"Z_LU\": ", Z_LU, ", \"Z_TOP\": ", Z_TOP, ", \"BY\": ", BY - BAY_GAP, ", \"BAY_GAP\": ", BAY_GAP, ", \"BAY_PRE\": ", BAY_PRE, ", \"LATCH\": ", LATCH, ", \"BAY_TL\": ", BAY_TL, ", \"XIAO_T\": ", XIAO_T,
  ", \"BX0\": ", BX(0), ", \"P\": ", P, ", \"D_IN\": ", D_IN, ", \"WALL\": ", WALL, ", \"KIT\": ", KIT,
  ", \"USB_U\": ", USB_U, ", \"FPC\": ", FPC, ", \"FPC_Z0\": ", FPC_Z0, ", \"FPC_Y\": ", FPC_Y, ", \"FPC_CABLE\": ", FPC_CABLE,
  ", \"FPC_X0\": ", fpc_wall_x(0), ", \"PIGTAIL\": ", PIGTAIL, ", \"WIFI_UFL\": ", WIFI_UFL, ", \"LORA_UFL\": ", LORA_UFL,
  ", \"LORA_UFL_H\": ", LORA_UFL_H, ", \"SPOOL\": ", SPOOL, ", \"SPOOL_P\": ", SPOOL_P, ", \"SMA_Z\": ", SMA_Z,
  ", \"LORA_X\": ", [for (i = [0 : BAYS - 1]) lora_x(i)], ", \"PLUNGERS\": ", [for (p = plungers()) [p[0][0], p[0][1], p[3]]],
  ", \"NUB_GAP\": ", NUB_GAP, ", \"TAB_L\": ", TAB_L, ", \"TAB_T\": ", TAB_T, ", \"CLIPS\": ", [for (k = [0, 1]) clip_target(k)], ", \"CLIP_IN\": ", [for (k = [0, 1]) clip_entry(k)],
  ", \"LT_SLOT\": ", LT_SLOT, ", \"LT_HOOK_DEPTH\": ", LT_POST_N[1] - LT_HOOK_N, ", \"WIFI\": \"", WIFI, "\"",
  ", \"BAYS\": ", BAYS, "}"));
