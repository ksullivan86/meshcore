// =====================================================================
// Tahoe MeshCore solar repeater, design revision 9
// https://github.com/ksullivan86/meshcore (folder tahoe-repeater)
// Licensed CC BY-NC-SA 4.0 (see LICENSE). No commercial use without
// written permission from the author.
// ---------------------------------------------------------------------
// A round printed enclosure for a RAK4631 MeshCore repeater, a 15 Ah
// LiFePO4 cell and a small 5 V solar panel. It hangs on a printed tree
// bracket that also carries the panel's round camera-style mount.
//
// Each joint closes with a quarter-turn thread that only fits one way
// round, so the sloped roof always faces away from the tree, and seals
// with one O-ring (AS568-153) that sits in a groove on the lower part and
// presses against a smooth bore in the upper part. The O-ring seals
// sideways, so the thread only has to hold the parts together and turns
// by hand. A latch on the tabs at the front clicks shut as the joint
// closes; a printed lock pin and an M3 lock screw are there as extras.
//
//   VERSION A (the main one): the top slides down onto the bracket's
//     dovetail rail and stays there. The base, with the cell, the boards
//     and every opening, screws up into it from below. To open it: pull
//     the latch tab, a quarter turn, lower the base.
//   VERSION B: a tall can slides down onto the rail and a short lid
//     screws on top. To open it: pull the latch tab, a quarter turn, lift
//     the lid off. The joint is higher up, so B is meant for milder weather.
//   VERSION C: a sleeve slides down onto B's rail, with A's base screwed
//     into its bottom and B's lid onto its top, so it opens at both ends.
//
//   MOUNT "tree": the panel mount's top hole takes a long wood screw
//     into the tree; its other two holes use M3 lock nuts sealed in the
//     bracket.
//   MOUNT "bolt": all three mount holes use sealed M3 lock nuts, and the
//     bracket gets its own screw above the mount.
//   MOUNT "wing": M3 bolts sit in hex pockets on the back of the bracket
//     with their threads out the front, and wing nuts hold the mount, so
//     the panel comes off by hand. Extra screw above the mount as "bolt".
//     Nothing is printed in: the bolts go in from the back afterwards.
//
// Inside, a sled clicks into sockets in the floor and pulls out by a
// handle. Printed turn buttons hold the boards on it, or M2 screws.
//
// Straps: every bracket has three strap channels across its front (low,
// middle and high), recessed so the enclosure slides down over the
// straps. Use one as extra hold, or two or three instead of tree screws.
//
// Sealed nuts: the bracket (tree and bolt mounts) holds nylon-insert
// lock nuts (DIN 985) and each lower lock tab holds a plain hex nut for
// the lock screw. Each goes in during a print pause. The heights are
// echoed below and listed in the build guide.
//
// Frame: Z up, joint at z = 0 (A), z = ZJ_B (B) or both (C), +Y toward
// the tree, -Y away from it (south). Units mm. Written for OpenSCAD 2021.01.
// =====================================================================

/* [What to make] */
PART    = "assembly"; // [assembly, kit, upper, lower, sleeve, bracket, sled, buttons, lock_pin, thread_test_male, thread_test_female, fit_test, mount_test, wing_spacers]
VERSION = "A";        // [A, B, C]
MOUNT   = "tree";     // [tree, bolt, wing]
POSE    = "print";    // [print, assembled]

/* [Panel mount: measure yours] */
// center to center between two of the mount's three holes
MOUNT_HOLE_SPACING = 36;
// the three holes, measured round from 3 o'clock; 90 = top
MOUNT_HOLE_ANG = [90, 210, 330];
// pocket that centres the mount's round base
MOUNT_D = 55.6;

/* [Hardware fit] */
INSERT_D    = 4.3;    // M3 heat-set insert hole (sled feet)
M2_INSERT_D = 3.1;    // M2 heat-set insert hole (board standoffs)
M3_CLEAR    = 3.4;
NUT_AF      = 5.8;    // pocket for an M3 nut, 5.5 across flats
NUT_H       = 2.8;    // lock tab: plain M3 hex nut, 2.4 thick
LOCKNUT_H   = 4.4;    // bracket: M3 nylon-insert lock nut (DIN 985), 4.0 thick
BOLT_HEAD_AF = 5.7;   // pocket for an M3 hex bolt head (wing mount)
TREE_SCREW_D = 5.2;   // tree-screw mount: clearance for the #10 wood screw through the top hole (opens up a #6 or #8 too)

/* [Hidden] */
$fa = 2; $fs = 0.4;
FN = 180;
SQ2 = sqrt(2);

// ------------------------------ shell ------------------------------
W     = 3.2;          // wall
R_C   = 42;           // opening inside the lower part's spigot
R_OUT = 54.3;         // outside radius
R_DI  = R_OUT - W;

// -------------------- thread: 8 ridges, quarter turn --------------------
TH_SEG  = [62, 60, 36, 63, 34, 33, 37, 35];  // ridge widths, degrees: fits at one angle only
TH_LEAD = 64;         // each ridge rises 64 mm per turn
TH_E    = 0.75;       // ridges +-0.75 (1.5 mm deep), flanks 39 deg or less from vertical
TH_RM   = 45.75;      // male mean radius: root 45.0, crest 46.5
TH_CLR  = 0.5;        // radial clearance
TH_H    = 16;         // thread length
TH_CH   = 1.2;        // lead-in chamfers
TURN    = TH_H / TH_LEAD * 360;   // 90 deg from drop-in to closed

// -------- seal: AS568-153 (88.57 x 2.62) in a groove on the spigot --------
OR_ID = 88.57;
OR_CS = 2.62;
R_G   = 45.2;         // groove floor
R_B   = 47.2;         // bore in the upper part
R_S   = 46.95;        // spigot lip beside the groove
G0    = 2.0;          // groove from z 2.0 ...
GW    = 3.6;          // ... to 5.6
G1    = G0 + GW;
SPIG_TOP = G1 + TH_H;         // 21.6: thread runs z 5.6 .. 21.6
FEM_TOP  = SPIG_TOP + 1;      // top of the female thread zone

// drip lip round the upper part's rim
LIP   = 2;
LIP_E = 0.8;

// ------------------------------ heights ------------------------------
FL_T   = 8;           // floor and flange
ZA0    = 154;         // A roof, inside: z = ZA0 + y (45 deg, high at the tree)
ZJ_B   = 130;         // B joint height
LID_SLOPE = 20;       // B lid roof
LID_Z_IN  = 40.5;     // B lid roof, inside, above its rim: z = LID_Z_IN + y tan(20)

// ------------------------------- lock -------------------------------
// The tabs at the front carry three ways to lock the joint. Use any of them.
//  - Snap latch: an arm on the upper tab rides over a post on the lower tab
//    and clicks in behind it as the joint closes. Pull the arm out to open.
//  - Lock pin: a printed pin through both tabs, tied on with a small zip tie.
//  - Lock screw: an M3 x 20 from the top into a nut sealed in the lower tab.
// Angles below are measured from LOCK_A, counterclockwise seen from above.
// The joint closes clockwise (the upper part turns clockwise on the lower).
LOCK_A  = -90;        // tabs at the front
LOCK_R  = 58.5;       // screw and pin circle
LUG_R0  = R_OUT - 4;  // both tabs run from inside the wall ...
LUG_R1  = 64.5;       // ... out to here
LUG_D   = [-20, 8];   // ... over these angles
LUG_H   = 12;         // upper part's tab
LOCK_SLOT = 3.5;      // +- deg slot for the screw in the upper tab
LOCK_NUT_TOP = 3.4;   // sealed nut pocket top, below the lower tab's top face;
                      // leaves room for a split lock washer under the M3 x 20
// The thread has some play, so hand-tight comes a few degrees past the point
// where its ridges line up. The upper part's thread is turned back by this
// much, so hand-tight lands about 1 deg past the drawn position.
LOCK_TIGHT = 2.5;
PIN_A   = -12.5;      // lock pin
PIN_D   = 5.4;        // its hole
PIN_SLOT = 3;         // +- deg slot in the upper tab
PIN_GROOVE = [2.6, 4.6];   // groove for the pin's barbs, below the lower tab's top face
PIN_GROOVE_D = 6.6;
LT_POST = [-12, -4];  // latch post on the lower tab; its catch face is at the first angle
LT_POST_R = [65, 68];
LT_POST_H = 8;
LT_RAMP = 3;          // the post's last 3 deg slope down, so the hook rides up onto it
LT_ARM  = [-21.5, 4]; // latch arm on the upper tab: free end, root
LT_ARM_R = [68.5, 71.3];
LT_ARM_H = 10;
LT_HOOK = [-17.5, -14.5];  // hook on the free end; it catches at the second angle,
LT_HOOK_R = 66.8;          // 2.5 deg before the drawn position, and reaches in to here
LT_ROOT = [4, 9.5];   // the arm's root block
LT_EYE  = [6.75, 66.9];    // tether hole in the root block: angle, radius
LT_TAB  = 76.5;       // pull tab on the arm's free end reaches out to here
TURN_C  = TURN + LOCK_TIGHT;    // drop-in to the drawn position
NUB_A_TOP  = LOCK_A - TURN_C;   // A: base tab lines up here to go on
NUB_A_BASE = LOCK_A + TURN_C;   // B: lid tab lines up here to go on

// ------------------- openings in the floor, all facing down -------------------
VENT_P  = [-21, -20]; // M12 vent stands upside down inside; its nut sits in a hex pocket underneath
VENT_HOLE = 12.4;
VENT_NUT_AF = 16.4;
VENT_POCKET = FL_T - 3.0;
GLAND_P = [20, -21];  // 1/4" NPT cable gland from underneath, its lock nut inside in a round pocket
GLAND_D = 14.3;
GLAND_POCKET_D = 24;
GLAND_POCKET = 5.6;    // deep enough that a gland with an 8 mm thread (AIRTAK 1/4" NPT) gets its lock nut on: 2.4 mm web
SMA_P   = [0, -30];   // SMA bulkhead
SMA_HOLE = 6.7;
SMA_POCKET_D = 16;
SMA_FLOOR = 2.0;

// ------------------- cell: Gotion 33140 stands behind the sled -------------------
CELL_D  = 33.6;
CELL_L  = 140;
CELL_P  = [-5, 20];   // off centre, so it clears A's sloped roof while the base turns
CELL_Z0 = 6;
CUP_RI  = 17.6;
CUP_T   = 2.4;
CUP_H   = 12;

// ------------------------------ sled ------------------------------
// The sled clicks into two sockets in the floor and pulls straight up by
// its handle. Its two feet still take M3 screws into the floor's inserts
// if you want them. Boards sit on standoffs and are held either by M2
// screws into inserts or by printed turn buttons that swing over the
// pads round their mounting holes. Board layouts: Adafruit's PCB files
// for the bq25185 and MiniBoost, RAK's mechanical drawing for the RAK19003.
SL_X  = 30;
SL_T  = 3;
SL_Z0 = 3;
SL_Z1 = 128;
SL_FOOT = [26, -4.5]; // screw feet (optional)
SO_D = 6;
SO_H = 7;             // room for a RAK1901 sensor under the RAK19003
PCB_T = 1.6;
M2_HOLE_DEPTH = SO_H + SL_T - 0.8;
// board corners on the sled (x, z), sizes and holes in each board's own frame
BQ0  = [-15.9, 64];   // Adafruit bq25185 #6091
BQ_SIZE = [31.75, 25.4];
BQ_HOLES = [[2.54, 2.54], [29.21, 2.54], [2.54, 22.86], [29.21, 22.86]];
MB0  = [8, 99];       // Adafruit MiniBoost #4654
MB_SIZE = [11.43, 17.78];
MB_HOLE = [2.54, 15.24];
MB_REST = [8.9, 9.0];
RAK0 = [-17, 20];     // RAK19003, USB-C edge on the left
RAK_SIZE = [35, 30];
RAK_HOLES = [[4, 4], [4, 26], [35, 15]];   // two 2.7 mm holes, and a half-hole in the far edge
RAK_SO_D = [5.5, 5.5, 6];
RAK_USB = 18.3;       // USB-C centre, up from the bottom edge
function rak_xz(p) = [RAK0[0] + p[0], RAK0[1] + p[1]];
function bq_xz(p) = [BQ0[0] + p[0], BQ0[1] + p[1]];
function mb_xz(p) = [MB0[0] + p[0], MB0[1] + p[1]];
// prongs that click into the floor sockets
PR_X = 17;            // prong centres, +-x
PR_TINE = 2.8;        // each prong is two tines ...
PR_GAP = 1.6;         // ... with a gap between them
PR_SLOT = 1.0;        // slot that frees each tine from the plate
PR_ROOT = 19;         // tines start here, up the plate
PR_TIP = -5.5;        // and reach down into the floor
PR_BARB = 0.7;        // barbs on the outer edges
PR_W = 2*PR_TINE + PR_GAP;
SK_THROAT = 1.5;      // socket: narrow throat, then a wider pocket
SK_DEPTH = 7.0;
// handle on top
HD_W = 24; HD_H = 13; HD_BAR = 4;
// cell strap: one 1/2 in hook-and-loop strap round the cell's middle. It crosses the
// sled's front behind the charger, in the one band that's clear of standoffs and posts.
CS_X = 27.5; CS_LEN = 14; CS_W = 2.6;
CS_Z = [69.7];
// turn buttons: posts beside each board, swinging arms over the hole pads
BTN_T = 2.4;          // button thickness
BTN_GAP = 1.2;        // arm clears parts up to 1.2 mm tall on the board
BTN_ARM = 3.2;        // arm width
BTN_FOOT = 2.4;       // foot that presses on the pad
POST_D = 6; SHANK_D = 4.0; HEAD_D = 4.8;
BTN_L = 6;            // every arm is the same length, so any button fits any post
// [post x, post z, foot x, foot z] on the sled; each foot lands on the pad round a mounting hole
BUTTONS = [
  concat(bq_xz([-2.97, -2.97]), bq_xz([1.27, 1.27])),
  concat(bq_xz([34.72, -2.97]), bq_xz([30.48, 1.27])),
  concat(bq_xz([-2.97, 28.37]), bq_xz([1.27, 24.13])),
  concat(bq_xz([34.72, 28.37]), bq_xz([30.48, 24.13])),
  concat(mb_xz([-2.97, 20.75]), mb_xz([1.27, 16.51])),
  concat(mb_xz([16.6, 0.9]), mb_xz([10.6, 0.9])),
  concat(rak_xz([-3.8, 4]), rak_xz([2.2, 4])),
  concat(rak_xz([2.3, 33.2]), rak_xz([2.3, 27.2])),
  concat(rak_xz([40.0, 15]), rak_xz([34.0, 15]))];
RAK_CORE = [12, 32];  // the RAK4631 core covers the base from here to here (u), full height

// ------------------------------ bracket ------------------------------
Y_PF  = 78;           // plate front face
PL_T  = 6;
PL_W  = 68;
RIB_D = 10;           // ribs toward the tree
Y_BK  = Y_PF + PL_T + RIB_D;   // 94, the bark
FEET  = [[-34, 5], [-14, 5], [9, 5], [29, 5]];
ZB0   = 2;            // bracket bottom
EDGE_CH = 2.5;        // chamfer on the front side edges, easy on straps
SCREW_D = 5.2;        // #10 wood screw clearance
HEAD_CB = 10.5;       // pan head counterbore
CB_DEPTH = 4.5;
KEY_HEAD = 11; KEY_SHANK = 5.4; KEY_SLIDE = 12;
KEY_LIP = 9.5;        // keyhole screw head stands 9.5 mm off the bark
DT_ROOT = 18; DT_TIP = 24; DT_H = 6; DT_CLR = 0.3;   // dovetail
RAIL_A = [6, 70];     // A: rail plus its 45 deg peak; the top lifts 83 mm to come off
BLK_A_W = 34; BLK_A_TOP = 100;
RAIL_B = [6, 40];     // B: short rail so the can (lid off) lifts off under the panel arm
BLK_B_W = 34; BLK_B_TOP = 110;
STRAP_W = 27;         // 1" strap
STRAP_REC = 2;        // recessed across the front, so the enclosure slides over the strap
STRAPS_A = [86, 130.5, 175];  // bottoms of the low, middle and high channels
STRAPS_B = [56, 118.5, 181];
ZIPS_A = [20, 55, 120, 164];  // zip-tie slot pairs for the panel cable, +X side, between the straps
ZIPS_B = [20, 40, 100, 164];
// panel mount pad
Z_PAD_A = 232;
Z_PAD_B = 242;
PAD_RAISE_B = 20;     // B's pad stands out 20 mm so the panel clears the lid coming off
PAD_D = 64;
MOUNT_POCKET = 2;
NUT_BACK = 5;         // sealed lock nut sits 5 mm behind the mount's pocket floor
WING_BOLT = 25;       // M3 x 25 hex bolts (wing mount) ...
WING_OUT  = 13.4;     // ... stick out 13.4 mm past the pocket floor
EXTRA_UP  = 35;       // bolt and wing mounts: extra tree screw above the pad
KNUCKLE = 80;         // mount's tilt joint, in front of its base
PNL = [170, 120, 7];  // Rebower 4 W panel
PNL_TILT = 55;        // from horizontal (winter sun at 39 N)

// ------------------------------ derived ------------------------------
function cum(v, i) = i == 0 ? 0 : cum(v, i - 1) + v[i - 1];
TH_N = len(TH_SEG);
TH_S = [for (i = [0 : TH_N]) cum(TH_SEG, i)];
MOUNT_BC = MOUNT_HOLE_SPACING / sin(60);
Z_TOPB = ZA0 + W*SQ2 + R_OUT;          // A roof at the back, outside
LID_TOPB = ZJ_B + LID_Z_IN + W/cos(LID_SLOPE) + R_OUT*tan(LID_SLOPE);
function z_pad(v) = v == "A" ? Z_PAD_A : Z_PAD_B;
function pad_face(v) = v == "A" ? Y_PF : Y_PF - PAD_RAISE_B;
function pocket_floor(v) = pad_face(v) + MOUNT_POCKET;
function key_z(v) = z_pad(v) - PAD_D/2 - 7.5;
function extra_z(v) = z_pad(v) + EXTRA_UP;
function zb1(v, m) = m == "tree" ? z_pad(v) + PAD_D/2 + 2 : extra_z(v) + HEAD_CB/2 + 4;
function rail(v) = v == "A" ? RAIL_A : RAIL_B;
function rail_screw_z(v) = (rail(v)[0] + rail(v)[1]) / 2;
function straps(v) = v == "A" ? STRAPS_A : STRAPS_B;
function zips(v) = v == "A" ? ZIPS_A : ZIPS_B;
function mount_hole(v, a) = [MOUNT_BC/2*cos(a), z_pad(v) + MOUNT_BC/2*sin(a)];
function print_z(y) = Y_BK - y;       // bracket prints bark side down
function knuckle_p(v) = [0, pad_face(v) - (KNUCKLE - MOUNT_POCKET), z_pad(v)];
function bed_fit(v, m) = (zb1(v, m) - ZB0 + PL_W) / SQ2;
// panel mount screws into the sealed lock nuts (M3, flat washer under the head):
// long enough to pass 1 mm through the nut, short enough not to reach the bark
function screw_min() = NUT_BACK + LOCKNUT_H + 1 + 0.5;          // + the mount's base thickness
function screw_max(v) = Y_BK - pocket_floor(v) + 0.5;            // + the mount's base thickness
function strap_top_max(v) = v == "A" ? z_pad(v) - MOUNT_D/2 - 1 : z_pad(v) - PAD_D/2 - 1;
function clear_of_straps(v, z0, z1) = len([for (s = straps(v)) if (z1 > s - 2 && z0 < s + STRAP_W + 2) 1]) == 0;

OR_STRETCH = 2*R_G / OR_ID - 1;
OR_SQUEEZE = (OR_CS*(1 - OR_STRETCH/2) - (R_B - R_G)) / (OR_CS*(1 - OR_STRETCH/2));
OR_FILL = (PI*OR_CS*OR_CS/4) / (GW*(R_B - R_G));
echo(str("v9: O-ring stretch ", round(OR_STRETCH*1000)/10, " %, squeeze ", round(OR_SQUEEZE*1000)/10,
         " %, groove fill ", round(OR_FILL*100), " %; turn ", TURN_C, " deg; A roof back ", Z_TOPB,
         "; B lid back ", LID_TOPB));
echo(str("v9: pauses (print z of the pocket top): A base ", FL_T - LOCK_NUT_TOP, ", B can ", ZJ_B + FL_T - LOCK_NUT_TOP,
         ", C sleeve ", ZJ_C - LOCK_NUT_TOP, ", bracket A ", print_z(pocket_floor("A") + NUT_BACK), ", bracket B and C ", print_z(pocket_floor("B") + NUT_BACK)));
echo(str("v9: panel mount screws: the mount's base thickness plus ", screw_min(), " to ", screw_max("A"),
         " mm (A) or plus ", screw_min(), " to ", screw_max("B"), " mm (B and C)"));
echo(str("v9: strap channels, bottom edges (", STRAP_W, " mm tall): A ", STRAPS_A, ", B and C ", STRAPS_B));
echo(str("v9: wing-nut spacers: A ", round(max(0, wing_spacer_len("A"))*10)/10, " mm (0 = none), B and C ", round(wing_spacer_len("B")*10)/10, " mm"));
echo(str("v9: bracket length / bed diagonal: A tree ", zb1("A","tree") - ZB0, "/", bed_fit("A","tree"),
         ", A bolt ", zb1("A","bolt") - ZB0, "/", bed_fit("A","bolt"), ", B tree ", zb1("B","tree") - ZB0, "/", bed_fit("B","tree"),
         ", B bolt ", zb1("B","bolt") - ZB0, "/", bed_fit("B","bolt"), "; mount bolt circle ", MOUNT_BC));
echo(str("v9: lock: latch catches ", LT_POST[0] - LT_HOOK[1], " deg before the drawn position, hook ", LT_POST_R[1] - LT_HOOK_R,
         " mm deep; pin slot +-", PIN_SLOT, " deg, screw slot +-", LOCK_SLOT, " deg"));
assert(TH_S[TH_N] == 360, "thread ridge widths must add to 360");
assert(min(TH_SEG) >= 30.2, "narrowest ridge would overhang more than 41.5 deg");
assert(OR_STRETCH > 0.01 && OR_STRETCH < 0.04, "O-ring stretch outside 1 to 4 %");
assert(OR_SQUEEZE > 0.15 && OR_SQUEEZE < 0.30, "O-ring squeeze outside 15 to 30 %");
assert(R_B - (TH_RM + TH_E) >= 0.5, "thread crest must pass the O-ring bore");
assert(bed_fit("B", "bolt") <= 252, "B bracket too long for a 256 mm bed");
assert(MOUNT_BC/2 + NUT_AF/2/cos(30) < PAD_D/2 - 2, "mount holes too far out for the pad");
assert(OR_FILL < 0.85, "O-ring groove over 85 % full");
function on_layer(z) = abs(z/0.2 - round(z/0.2)) < 1e-6;
assert(on_layer(FL_T - LOCK_NUT_TOP) && on_layer(ZJ_B + FL_T - LOCK_NUT_TOP) && on_layer(ZJ_C - LOCK_NUT_TOP), "lock nut pocket not on a 0.2 mm layer");
// lock: the parts clear each other, the arm clears the post, the pin and screw slots stay apart
assert(LT_POST_R[0] - LUG_R1 >= 0.4 && LT_ARM_R[0] - LT_POST_R[1] >= 0.4, "latch post too close to the upper tab or the arm");
assert(LT_HOOK[1] < LT_POST[0] && LT_POST[1] < LT_ROOT[0] - LOCK_SLOT, "latch hook, post and root out of order");
assert((PIN_A + PIN_SLOT)*PI/180*LOCK_R + PIN_D/2 < -LOCK_SLOT*PI/180*LOCK_R - M3_CLEAR/2 - 1.2, "pin slot runs into the screw slot");
assert((PIN_A - PIN_SLOT - LUG_D[0])*PI/180*LOCK_R - PIN_D/2 >= 1.5, "pin slot too close to the end of the tab");
assert(on_layer(print_z(pocket_floor("A") + NUT_BACK)) && on_layer(print_z(pocket_floor("B") + NUT_BACK)),
       "bracket nut pockets not on a 0.2 mm layer");
assert(screw_max("A") - screw_min() >= 3, "too little room behind A's lock nuts for a range of screw lengths");
assert(LOCKNUT_H >= 4.2 && NUT_H >= 2.6, "nut pockets must stay deeper than the nuts, so the nozzle clears them after the pause");
for (v = ["A", "B"]) {
  s = straps(v);
  assert(s[0] >= rail(v)[1] + DT_TIP/2 + 2, str(v, ": low strap channel runs into the rail"));
  assert(s[len(s) - 1] + STRAP_W <= strap_top_max(v), str(v, ": high strap channel runs into the panel mount's pad"));
  for (i = [1 : len(s) - 1]) assert(s[i] >= s[i - 1] + STRAP_W + 5, str(v, ": strap channels too close together"));
  for (z = zips(v)) assert(clear_of_straps(v, z, z + 2.4), str(v, ": zip-tie slot at ", z, " is inside a strap channel"));
}

// ============================== HELPERS ==============================
// Thread surface: radius r + e*g(phi - 360*z/lead), one raised-cosine ridge per
// TH_SEG segment. Male and female share the phase, so they meet one way only.
function th_g(p) = let(q = p - 360*floor(p/360), i = max([for (k = [0 : TH_N - 1]) if (q >= TH_S[k]) k]))
  -cos(360*(q - TH_S[i])/(TH_S[i + 1] - TH_S[i]));
module kthread(r, z0, z1, dz = 0.4, ph = 0) {   // ph turns the ridge pattern, degrees
  na = 180;            // 2 deg steps: within 0.02 mm of the true surface
  nz = max(2, ceil((z1 - z0)/dz));
  pts = [for (k = [0 : nz]) for (i = [0 : na - 1])
           let(z = z0 + (z1 - z0)*k/nz, phi = 360*i/na, rho = r + TH_E*th_g(phi - 360*z/TH_LEAD - ph))
           [rho*cos(phi), rho*sin(phi), z]];
  side = [for (k = [0 : nz - 1]) for (i = [0 : na - 1])
            let(a = k*na + i, b = k*na + (i + 1)%na, c = (k + 1)*na + (i + 1)%na, d = (k + 1)*na + i)
            [a, d, c, b]];
  bottom = [[for (i = [0 : na - 1]) i]];
  top = [[for (i = [na - 1 : -1 : 0]) nz*na + i]];
  polyhedron(points = pts, faces = concat(side, bottom, top), convexity = 6);
}
// lower part's spigot: lip, O-ring groove, then the thread, 45 deg start and a lead-in on top
module male_spigot() difference() {
  union() {
    cylinder(r = R_S, h = G0, $fn = FN);
    translate([0, 0, G0 - 0.01]) cylinder(r = R_G, h = GW + 0.02, $fn = FN);
    intersection() {
      kthread(TH_RM, G1, SPIG_TOP);
      translate([0, 0, G1 - 0.001]) cylinder(r1 = R_G, r2 = R_G + TH_H + 0.002, h = TH_H + 0.002, $fn = FN);
      union() {
        translate([0, 0, G1 - 1]) cylinder(r = 60, h = SPIG_TOP - TH_CH - G1 + 1, $fn = FN);
        translate([0, 0, SPIG_TOP - TH_CH - 0.001])
          cylinder(r1 = TH_RM + TH_E, r2 = TH_RM + TH_E - TH_CH, h = TH_CH + 0.002, $fn = FN);
      }
    }
  }
  translate([0, 0, -1]) cylinder(r = R_C, h = SPIG_TOP + 2, $fn = FN);
}
// what the upper part's skirt loses: O-ring bore with a lead-in, 45 deg step, female thread
module female_cut() {
  kthread(TH_RM + TH_CLR, G1 - 0.6, FEM_TOP + 0.37, 0.4, -LOCK_TIGHT);   // no grid ring on the FEM_TOP plane
  translate([0, 0, -1]) cylinder(r = R_B, h = G1 + 1, $fn = FN);
  translate([0, 0, G1 - 0.001])
    cylinder(r1 = R_B, r2 = TH_RM + TH_CLR - TH_E, h = R_B - (TH_RM + TH_CLR - TH_E), $fn = FN);
  translate([0, 0, -0.01]) cylinder(r1 = R_B + TH_CH, r2 = R_B, h = TH_CH + 0.01, $fn = FN);
}
module drip_lip() rotate_extrude($fn = FN)
  polygon([[R_OUT - 1, 0], [R_OUT + LIP, 0], [R_OUT + LIP, LIP_E], [R_OUT - 1, LIP_E + LIP + 1]]);
module nub(a, z0, z1, under = true) rotate(a) translate([R_OUT - 0.5, 0, 0]) {
  translate([0, 0, z0]) cylinder(d = 4, h = z1 - z0, $fn = 24);
  if (under) translate([0, 0, z0 - 2]) cylinder(d1 = 0.01, d2 = 4, h = 2.001, $fn = 24);   // 45 deg underside
}
// ribs to grip the part that turns, clear of the lock tabs
function lock_d(a) = ((a - LOCK_A + 540) % 360) - 180;   // angle a, measured from LOCK_A
module grip_ribs(z0, z1) for (a = [0 : 10 : 359]) if (lock_d(a) < LUG_D[0] - 6 || lock_d(a) > LUG_D[1] + 6)
  rotate(a) hull() {   // 45 deg lower end, so a rib that starts off the bed prints clean
    translate([R_OUT - 0.2, 0, z0 + 2.6]) cylinder(d = 2.6, h = z1 - z0 - 2.6, $fn = 16);
    translate([R_OUT - 0.3, 0, z0]) cylinder(d = 0.2, h = z1 - z0, $fn = 8);
  }

// ------------------------------ lock tabs ------------------------------
function la(d) = LOCK_A + d;                          // angle d from LOCK_A
function pol(r, d) = r*[cos(la(d)), sin(la(d))];      // point at radius r, angle d from LOCK_A
module sector2d(r0, r1, d0, d1) {                     // ring sector, angles from LOCK_A
  n = max(2, ceil(abs(d1 - d0)));
  polygon(concat([for (i = [0 : n]) pol(r1, d0 + (d1 - d0)*i/n)], [for (i = [n : -1 : 0]) pol(r0, d0 + (d1 - d0)*i/n)]));
}
module arc_slot(r, d, d0, d1, z0, h) for (i = [0 : 3])   // slot along the circle r, from d0 to d1
  hull() for (k = [i, i + 1]) translate(concat(pol(r, d0 + (d1 - d0)*k/4), [z0])) cylinder(d = d, h = h, $fn = 32);
// the tab both parts share, outer corners rounded
module tab2d() offset(r = 2.5) offset(delta = -2.5) sector2d(LUG_R0, LUG_R1, LUG_D[0], LUG_D[1]);
// upper part: the shared tab and the latch arm's root block
module upper_tab2d() {
  tab2d();
  offset(r = 1) offset(delta = -1) sector2d(LUG_R1 - 1, LT_ARM_R[1], LT_ROOT[0], LT_ROOT[1]);
}
// the latch arm: a curved spring along the outside of the post, a hook on its
// free end (45 deg lead-in, square catch face) and a tab to pull it out by
module latch_arm2d() {
  d0 = LT_ARM[0];
  sector2d(LT_ARM_R[0], LT_ARM_R[1], d0 + 1, LT_ARM[1] + 0.5);
  hull() {   // rounded free end and the pull tab
    translate(pol(LT_ARM_R[0] + 1, d0 + 1)) circle(r = 1, $fn = 16);
    translate(pol(LT_TAB - 1.6, d0 + 1.3)) circle(r = 1.6, $fn = 20);
    sector2d(LT_ARM_R[0], LT_ARM_R[1], d0 + 1, d0 + 2.8);
  }
  dl = (LT_ARM_R[0] - LT_HOOK_R) / (LT_ARM_R[0]*PI/180);   // lead-in: as far round as it is deep
  polygon([pol(LT_ARM_R[0] + 0.1, LT_HOOK[0]), pol(LT_HOOK_R, LT_HOOK[0] + dl),
           pol(LT_HOOK_R, LT_HOOK[1]), pol(LT_ARM_R[0] + 0.1, LT_HOOK[1])]);
}
// lower part: the shared tab and a ledge under the latch post
module lower_tab2d() {
  tab2d();
  sector2d(LUG_R1 - 1, LT_POST_R[1], LT_POST[0] - 0.5, LT_POST[1] + 0.5);
}
// the latch post: catch face at its -d end, outer face sloping down over its +d end
module latch_post2d() {
  n = 12; d0 = LT_POST[0]; d1 = LT_POST[1]; dr = d1 - LT_RAMP; r1 = LT_POST_R[1]; re = LT_HOOK_R - 0.3;
  polygon(concat([for (i = [0 : n]) pol(r1, d0 + (dr - d0)*i/n)],
                 [for (i = [1 : n]) pol(r1 - (r1 - re)*i/n, dr + (d1 - dr)*i/n)],
                 [for (i = [n : -1 : 0]) pol(LT_POST_R[0], d0 + (d1 - d0)*i/n)]));
}
// the upper part's tab and latch arm, on the joint plane z0; and what they lose
module upper_lock(z0) translate([0, 0, z0]) {
  linear_extrude(height = LUG_H) upper_tab2d();
  linear_extrude(height = LT_ARM_H) latch_arm2d();
}
module upper_lock_cuts(z0) {
  arc_slot(LOCK_R, M3_CLEAR, -LOCK_SLOT, LOCK_SLOT, z0 - 1, LUG_H + 2);          // screw
  arc_slot(LOCK_R, PIN_D, PIN_A - PIN_SLOT, PIN_A + PIN_SLOT, z0 - 1, LUG_H + 2); // pin
  translate(concat(pol(LT_EYE[1], LT_EYE[0]), [z0 - 1])) cylinder(d = 3.2, h = LUG_H + 2, $fn = 24);   // tether
}
// the lower part's tab and latch post; zt = the tab's top face (the joint)
module lower_lock(zt) {
  translate([0, 0, zt - FL_T]) linear_extrude(height = FL_T) lower_tab2d();
  translate([0, 0, zt - 0.01]) linear_extrude(height = LT_POST_H + 0.01) latch_post2d();
}
module lower_lock_gusset(zt) {   // 45 deg underside, for a tab that isn't on the bed
  zb = zt - FL_T;
  for (s = [0, 1]) let(r = s == 0 ? LUG_R1 + 0.5 : LT_POST_R[1] + 0.5) intersection() {
    translate([0, 0, zb - r]) cylinder(r1 = 0, r2 = r, h = r + 0.01, $fn = FN);
    translate([0, 0, zb - 30]) linear_extrude(height = 30.01) if (s == 0) tab2d(); else lower_tab2d();
  }
}
module lower_lock_cuts(zt) {
  lock_nut(zt);
  translate(concat(pol(LOCK_R, PIN_A), [zt])) {   // pin hole, a groove for its barbs, a lead-in
    translate([0, 0, -FL_T - 20]) cylinder(d = PIN_D, h = FL_T + 21, $fn = 32);
    translate([0, 0, -PIN_GROOVE[1]]) cylinder(d = PIN_GROOVE_D, h = PIN_GROOVE[1] - PIN_GROOVE[0] - 0.6, $fn = 32);
    translate([0, 0, -PIN_GROOVE[0] - 0.6 - 0.01]) cylinder(d1 = PIN_GROOVE_D, d2 = PIN_D, h = 0.61, $fn = 32);
    translate([0, 0, -0.6]) cylinder(d1 = PIN_D, d2 = PIN_D + 1.2, h = 0.61, $fn = 32);
  }
}
// sealed nut in the lower part's tab; zt = the tab's top face (the joint)
module lock_nut(zt) rotate(LOCK_A) translate([LOCK_R, 0, 0]) {
  translate([0, 0, zt - LOCK_NUT_TOP - NUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = NUT_H, $fn = 6);
  translate([0, 0, zt - LOCK_NUT_TOP - NUT_H - 6]) cylinder(d = M3_CLEAR, h = LOCK_NUT_TOP + NUT_H + 7);
}

// ------------------------------ lock pin ------------------------------
// Printed lying flat, round side up. It goes down through the upper tab's slot
// into the lower tab, where barbs on its split end click into a groove. The
// ring takes a small zip tie to the tether hole in the latch arm's root block.
PIN_W = 5.0;          // round, with a flat ...
PIN_FLAT = 0.6;       // ... this far up from the bottom
PIN_TIP = 6.5;        // reaches this far into the lower tab
PIN_SPLIT = 11;       // split this far up from its tip
PIN_BARB = 0.6;       // barbs stand out this far
function pin_x(z) = LUG_H - z;     // along the pin (print x) from installed height z
module pin_section2d(s = 1) intersection() {
  scale([s, 1]) translate([0, PIN_W/2 - PIN_FLAT]) circle(d = PIN_W, $fn = 40);
  translate([-5, 0]) square([10, PIN_W]);
}
module pin_slice(x, s) translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(height = 0.01) pin_section2d(s);
module lock_pin() {   // print pose: shoulder at x = 0, tip toward +x, ring toward -x
  L = LUG_H + PIN_TIP; sb = (PIN_W + 2*PIN_BARB)/PIN_W;
  x0 = pin_x(-PIN_GROOVE[0]); x1 = x0 + PIN_BARB; x2 = x1 + 0.6; x3 = x2 + PIN_BARB/tan(30);
  difference() {
    union() {
      hull() { pin_slice(0, 1); pin_slice(L - 1.2, 1); }
      hull() { pin_slice(L - 1.2, 1); pin_slice(L, 0.6); }     // tapered tip
      hull() { pin_slice(x0, 1); pin_slice(x1, sb); }          // barbs: 45 deg back ...
      hull() { pin_slice(x1, sb); pin_slice(x2, sb); }
      hull() { pin_slice(x2, sb); pin_slice(x3, 1); }          // ... 30 deg front
      linear_extrude(height = PIN_W - PIN_FLAT) difference() {   // shoulder and ring
        hull() { translate([-2.5, -7]) square([2.5, 14]); translate([-8.5, 0]) circle(d = 12, $fn = 48); }
        translate([-8.5, 0]) circle(d = 6.5, $fn = 32);
      }
    }
    translate([L - PIN_SPLIT, -0.6, -1]) cube([PIN_SPLIT + 1, 1.2, PIN_W + 2]);   // the split
  }
}
module below_plane(c) {  // z <= c + y (45 deg, high toward +Y)
  rotate([90, 0, 90]) linear_extrude(height = 400, center = true)
    polygon([[-200, -60], [200, -60], [200, c + 200], [-200, c - 200]]);
}
module below_lid_roof(c) {  // z <= c + y tan(LID_SLOPE)
  rotate([90, 0, 90]) linear_extrude(height = 400, center = true)
    polygon([[-200, -60], [200, -60], [200, c + 200*tan(LID_SLOPE)], [-200, c - 200*tan(LID_SLOPE)]]);
}
// dovetail channel (open toward +Y at y_back) from z0 to z1, then a 45 deg roof
module dt_channel(y_back, z0, z1) {
  c = DT_CLR;
  tc = [[-DT_ROOT/2 - c, y_back + 1], [DT_ROOT/2 + c, y_back + 1], [DT_ROOT/2 + c, y_back],
        [DT_TIP/2 + c, y_back - DT_H - c], [-DT_TIP/2 - c, y_back - DT_H - c], [-DT_ROOT/2 - c, y_back]];
  translate([0, 0, z0]) linear_extrude(height = z1 - z0) polygon(tc);
  hull() {
    translate([0, 0, z1 - 0.01]) linear_extrude(height = 0.01) polygon(tc);
    translate([-0.005, y_back - DT_H - c, z1 + DT_TIP/2 + c]) cube([0.01, DT_H + c + 1, 0.01]);
  }
}
module dt_rail(z0, z1) {  // on the plate, tip toward -Y, 45 deg peak on top
  tr = [[-DT_ROOT/2, Y_PF + 0.01], [DT_ROOT/2, Y_PF + 0.01], [DT_TIP/2, Y_PF - DT_H], [-DT_TIP/2, Y_PF - DT_H]];
  translate([0, 0, z0]) linear_extrude(height = z1 - z0) polygon(tr);
  hull() {
    translate([0, 0, z1 - 0.01]) linear_extrude(height = 0.01) polygon(tr);
    translate([-0.005, Y_PF - DT_H, z1 + DT_TIP/2]) cube([0.01, DT_H + 0.01, 0.01]);
  }
}
module yhole(x, z, d, y0, y1, fn = 0) translate([x, y0, z]) rotate([-90, 0, 0])
  if (fn > 0) cylinder(d = d, h = y1 - y0, $fn = fn); else cylinder(d = d, h = y1 - y0);
module yhex(x, z, af, y0, y1) translate([x, y0, z]) rotate([-90, 0, 0]) cylinder(d = af/cos(30), h = y1 - y0, $fn = 6);
module clipz(z0, z1) intersection() { union() children(); translate([-200, -200, z0]) cube([400, 400, z1 - z0]); }
module pad_frame(v) translate([0, pad_face(v), z_pad(v)]) rotate([90, 0, 0]) children();  // local +z = -Y

// ============================ FLOOR AND INSIDES ============================
module insides_mounts() {
  translate([CELL_P[0], CELL_P[1], 0]) difference() {   // cell cup, three pads, open toward the sled
    cylinder(r = CUP_RI + CUP_T, h = CUP_H);
    translate([0, 0, CELL_Z0]) cylinder(r = CUP_RI, h = CUP_H);
    translate([0, 0, CUP_H - 1.6]) cylinder(r1 = CUP_RI, r2 = CUP_RI + 1.6, h = 1.61);   // lead-in, so the cell finds the cup
    translate([0, 0, -1]) cylinder(r = CUP_RI - 5, h = CUP_H + 2);
    for (a = [30, 150, 270]) rotate(a) translate([CUP_RI - 6, -4, -1]) cube([7, 8, CELL_Z0 + 1]);
    translate([-12, -CUP_RI - CUP_T - 1, -1]) cube([24, 10, CUP_H + 2]);
  }
  for (s = [-1, 1]) translate([s*SL_FOOT[0], SL_FOOT[1], 0]) cylinder(d = 9, h = SL_Z0);
}
module floor_cuts() {
  // vent: M12 hole, hex pocket for its nut underneath
  translate([VENT_P[0], VENT_P[1], -FL_T - 1]) cylinder(d = VENT_HOLE, h = FL_T + 2);
  translate([VENT_P[0], VENT_P[1], -FL_T - 0.01]) cylinder(d = VENT_NUT_AF/cos(30), h = VENT_POCKET + 0.01, $fn = 6);
  // cable gland: hole, pocket inside for its lock nut
  translate([GLAND_P[0], GLAND_P[1], -FL_T - 1]) cylinder(d = GLAND_D, h = FL_T + 2);
  translate([GLAND_P[0], GLAND_P[1], -GLAND_POCKET]) cylinder(d = GLAND_POCKET_D, h = GLAND_POCKET + 1);
  // SMA bulkhead: pocket inside, hole through the thin floor
  translate([SMA_P[0], SMA_P[1], -FL_T + SMA_FLOOR]) cylinder(d = SMA_POCKET_D, h = FL_T);
  translate([SMA_P[0], SMA_P[1], -FL_T - 1]) cylinder(d = SMA_HOLE, h = FL_T + 2);
  // heat-set inserts for the sled's feet (screws are optional)
  for (s = [-1, 1]) translate([s*SL_FOOT[0], SL_FOOT[1], SL_Z0 - 7.5]) cylinder(d = INSERT_D, h = 8.5);   // M3 x 8 or x 10
  // sockets the sled's prongs click into: a narrow throat, then a wider pocket for the barbs
  for (s = [-1, 1]) translate([s*PR_X, SL_T/2, 0]) {
    translate([-(PR_W/2 + 0.1), -(SL_T + 0.4)/2, -SK_THROAT]) cube([PR_W + 0.2, SL_T + 0.4, SK_THROAT + 1]);
    translate([-(PR_W/2 + PR_BARB + 0.2), -(SL_T + 0.4)/2, -SK_DEPTH]) cube([PR_W + 2*PR_BARB + 0.4, SL_T + 0.4, SK_DEPTH - SK_THROAT + 0.01]);
    hull() {   // lead-in
      translate([-(PR_W/2 + 0.1), -(SL_T + 0.4)/2, -0.5]) cube([PR_W + 0.2, SL_T + 0.4, 0.01]);
      translate([-(PR_W/2 + 0.6), -(SL_T + 1.2)/2, 0]) cube([PR_W + 1.2, SL_T + 1.2, 0.01]);
    }
  }
}

// ================================ VERSION A ================================
module top_a() difference() {
  union() {
    intersection() {
      cylinder(r = R_OUT, h = 300, $fn = FN);
      below_plane(ZA0 + W*SQ2);
    }
    upper_lock(0);
    drip_lip();
    nub(NUB_A_TOP, 0.001, 10, false);
    translate([-BLK_A_W/2, R_OUT - 6, 0]) cube([BLK_A_W, Y_PF - DT_CLR - (R_OUT - 6), BLK_A_TOP]);
  }
  intersection() {
    translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 300, $fn = FN);
    below_plane(ZA0);
  }
  female_cut();
  upper_lock_cuts(0);
  dt_channel(Y_PF - DT_CLR, -1, RAIL_A[1] + DT_CLR);
}
module base_a() difference() {
  union() {
    translate([0, 0, -FL_T]) cylinder(r = R_OUT, h = FL_T, $fn = FN);
    lower_lock(0);
    grip_ribs(-FL_T, -1);
    male_spigot();
    insides_mounts();
  }
  floor_cuts();
  lower_lock_cuts(0);
}

// ================================ VERSION B ================================
Z_SHOULDER = ZJ_B - FL_T - (R_DI - R_C);   // can narrows at 45 deg to the spigot opening
module can_b() difference() {
  union() {
    difference() {
      union() {
        translate([0, 0, -FL_T]) cylinder(r = R_OUT, h = FL_T + ZJ_B, $fn = FN);
        translate([0, 0, ZJ_B]) male_spigot();
        lower_lock(ZJ_B);
        lower_lock_gusset(ZJ_B);
        nub(NUB_A_BASE, ZJ_B - FL_T, ZJ_B);
        translate([-BLK_B_W/2, R_OUT - 6, -FL_T]) cube([BLK_B_W, Y_PF - DT_CLR - (R_OUT - 6), BLK_B_TOP + FL_T]);
      }
      cylinder(r = R_DI, h = Z_SHOULDER + 0.01, $fn = FN);
      translate([0, 0, Z_SHOULDER]) cylinder(r1 = R_DI, r2 = R_C, h = R_DI - R_C, $fn = FN);
      translate([0, 0, ZJ_B - FL_T - 0.5]) cylinder(r = R_C, h = FL_T + 2, $fn = FN);
    }
    insides_mounts();
  }
  floor_cuts();
  lower_lock_cuts(ZJ_B);
  dt_channel(Y_PF - DT_CLR, -FL_T - 1, RAIL_B[1] + DT_CLR);
}
module lid_b() translate([0, 0, ZJ_B]) difference() {
  union() {
    intersection() {
      cylinder(r = R_OUT, h = 100, $fn = FN);
      below_lid_roof(LID_Z_IN + W/cos(LID_SLOPE));
    }
    upper_lock(0);
    drip_lip();
    grip_ribs(LIP_E + LIP + 1, 20);
  }
  intersection() {
    translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 100, $fn = FN);
    below_lid_roof(LID_Z_IN);
  }
  female_cut();
  upper_lock_cuts(0);
}

// ================================ VERSION C ================================
// A sleeve that opens at both ends. A's base screws up into its bottom (the
// boards come out that way) and B's lid screws onto its top. It slides onto
// B's bracket like B's can. The joints are A's and B's, at the same heights.
ZJ_C = ZJ_B;
module sleeve_c() difference() {
  union() {
    cylinder(r = R_OUT, h = ZJ_C, $fn = FN);
    upper_lock(0);                          // bottom joint, as A's top
    drip_lip();
    nub(NUB_A_TOP, 0.001, 10, false);
    translate([0, 0, ZJ_C]) male_spigot();  // top joint, as B's can
    lower_lock(ZJ_C);
    lower_lock_gusset(ZJ_C);
    nub(NUB_A_BASE, ZJ_C - FL_T, ZJ_C);
    translate([-BLK_B_W/2, R_OUT - 6, 0]) cube([BLK_B_W, Y_PF - DT_CLR - (R_OUT - 6), BLK_B_TOP]);
  }
  translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = Z_SHOULDER - FEM_TOP + 0.01, $fn = FN);
  translate([0, 0, Z_SHOULDER]) cylinder(r1 = R_DI, r2 = R_C, h = R_DI - R_C, $fn = FN);
  translate([0, 0, ZJ_C - FL_T - 0.5]) cylinder(r = R_C, h = FL_T + 2, $fn = FN);
  female_cut();
  upper_lock_cuts(0);
  lower_lock_cuts(ZJ_C);
  dt_channel(Y_PF - DT_CLR, -1, RAIL_B[1] + DT_CLR);
}

// ================================ SLED ================================
function standoffs() = concat(
  [for (h = BQ_HOLES) concat(bq_xz(h), [SO_D])],
  [concat(mb_xz(MB_HOLE), [SO_D])],
  [for (i = [0 : 2]) concat(rak_xz(RAK_HOLES[i]), [RAK_SO_D[i]])]);
ZIP = [[-24, 62], [26, 62], [-20, 100], [-4, 100], [26, 88]];   // wiring, and the protection board
H_BTN = SO_H + PCB_T + BTN_GAP;       // collar top: a button's hub sits here, clear of the board
// cylinder from the plate's front face forward (toward -y) by h
module fwd(x, z, d, h, fn = 0) translate([x, 0.01, z]) rotate([90, 0, 0])
  if (fn > 0) cylinder(d = d, h = h + 0.01, $fn = fn); else cylinder(d = d, h = h + 0.01);
// one tine in the plate plane (x, z); its barb points away from the prong's centre gap
module tine2d(x_in, x_out) {
  s = sign(x_out - x_in);
  zw = -SK_THROAT - 0.6;             // widest point of the barb, just under the socket's throat
  polygon([[x_in, PR_ROOT], [x_out, PR_ROOT], [x_out, zw + PR_BARB/tan(55)], [x_out + s*PR_BARB, zw],
           [x_out, zw - PR_BARB/tan(30)], [x_out, PR_TIP + 0.8], [x_out - s*0.8, PR_TIP], [x_in, PR_TIP]]);
}
module plate2d() difference() {
  union() {
    translate([-SL_X, SL_Z0]) square([2*SL_X, SL_Z1 - SL_Z0]);
    difference() {   // handle
      translate([-HD_W/2, SL_Z1 - 1]) offset(r = 2) offset(delta = -2) square([HD_W, HD_H + 1]);
      translate([-HD_W/2 + 4, SL_Z1]) offset(r = 1.5) offset(delta = -1.5) square([HD_W - 8, HD_H - HD_BAR]);
    }
    for (s = [-1, 1]) {
      tine2d(s*PR_X - PR_GAP/2, s*PR_X - PR_W/2);
      tine2d(s*PR_X + PR_GAP/2, s*PR_X + PR_W/2);
    }
  }
  for (s = [-1, 1]) {
    // free each prong's outer edges from the plate, up to the root ...
    for (e = [-1, 1]) translate([s*PR_X + (e < 0 ? -PR_W/2 - PR_SLOT : PR_W/2), SL_Z0 - 0.01]) square([PR_SLOT, PR_ROOT - SL_Z0]);
    // ... and open the gap between its two tines
    translate([s*PR_X - PR_GAP/2, PR_TIP - 1]) square([PR_GAP, PR_ROOT - PR_TIP + 1]);
  }
}
// post for a turn button: collar, shank, and a head the button snaps under
module btn_post(x, z) {
  fwd(x, z, POST_D, H_BTN, 32);
  translate([x, -H_BTN + 0.01, z]) rotate([90, 0, 0]) cylinder(d = SHANK_D, h = BTN_T + 0.12, $fn = 32);
  translate([x, -H_BTN - BTN_T - 0.1, z]) rotate([90, 0, 0]) cylinder(d1 = HEAD_D, d2 = SHANK_D - 0.6, h = 1.4, $fn = 32);
}
module sled_assembled() {
  difference() {
    union() {
      translate([0, SL_T, 0]) rotate([90, 0, 0]) linear_extrude(height = SL_T) plate2d();
      for (s = [-1, 1]) translate([s*SL_FOOT[0] - 5, -9, SL_Z0]) cube([10, 9 + 0.01, 3.5]);
      for (i = [0 : len(standoffs()) - 1]) let(p = standoffs()[i])
        if (i == len(standoffs()) - 1)   // RAK half-hole: keep the standoff off the board's underside
          intersection() { fwd(p[0], p[1], p[2], SO_H, 36); translate([RAK0[0] + 32.5, -SO_H - 1, p[1] - 5]) cube([10, SO_H + 2, 10]); }
        else fwd(p[0], p[1], p[2], SO_H, 36);
      fwd(mb_xz(MB_REST)[0], mb_xz(MB_REST)[1], 4, SO_H, 24);
      for (b = BUTTONS) btn_post(b[0], b[1]);
    }
    for (p = standoffs()) translate([p[0], -SO_H - 0.01, p[1]]) rotate([-90, 0, 0]) cylinder(d = M2_INSERT_D, h = M2_HOLE_DEPTH + 0.01);
    for (s = [-1, 1]) translate([s*SL_FOOT[0], SL_FOOT[1], SL_Z0 - 1]) cylinder(d = M3_CLEAR, h = 6);
    for (z = ZIP) translate([z[0] - 2.1, -1, z[1] - 1]) cube([4.2, SL_T + 2, 2]);
    for (z0 = CS_Z) for (s = [-1, 1]) translate([s*CS_X - CS_W/2, -1, z0]) cube([CS_W, SL_T + 2, CS_LEN]);   // cell straps
  }
}
module sled_flat() translate([0, 0, SL_T]) rotate([-90, 0, 0]) sled_assembled();
// turn button: a C-shaped hub that snaps over the post's head and grips its shank,
// and an arm whose foot presses on the pad round a board's mounting hole
module button2d() difference() {
  union() {
    circle(d = 8, $fn = 40);
    hull() { circle(d = BTN_ARM, $fn = 24); translate([BTN_L, 0]) circle(d = BTN_ARM, $fn = 24); }
  }
  circle(d = SHANK_D - 0.1, $fn = 32);
  translate([-5, -0.5]) square([5, 1.0]);
}
module button() {   // hub underside at z = 0, arm along +x, foot below
  linear_extrude(height = BTN_T) button2d();
  translate([BTN_L, 0, -(BTN_GAP + 0.05)]) cylinder(d = BTN_FOOT, h = BTN_GAP + 0.06, $fn = 24);
}
module buttons_assembled() for (b = BUTTONS)   // swung shut over the pads
  translate([b[0], -H_BTN, b[1]]) rotate([90, 0, 0]) rotate(atan2(b[3] - b[1], b[2] - b[0])) button();
module buttons_print() {   // all nine on a snap-off spine, arms up, feet up
  n = len(BUTTONS);
  for (i = [0 : n - 1]) translate([0, i*10, BTN_T]) mirror([0, 0, 1]) button();
  translate([-6.5, -2, 0]) cube([1.2, (n - 1)*10 + 4, 1.2]);
  for (i = [0 : n - 1]) translate([-5.5, i*10 + 1.6, 0]) cube([2.3, 0.8, 0.8]);   // off the C split
}

// =============================== BRACKETS ===============================
module mount_holes(v, m) {
  pf = pad_face(v); fl = pocket_floor(v);
  for (a = MOUNT_HOLE_ANG) {
    p = mount_hole(v, a);
    if (m == "tree" && a == 90) {
      yhole(p[0], p[1], TREE_SCREW_D, pf - 1, Y_BK + 1);           // wood screw into the tree
    } else if (m == "wing") {
      yhole(p[0], p[1], M3_CLEAR, pf - 1, Y_BK + 1);
      yhex(p[0], p[1], BOLT_HEAD_AF, fl + WING_BOLT - WING_OUT, Y_BK + 1);   // bolt head from the back
    } else {
      yhole(p[0], p[1], M3_CLEAR, pf - 1, Y_BK + 1);
      yhex(p[0], p[1], NUT_AF, fl + NUT_BACK, fl + NUT_BACK + LOCKNUT_H);    // sealed lock nut, nylon side toward the tree
    }
  }
}
module bracket(v, m) {
  zp = z_pad(v); z1 = zb1(v, m); r = rail(v);
  pf = pad_face(v); kz = key_z(v); rz = rail_screw_z(v); ez = extra_z(v);
  difference() {
    union() {
      // plate, front side edges chamfered
      translate([0, 0, ZB0]) linear_extrude(height = z1 - ZB0)
        polygon([[-PL_W/2, Y_PF + EDGE_CH], [-PL_W/2 + EDGE_CH, Y_PF], [PL_W/2 - EDGE_CH, Y_PF],
                 [PL_W/2, Y_PF + EDGE_CH], [PL_W/2, Y_PF + PL_T], [-PL_W/2, Y_PF + PL_T]]);
      for (f = FEET) translate([f[0], Y_PF + PL_T - 0.01, ZB0]) cube([f[1], RIB_D + 0.01, z1 - ZB0]);
      clipz(ZB0, z1) {
        // round foot behind the pad, down to the bark
        yhole(0, zp, PAD_D, Y_PF + 1, Y_BK, 120);
        // local feet behind the centre-row screws
        yhole(0, rz, 19, Y_PF + 1, Y_BK, 48);
        hull() for (z = [kz - KEY_SLIDE, kz]) yhole(0, z, 20, Y_PF + 1, Y_BK, 48);
        if (m != "tree") yhole(0, ez, 20, Y_PF + 1, Y_BK, 48);
      }
      if (pf < Y_PF) yhole(0, zp, PAD_D, pf, Y_PF + 0.01, 120);   // B: raised pad
      dt_rail(r[0], r[1]);
    }
    // pocket that centres the mount's round base
    yhole(0, zp, MOUNT_D, pf - 1, pf + MOUNT_POCKET, 120);
    mount_holes(v, m);
    // keyhole: the head goes in the round hole and the bracket drops KEY_SLIDE;
    // the head then sits in a recess, KEY_LIP off the bark, and can be tightened
    yhole(0, kz - KEY_SLIDE, KEY_HEAD, Y_PF - 1, Y_BK + 1);
    hull() for (z = [kz - KEY_SLIDE, kz]) yhole(0, z, KEY_SHANK, Y_PF - 1, Y_BK + 1);
    hull() for (z = [kz - KEY_SLIDE, kz]) yhole(0, z, KEY_HEAD, Y_PF - 1, Y_BK - KEY_LIP);
    // tree screw inside the rail, head sunk below the rail face
    yhole(0, rz, SCREW_D, Y_PF - DT_H - 1, Y_BK + 1);
    yhole(0, rz, HEAD_CB, Y_PF - DT_H - 1, Y_PF - DT_H + CB_DEPTH);
    // bolt and wing mounts: the bracket's own top screw
    if (m != "tree") {
      yhole(0, ez, SCREW_D, Y_PF - 1, Y_BK + 1);
      yhole(0, ez, HEAD_CB, Y_PF - 1, Y_PF + CB_DEPTH);
    }
    // strap channels across the front: low, middle, high
    for (z = straps(v)) translate([-PL_W/2 - 1, Y_PF - 1, z]) cube([PL_W + 2, STRAP_REC + 1, STRAP_W]);
    // zip-tie slot pairs for the panel cable
    for (z = zips(v)) for (x = [20, 25]) translate([x, Y_PF - 1, z]) cube([3, PL_T + 2, 2.4]);
  }
}
// Wing-nut mount: the bolt head sits at the front end of a hex pocket that opens
// at the back. On B the pocket is deeper than the head, so a printed hex spacer
// goes in behind each head and the tree holds it there.
function wing_pocket(v) = Y_BK - (pocket_floor(v) + WING_BOLT - WING_OUT);
function wing_spacer_len(v) = wing_pocket(v) - 2.0 - 0.4;     // DIN 933 M3 head is 2 mm
module wing_spacer(v) rotate([0, 90, 0]) rotate(30)            // lies on a flat side to print
  cylinder(d = (BOLT_HEAD_AF - 0.4)/cos(30), h = wing_spacer_len(v), $fn = 6);
module wing_spacers_print(v) for (i = [0 : 2]) translate([0, i*9, (BOLT_HEAD_AF - 0.4)/2]) wing_spacer(v);
module bracket_print(v, m) {   // bark side down, turned 45 deg to fit the bed
  rotate(45) translate([0, 0, Y_BK]) rotate([-90, 0, 0])
    translate([0, 0, -(ZB0 + zb1(v, m))/2]) bracket(v, m);
}

// ============================ TEST PIECES ============================
// Print these first. Put the O-ring on the male ring, start the female ring
// with its tab at the male ring's nub and turn it clockwise, about a quarter
// turn: the latch should click, the tabs line up and the O-ring hide in the
// bore. The rings carry the same lock as the enclosure, so the pin and the
// screw can be tried too (the nut is optional here).
TT_FL = FL_T;
module thread_test_male() difference() {
  union() {
    translate([0, 0, -TT_FL]) cylinder(r = R_OUT, h = TT_FL, $fn = FN);
    lower_lock(0);
    nub(NUB_A_BASE, -TT_FL, 0, false);
    male_spigot();
  }
  translate([0, 0, -TT_FL - 1]) cylinder(r = R_C - 3, h = TT_FL + 2, $fn = FN);
  lower_lock_cuts(0);
}
module thread_test_female() difference() {
  union() {
    cylinder(r = R_OUT, h = FEM_TOP + 3, $fn = FN);
    upper_lock(0);
    drip_lip();
  }
  female_cut();
  translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 10, $fn = FN);
  upper_lock_cuts(0);
}
// insert holes, a nut pocket and a bolt-head pocket, to check the fits
module fit_test() {
  m3 = [4.1, 4.3, 4.5];  m2 = [3.0, 3.1, 3.2];  m2_txt = ["3.0", "3.1", "3.2"];
  difference() {
    cube([92, 18, 9]);
    for (i = [0 : 2]) {
      translate([8 + i*12, 7, 1.5]) cylinder(d = m3[i], h = 9);
      translate([48 + i*8, 7, 9 - M2_HOLE_DEPTH]) cylinder(d = m2[i], h = M2_HOLE_DEPTH + 1);
      translate([8 + i*12, 14.5, 8]) linear_extrude(height = 1.01)
        text(str(m3[i]), size = 3, halign = "center", valign = "center");
      translate([48 + i*8, 14.5, 8]) linear_extrude(height = 1.01)
        text(m2_txt[i], size = 2.4, halign = "center", valign = "center");
    }
    translate([76, 7, 9 - LOCKNUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = LOCKNUT_H + 1, $fn = 6);
    translate([76, 7, -1]) cylinder(d = M3_CLEAR, h = 11);
    translate([86, 7, -1]) rotate(30) cylinder(d = BOLT_HEAD_AF/cos(30), h = 3.4, $fn = 6);
    translate([86, 7, -1]) cylinder(d = M3_CLEAR, h = 11);
    translate([76, 14.5, 8]) linear_extrude(height = 1.01) text("nut", size = 2.4, halign = "center", valign = "center");
    translate([86, 14.5, 8]) linear_extrude(height = 1.01) text("bolt", size = 2.4, halign = "center", valign = "center");
    translate([86, 2.6, 8]) linear_extrude(height = 1.01) text("under", size = 1.8, halign = "center", valign = "center");
  }
}

// The bracket's pad in miniature: the pocket for the mount's round base and the
// three holes. Drop your panel mount in and push M3 screws through its holes
// before you print a whole bracket. The tab marks the top.
MT_T = 4;
module mount_test() difference() {
  union() {
    cylinder(d = PAD_D, h = MT_T, $fn = 120);
    translate([-13, PAD_D/2 - 6, 0]) cube([26, 17, 2]);
  }
  translate([0, 0, MT_T - MOUNT_POCKET]) cylinder(d = MOUNT_D, h = MOUNT_POCKET + 1, $fn = 120);
  for (a = MOUNT_HOLE_ANG) translate([MOUNT_BC/2*cos(a), MOUNT_BC/2*sin(a), -1]) cylinder(d = M3_CLEAR, h = MT_T + 2);
  translate([0, 0, -1]) cylinder(d = 24, h = MT_T + 2, $fn = 72);
  translate([0, PAD_D/2 + 5.2, 2 - 0.6]) linear_extrude(height = 1)
    text(str("UP ", MOUNT_HOLE_SPACING), size = 4.2, halign = "center", valign = "center");
}

// ============================== PREVIEW DUMMIES ==============================
CLR_SHELL = [0.93, 0.92, 0.88];
CLR_BRKT  = [0.35, 0.35, 0.33];
module cell_dummy() color([0.22, 0.42, 0.58]) translate([CELL_P[0], CELL_P[1], CELL_Z0]) cylinder(d = CELL_D, h = CELL_L);
module boards_dummy() {
  yb = -SO_H - PCB_T;   // boards' top faces
  // RAK19003 (notch in its lower edge, half-hole in its far edge), its USB-C and the cable's plug,
  // the RAK4631 core on top and a RAK1901 underneath
  color([0.15, 0.15, 0.15]) difference() {
    translate([RAK0[0], yb, RAK0[1]]) cube([RAK_SIZE[0], PCB_T, RAK_SIZE[1]]);
    translate([RAK0[0] + 15.5, yb - 1, RAK0[1] - 1]) cube([13, PCB_T + 2, 9]);
    translate([RAK0[0] + RAK_SIZE[0], yb - 1, RAK0[1] + 15]) rotate([-90, 0, 0]) cylinder(d = 2.7, h = PCB_T + 2, $fn = 16);
  }
  color("Silver") translate([RAK0[0] - 0.77, yb - 3.26, RAK0[1] + RAK_USB - 4.47]) cube([7.35, 3.26, 8.94]);
  color([0.1, 0.1, 0.1]) translate([RAK0[0] - 0.77 - 21, yb - 3.26/2 - 3.25, RAK0[1] + RAK_USB - 6.2]) cube([21, 6.5, 12.4]);
  color("White") translate([RAK0[0] + RAK_CORE[0], yb - 4.2, RAK0[1]]) cube([RAK_CORE[1] - RAK_CORE[0], 2.7, RAK_SIZE[1]]);
  color([0.1, 0.4, 0.2]) translate([RAK0[0] + 21, -SO_H + 0.01, RAK0[1] + 16]) cube([10, 3.5, 10]);
  // bq25185 with its USB-C and two JST sockets
  color([0.1, 0.25, 0.55]) translate([BQ0[0], yb, BQ0[1]]) cube([BQ_SIZE[0], PCB_T, BQ_SIZE[1]]);
  color("Silver") translate([BQ0[0] + 15.875 - 4.47, yb - 3.2, BQ0[1] + BQ_SIZE[1] - 6.75]) cube([8.94, 3.2, 7.35]);
  color("White") for (x = [11.43, 20.32]) translate([BQ0[0] + x - 4, yb - 4.5, BQ0[1]]) cube([8, 4.5, 6]);
  // MiniBoost and its inductor
  color([0.1, 0.25, 0.55]) translate([MB0[0], yb, MB0[1]]) cube([MB_SIZE[0], PCB_T, MB_SIZE[1]]);
  color([0.2, 0.2, 0.2]) translate([MB0[0] + 3.683 - 2.5, yb - 4.5, MB0[1] + 8.763 - 2.5]) cube([5, 4.5, 5]);
  // protection board
  color([0.15, 0.15, 0.15]) translate([-27, -2.5, 97]) cube([22, 2.5, 14]);
}
module ports_dummy() {
  color([0.1, 0.1, 0.1]) translate([VENT_P[0], VENT_P[1], 0.01]) cylinder(d = 18.5, h = 10);
  color([0.1, 0.1, 0.1]) translate([VENT_P[0], VENT_P[1], -FL_T - 1.8]) cylinder(d = 18, h = 3.79, $fn = 6);
  color([0.14, 0.14, 0.14]) translate([GLAND_P[0], GLAND_P[1], -FL_T - 16]) cylinder(d = 20, h = 15.99, $fn = 6);
  color([0.14, 0.14, 0.14]) translate([GLAND_P[0], GLAND_P[1], -GLAND_POCKET + 0.01]) cylinder(d = 21, h = 5, $fn = 6);
  color([0.9, 0.9, 0.9]) translate([GLAND_P[0], GLAND_P[1], -FL_T - 45]) cylinder(d = 3.5, h = 30);
  color("Gold") translate([SMA_P[0], SMA_P[1], -FL_T - 2.5]) cylinder(d = 9.2, h = 2.49, $fn = 6);
  color([0.08, 0.08, 0.08]) translate([SMA_P[0], SMA_P[1], -FL_T - 120]) cylinder(d = 12, h = 110);
  color("Gold") translate([SMA_P[0], SMA_P[1], -FL_T - 10.5]) cylinder(d = 9.2, h = 8, $fn = 6);
}
// the cell strap: across the sled's front behind the charger, through the side slots and round the cell
module cell_strap_dummy() color([0.12, 0.12, 0.12]) translate([0, 0, CS_Z[0] + (CS_LEN - 12.7)/2]) linear_extrude(height = 12.7)
  difference() {
    hull() { translate(CELL_P) circle(r = CELL_D/2 + 1.3); for (s = [-1, 1]) translate([s*(CS_X + 1.1) - 0.1, -1.3]) square([0.2, 5]); }
    hull() { translate(CELL_P) circle(r = CELL_D/2 + 0.05); for (s = [-1, 1]) translate([s*(CS_X - 1.1) - 0.1, 0]) square([0.2, 3.3]); }
  }
module oring_dummy() color([0.05, 0.05, 0.05]) translate([0, 0, G0 + OR_CS*1.12/2 + 0.02])
  rotate_extrude($fn = FN) translate([R_G + (R_B - R_G)/2, 0]) scale([(R_B - R_G)/OR_CS, 1.12]) circle(d = OR_CS, $fn = 24);
module lock_screw_dummy() color("Silver") rotate(LOCK_A) translate([LOCK_R, 0, 0]) {
  translate([0, 0, LUG_H]) cylinder(d = 7, h = 0.5);               // flat washer
  translate([0, 0, LUG_H + 0.5]) difference() {                    // split lock washer, pressed flat
    cylinder(d = 6.1, h = 0.8); translate([0, 0, -1]) cylinder(d = 3.2, h = 3); }
  translate([0, 0, LUG_H + 1.3]) cylinder(d = 5.5, h = 3);         // M3 x 20 head
  translate([0, 0, LUG_H + 1.3 - 20]) cylinder(d = 3, h = 20);
  translate([0, 0, -LOCK_NUT_TOP - (NUT_H - 2.4) - 2.4]) rotate(30) cylinder(d = 5.5/cos(30), h = 2.4, $fn = 6);
}
// the lock pin in its hole, the ring standing along the tab, flat side in
module lock_pin_dummy() color([0.75, 0.7, 0.6]) translate(pol(LOCK_R, PIN_A)) rotate(la(PIN_A))
  multmatrix([[0, 0, 1, -(PIN_W/2 - PIN_FLAT)], [0, 1, 0, 0], [-1, 0, 0, LUG_H], [0, 0, 0, 1]]) lock_pin();
module mount_dummy(v) color("WhiteSmoke") pad_frame(v) {   // round camera-style mount, approximate
  translate([0, 0, -MOUNT_POCKET]) cylinder(d = 55, h = 4, $fn = 72);
  translate([0, 0, 2]) cylinder(d1 = 40, d2 = 24, h = 8, $fn = 48);
  translate([0, 0, 10]) cylinder(d1 = 24, d2 = 20, h = KNUCKLE - MOUNT_POCKET - 10 - 6, $fn = 48);
  translate([0, 0, KNUCKLE - MOUNT_POCKET - 6]) cylinder(d = 20, h = 8, $fn = 48);
}
module panel_dummy(v) translate(knuckle_p(v)) rotate([PNL_TILT, 0, 0]) {
  color("WhiteSmoke") { cylinder(d = 22, h = 12); translate([-PNL[0]/2, -PNL[1]/2, 12]) cube(PNL); }
  color([0.05, 0.05, 0.07]) translate([-PNL[0]/2 + 5, -PNL[1]/2 + 5, 12 + PNL[2]]) cube([PNL[0] - 10, PNL[1] - 10, 0.6]);
}
module tree_screws_dummy(v, m) color("Silver") {   // [x, z, y of head underside, head d, shank d]
  for (p = concat([[0, rail_screw_z(v), Y_PF - DT_H + CB_DEPTH, 9.5, 4.8]], [[0, key_z(v), Y_BK - KEY_LIP, 9.5, 4.8]],
                  m == "tree" ? [[0, mount_hole(v, 90)[1], pocket_floor(v) - 4, 7, 3.5]] : [[0, extra_z(v), Y_PF + CB_DEPTH, 9.5, 4.8]]))
    translate([p[0], p[2], p[1]]) rotate([-90, 0, 0]) {
      translate([0, 0, -3.3]) cylinder(d = p[3], h = 3.3);
      cylinder(d = p[4], h = 70);
    }
}
module trunk() color([0.33, 0.25, 0.19]) translate([0, Y_BK + 250, -500]) cylinder(r = 250, h = 1300, $fn = 120);

// ================================ LAYOUTS ================================
function bv(v) = v == "C" ? "B" : v;    // C uses B's brackets, mount height and panel
function joints(v) = v == "A" ? [0] : v == "B" ? [ZJ_B] : [0, ZJ_C];
module upper(v) if (v == "A") top_a(); else lid_b();       // C: B's lid
module lower(v) if (v == "B") can_b(); else base_a();      // C: A's base
module upper_print(v) if (v == "A") top_a(); else translate([0, 0, -ZJ_B]) lid_b();
module lower_print(v) translate([0, 0, FL_T]) lower(v);
module assembly(v, m) {
  color(CLR_SHELL) upper(v);
  color(CLR_SHELL) lower(v);
  if (v == "C") color(CLR_SHELL) sleeve_c();
  color(CLR_BRKT) bracket(bv(v), m);
  color([0.75, 0.7, 0.6]) sled_assembled();
  color([0.75, 0.7, 0.6]) buttons_assembled();
  cell_dummy(); boards_dummy(); ports_dummy();
  for (z = joints(v)) translate([0, 0, z]) { oring_dummy(); lock_screw_dummy(); lock_pin_dummy(); }
  mount_dummy(bv(v)); panel_dummy(bv(v));
}
// Every printed part of one version, laid out apart. In Bambu Studio:
// right-click > Split > To objects, then put them on plates (see the build guide).
module kit(v, m) {
  translate([-75, 0]) upper_print(v);
  translate([75, 0]) lower_print(v);
  if (v == "C") translate([-225, 0]) sleeve_c();
  translate([215, 0]) rotate(90) translate([0, -(SL_Z0 + SL_Z1)/2, 0]) sled_flat();
  translate([330, -40]) mount_test();
  translate([-75, 200]) translate([0, 0, TT_FL]) thread_test_male();
  translate([75, 200]) thread_test_female();
  translate([160, 200]) fit_test();
  translate([290, 170]) buttons_print();
  for (i = [0 : len(joints(v)) - 1]) translate([290, 280 + i*20]) lock_pin();
  translate([0, 480]) bracket_print(bv(v), m);
  if (m == "wing" && wing_spacer_len(bv(v)) > 1) translate([200, 330, 0]) wing_spacers_print(bv(v));
}

// ================================ DISPATCH ================================
if (PART == "assembly") assembly(VERSION, MOUNT);
else if (PART == "kit") kit(VERSION, MOUNT);
else if (PART == "upper") { if (POSE == "print") upper_print(VERSION); else upper(VERSION); }
else if (PART == "lower") { if (POSE == "print") lower_print(VERSION); else lower(VERSION); }
else if (PART == "sleeve") sleeve_c();
else if (PART == "bracket") { if (POSE == "print") bracket_print(bv(VERSION), MOUNT); else bracket(bv(VERSION), MOUNT); }
else if (PART == "sled") { if (POSE == "print") sled_flat(); else sled_assembled(); }
else if (PART == "thread_test_male") { if (POSE == "print") translate([0, 0, TT_FL]) thread_test_male(); else thread_test_male(); }
else if (PART == "thread_test_female") thread_test_female();
else if (PART == "fit_test") fit_test();
else if (PART == "mount_test") mount_test();
else if (PART == "buttons") { if (POSE == "print") buttons_print(); else buttons_assembled(); }
else if (PART == "lock_pin") { if (POSE == "print") lock_pin(); else lock_pin_dummy(); }
else if (PART == "wing_spacers") wing_spacers_print(bv(VERSION));
