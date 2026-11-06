# Parts list

Everything you need to build one tracker, as a checklist. [`parts.csv`](parts.csv) has the same list as a spreadsheet you can sort or filter.

Prices are what these cost when I checked in early November 2026, before tax and shipping. They'll drift, so check before you order. The links are just where I found each part, not endorsements. Anything with the same specs will do.

The boxes can't be ticked on GitHub itself. Print the page, or paste the list into an issue, where they can.

## Radio and power

- [ ] **Seeed Wio Tracker L1 E-ink.** [RobotShop RB-See-1210](https://robotshop.com/products/seeedstudio-wio-tracker-l1-e-ink), $38.15. It comes with the 2.13" e-ink screen, a small ribbon adapter board and a 50 mm ribbon, a LoRa antenna and a GPS patch. It ships with Meshtastic; flash MeshCore onto it. Get the frequency band that's legal where you live.
- [ ] **3.7 V 3000 mAh LiPo cell with a protection board and a JST 1.25 plug.** [Meshnology](https://meshnology.com/products/3-7v-3000mah-rechargeable-battery-for-arduino-esp32), $15.99. The bay takes a cell up to 10.5 × 37 × 68 mm. Check the plug's polarity against the board before you plug it in: JST 1.25 cells don't all agree.

## Case

- [ ] **4 × M3 heat-set inserts,** 5 mm wide and 6 mm long (METERXITY or any brass M3 insert that size). The fit test needs one.
- [ ] **4 × M3 × 18 socket-head screws,** stainless. M3 × 16 also works, with a little less thread in the insert. The fit test needs one.
- [ ] **½ in hook-and-loop strap,** cut to about 130 mm, for the cell. [VELCRO One-Wrap 8 × ½ in, 5-pack, Home Depot 90438ACS](http://www.homedepot.com/p/VELCRO-brand-8-in-x-1-2-in-One-Wrap-Straps-Multicolor-5-Pack-90438ACS/202261928), $3.97. It must be ½ in (12.7 mm) wide or narrower and about 1.2 mm thick.
- [ ] Optional: a thin foam pad (0.2 mm) behind the screen. The cover leaves room for it but doesn't need it.

## Filament

- [ ] **PETG or ASA,** about 25 g for the fit test.

## Tools

- 3D printer. Everything here was sized for a Bambu Lab P1S.
- Calipers, for the measurements in [the build guide](build-guide.md#3-measure-what-is-still-a-guess).
- Soldering iron with an M3 heat-set tip. The bosses leave room for a tip up to 7 mm wide.
- A 2.5 mm hex key for the M3 socket heads.
- A computer with a USB-C cable and Chrome or Edge, to flash MeshCore.
