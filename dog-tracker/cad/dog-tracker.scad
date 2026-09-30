// =====================================================================
// MeshCore dog-collar tracker, design revision 2
// https://github.com/ksullivan86/meshcore (folder dog-tracker)
// Licensed CC BY-NC-SA 4.0 (see LICENSE). No commercial use without
// written permission from the author.
// ---------------------------------------------------------------------
// A small sealed pod that rides on a dog's collar or harness strap and
// holds a MeshCore tracker: a Seeed XIAO nRF52840 + Wio-SX1262 kit and a
// Seeed L76K GNSS module with its active patch antenna.
//
//   VERSION "swap": the battery is one lithium-ion cell, a 16340 or an
//     18350, in a printed barrel along one side of the pod. A screw cap
//     with an O-ring closes the barrel, so you swap the cell without
//     taking the pod off the collar.
//       + contact: a piece of nickel strip on the barrel's floor, sunk
//         behind a small ring so a cell put in backwards can't reach it.
//       - contact: a conical spring on a washer in the cap. The washer
//         floats on a small O-ring, and a post keeps both in the cap.
//         Closing the cap lands the washer on a second nickel strip that
//         folds over the barrel's end and runs back down a groove in the
//         bore; the O-ring keeps it pressed there even if the cap backs
//         off a little.
//     The barrel is its own part, printed standing up so its thread and
//     O-ring surfaces come out clean. It's glued into a trough in the pod.
//   VERSION "sealed": a LiPo pouch cell lives inside the pod. It's the
//     smallest build. Charge it through the magnetic port.
//
// Both pods have a magnetic charging port and close their electronics
// compartment with a push-in lid and one O-ring. The collar runs through
// two bridges at the ends of the pod and lies across the lid.
//
// Frame: X along the collar, Y across it, Z outward (away from the
// dog). z = 0 is the pod's back rim. Units mm. OpenSCAD 2021.01.
// =====================================================================

/* [What to make] */
PART = "kit";         // [kit, pod, lid, barrel, cap, fit_test, assembly, exploded]
VERSION = "swap";     // [swap, sealed]
// swap: the cell size the barrel takes
CELL = "16340";       // [16340, 18350, custom]
// sealed: your LiPo pouch cell (the 3040 family is 30 x 40 mm)
BATTERY = "603040";   // [503040, 603040, 803040, custom]
// width of the collar or harness strap
COLLAR = "1in";       // [3/4in, 1in, 1-1/4in, 1-1/2in, custom]
// print = laid out for the printer, assembled = where it sits on the collar
POSE = "print";       // [print, assembled]

/* [Your cell (CELL = custom)] */
// largest diameter, longest length and shortest length of the cells you'll use (mm)
CUSTOM_CELL = [17.0, 36.6, 33.5];

/* [Your pouch cell (BATTERY = custom)] */
// thickness, width, length, including the protection board and any tape
CUSTOM_POUCH = [6.2, 30.5, 44.0];

/* [Your collar (COLLAR = custom)] */
CUSTOM_STRAP_W = 25.4;
// room for the strap's thickness (most collars are 2 to 4 mm)
STRAP_T = 4.2;

/* [Swap: contacts] */
// the washer in the cap: outside diameter (0 = 20 mm for a 16340, 22.2 mm for an 18350)
WASHER_D = 0;
// its thickness
WASHER_T = 1.2;
// its hole: bigger than the post's head, smaller than the spring's narrow end
WASHER_HOLE = 5.0;
// the conical spring: narrow end outside diameter, wide end outside diameter, wire, free length
SPRING = [5.6, 10.0, 0.7, 12.0];
// how far the + contact sits below the ring round it; 0 makes it flush and turns off the guard against a reversed cell
KEEPER = 0.4;

/* [Hardware fit] */
// lid skirt to bore, per side (FDM bores print a little small)
LID_GAP = 0.20;
// cap thread to barrel thread, per side. It changes the cap only.
THREAD_GAP = 0.25;
// magnetic charge connector, device half: the opening (w x h). Anything up to this size fits; a smaller one is potted in flush.
POGO_FACE = [11.5, 5.0];
// its body (w x h x depth), for the stand-in only
POGO_BODY = [10.2, 4.6, 6.0];

/* [Hidden] */
$fa = 4; $fs = 0.35;
EPS = 0.01;
DUMMY = "";           // maintainer use: export a stand-in part for renders and checks
CAP_OPEN = 0;         // maintainer use: how far the cap is unscrewed in the assembly (mm)

// ------------------------------------------------------------ battery and collar
POUCH = BATTERY == "503040" ? [5.2, 30.5, 44.0]
      : BATTERY == "603040" ? [6.2, 30.5, 44.0]
      : BATTERY == "803040" ? [8.2, 30.5, 44.0]
      : CUSTOM_POUCH;                                // [T, W, L]
SC = CELL == "16340" ? [17.0, 36.6, 33.5]
   : CELL == "18350" ? [19.1, 39.9, 38.3]
   : CUSTOM_CELL;                                    // [D, L max, L min]
STRAP_W = COLLAR == "3/4in" ? 19.05 : COLLAR == "1in" ? 25.4
        : COLLAR == "1-1/4in" ? 31.75 : COLLAR == "1-1/2in" ? 38.1 : CUSTOM_STRAP_W;
TUN_W = STRAP_W + 1.0;    // strap tunnel width
STRIP_T = 3.0;            // bridge under the strap
STRIP_W = 5.0;            // bridge width along the collar

// ------------------------------------------------------------ shell and seal
WALL = 2.2;
T_FRONT = 1.6;            // outer (GNSS) face
SKIN = 1.2;               // outer face over the barrel
CF = 1.2;                 // 45 deg chamfer round the outer face
RB = 4.5;                 // bore corner radius
LID_PLATE = 1.6;
SKIRT_T = 1.8;
SKIRT_H = 5.4;
SKIRT_RI = RB - LID_GAP - SKIRT_T - 0.1;   // skirt's inside corner radius: keeps the wall behind the O-ring groove even (0.8 mm)
G_Z = [2.0, 3.9];         // O-ring groove band on the lid's skirt
G_D = 0.95;               // lid groove depth
LEAD_IN = 0.6;            // chamfer on the bore mouth
OR_CS = 1.5;              // both O-rings are 1.5 mm cross-section nitrile
OR_GLAND = 1.15;          // radial gland for the cap's O-ring: 23% squeeze

// ------------------------------------------------------------ electronics (mm)
XIAO_ENV = [22.6, 23.6];  // XIAO nRF52840 + Wio-SX1262 kit is 22 x 23 x 8
XIAO_BOX = [22, 23, 8];
PATCH = [18, 18, 6.5];    // L76K's active GNSS patch incl. its LNA board
PATCH_WELL = 19.4;
L76K = [21, 18, 4.0];     // L76K GNSS module for XIAO (18 x 21 board)
FPC = [28.5, 9.5];        // the kit's flexible LoRa antenna
STACK = 11.8;             // patch + coax + L76K behind the outer face

// =====================================================================
//                               helpers
// =====================================================================
module rr(w, h, r) {
    r2 = max(0.05, min(r, w / 2 - 0.01, h / 2 - 0.01));
    offset(r = r2) square([w - 2 * r2, h - 2 * r2], center = true);
}
module rrx(w, h, r, z0, z1) { translate([0, 0, z0]) linear_extrude(z1 - z0) rr(w, h, r); }
module box(x0, x1, y0, y1, z0, z1) {
    translate([min(x0, x1), min(y0, y1), min(z0, z1)])
        cube([abs(x1 - x0), abs(y1 - y0), abs(z1 - z0)]);
}
// rounded-rectangle prism with 45 deg chamfers (convex outline)
module cprism(w, h, r, z0, z1, cb = 0, ct = 0) {
    hull() {
        if (cb > 0) rrx(w - 2 * cb, h - 2 * cb, r - cb, z0, z0 + EPS);
        rrx(w, h, r, z0 + cb, z1 - ct);
        if (ct > 0) rrx(w - 2 * ct, h - 2 * ct, r - ct, z1 - EPS, z1);
    }
}
function rrlen(w, h, r) = 2 * (w + h) - 8 * r + 2 * PI * r;
function best_id(len) = round(len / 1.03 / PI);        // O-ring ID for about 3% stretch

// A thread: an n-start helix of trapezoid ridges with 45 deg flanks, built
// by twisting its cross-section. Every piece of thread made with the same
// numbers follows the same helix, so the cap's cutter lines up with the
// barrel's ridges wherever it starts. Right-hand: tighten clockwise.
function tprof(u, P, d) = let(w = (P - 2 * d) / 2, v = u - P * floor(u / P))
    v < w ? 0 : v < w + d ? v - w : v < 2 * w + d ? d : v < 2 * w + 2 * d ? 2 * w + 2 * d - v : 0;
module thread2d(r0, P, d, n, seg = 96) {
    L = n * P;
    polygon([for (i = [0 : seg - 1]) let(a = 360 * i / seg, r = r0 + tprof(a / 360 * L, P, d)) [r * cos(a), r * sin(a)]]);
}
module helix(r0, P, d, n, z0, z1) {
    L = n * P;
    translate([0, 0, z0]) rotate([0, 0, z0 * 360 / L])
        linear_extrude(height = z1 - z0, twist = -360 * (z1 - z0) / L, slices = max(2, ceil((z1 - z0) / L * 40)), convexity = 6)
            thread2d(r0, P, d, n);
}

// =====================================================================
//                    SWAP: barrel, cap and pod (derived)
// =====================================================================
W_D = WASHER_D > 0 ? WASHER_D : (CELL == "18350" ? 22.2 : 20.0);
W_T = WASHER_T;
W_HOLE = WASHER_HOLE;
NI = 0.15;                // nickel strip
NI_W = 5.6;               // groove and slots for 5 mm strip
CB = SC[0] + 0.4;         // cell bore
GR_D = 0.3;               // groove for the - strip, into the bore wall
T_END = 2.0;              // the barrel's floor
KR = [5.0, 6.8];          // ring round the + contact, radii
Z_RING = NI + KEEPER;     // top of that ring above the floor
BUTTON = 0.8;             // stand-in only: how far a cell's button top sticks out
// The cell stands on its button, on the + strip, so its - end is at NI + its
// length. The washer's face sits on the - strip, at Z_TIP + NI. The spring
// in between is half its free length tall with the longest cell, and longer
// with a shorter one.
H_SPR = SPRING[3] / 2;
Z_TIP = SC[1] + H_SPR;    // the barrel's end face (the - strip lies on it)
SP_ID = SPRING[0] - 2 * SPRING[2];       // the spring's narrow end, inside
B_WALL = 1.4;
B_R = CB / 2 + B_WALL;    // outside of the barrel, in the trough
FLAT = 0.6;               // flat on the outer-face side, keys it in the trough
// Thread root and O-ring groove floor: the washer passes the cap's thread with
// 0.3 mm a side, and the cap's O-ring is stretched at least 1.5%. The barrel is
// drawn for the default THREAD_GAP, so changing it changes the cap only.
R_ROOT_MIN = max(CB / 2 + 1.2, W_D / 2 + 0.3 - 0.25);
CAP_OR_ID = round(2 * R_ROOT_MIN / 1.03);
R_ROOT = max(R_ROOT_MIN, CAP_OR_ID / 2 * 1.015);
TH_D = 0.7;               // thread depth
TH_P = 2.0;               // ridge to ridge
TH_N = 2;                 // two starts: a 4 mm lead, about 1.3 turns to close
TH_L = TH_P * TH_N;
R_CREST = R_ROOT + TH_D;
R_SEAL = R_ROOT + OR_GLAND;              // the cap's bore, where the O-ring seals
R_FROOT = R_CREST + THREAD_GAP;          // root of the cap's thread
CAP_WALL = 1.3;
FLUTE = 0.35;             // depth of the grip flutes round the cap
R_CAP = R_SEAL + CAP_WALL;
L_TH = 5.0;
Z_TH0 = Z_TIP - L_TH;
OR_W = 2.0;               // O-ring groove width
Z_G1 = Z_TH0 - 0.8;
Z_G0 = Z_G1 - OR_W;
Z_RIM = Z_G0 - 0.9;       // the cap's rim, when it's tight
Z_FACE = Z_RIM - 0.6;     // the pod's face; the barrel steps out to the spigot here
// In the cap the washer floats on a 12 x 1.5 O-ring (the cushion) in a groove
// in the end wall. Closing the cap lands the washer on the - strip, then
// squeezes the cushion CU_SQ until the washer sits on the end wall. If the
// cap backs off, the cushion keeps the washer pressed on the strip.
CU_ID = 12;
CU_DEPTH = 1.2;           // groove depth behind the washer's seat: a whole number of 0.2 mm layers
CU_SQ = OR_CS - CU_DEPTH; // the cushion's squeeze when the cap is tight: 0.3 mm, 20%
CU_G = [CU_ID / 2 - 0.05, CU_ID / 2 + 2.15];   // its groove, inner and outer radius
// the post in the middle of the cap: it goes through the washer's hole, and
// its head keeps the spring's narrow end (and so the washer) in the cap. The
// head is a 0.4 mm band with a tip above it; once the spring is on, the tip
// is melted over the band with a soldering iron, so the spring can't come off.
POST = [SP_ID - 0.6, SP_ID + 0.2];             // neck and head diameters
CAP_END = 2.6;            // cap end wall behind the washer's seat
Z_CAP_TOP = Z_TIP + NI + W_T + CAP_END;

// pod layout. The barrel runs along Y at the -X side; the electronics
// compartment (closed by the lid) is on the +X side; the cap sits in a
// notch at the -X +Y corner, clear of the strap.
CAP_CLR = 0.3;
NOTCH_WALL = 2.0;         // wall between the cap's notch and the compartment
S_BX = 25.2;              // compartment bore
S_BY = 48.4;
X_OFF = R_CAP + CAP_CLR;              // barrel axis to the pod's -X edge
S_W = X_OFF + (X_OFF + NOTCH_WALL) + S_BX + WALL;
S_D = S_BY + 2 * WALL;
X_B = -S_W / 2 + X_OFF;               // barrel axis
X_D = X_B + X_OFF + NOTCH_WALL;       // compartment's -X face
X_C = X_D + S_BX / 2;                 // compartment centre
Z_B = B_R;                            // barrel axis height: its bottom is flush with the back
S_H = Z_B + B_R - FLAT + SKIN;
S_Z_FI = S_H - T_FRONT;               // inside of the outer face over the compartment
R_T = B_R + 0.15;                     // trough
POCKET = 4.0;                         // potting pocket behind the barrel's floor
// the battery wires' passage from the pocket into the compartment: a 3 x 1.6 mm
// slot, above the lid's skirt and below the L76K
WIRE_SLOT = [3.0, 1.6];
WIRE_HOLE_Z = SKIRT_H + 0.3 + WIRE_SLOT[1] / 2;
POCKET_R = min(4, POCKET);            // the pocket's outer corner is rounded, to keep the pod's corner thick
S_TAB_Y = [-S_BY / 4 + 4, S_BY / 4];  // the lid's stop tabs on the side walls: the -Y ones clear of the wire slot
// the barrel's floor, outside face: as far toward -Y as the potting pocket allows,
// but the cap's notch must start past the strap tunnel's side wall (2.2 mm)
Y_E = max(-S_BY / 2 + 3.4, TUN_W / 2 + 2.2 - (T_END + Z_FACE));
Y_F = Y_E + T_END + Z_FACE;           // the pod's face at the barrel
Y_CAPEND = Y_E + T_END + Z_CAP_TOP;
Z_BOT = -(STRAP_T + STRIP_T);

// =====================================================================
//                    SEALED: dimensions (derived)
// =====================================================================
A_BATT = [POUCH[2] + 0.5, POUCH[1], POUCH[0]];      // L (X), W (Y), T (Z)
A_BX = A_BATT[0] + 1.4 + 2 * (SKIRT_T + LID_GAP);
A_BY = A_BATT[1] + 1.4 + 2 * (SKIRT_T + LID_GAP);
A_FRONT = STACK;          // patch + coax + L76K stacked behind the outer face
A_H = LID_PLATE + (A_BATT[2] + 0.4) + A_FRONT + T_FRONT;
A_W = A_BX + 2 * WALL;
A_D = A_BY + 2 * WALL;
A_WB = A_BX + 2 * STRIP_W;
A_Z_FI = A_H - T_FRONT;

// =====================================================================
//                    O-ring numbers and checks
// =====================================================================
function lid_root_len(bx, by) = rrlen(bx - 2 * LID_GAP - 2 * G_D, by - 2 * LID_GAP - 2 * G_D, RB - LID_GAP - G_D);
BX = VERSION == "swap" ? S_BX : A_BX;
BY = VERSION == "swap" ? S_BY : A_BY;
LID_OR_ID = best_id(lid_root_len(BX, BY));
LID_STRETCH = lid_root_len(BX, BY) / (PI * LID_OR_ID) - 1;
GLAND = G_D + LID_GAP;
SQUEEZE = (OR_CS - GLAND) / OR_CS;
FILL = PI * OR_CS * OR_CS / 4 / (GLAND * (G_Z[1] - G_Z[0]));
CAP_STRETCH = R_ROOT / (CAP_OR_ID / 2) - 1;
CAP_SQUEEZE = (OR_CS - OR_GLAND) / OR_CS;
CAP_FILL = PI * OR_CS * OR_CS / 4 / (OR_GLAND * OR_W);
CU_FILL = PI * OR_CS * OR_CS / 4 / (CU_DEPTH * (CU_G[1] - CU_G[0]));
function pct(x) = round(x * 1000) / 10;
function r1(x) = round(x * 10) / 10;

echo(str("r2: VERSION ", VERSION, VERSION == "swap" ? str(", CELL ", CELL, " ", SC) : str(", BATTERY ", BATTERY, " ", POUCH),
         ", strap ", STRAP_W, " mm"));
if (VERSION == "swap") {
    echo(str("r2: pod ", r1(S_W), " x ", r1(max(S_D / 2, Y_CAPEND) + S_D / 2), " x ", r1(S_H), " mm, ",
             r1(S_W + 2 * STRIP_W), " mm long at the collar bridges; cap ", r1(2 * R_CAP), " mm across"));
    echo(str("r2: barrel ", r1(T_END + Z_TIP), " mm long; cell bore ", CB, " mm; washer ", W_D, " x ", W_T,
             " mm; spring ", SPRING, ": ", H_SPR, " mm tall (squeezed ", r1(SPRING[3] - H_SPR), " mm) with a ", SC[1],
             " mm cell, ", r1(H_SPR + SC[1] - SC[2]), " mm (squeezed ", r1(SPRING[3] - H_SPR - SC[1] + SC[2]), " mm) with a ", SC[2], " mm one"));
    echo(str("r2: cap O-ring ", CAP_OR_ID, " x ", OR_CS, " mm: stretch ", pct(CAP_STRETCH),
             "%, squeeze ", pct(CAP_SQUEEZE), "%, groove fill ", pct(CAP_FILL), "%; cushion O-ring ", CU_ID, " x ", OR_CS,
             " mm: squeeze ", pct(CU_SQ / OR_CS), "% with the cap tight, groove fill ", pct(CU_FILL), "%"));
} else {
    echo(str("r2: pod ", A_W, " x ", A_D, " x ", A_H, " mm, ", A_WB, " mm long at the collar bridges"));
}
echo(str("r2: lid O-ring ", LID_OR_ID, " x ", OR_CS, " mm: stretch ", pct(LID_STRETCH),
         "%, squeeze ", pct(SQUEEZE), "%, groove fill ", pct(FILL), "%"));
// numbers for cad/tools/check.py
if (VERSION == "swap")
    echo(str("r2check: {\"X_B\": ", X_B, ", \"Y_E\": ", Y_E, ", \"Z_B\": ", Z_B, ", \"X_D\": ", X_D,
             ", \"POCKET\": ", POCKET, ", \"WIRE_HOLE_Z\": ", WIRE_HOLE_Z, ", \"S_BY\": ", S_BY,
             ", \"POGO_FACE\": ", POGO_FACE, ", \"POGO_BODY\": ", POGO_BODY, ", \"WIRE_SLOT\": ", WIRE_SLOT,
             ", \"POCKET_WALL\": ", POCKET_WALL, ", \"LID_CORNER_WALL\": ", LID_CORNER_WALL, "}"));

assert(LID_STRETCH > 0.01 && LID_STRETCH < 0.06, "lid O-ring stretch out of range");
assert(SQUEEZE > 0.15 && SQUEEZE < 0.30, "lid O-ring squeeze out of range");
assert(FILL < 0.86, "lid O-ring groove too full");
assert(CAP_STRETCH > 0.01 && CAP_STRETCH < 0.06, "cap O-ring stretch out of range");
assert(CAP_FILL < 0.86, "cap O-ring groove too full");
assert(TUN_W <= (VERSION == "swap" ? S_D : A_D) - 6, "strap too wide for this pod");
assert(R_SEAL >= R_FROOT, "THREAD_GAP too big: the cap's thread is wider than its seal bore");
assert(W_D / 2 >= CB / 2 + NI + 0.45, "washer too small: it won't reach the - strip on the barrel's end");
assert(W_D / 2 + 0.15 <= R_ROOT + THREAD_GAP, "THREAD_GAP too small: the washer won't pass the cap's thread");
assert(H_SPR + SC[1] - SC[2] <= SPRING[3] - 2.5, "cells too different in length for the spring");
assert(POST[1] <= W_HOLE - 0.3, "the washer's hole is too small for the post (or the spring's narrow end is too big)");
assert(CU_G[1] <= W_D / 2 - 1.0, "washer too small for the cushion O-ring");
assert(CU_FILL < 0.86, "cushion O-ring groove too full");
assert(Y_F > Y_E + T_END + 20, "barrel too short for the pod");
// the thinnest walls the file controls
LID_CORNER_WALL = (RB - LID_GAP - G_D) - sqrt(2) * abs(SKIRT_T + SKIRT_RI - (RB - LID_GAP)) - SKIRT_RI;
assert(LID_CORNER_WALL >= 0.8 && SKIRT_T - G_D >= 0.8, "lid skirt too thin behind the O-ring groove");
PC = [-S_W / 2 + RB + WALL, -S_D / 2 + RB + WALL];              // centre of the pod's outside corner by the pocket
PA = [X_B - R_T + POCKET_R, Y_E - POCKET + POCKET_R];            // centre of the pocket's rounded corner
POCKET_WALL = min(X_B - R_T + S_W / 2, Y_E - POCKET + S_D / 2,
                  (PA[0] < PC[0] && PA[1] < PC[1]) ? RB + WALL - norm(PA - PC) - POCKET_R : 99)
              - max(0, (Z_B + B_R - FLAT + 0.15) - (S_H - CF));
assert(VERSION != "swap" || POCKET_WALL >= 1.0, "the potting pocket comes too close to the pod's outside");
assert(W_HOLE <= SPRING[0] - 0.3, "the washer's hole is so big the spring's narrow end could drop through it");
assert(VERSION != "swap" || Y_E - POCKET / 2 + WIRE_SLOT[0] / 2 < S_TAB_Y[0] - 3 - 0.5, "the wire slot runs into the lid's stop tab: strap too wide");
assert(VERSION != "swap" || SKIRT_H + 0.3 + POGO_FACE[1] <= S_Z_FI - XIAO_BOX[2] - 0.1,
       "POGO_FACE too tall: the magnetic connector would reach the XIAO");

// =====================================================================
//                    electronics positions
// =====================================================================
// swap compartment: patch at the -Y end, XIAO kit at the +Y end, the
// magnetic port in the +Y end wall under the XIAO, antenna on the +X wall
S_PATCH_C = [X_D + 0.6 + (PATCH_WELL + 2) / 2 + 0.9, -S_BY / 2 + 0.6 + (PATCH_WELL + 2) / 2];
S_XIAO0 = [X_D + 1.0, S_BY / 2 - 1.2 - XIAO_ENV[1]];
// centre of the opening in the +Y wall. Its bottom edge is above the lid's
// skirt and its top edge below the XIAO, so the connector can't be potted
// where either would hit it.
S_POGO_C = [X_C, S_D / 2, SKIRT_H + 0.3 + POGO_FACE[1] / 2];
S_FPC = [X_D + S_BX - 0.35, -FPC[0] / 2 + 2];                                   // x of its inner face, y start

// sealed head (as in the first prototype)
A_XIAO0 = [-A_BX / 2 + 1.0, -A_BY / 2 + 1.0];
A_PATCH_C = [A_XIAO0[0] + 24 + 1.2 + (PATCH_WELL + 2) / 2, A_XIAO0[1] + 24 / 2];
A_POGO_C = [-15.5, (A_XIAO0[1] + 24 + A_BY / 2) / 2];

// =====================================================================
//                               shared parts
// =====================================================================
// L-shaped corner posts that locate a board against the outer face
module corner_guides(x0, y0, ex, ey, z_fi, h = 3.0, t = 1.0, leg = 3.5) {
    for (c = [[x0, -1], [x0 + ex, 1]], d = [[y0, -1], [y0 + ey, 1]]) {
        cx = c[0]; sx = c[1]; cy = d[0]; sy = d[1];
        box(cx, cx + sx * t, cy + sy * t, cy - sy * leg, z_fi - h, z_fi + EPS);
        box(cx + sx * t, cx - sx * leg, cy, cy + sy * t, z_fi - h, z_fi + EPS);
    }
}
module patch_well(c, z_fi, h = 1.5, t = 1.0) {
    translate([c[0], c[1], z_fi - h]) linear_extrude(h + EPS)
        difference() { rr(PATCH_WELL + 2 * t, PATCH_WELL + 2 * t, 1.2); rr(PATCH_WELL, PATCH_WELL, 0.4); }
}
// magnetic port through the outer face (sealed)
module pogo_frame(c, z_fi) {
    translate([c[0], c[1], z_fi - 3.0]) linear_extrude(3.0 + EPS)
        difference() { rr(POGO_FACE[0] + 2.4, POGO_FACE[1] + 2.4, 1.2); rr(POGO_FACE[0], POGO_FACE[1], 0.3); }
}
module pogo_cut(c, z_fi, H) {
    translate([c[0], c[1], z_fi - 3.2]) linear_extrude(H - z_fi + 3.2 + 1) rr(POGO_FACE[0], POGO_FACE[1], 0.3);
}
// magnetic port through the +Y end wall (swap): the opening, and two side
// rails behind it that hold the connector square while it's potted
module pogo_side_cut() {
    translate([S_POGO_C[0], S_D / 2 + 1, S_POGO_C[2]]) rotate([90, 0, 0])
        linear_extrude(WALL + 1 + 3.2) rr(POGO_FACE[0], POGO_FACE[1], 0.3);
}
module pogo_side_rails() {        // 45 deg on top, so they print (face down) without support
    for (s = [-1, 1]) {
        x = S_POGO_C[0] + s * (POGO_FACE[0] / 2 + 0.6);
        z0 = S_POGO_C[2] - POGO_FACE[1] / 2; z1 = S_POGO_C[2] + POGO_FACE[1] / 2;
        hull() {
            box(x - 0.6, x + 0.6, S_BY / 2 - 3.0, S_BY / 2 + EPS, z0, z1 - 3.0);
            box(x - 0.6, x + 0.6, S_BY / 2 - EPS, S_BY / 2 + EPS, z0, z1);
        }
    }
}
// volume swept by the lid skirt; nothing inside the pod may reach into it
module skirt_keepout(bx, by, margin = 0.3) {
    k = 2 * (LID_GAP + SKIRT_T);
    translate([0, 0, -1]) linear_extrude(SKIRT_H + 1.4)
        difference() { rr(bx + 6, by + 6, RB + 3); rr(bx - k - 2 * margin, by - k - 2 * margin, 0.7); }
}
// bore with a lead-in chamfer at the mouth, from z0 up to z_fi
module bore(bx, by, z0, z_fi) {
    rrx(bx, by, RB, z0, z_fi);
    hull() {
        rrx(bx + 2 * LEAD_IN, by + 2 * LEAD_IN, RB + LEAD_IN, z0, 0);
        rrx(bx, by, RB, LEAD_IN - EPS, LEAD_IN);
    }
}
// four 45 deg stop tabs that seat the lid skirt flush with the rim; on the
// long walls (sealed) or the side walls (swap)
module stop_tabs(bx, by, on_ends = false) {
    if (on_ends) for (yc = S_TAB_Y, s = [1, -1]) {
        xw = s * bx / 2;
        hull() {
            box(xw - s * 1.2, xw + s * 0.5, yc - 3, yc + 3, SKIRT_H, SKIRT_H + EPS);
            box(xw - s * EPS, xw + s * 0.5, yc - 3, yc + 3, SKIRT_H + 1.2 - EPS, SKIRT_H + 1.2);
        }
    }
    else for (xc = [-bx / 4, bx / 4], s = [1, -1]) {
        yw = s * by / 2;
        hull() {
            box(xc - 3, xc + 3, yw - s * 1.2, yw + s * 0.5, SKIRT_H, SKIRT_H + EPS);
            box(xc - 3, xc + 3, yw - s * EPS, yw + s * 0.5, SKIRT_H + 1.2 - EPS, SKIRT_H + 1.2);
        }
    }
}
// the push-in lid: plate, skirt, O-ring groove, pry notch at +X
module lid_plug(bx, by) {
    o = [bx - 2 * LID_GAP, by - 2 * LID_GAP, RB - LID_GAP];
    k = 2 * (LID_GAP + SKIRT_T);
    difference() {
        union() {
            rrx(o[0], o[1], o[2], 0, LID_PLATE);
            difference() {
                hull() {          // skirt with a 0.4 mm chamfer on top
                    rrx(o[0], o[1], o[2], 0, SKIRT_H - 0.4);
                    rrx(o[0] - 0.8, o[1] - 0.8, o[2] - 0.4, SKIRT_H - EPS, SKIRT_H);
                }
                rrx(bx - k, by - k, SKIRT_RI, -1, SKIRT_H + 1);
            }
        }
        difference() {
            rrx(o[0] + 6, o[1] + 6, o[2] + 3, G_Z[0], G_Z[1]);
            rrx(o[0] - 2 * G_D, o[1] - 2 * G_D, o[2] - G_D, G_Z[0] - 1, G_Z[1] + 1);
        }
        box(bx / 2 - 3.2, bx / 2 + 1, -3.5, 3.5, -1, 0.7);      // pry notch
    }
}
// collar bridges at both X ends of a pod W long and D wide, centred on the
// origin: a plate under the pod's end with the strap tunnel through it,
// flared at 45 deg up to the end wall. xin0 and xin1 are how far in (x)
// each plate may reach under the pod.
module bridges(W, D, R, xin0, xin1) {
    Wb = W + 2 * STRIP_W;
    for (s = [-1, 1]) {
        xin = s < 0 ? xin0 : xin1;
        difference() {
            union() {
                intersection() { rrx(Wb, D, R, Z_BOT, 0); box(xin, s * Wb, -D, D, Z_BOT - 1, 1); }
                hull() {
                    intersection() { rrx(Wb, D, R, -0.3, 0); box(xin, s * Wb, -D, D, -1, 1); }
                    intersection() { rrx(W, D, R, STRIP_W, STRIP_W + 0.01); box(xin - s * 0.8, s * W, -D, D, STRIP_W - 1, STRIP_W + 1); }
                }
            }
            box(-Wb, Wb, -TUN_W / 2, TUN_W / 2, -STRAP_T, 0);
            // 0.8 mm chamfers where the strap enters
            hull() {
                box(s * (Wb / 2 - EPS), s * (Wb / 2 + 1), -TUN_W / 2 - 0.8, TUN_W / 2 + 0.8, -STRAP_T - 0.8, -EPS);
                box(s * (Wb / 2 - 0.8), s * (Wb / 2 - 0.8 + EPS), -TUN_W / 2, TUN_W / 2, -STRAP_T, -EPS);
            }
        }
    }
}

// =====================================================================
//                               SWAP parts
// =====================================================================
// The barrel, in its own frame: axis z, floor at z = 0 (its outside face at
// -T_END), end face at Z_TIP. Local +x points at the compartment, local -y
// at the outer face.
module barrel() {
    difference() {
        union() {
            // the part in the trough: round, with a flat on the outer-face side
            intersection() {
                translate([0, 0, -T_END]) cylinder(r = B_R, h = T_END + Z_FACE + EPS);
                translate([-B_R - 1, -(B_R - FLAT), -T_END - 1]) cube([2 * B_R + 2, 2 * B_R + 2, Z_FACE + T_END + 2]);
            }
            // spigot: land, O-ring groove, land, thread
            translate([0, 0, Z_FACE]) cylinder(r = R_CREST, h = Z_G0 - Z_FACE);
            translate([0, 0, Z_G0 - EPS]) cylinder(r = R_ROOT, h = Z_G1 - Z_G0 + 2 * EPS);
            translate([0, 0, Z_G1]) cylinder(r = R_CREST, h = Z_TH0 - Z_G1);
            helix(R_ROOT, TH_P, TH_D, TH_N, Z_TH0 - EPS, Z_TIP);
        }
        // cell bore, with a small lead-in at the end face
        cylinder(d = CB, h = Z_TIP + 1);
        translate([0, 0, Z_TIP - 0.3]) cylinder(d1 = CB, d2 = CB + 0.6, h = 0.3 + EPS);
        // - strip: groove down the bore on +x, and on through the floor
        translate([CB / 2 - 0.3, -NI_W / 2, -T_END - 1]) cube([GR_D + 0.3, NI_W, Z_TIP + T_END + 2]);
        // + strip: slot through the floor, inside the ring
        translate([-3.2 - 0.3, -NI_W / 2, -T_END - 1]) cube([0.6, NI_W, T_END + 1 + EPS]);
        // mark the side the - strip is on, on the floor's outside face
        translate([CB / 2 - 3.2, 0, -T_END - 1]) linear_extrude(1.4) text("-", size = 4, halign = "center", valign = "center");
        translate([-6.5, 0, -T_END - 1]) linear_extrude(1.4) text("+", size = 3.2, halign = "center", valign = "center");
    }
    // ring round the + contact
    difference() {
        cylinder(r = KR[1], h = Z_RING);
        translate([0, 0, -1]) cylinder(r = KR[0], h = Z_RING + 2);
    }
}
// The cap, in its own frame: axis z, rim at z = 0. Tight on the barrel,
// its z = 0 sits at the barrel's Z_RIM.
module cap() {
    zt0 = Z_TH0 - Z_RIM;
    zt1 = Z_TIP - Z_RIM;
    zw = Z_TIP + NI - Z_RIM;              // washer's front face, cap tight (on the - strip)
    zwb = zw + W_T;                       // the washer's seat on the end wall
    ztop = zwb + CAP_END;
    zhu = zw - CU_SQ - SPRING[2] - 0.1;   // underside of the post's head
    hr = (POST[1] - POST[0]) / 2;
    difference() {
        union() {
            cylinder(r = R_CAP, h = ztop - 0.8);
            translate([0, 0, ztop - 0.8 - EPS]) cylinder(r1 = R_CAP, r2 = R_CAP - 0.8, h = 0.8 + EPS);
        }
        // grip: shallow flutes round the outside
        for (i = [0 : 17]) rotate([0, 0, i * 20 + 10])
            translate([R_CAP + 0.9 - FLUTE, 0, 1.0]) cylinder(r = 0.9, h = ztop - 2.2, $fn = 16);
        // seal bore, with a lead-in at the rim. It runs 0.6 mm past the start of the
        // barrel's thread, so the cap's ridges never bottom on the land below it:
        // what stops the cap is the washer, on the strip, reaching its seat.
        translate([0, 0, -1]) cylinder(r = R_SEAL, h = zt0 + 1.6);
        translate([0, 0, -EPS]) cylinder(r1 = R_SEAL + 0.6, r2 = R_SEAL, h = 0.6);
        // thread: the barrel's helix, grown by the clearance
        translate([0, 0, -Z_RIM]) helix(R_ROOT + THREAD_GAP, TH_P, TH_D, TH_N, Z_TH0 - 1.2, Z_TIP + 0.25);
        translate([0, 0, zt0 - 1.2]) cylinder(r = R_ROOT + THREAD_GAP, h = zt1 - zt0 + 1.45);
        // washer pocket: a loose fit, so the washer can float
        translate([0, 0, zt1]) cylinder(r = W_D / 2 + 0.25, h = zwb - zt1);
        // groove for the cushion O-ring, behind the washer
        translate([0, 0, zwb - EPS]) difference() {
            cylinder(r = CU_G[1], h = CU_DEPTH + EPS);
            translate([0, 0, -1]) cylinder(r = CU_G[0], h = CU_DEPTH + 2);
        }
    }
    // the post: through the washer's hole, with a head the spring's narrow end
    // screws past. 45 deg under the head, so it prints standing.
    translate([0, 0, zhu]) cylinder(d = POST[0], h = zwb - zhu + EPS);
    hull() {          // 45 deg under the head, then a 0.4 mm band
        translate([0, 0, zhu - EPS]) cylinder(d = POST[0], h = EPS);
        translate([0, 0, zhu - hr - 0.4]) cylinder(d = POST[1], h = hr + 0.4 - EPS);
    }
    hull() {          // the tip, melted over the band once the spring is on
        translate([0, 0, zhu - hr - 0.4 - EPS]) cylinder(d = POST[1], h = EPS);
        translate([0, 0, zhu - hr - 0.4 - (POST[1] / 2 - 1.2)]) cylinder(d = 2.4, h = EPS);
    }
}

// the potting pocket in plan, with its corner at the pod's outside corner rounded
module pocket2d() {
    intersection() {
        hull() {
            translate([X_B - R_T + POCKET_R, Y_E - POCKET + POCKET_R]) circle(r = POCKET_R);
            translate([X_B + R_T - 1, Y_E - POCKET]) square([1, POCKET]);
            translate([X_B - R_T, Y_E - EPS]) square([2 * R_T, EPS]);
        }
        translate([X_B - R_T, Y_E - POCKET]) square([2 * R_T, POCKET + EPS]);
    }
}
module swap_pod() {
    zt = Z_B + B_R - FLAT + 0.15;         // top of the trough (the barrel's flat)
    difference() {
        union() {
            cprism(S_W, S_D, RB + WALL, 0, S_H, 0, CF);
            bridges(S_W, S_D, RB + WALL, X_B - R_CREST - 0.3, S_W / 2 - WALL + 0.8);   // the -X plate stays clear of the barrel going in
        }
        // notch for the cap at the -X +Y corner, taking the -X bridge with it
        // (the bridge ends at the tunnel's side wall, so nothing hangs in the air
        // over the notch when the pod prints face down)
        box(-S_W, X_D - NOTCH_WALL, Y_F, S_D, Z_BOT - 1, S_H + 1);
        // clearance round the cap, through the bridge under it
        translate([X_B, Y_F + 0.3, Z_B]) rotate([-90, 0, 0]) cylinder(r = X_OFF, h = S_D);
        // compartment: bore for the lid, and a pry notch in the rim at +X
        translate([X_C, 0, 0]) bore(S_BX, S_BY, -1, S_Z_FI);
        box(X_D + S_BX - 0.2, X_D + S_BX + 1.3, -3.5, 3.5, -0.5, 1.0);
        // trough for the barrel: round up to its flat, open at the back
        intersection() {
            translate([X_B, Y_E - EPS, Z_B]) rotate([-90, 0, 0]) cylinder(r = R_T, h = S_D);
            box(X_B - R_T - 1, X_B + R_T + 1, -S_D, S_D, -1, zt);
        }
        box(X_B - R_T, X_B + R_T, Y_E - EPS, S_D, -1, Z_B);
        // potting pocket behind the barrel's floor, and the hole on into the
        // compartment. The hole runs 5 mm into the compartment, past its
        // rounded corner, so it opens fully however far toward the end the pocket is.
        translate([0, 0, -1]) linear_extrude(zt + 1) pocket2d();
        box(X_B, X_D + 5, Y_E - POCKET / 2 - WIRE_SLOT[0] / 2, Y_E - POCKET / 2 + WIRE_SLOT[0] / 2,
            WIRE_HOLE_Z - WIRE_SLOT[1] / 2, WIRE_HOLE_Z + WIRE_SLOT[1] / 2);
        // magnetic port through the +Y end wall
        pogo_side_cut();
        // battery sign on the outer face over the barrel: + goes in first, toward -Y
        translate([X_B, (Y_E + Y_F) / 2 - 2, S_H - 0.4]) linear_extrude(1) battery_sign();
    }
    translate([X_C, 0, 0]) stop_tabs(S_BX, S_BY, on_ends = true);
    difference() {
        union() {
            corner_guides(S_XIAO0[0], S_XIAO0[1], XIAO_ENV[0], XIAO_ENV[1], S_Z_FI);
            patch_well(S_PATCH_C, S_Z_FI);
            pogo_side_rails();
        }
        translate([X_C, 0, 0]) skirt_keepout(S_BX, S_BY);
        pogo_side_cut();
    }
}
// a battery outline along Y with its + end toward -Y, recessed in the outer face
module battery_sign(l = 22, w = 8.5, t = 0.8) {
    difference() {
        union() { rr(w, l, 1.2); translate([0, -l / 2 - 1.2]) square([w * 0.45, 2.6], center = true); }
        rr(w - 2 * t, l - 2 * t, 0.6);
    }
    translate([0, -l / 2 + 4.2]) { square([4.2, t], center = true); square([t, 4.2], center = true); }
    translate([0, l / 2 - 4.2]) square([4.2, t], center = true);
}
module swap_lid() { translate([X_C, 0, 0]) lid_plug(S_BX, S_BY); }

// barrel and cap in the pod's frame; open = how far the cap is unscrewed
module barrel_placed() { translate([X_B, Y_E + T_END, Z_B]) rotate([-90, 0, 0]) barrel(); }
module cap_placed(open = 0) {
    translate([X_B, Y_E + T_END, Z_B]) rotate([-90, 0, 0])
        translate([0, 0, Z_RIM + open]) rotate([0, 0, open * 360 / TH_L]) cap();
}

// =====================================================================
//                               SEALED pod
// =====================================================================
module sealed_body() {
    W = A_W; D = A_D; R = RB + WALL;
    difference() {
        union() {
            cprism(W, D, R, 0, A_H, 0, CF);
            bridges(W, D, R, -A_BX / 2 - 0.8, A_BX / 2 + 0.8);
        }
        bore(A_BX, A_BY, -1, A_Z_FI);
        pogo_cut(A_POGO_C, A_Z_FI, A_H);
        // pry notch in the rim at +X, reached through the collar opening
        box(A_BX / 2 - 0.2, A_BX / 2 + 1.3, -3.5, 3.5, -0.5, 1.0);
        // arrow on the outer face: points to the side the antenna sits on
        translate([4.5, A_BY / 2 - 4.0, A_H - 0.6]) linear_extrude(1)
            polygon([[-3.5, -2.5], [3.5, -2.5], [0, 2.5]]);
    }
    stop_tabs(A_BX, A_BY);
    difference() {
        union() {
            corner_guides(A_XIAO0[0], A_XIAO0[1], 24, 24, A_Z_FI);
            patch_well(A_PATCH_C, A_Z_FI);
            pogo_frame(A_POGO_C, A_Z_FI);
        }
        skirt_keepout(A_BX, A_BY);
        pogo_cut(A_POGO_C, A_Z_FI, A_H);
    }
}
module sealed_lid() { lid_plug(A_BX, A_BY); }

// =====================================================================
//                               fit test
// =====================================================================
// A short piece of barrel (8 mm of cell bore, the O-ring groove and the
// thread), standing on its cut end the way the barrel prints, plus a cap
// and a patch of wall with the magnetic port's opening.
module fit_spigot() {
    z0 = Z_FACE - 8;
    translate([0, 0, -z0]) intersection() {
        barrel();
        translate([-50, -50, z0]) cube([100, 100, 100]);
    }
}
// The barrel's floor with the ring round the + contact and 3 mm of bore, to
// check that your cell's button reaches the + strip (and a reversed cell doesn't)
module fit_keeper() {
    translate([0, 0, T_END]) intersection() {
        barrel();
        translate([-50, -50, -T_END - 1]) cube([100, 100, T_END + 1 + 3.0]);
    }
}
module fit_pogo() {       // stands on its edge like the pod's +Y wall
    h = POGO_FACE[1] + 7;
    difference() {
        union() {
            box(-POGO_FACE[0] / 2 - 5, POGO_FACE[0] / 2 + 5, 0, WALL, 0, h);
            box(-POGO_FACE[0] / 2 - 5, POGO_FACE[0] / 2 + 5, 0, 8, 0, 1.6);      // foot
            for (s = [-1, 1]) {
                x = s * (POGO_FACE[0] / 2 + 0.6);
                box(x - 0.6, x + 0.6, WALL - EPS, WALL + 3.0, 0, 3.5 + POGO_FACE[1]);
            }
        }
        translate([0, -1, 3.5 + POGO_FACE[1] / 2]) rotate([-90, 0, 0]) linear_extrude(WALL + 5) rr(POGO_FACE[0], POGO_FACE[1], 0.3);
    }
}

// =====================================================================
//                      stand-ins (for renders and checks)
// =====================================================================
module in_barrel() { translate([X_B, Y_E + T_END, Z_B]) rotate([-90, 0, 0]) children(); }
module dummy(name) {
    sw = VERSION == "swap";
    z_fi = sw ? S_Z_FI : A_Z_FI;
    if (sw) {
        c = [S_XIAO0[0] + XIAO_ENV[0] / 2, S_XIAO0[1] + XIAO_ENV[1] / 2];
        pc = S_PATCH_C;
        if (name == "xiao") box(c[0] - XIAO_BOX[0] / 2, c[0] + XIAO_BOX[0] / 2, c[1] - XIAO_BOX[1] / 2, c[1] + XIAO_BOX[1] / 2, z_fi - XIAO_BOX[2], z_fi);
        if (name == "patch") box(pc[0] - 9, pc[0] + 9, pc[1] - 9, pc[1] + 9, z_fi - PATCH[2], z_fi);
        if (name == "l76k") box(pc[0] - L76K[0] / 2, pc[0] + L76K[0] / 2, pc[1] - L76K[1] / 2, pc[1] + L76K[1] / 2, z_fi - STACK, z_fi - STACK + L76K[2]);
        if (name == "pogo") box(S_POGO_C[0] - POGO_BODY[0] / 2, S_POGO_C[0] + POGO_BODY[0] / 2, S_D / 2 - POGO_BODY[2], S_D / 2,
                                S_POGO_C[2] - POGO_BODY[1] / 2, S_POGO_C[2] + POGO_BODY[1] / 2);
        if (name == "fpc") box(S_FPC[0], S_FPC[0] + 0.3, S_FPC[1], S_FPC[1] + FPC[0], z_fi - 0.5 - FPC[1], z_fi - 0.5);
        // the cell stands on its button, on the + strip
        if (name == "cell" || name == "cell_short") in_barrel() translate([0, 0, NI]) {
            cylinder(d = 6.0, h = BUTTON + EPS);
            translate([0, 0, BUTTON]) cylinder(d = SC[0], h = (name == "cell" ? SC[1] : SC[2]) - BUTTON);
        }
        if (name == "washer") in_barrel() translate([0, 0, Z_TIP + NI]) difference() { cylinder(d = W_D, h = W_T); translate([0, 0, -1]) cylinder(d = W_HOLE, h = 5); }
        // the spring, squeezed by the longest cell: from the cell's - end to the washer
        if (name == "spring") in_barrel() translate([0, 0, Z_TIP + NI - H_SPR])
            difference() {
                cylinder(d1 = SPRING[1], d2 = SPRING[0], h = H_SPR - 0.02);
                translate([0, 0, -EPS]) cylinder(d1 = SPRING[1] - 2 * SPRING[2], d2 = SP_ID, h = H_SPR);
            }
        // the cushion O-ring in its groove in the cap, squeezed
        if (name == "cushion") in_barrel() translate([0, 0, Z_TIP + NI + W_T + 0.05]) difference() {
            cylinder(r = CU_G[1] - 0.05, h = CU_DEPTH - 0.1);
            translate([0, 0, -1]) cylinder(r = CU_G[0] + 0.05, h = CU_DEPTH + 2);
        }
        if (name == "strip_neg") in_barrel() {
            translate([CB / 2 + GR_D - NI, -2.5, -T_END - 3]) cube([NI, 5, Z_TIP + T_END + 3]);
            translate([CB / 2 + 0.1, -2.5, Z_TIP]) cube([R_ROOT - CB / 2 - 0.2, 5, NI]);
        }
        if (name == "strip_pos") in_barrel() {
            translate([-3.2 - 0.15, -2.5, 0]) cube([6, 5, NI]);
            translate([-3.2 - 0.15, -2.5, -T_END - 3]) cube([NI, 5, T_END + 3]);
        }
        if (name == "cap_oring") in_barrel() translate([0, 0, Z_G0 + 0.25]) difference() {
            cylinder(r = R_SEAL - 0.01, h = OR_W - 0.5); translate([0, 0, -1]) cylinder(r = R_ROOT + 0.01, h = 5); }
    } else {
        c = [A_XIAO0[0] + 12, A_XIAO0[1] + 12];
        pc = A_PATCH_C;
        if (name == "xiao") box(c[0] - XIAO_BOX[0] / 2, c[0] + XIAO_BOX[0] / 2, c[1] - XIAO_BOX[1] / 2, c[1] + XIAO_BOX[1] / 2, z_fi - XIAO_BOX[2], z_fi);
        if (name == "patch") box(pc[0] - 9, pc[0] + 9, pc[1] - 9, pc[1] + 9, z_fi - PATCH[2], z_fi);
        if (name == "l76k") box(pc[0] - 10.5, pc[0] + 10.5, pc[1] - 9, pc[1] + 9, z_fi - PATCH[2] - 1.5 - 3.5, z_fi - PATCH[2] - 1.5);
        if (name == "pogo") box(A_POGO_C[0] - POGO_BODY[0] / 2, A_POGO_C[0] + POGO_BODY[0] / 2, A_POGO_C[1] - POGO_BODY[1] / 2, A_POGO_C[1] + POGO_BODY[1] / 2, A_H - POGO_BODY[2], A_H);
        if (name == "fpc") box(-9.0, 19.5, A_BY / 2 - 0.35, A_BY / 2 - 0.05, z_fi - 10.0, z_fi - 0.5);
        if (name == "cell") box(-A_BATT[0] / 2, A_BATT[0] / 2, -A_BATT[1] / 2, A_BATT[1] / 2, LID_PLATE + 0.2, LID_PLATE + 0.2 + A_BATT[2]);
    }
    if (name == "oring") {
        bx = sw ? S_BX : A_BX; by = sw ? S_BY : A_BY;
        o = [bx - 2 * LID_GAP, by - 2 * LID_GAP, RB - LID_GAP];
        translate([sw ? X_C : 0, 0, G_Z[0] + 0.2]) linear_extrude(G_Z[1] - G_Z[0] - 0.4)
            difference() { rr(o[0] + 2 * LID_GAP, o[1] + 2 * LID_GAP, o[2] + LID_GAP); rr(o[0] - 2 * G_D, o[1] - 2 * G_D, o[2] - G_D); }
    }
    if (name == "strap") {
        W = sw ? S_W : A_WB;
        box(-W / 2 - 15, W / 2 + 15, -STRAP_W / 2, STRAP_W / 2, -3.0, -0.05);
    }
}

// =====================================================================
//                               layout
// =====================================================================
module pod_print() {        // outer face down
    if (VERSION == "swap") translate([0, 0, S_H]) rotate([180, 0, 0]) swap_pod();
    else translate([0, 0, A_H]) rotate([180, 0, 0]) sealed_body();
}
module lid_print() {        // plate down, centred
    if (VERSION == "swap") lid_plug(S_BX, S_BY); else sealed_lid();
}
module barrel_print() { translate([0, 0, T_END]) barrel(); }                       // floor down
module cap_print() { translate([0, 0, Z_CAP_TOP - Z_RIM]) rotate([180, 0, 0]) cap(); }   // end wall down
module kit() {
    if (VERSION == "swap") {
        translate([-S_W / 2 - 3, 0, 0]) rotate([0, 0, 90]) pod_print();
        translate([S_BY / 2 + 6, S_BX / 2 + 3, 0]) rotate([0, 0, 90]) lid_print();
        translate([S_BY / 2 + 2 + B_R, -R_CAP - 6, 0]) barrel_print();
        translate([S_BY / 2 + 2 + 2 * B_R + R_CAP + 4, -R_CAP - 6, 0]) cap_print();
    } else {
        translate([0, A_D / 2 + 4, 0]) pod_print();
        translate([0, -A_BY / 2 - 4, 0]) lid_print();
    }
}
module assembly(explode = 0) {
    if (VERSION == "swap") {
        swap_pod();
        translate([0, 0, -explode]) swap_lid();
        barrel_placed();
        cap_placed(explode > 0 ? 6 + 1.5 * explode : CAP_OPEN);
    } else {
        sealed_body();
        translate([0, 0, -explode]) sealed_lid();
    }
}
module fit_test() {
    fit_spigot();
    translate([2 * R_CAP + 4, 0, 0]) cap_print();
    translate([0, -R_CAP - 12, 0]) fit_pogo();
    translate([2 * R_CAP + 4, -R_CAP - 14, 0]) fit_keeper();
}

if (DUMMY != "") dummy(DUMMY);
else if (PART == "kit") kit();
else if (PART == "pod") { if (POSE == "print") pod_print(); else if (VERSION == "swap") swap_pod(); else sealed_body(); }
else if (PART == "lid") { if (POSE == "print") lid_print(); else if (VERSION == "swap") swap_lid(); else sealed_lid(); }
else if (PART == "barrel") { if (POSE == "print") barrel_print(); else barrel_placed(); }
else if (PART == "cap") { if (POSE == "print") cap_print(); else cap_placed(CAP_OPEN); }
else if (PART == "fit_test") fit_test();
else if (PART == "assembly") assembly(0);
else if (PART == "exploded") assembly(10);
