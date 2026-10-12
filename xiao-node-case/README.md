# XIAO node case

A desk or shelf case that holds two (or three) Seeed XIAO ESP32S3 + Wio-SX1262 kits side by side, each with its own USB-C port, so one box can run a Home Assistant companion and a CoreScope observer (or a local repeater) at the same site.

**Status:** design brief only. Nothing to print yet.

## Why not the single-kit shells

The MakerWorld shell (model 1011485) works, but:
- my socket-head screw heads don't sit flush in its counterbores
- it's so small and light that anything bigger than a stub antenna tips it over
- it's under a Standard Digital File License, so it can't be remixed and published here. This case is drawn from scratch.

## Requirements

- **Bays:** a setting for 1, 2 or 3 kits. Each kit is held without tools (no heat-set inserts) and can come out for flashing.
- **Power and flashing:** a separate USB-C opening per kit, lined up with the connector, with room for a normal cable boot. BOOT and RESET on each XIAO reachable from outside (pin holes or printed plungers). The status LED visible.
- **LoRa antennas:** an SMA bulkhead per kit on a U.FL pigtail, spaced as far apart as the case allows so the radios don't swamp each other.
- **WiFi antennas:** a mount per kit for the XIAO's 2.4 GHz antenna: either the stock FPC antenna stuck to an inside wall, or an RP-SMA bulkhead on a U.FL pigtail.
- **Stability:** a wide, low base that stays upright with full-size antennas fitted. Optional keyhole slots for wall mounting.
- **Closing the case:** sized for my TOOINKCV M2/M3 socket-head screws and nuts (nut traps, not heat-set inserts), or a screwless snap lid. Counterbores are measured from my screw heads, with clearance.
- **Printing:** P1S, no supports, every part for one version in a single STL (`stl/`), matching the other projects.

## Decided

- **Versions:** 1-bay, 2-bay and 3-bay, each its own STL.
- **LoRa:** SMA bulkhead per kit, like the MakerWorld shell.
- **Buttons:** printed plungers for the XIAO's B (boot) and R (reset) buttons and the Wio-SX1262's user button. In the kit the XIAO sits on top of the Wio board, with B and R on either side of its USB-C, so all three plungers come from the top/front.
- **USB labels:** debossed text by each USB-C opening, set in the CAD (e.g. HA, OBS, RELAY).
- **Board holding:** the Tahoe repeater's turn buttons. The bay floor has a relief pocket under the factory-soldered header pins, so the pins never touch the case and can't be pushed back through the board. The board rests on its edges.
- **Lid:** the Tahoe repeater's flexure latch (arm rides over a post and clicks in), adapted to a slide-on lid, since a quarter-turn thread doesn't suit a rectangular box. The M3 screw into a nut stays as an option.
- **WiFi:** the stock FPC antenna on an inside wall by default, with an optional RP-SMA bulkhead per kit (a CAD setting).
- **Mounting:** desk only. A wide, low base, no wall slots.
- **WiFi/BLE antenna fit:** a molded pocket for the stock FPC antenna and a routed channel for its U.FL cable, sized to the real cable length with a gentle bend, so it goes in without forcing. The FPC sits on the far wall from the LoRa pigtails.
- **Ballast:** a pocket in the base for a stack of M6 fender washers (or steel/lead shot), closed by the base plate, so the case stays put with full-size antennas. Optional magnet pockets in the feet.
- **Battery:** not planned. See the notes below.

## Open questions

Needed from the real kit before building (photos of both sides next to a ruler):
- assembled stack height, and how far the soldered header pins stick out
- stock FPC antenna size and cable length; LoRa pigtail length

## Notes

- **Magnets** don't affect the radios (a static field doesn't touch RF), but they only help on a steel surface. Weight works anywhere.
- **Battery:** a cell would let one bay keep running as a repeater through a power cut, but the HA companion and the observer need WiFi, which goes down with the power unless the router is on a UPS. A LiPo held at full charge 24/7 indoors also wears out and is a needless risk, so the base uses ballast instead.

## Folder layout (once there's something to print)

```
xiao-node-case/
  README.md
  stl/      one file per version, holding every printed part it needs
  images/
  docs/     parts list, build guide, customizing
  cad/      OpenSCAD source and fit checks
```
