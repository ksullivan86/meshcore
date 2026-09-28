// =====================================================================
// Tahoe MeshCore solar repeater, design revision 7
// https://github.com/ksullivan86/meshcore
// Licensed CC BY-NC-SA 4.0 (see LICENSE). No commercial use without
// written permission from the author.
// ---------------------------------------------------------------------
// A round printed enclosure for a RAK4631 MeshCore repeater, a 15 Ah
// LiFePO4 cell and a small 5 V solar panel. It hangs on a printed tree
// bracket that also carries the panel's round camera-style mount.
//
// The enclosure has one joint. It closes with a quarter-turn thread
// that only fits one way round, so the sloped roof always faces away
// from the tree, and it seals with one O-ring (AS568-153) that sits in a
// groove on the lower part and presses against a smooth bore in the
// upper part. The O-ring seals sideways, so the thread only has to hold
// the parts together and turns by hand.
//
//   VERSION A (the main one): the top slides down onto the bracket's
//     dovetail rail and stays there. The base, with the cell, the boards
//     and every opening, screws up into it from below. To open it: lock
//     screw out, a quarter turn, lower the base.
//   VERSION B: a tall can slides down onto the rail and a short lid
//     screws on top. To open it: lock screw out, a quarter turn, lift the
//     lid off. The joint is higher up, so B is meant for milder weather.
//
//   MOUNT "tree": the panel mount's top hole takes a long wood screw
//     into the tree; its other two holes use M3 nuts sealed in the
//     bracket.
//   MOUNT "bolt": all three mount holes use sealed M3 nuts, and the
//     bracket gets its own screw above the mount. Works with straps too.
//   MOUNT "wing": M3 bolts sit in hex pockets on the back of the bracket
//     with their threads out the front, and wing nuts hold the mount, so
//     the panel comes off by hand. Extra screw above the mount as "bolt".
//
// Sealed nuts: the bracket (tree and bolt mounts) and the lower part's
// lock tab each hold a hex nut that goes in during a print pause. The
// heights are echoed below and listed in the build guide.
//
// Frame: Z up, joint at z = 0 (A) or z = ZJ_B (B), +Y toward the tree,
// -Y away from it (south). Units mm. Written for OpenSCAD 2021.01.
// =====================================================================

/* [What to make] */
PART    = "assembly"; // [assembly, kit, upper, lower, bracket, sled, thread_test_male, thread_test_female, fit_test, wing_spacers]
VERSION = "A";        // [A, B]
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
NUT_AF      = 5.8;    // pocket for an M3 hex nut, 5.5 across flats x 2.4
NUT_H       = 2.8;
BOLT_HEAD_AF = 5.7;   // pocket for an M3 hex bolt head (wing mount)
TREE_SCREW_D = 4.8;   // hole for the long #6 or #8 wood screw (tree-screw mount)

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

// ---------------------- lock: one M3 x 20 from the top ----------------------
LOCK_A  = -90;        // tabs at the front
LOCK_R  = 58.5;
LUG_W   = 12;
LUG_R1  = LOCK_R + LUG_W/2;
LUG_H   = 12;         // upper part's tab
LOCK_SLOT = 4;        // +- deg slot in the upper tab
LOCK_NUT_TOP = 4.4;   // sealed nut pocket top, below the lower tab's top face
NUB_A_TOP  = LOCK_A - TURN;   // A: base tab lines up here to go on
NUB_A_BASE = LOCK_A + TURN;   // B: lid tab lines up here to go on

// ------------------- openings in the floor, all facing down -------------------
VENT_P  = [-21, -20]; // M12 vent stands upside down inside; its nut sits in a hex pocket underneath
VENT_HOLE = 12.4;
VENT_NUT_AF = 16.4;
VENT_POCKET = FL_T - 3.0;
GLAND_P = [20, -21];  // 1/4" NPT cable gland, lock nut inside
GLAND_D = 14.3;
GLAND_POCKET_D = 24;
GLAND_POCKET = 2.0;
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
SL_X  = 30;
SL_T  = 3;
SL_Z0 = 3;
SL_Z1 = 128;
SL_FOOT = [26, -4.5];
SO_D = 6;
SO_H = 7;             // room for a RAK1901 sensor under the RAK19003
M2_HOLE_DEPTH = SO_H + SL_T - 0.8;
BQ0  = [-15.9, 64];   // Adafruit bq25185 #6091
BQ_HOLES = [[2.54, 2.54], [29.21, 2.54], [2.54, 22.86], [29.21, 22.86]];
MB0  = [8, 96];       // Adafruit MiniBoost #4654
MB_HOLE = [2.54, 15.24];
MB_REST = [8.9, 9.0];
RAK0 = [6, 43];       // RAK19003
RAK_HOLES = [[-17, 18], [7, 16], [-4, -5]];
function rak_xz(p) = [RAK0[0] - p[1], RAK0[1] + p[0]];

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
STRAP_REC = 2;        // recessed across the front, behind the enclosure
STRAPS_A = [106, 138];
STRAPS_B = [114, 146];
ZIPS_A = [20, 55, 90, 180];   // zip-tie slot pairs for the panel cable, +X side
ZIPS_B = [20, 60, 100, 190];
// panel mount pad
Z_PAD_A = 232;
Z_PAD_B = 242;
PAD_RAISE_B = 20;     // B's pad stands out 20 mm so the panel clears the lid coming off
PAD_D = 64;
MOUNT_POCKET = 2;
NUT_BACK = 7;         // sealed nut sits 7 mm behind the mount's pocket floor
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

OR_STRETCH = 2*R_G / OR_ID - 1;
OR_SQUEEZE = (OR_CS*(1 - OR_STRETCH/2) - (R_B - R_G)) / (OR_CS*(1 - OR_STRETCH/2));
OR_FILL = (PI*OR_CS*OR_CS/4) / (GW*(R_B - R_G));
echo(str("v7: O-ring stretch ", round(OR_STRETCH*1000)/10, " %, squeeze ", round(OR_SQUEEZE*1000)/10,
         " %, groove fill ", round(OR_FILL*100), " %; turn ", TURN, " deg; A roof back ", Z_TOPB,
         "; B lid back ", LID_TOPB));
echo(str("v7: pauses (print z of the pocket top): A base ", FL_T - LOCK_NUT_TOP, ", B can ", ZJ_B + FL_T - LOCK_NUT_TOP,
         ", bracket A ", print_z(pocket_floor("A") + NUT_BACK), ", bracket B ", print_z(pocket_floor("B") + NUT_BACK)));
echo(str("v7: wing-nut spacers: A ", round(max(0, wing_spacer_len("A"))*10)/10, " mm (0 = none), B ", round(wing_spacer_len("B")*10)/10, " mm"));
echo(str("v7: bracket length / bed diagonal: A tree ", zb1("A","tree") - ZB0, "/", bed_fit("A","tree"),
         ", A bolt ", zb1("A","bolt") - ZB0, "/", bed_fit("A","bolt"), ", B tree ", zb1("B","tree") - ZB0, "/", bed_fit("B","tree"),
         ", B bolt ", zb1("B","bolt") - ZB0, "/", bed_fit("B","bolt"), "; mount bolt circle ", MOUNT_BC));
assert(TH_S[TH_N] == 360, "thread ridge widths must add to 360");
assert(min(TH_SEG) >= 30.2, "narrowest ridge would overhang more than 41.5 deg");
assert(OR_STRETCH > 0.01 && OR_STRETCH < 0.04, "O-ring stretch outside 1 to 4 %");
assert(OR_SQUEEZE > 0.15 && OR_SQUEEZE < 0.30, "O-ring squeeze outside 15 to 30 %");
assert(R_B - (TH_RM + TH_E) >= 0.5, "thread crest must pass the O-ring bore");
assert(bed_fit("B", "bolt") <= 252, "B bracket too long for a 256 mm bed");
assert(MOUNT_BC/2 + NUT_AF/2/cos(30) < PAD_D/2 - 2, "mount holes too far out for the pad");
assert(OR_FILL < 0.85, "O-ring groove over 85 % full");
function on_layer(z) = abs(z/0.2 - round(z/0.2)) < 1e-6;
assert(on_layer(FL_T - LOCK_NUT_TOP) && on_layer(ZJ_B + FL_T - LOCK_NUT_TOP), "lock nut pocket not on a 0.2 mm layer");
assert(on_layer(print_z(pocket_floor("A") + NUT_BACK)) && on_layer(print_z(pocket_floor("B") + NUT_BACK)),
       "bracket nut pockets not on a 0.2 mm layer");

// ============================== HELPERS ==============================
// Thread surface: radius r + e*g(phi - 360*z/lead), one raised-cosine ridge per
// TH_SEG segment. Male and female share the phase, so they meet one way only.
function th_g(p) = let(q = p - 360*floor(p/360), i = max([for (k = [0 : TH_N - 1]) if (q >= TH_S[k]) k]))
  -cos(360*(q - TH_S[i])/(TH_S[i + 1] - TH_S[i]));
module kthread(r, z0, z1, dz = 0.4) {
  na = 360;
  nz = max(2, ceil((z1 - z0)/dz));
  pts = [for (k = [0 : nz]) for (i = [0 : na - 1])
           let(z = z0 + (z1 - z0)*k/nz, phi = 360*i/na, rho = r + TH_E*th_g(phi - 360*z/TH_LEAD))
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
  kthread(TH_RM + TH_CLR, G1 - 0.6, FEM_TOP + 0.37);   // no grid ring on the FEM_TOP plane
  translate([0, 0, -1]) cylinder(r = R_B, h = G1 + 1, $fn = FN);
  translate([0, 0, G1 - 0.001])
    cylinder(r1 = R_B, r2 = TH_RM + TH_CLR - TH_E, h = R_B - (TH_RM + TH_CLR - TH_E), $fn = FN);
  translate([0, 0, -0.01]) cylinder(r1 = R_B + TH_CH, r2 = R_B, h = TH_CH + 0.01, $fn = FN);
}
module drip_lip() rotate_extrude($fn = FN)
  polygon([[R_OUT - 1, 0], [R_OUT + LIP, 0], [R_OUT + LIP, LIP_E], [R_OUT - 1, LIP_E + LIP + 1]]);
module lug2d() rotate(LOCK_A) hull() {
  translate([LOCK_R, 0]) circle(d = LUG_W);
  translate([R_OUT - 4, -LUG_W/2]) square([1, LUG_W]);
}
module lug_gusset(zt) hull() {        // 45 deg underside for a tab that isn't on the bed
  translate([0, 0, zt - 0.01]) linear_extrude(height = 0.01) lug2d();
  translate([0, 0, zt - (LUG_R1 - R_OUT) - 1]) linear_extrude(height = 0.01)
    intersection() { lug2d(); circle(r = R_OUT - 1, $fn = FN); }
}
module nub(a, z0, z1, under = true) rotate(a) translate([R_OUT - 0.5, 0, 0]) {
  translate([0, 0, z0]) cylinder(d = 4, h = z1 - z0, $fn = 24);
  if (under) translate([0, 0, z0 - 2]) cylinder(d1 = 0.01, d2 = 4, h = 2.001, $fn = 24);   // 45 deg underside
}
module grip_ribs(z0, z1) for (a = [0 : 10 : 359]) if (abs(((a - LOCK_A + 540) % 360) - 180) > 16)
  rotate(a) hull() {   // 45 deg lower end, so a rib that starts off the bed prints clean
    translate([R_OUT - 0.2, 0, z0 + 2.6]) cylinder(d = 2.6, h = z1 - z0 - 2.6, $fn = 16);
    translate([R_OUT - 0.3, 0, z0]) cylinder(d = 0.2, h = z1 - z0, $fn = 8);
  }
module lock_slot() hull() for (b = [LOCK_A - LOCK_SLOT, LOCK_A + LOCK_SLOT])
  rotate(b) translate([LOCK_R, 0, -1]) cylinder(d = M3_CLEAR, h = LUG_H + 2);
// sealed nut in the lower part's tab; zt = the tab's top face (the joint)
module lock_nut(zt) rotate(LOCK_A) translate([LOCK_R, 0, 0]) {
  translate([0, 0, zt - LOCK_NUT_TOP - NUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = NUT_H, $fn = 6);
  translate([0, 0, zt - LOCK_NUT_TOP - NUT_H - 6]) cylinder(d = M3_CLEAR, h = LOCK_NUT_TOP + NUT_H + 7);
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
  // heat-set inserts for the sled's feet
  for (s = [-1, 1]) translate([s*SL_FOOT[0], SL_FOOT[1], SL_Z0 - 7.5]) cylinder(d = INSERT_D, h = 8.5);   // M3 x 8 or x 10
}

// ================================ VERSION A ================================
module top_a() difference() {
  union() {
    intersection() {
      cylinder(r = R_OUT, h = 300, $fn = FN);
      below_plane(ZA0 + W*SQ2);
    }
    linear_extrude(height = LUG_H) lug2d();
    drip_lip();
    nub(NUB_A_TOP, 0.001, 10, false);
    translate([-BLK_A_W/2, R_OUT - 6, 0]) cube([BLK_A_W, Y_PF - DT_CLR - (R_OUT - 6), BLK_A_TOP]);
  }
  intersection() {
    translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 300, $fn = FN);
    below_plane(ZA0);
  }
  female_cut();
  lock_slot();
  dt_channel(Y_PF - DT_CLR, -1, RAIL_A[1] + DT_CLR);
}
module base_a() difference() {
  union() {
    translate([0, 0, -FL_T]) cylinder(r = R_OUT, h = FL_T, $fn = FN);
    translate([0, 0, -FL_T]) linear_extrude(height = FL_T) lug2d();
    grip_ribs(-FL_T, -1);
    male_spigot();
    insides_mounts();
  }
  floor_cuts();
  lock_nut(0);
}

// ================================ VERSION B ================================
Z_SHOULDER = ZJ_B - FL_T - (R_DI - R_C);   // can narrows at 45 deg to the spigot opening
module can_b() difference() {
  union() {
    difference() {
      union() {
        translate([0, 0, -FL_T]) cylinder(r = R_OUT, h = FL_T + ZJ_B, $fn = FN);
        translate([0, 0, ZJ_B]) male_spigot();
        translate([0, 0, ZJ_B - FL_T]) linear_extrude(height = FL_T) lug2d();
        lug_gusset(ZJ_B - FL_T);
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
  lock_nut(ZJ_B);
  dt_channel(Y_PF - DT_CLR, -FL_T - 1, RAIL_B[1] + DT_CLR);
}
module lid_b() translate([0, 0, ZJ_B]) difference() {
  union() {
    intersection() {
      cylinder(r = R_OUT, h = 100, $fn = FN);
      below_lid_roof(LID_Z_IN + W/cos(LID_SLOPE));
    }
    linear_extrude(height = LUG_H) lug2d();
    drip_lip();
    grip_ribs(LIP_E + LIP + 1, 20);
  }
  intersection() {
    translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 100, $fn = FN);
    below_lid_roof(LID_Z_IN);
  }
  female_cut();
  lock_slot();
}

// ================================ SLED ================================
function standoffs() = concat(
  [for (h = BQ_HOLES) [BQ0[0] + h[0], BQ0[1] + h[1]]],
  [[MB0[0] + MB_HOLE[0], MB0[1] + MB_HOLE[1]]],
  [for (h = RAK_HOLES) rak_xz(h)]);
ZIP = [[-24, 40], [24, 40], [-24, 118], [24, 118],
       [-24, 62], [22, 62], [-20, 100], [-4, 100], [22, 92]];
module sled_assembled() {
  difference() {
    union() {
      translate([-SL_X, 0, SL_Z0]) cube([2*SL_X, SL_T, SL_Z1 - SL_Z0]);
      for (s = [-1, 1]) translate([s*SL_FOOT[0] - 5, -9, SL_Z0]) cube([10, 9 + 0.01, 3.5]);
      for (s = standoffs()) translate([s[0], 0.01, s[1]]) rotate([90, 0, 0]) cylinder(d = SO_D, h = SO_H + 0.01);
      translate([MB0[0] + MB_REST[0], 0.01, MB0[1] + MB_REST[1]]) rotate([90, 0, 0]) cylinder(d = 4, h = SO_H + 0.01);
    }
    for (s = standoffs()) translate([s[0], -SO_H - 0.01, s[1]]) rotate([-90, 0, 0]) cylinder(d = M2_INSERT_D, h = M2_HOLE_DEPTH + 0.01);
    for (s = [-1, 1]) translate([s*SL_FOOT[0], SL_FOOT[1], SL_Z0 - 1]) cylinder(d = M3_CLEAR, h = 6);
    for (z = ZIP) translate([z[0] - 2.1, -1, z[1] - 1]) cube([4.2, SL_T + 2, 2]);
  }
}
module sled_flat() translate([0, 0, SL_T]) rotate([-90, 0, 0]) sled_assembled();

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
      yhex(p[0], p[1], NUT_AF, fl + NUT_BACK, fl + NUT_BACK + NUT_H);        // sealed nut
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
    // strap channels across the front
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
// with its tab at the male ring's nub and turn a quarter turn: it should stop
// with the tabs lined up and the O-ring hidden in the bore.
TT_FL = 5;
module thread_test_male() difference() {
  union() {
    translate([0, 0, -TT_FL]) cylinder(r = R_OUT, h = TT_FL, $fn = FN);
    translate([0, 0, -TT_FL]) linear_extrude(height = TT_FL) lug2d();
    nub(NUB_A_BASE, -TT_FL, 0, false);
    male_spigot();
  }
  translate([0, 0, -TT_FL - 1]) cylinder(r = R_C - 3, h = TT_FL + 2, $fn = FN);
}
module thread_test_female() difference() {
  union() {
    cylinder(r = R_OUT, h = FEM_TOP + 3, $fn = FN);
    linear_extrude(height = LUG_H) lug2d();
    drip_lip();
  }
  female_cut();
  translate([0, 0, FEM_TOP]) cylinder(r = R_DI, h = 10, $fn = FN);
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
    translate([76, 7, 9 - NUT_H]) rotate(30) cylinder(d = NUT_AF/cos(30), h = NUT_H + 1, $fn = 6);
    translate([76, 7, -1]) cylinder(d = M3_CLEAR, h = 11);
    translate([86, 7, -1]) rotate(30) cylinder(d = BOLT_HEAD_AF/cos(30), h = 3.4, $fn = 6);
    translate([86, 7, -1]) cylinder(d = M3_CLEAR, h = 11);
    translate([76, 14.5, 8]) linear_extrude(height = 1.01) text("nut", size = 2.4, halign = "center", valign = "center");
    translate([86, 14.5, 8]) linear_extrude(height = 1.01) text("bolt", size = 2.4, halign = "center", valign = "center");
    translate([86, 2.6, 8]) linear_extrude(height = 1.01) text("under", size = 1.8, halign = "center", valign = "center");
  }
}

// ============================== PREVIEW DUMMIES ==============================
CLR_SHELL = [0.93, 0.92, 0.88];
CLR_BRKT  = [0.35, 0.35, 0.33];
module cell_dummy() color([0.22, 0.42, 0.58]) translate([CELL_P[0], CELL_P[1], CELL_Z0]) cylinder(d = CELL_D, h = CELL_L);
module boards_dummy() {
  color([0.15, 0.15, 0.15]) translate([RAK0[0] - 22, -SO_H - 1.6, RAK0[1] - 23]) cube([32, 1.6, 36]);
  color("White") translate([RAK0[0] - 14, -SO_H - 8, RAK0[1] - 18]) cube([20, 6.4, 26]);
  color([0.1, 0.4, 0.2]) translate([RAK0[0] - 8, -SO_H + 0.01, RAK0[1] - 20]) cube([10, 3.5, 10]);   // RAK1901
  color([0.1, 0.25, 0.55]) translate([BQ0[0], -SO_H - 1.6, BQ0[1]]) cube([31.75, 1.6, 25.4]);
  color([0.1, 0.25, 0.55]) translate([MB0[0], -SO_H - 1.6, MB0[1]]) cube([11.43, 1.6, 17.78]);
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
module oring_dummy() color([0.05, 0.05, 0.05]) translate([0, 0, G0 + OR_CS*1.12/2 + 0.02])
  rotate_extrude($fn = FN) translate([R_G + (R_B - R_G)/2, 0]) scale([(R_B - R_G)/OR_CS, 1.12]) circle(d = OR_CS, $fn = 24);
module lock_screw_dummy() color("Silver") rotate(LOCK_A) translate([LOCK_R, 0, 0]) {
  translate([0, 0, LUG_H]) cylinder(d = 7, h = 0.5);
  translate([0, 0, LUG_H + 0.5]) cylinder(d = 5.5, h = 3);
  translate([0, 0, LUG_H + 0.5 - 20]) cylinder(d = 3, h = 20);
  translate([0, 0, -LOCK_NUT_TOP - 0.4 - 2.4]) rotate(30) cylinder(d = 5.5/cos(30), h = 2.4, $fn = 6);
}
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
module upper(v) if (v == "A") top_a(); else lid_b();
module lower(v) if (v == "A") base_a(); else can_b();
module upper_print(v) if (v == "A") top_a(); else translate([0, 0, -ZJ_B]) lid_b();
module lower_print(v) translate([0, 0, FL_T]) lower(v);
module assembly(v, m) {
  color(CLR_SHELL) upper(v);
  color(CLR_SHELL) lower(v);
  color(CLR_BRKT) bracket(v, m);
  color([0.75, 0.7, 0.6]) translate([0, 0, 0]) sled_assembled();
  cell_dummy(); boards_dummy(); ports_dummy();
  translate([0, 0, v == "A" ? 0 : ZJ_B]) { oring_dummy(); lock_screw_dummy(); }
  mount_dummy(v); panel_dummy(v);
}
// Every printed part of one version, laid out apart. In Bambu Studio:
// right-click > Split > To objects, then put them on plates (see the build guide).
KIT_POS = [[-75, 0], [75, 0], [200, 0], [-75, 150], [75, 150], [190, 150], [0, 400]];
module kit(v, m) {
  translate(KIT_POS[0]) upper_print(v);
  translate(KIT_POS[1]) lower_print(v);
  translate(KIT_POS[2]) rotate(90) translate([0, -(SL_Z0 + SL_Z1)/2, 0]) sled_flat();
  translate(KIT_POS[3]) translate([0, 0, TT_FL]) thread_test_male();
  translate(KIT_POS[4]) thread_test_female();
  translate(KIT_POS[5]) translate([-46, -9, 0]) fit_test();
  translate(KIT_POS[6]) bracket_print(v, m);
  if (m == "wing" && wing_spacer_len(v) > 1) translate([250, 140, 0]) wing_spacers_print(v);
}

// ================================ DISPATCH ================================
if (PART == "assembly") assembly(VERSION, MOUNT);
else if (PART == "kit") kit(VERSION, MOUNT);
else if (PART == "upper") { if (POSE == "print") upper_print(VERSION); else upper(VERSION); }
else if (PART == "lower") { if (POSE == "print") lower_print(VERSION); else lower(VERSION); }
else if (PART == "bracket") { if (POSE == "print") bracket_print(VERSION, MOUNT); else bracket(VERSION, MOUNT); }
else if (PART == "sled") { if (POSE == "print") sled_flat(); else sled_assembled(); }
else if (PART == "thread_test_male") { if (POSE == "print") translate([0, 0, TT_FL]) thread_test_male(); else thread_test_male(); }
else if (PART == "thread_test_female") thread_test_female();
else if (PART == "fit_test") fit_test();
else if (PART == "wing_spacers") wing_spacers_print(VERSION);
