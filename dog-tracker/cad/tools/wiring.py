#!/usr/bin/env python3
"""Draws images/wiring.png, the wiring diagram in the build guide."""
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RED, BLK, BLU, GRN, GRY, ORG, PUR = '#D62728', '#222222', '#1F5FB0', '#2CA02C', '#8C8C8C', '#E3A21A', '#9467BD'


def block(ax, x, y, w, h, title, pins=(), side='right', fc='#F4F4F4', ec='#333333', sub=None):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle='round,pad=0.02,rounding_size=0.12', fc=fc, ec=ec, lw=1.4))
    ax.text(x + w / 2, y + h - 0.22, title, ha='center', va='top', fontsize=11, weight='bold')
    if sub:
        lines = title.count('\n') + 1
        ax.text(x + w / 2, y + h - 0.30 - 0.36 * lines, sub, ha='center', va='top', fontsize=8.3, color='#555555')
    out = {}
    n = len(pins)
    for i, name in enumerate(pins):
        py = y + 0.35 + (n - 1 - i) * 0.42 if n else y
        px = x + w if side == 'right' else x
        ax.text(px - 0.12 if side == 'right' else px + 0.12, py, name, ha='right' if side == 'right' else 'left', va='center', fontsize=9)
        ax.plot([px], [py], 'o', ms=4, color='#333333')
        out[name] = (px, py)
    return out


def wire(ax, a, b, color, lw=2.2, via=None):
    mid = via if via is not None else (a[0] + b[0]) / 2
    ax.plot([a[0], mid, mid, b[0]], [a[1], a[1], b[1], b[1]], color=color, lw=lw, solid_capstyle='round', solid_joinstyle='round')


fig, ax = plt.subplots(figsize=(15, 8.6), dpi=110)
ax.set_xlim(0, 16); ax.set_ylim(0.6, 10); ax.axis('off')

# --- the barrel (swap version): a sketch of the cell and its contacts
bx0, by0, bw, bh = 0.2, 5.3, 5.2, 4.4
ax.add_patch(FancyBboxPatch((bx0, by0), bw, bh, boxstyle='round,pad=0.02,rounding_size=0.15', fc='#EAF2F8', ec='#3C8DBC', lw=1.2, ls='--'))
ax.text(bx0 + 0.2, by0 + bh - 0.15, 'BARREL (swap version)', fontsize=9, color='#2E6F95', weight='bold', va='top')
# cell body, + end on the left (the barrel's floor), - end on the right (the cap)
cy = 7.6
ax.add_patch(FancyBboxPatch((1.25, cy - 0.55), 2.3, 1.1, boxstyle='round,pad=0.01,rounding_size=0.08', fc='#C9CFD6', ec='#555555', lw=1.2))
ax.add_patch(FancyBboxPatch((1.05, cy - 0.2), 0.2, 0.4, boxstyle='round,pad=0.0,rounding_size=0.03', fc='#C9CFD6', ec='#555555', lw=1.2))
ax.text(2.4, cy, '16340 or 18350\nprotected, button top', ha='center', va='center', fontsize=8.3)
ax.text(1.12, cy + 0.35, '+', ha='center', va='bottom', fontsize=12, weight='bold', color=RED)
# + strip on the floor
ax.plot([0.85, 0.85], [cy - 0.45, cy + 0.45], color=RED, lw=3)
ax.text(0.62, cy + 0.62, '+ strip on the\nbarrel\'s floor', fontsize=7.5, ha='left', va='bottom', color=RED)
# spring, washer, cap
xs = [3.55 + 0.1 * i for i in range(7)]
ax.plot(xs, [cy + (0.35 if i % 2 else -0.35) * (1 - i / 9) for i in range(7)], color='#666666', lw=1.5)
ax.plot([4.25, 4.25], [cy - 0.75, cy + 0.75], color='#8C96A0', lw=5)
ax.text(4.25, cy + 0.85, 'washer, on a small\nO-ring in the cap', fontsize=7.5, ha='center', va='bottom', color='#555555')
ax.add_patch(plt.Circle((4.52, cy + 0.45), 0.09, fc='none', ec='#555555', lw=1.2))
ax.add_patch(plt.Circle((4.52, cy - 0.45), 0.09, fc='none', ec='#555555', lw=1.2))
ax.text(3.85, cy - 0.62, 'spring', fontsize=7.5, ha='center', va='top', color='#555555')
# - strip: folded over the barrel's end, runs back along the bore
ax.plot([4.1, 4.1, 0.95], [cy - 0.9, cy - 1.05, cy - 1.05], color=BLK, lw=2.2)
ax.plot([4.1, 4.1], [cy - 0.75, cy - 0.9], color=BLK, lw=2.2)
ax.text(2.5, cy - 1.18, '- strip: pressed by the washer, runs back down the bore', fontsize=7.5, ha='center', va='top')
# tails through the floor into the potting pocket
ax.plot([0.85, 0.5, 0.5], [cy, cy, 5.85], color=RED, lw=2.2)
ax.plot([0.95, 0.35, 0.35], [cy - 1.05, cy - 1.05, 5.65], color=BLK, lw=2.2)
ax.text(0.62, 5.55, 'tails through the floor,\nsoldered to wires, potted', fontsize=7.5, ha='left', va='top', color='#333333')
batp, batn = (0.5, 5.85), (0.35, 5.65)

# --- the pod
ax.add_patch(FancyBboxPatch((5.8, 0.8), 10.0, 8.9, boxstyle='round,pad=0.02,rounding_size=0.15', fc='#FDF3EA', ec='#F07F2A', lw=1.2, ls='--'))
ax.text(6.0, 9.55, 'COMPARTMENT (both versions)', fontsize=9, color='#C0601A', weight='bold', va='top')
xiao = block(ax, 9.6, 3.0, 2.9, 5.9, 'XIAO nRF52840\n+ Wio-SX1262 kit', [], sub=None)
pins_l, pins_r = {}, {}
for i, n in enumerate(['BAT+', 'BAT-', '5V', 'GND']):
    py = 7.3 - i * 0.6
    ax.plot([9.6], [py], 'o', ms=4, color='#333333')
    ax.text(9.72, py, n, ha='left', va='center', fontsize=9)
    pins_l[n] = (9.6, py)
for i, n in enumerate(['3V3', 'GND', 'D7 (RX)', 'D6 (TX)', 'D0']):
    py = 7.3 - i * 0.6
    ax.plot([12.5], [py], 'o', ms=4, color='#333333')
    ax.text(12.38, py, n, ha='right', va='center', fontsize=9)
    pins_r[n] = (12.5, py)
ax.text(11.05, 3.25, 'U.FL (LoRa)', fontsize=8.5, ha='center', color='#555555')
# battery wires come in through the potted hole
wire(ax, batp, pins_l['BAT+'], RED, via=8.3)
wire(ax, batn, pins_l['BAT-'], BLK, via=8.5)
ax.text(7.0, 5.1, 'through the potted\nhole from the barrel', fontsize=7.5, ha='center', va='top', color='#555555')
# PTC fuse in the red wire (swap, recommended)
fy = pins_l['BAT+'][1]
ax.add_patch(FancyBboxPatch((8.72, fy - 0.13), 0.5, 0.26, boxstyle='round,pad=0.0,rounding_size=0.05', fc='white', ec=RED, lw=1.4))
ax.text(8.97, fy + 0.2, 'PTC fuse', fontsize=7.5, ha='center', va='bottom', color=RED)
# capacitor across BAT+ and BAT- (swap, recommended)
cx = 9.25
ax.plot([cx, cx], [pins_l['BAT+'][1], pins_l['BAT+'][1] - 0.2], color=RED, lw=1.4)
ax.plot([cx, cx], [pins_l['BAT-'][1], pins_l['BAT-'][1] + 0.2], color=BLK, lw=1.4)
ax.plot([cx - 0.14, cx + 0.14], [pins_l['BAT+'][1] - 0.2] * 2, color='#333333', lw=2)
ax.plot([cx - 0.14, cx + 0.14], [pins_l['BAT-'][1] + 0.2] * 2, color='#333333', lw=2)
ax.text(cx - 0.2, (pins_l['BAT+'][1] + pins_l['BAT-'][1]) / 2, '220 µF', fontsize=7.5, ha='right', va='center', color='#333333')
ax.text(cx + 0.2, pins_l['BAT+'][1] - 0.2, '+', fontsize=9, ha='left', va='center', color=RED, weight='bold')

pogo = block(ax, 6.1, 1.0, 1.7, 1.9, 'Magnetic\nport', ['+', '-'], sub='swap: end wall\nsealed: outer face')
wire(ax, pogo['+'], pins_l['5V'], ORG, via=8.8)
wire(ax, pogo['-'], pins_l['GND'], BLK, via=9.1)

# the L76K's pins line up with the XIAO pins they go to, so every wire is straight
block(ax, 13.4, 4.2, 2.1, 4.7, 'L76K GNSS', [], side='left', sub=None)
ax.text(14.45, 4.45, 'no header sockets', ha='center', va='bottom', fontsize=8.3, color='#555555')
for (name, pin, col) in (('VCC', '3V3', RED), ('GND', 'GND', BLK), ('TX', 'D7 (RX)', BLU),
                         ('RX', 'D6 (TX)', GRN), ('WAKE', 'D0', PUR)):
    y = pins_r[pin][1]
    ax.plot([13.4], [y], 'o', ms=4, color='#333333')
    ax.text(13.52, y, name, ha='left', va='center', fontsize=9)
    ax.plot([12.5, 13.4], [y, y], color=col, lw=1.8, solid_capstyle='round')
patch = block(ax, 13.4, 1.0, 2.1, 1.8, 'GNSS patch', [], sub='active, U.FL,\nceramic to\nthe face')
ax.plot([14.45, 14.45], [2.8, 3.9], color=GRY, lw=1.6, ls=':')
ant = block(ax, 9.85, 1.0, 2.4, 1.6, 'LoRa antenna', [], sub='FPC, U.FL')
ax.plot([11.05, 11.05], [2.6, 3.0], color=GRY, lw=1.6, ls=':')

ax.text(0.3, 4.3, 'Sealed version: no barrel.\nThe LiPo\'s red and black\nleads go straight to\nBAT+ and BAT-.', fontsize=9, va='top', ha='left', color='#333333')
ax.text(0.3, 2.3, 'red +   black -   orange 5 V\nblue, green: serial (TX to RX)\npurple: GNSS standby\n\nSwap version: the PTC fuse and\nthe capacitor are part of the build.\n\nLeave the L76K\'s XIAO end\nunsoldered until you have a\nGNSS build (Firmware).', fontsize=8.5, va='top', ha='left', color='#555555')
plt.tight_layout()
fn = os.path.join(ROOT, 'images', 'wiring.png')
fig.savefig(fn, facecolor='white')
print(fn)
