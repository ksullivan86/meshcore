# Parts list

Everything you need to build one tracker, as a checklist. It's here twice: first by what each part is for, then [sorted by store](#shopping-list-by-store), which is the easier one to order from. [`parts.csv`](parts.csv) has the same list as a spreadsheet you can sort or filter by store or by version. GitHub shows it as a searchable table, or you can open it in Excel or Google Sheets.

The electronics are the same for both versions. The differences are the battery and the parts that go with it: see [Swap version](#swap-version) and [Sealed version](#sealed-version).

Prices are what these cost when I checked in late September 2026, before tax and shipping. They'll drift, and eBay and Amazon listings come and go, so check before you order. The links are just where I found each part, not endorsements. Anything with the same specs will do. Parts marked **(fit test)** vary between sellers, so check them with the fit test print before you print the pod.

The boxes can't be ticked on GitHub itself. Print the page, or paste the list into an issue, where they can.

## What it costs

| | Swap, 16340 | Swap, 18350 | Sealed |
|---|---|---|---|
| Electronics | $37.48 | $37.48 | $37.48 |
| Battery | $10.95 (a cell with its own USB-C port) | $7.49, plus $6.90 for a charger | $10.02 |
| Nickel strip, springs, washers | $27.47 (packs) | about $22 (packs, and a hardware-store washer) | |
| Fuse and capacitor | about $1 | about $1 | |
| O-rings | about $15 (three packs of 10) | about $15 (three packs of 10) | $6.38 (a pack of 10) |
| **One tracker** | **about $92** | **about $90** | **about $54** |
| Each tracker after that | about $52 | about $49 | about $48 |
| A spare cell | $10.95 | $7.49 | |

The swap version costs more for the first one because the strip, springs, washers and O-rings come in packs that cover ten or more trackers. If you don't already have them, add about $60 for epoxy, superglue, silicone grease and a spool of filament (about $45 with the cheaper epoxy and filament below), plus flux, heat shrink and tape.

## Electronics (both versions)

- [ ] **Seeed Studio XIAO nRF52840 & Wio-SX1262 Kit** (SKU 102010710). [Seeed Studio](https://www.seeedstudio.com/XIAO-nRF52840-Wio-SX1262-Kit-for-Meshtastic-p-6400.html), $13.49. The nRF52840 microcontroller with Bluetooth and an SX1262 LoRa radio board, already joined: 22 × 23 × 8 mm. It covers 862 to 930 MHz, so the same kit works in the US and the EU. It comes with a flexible (FPC) LoRa antenna on a U.FL lead, which the pod is drawn for, and it has a lithium charger built in.
- [ ] **Seeed Studio L76K GNSS Module for XIAO** (SKU 109100021). [Seeed Studio](https://www.seeedstudio.com/L76K-GNSS-Module-for-Seeed-Studio-XIAO-p-5864.html), $11.99. GPS, BeiDou, GLONASS and QZSS on an 18 × 21 mm board. It comes with an active patch antenna on a 10 cm lead and a pair of header sockets. You won't need the sockets, because it's wired, not stacked.
- [ ] **2-pin magnetic charging connector with its USB cable** **(fit test)**. For example [eBay item 305540009139](https://www.ebay.com/itm/305540009139), $10.50 for one set: the half that goes in the pod, the half on the cable, and the cable (choose "2Pin").
  - The pod takes the half with the flat contacts. Its face has to fit an 11.5 × 5 mm opening. A smaller one is fine, because you pot it in flush. For a bigger one, set `POGO_FACE` and export your own pod ([Changing the design](customizing.md)); the 16340 pod has room for one up to 5.4 mm tall.
  - Choose one whose halves only snap together one way round, with the magnets pushing apart when you turn it over. One that connects either way can feed the XIAO reversed power. If yours does, add a 1N5817 Schottky diode in its + lead (see [Supplies](#supplies)).
- [ ] **30 AWG silicone wire**, red and black. [Adafruit #2001](https://www.adafruit.com/product/2001) and [#2003](https://www.adafruit.com/product/2003), $0.75 each for 2 m. For the L76K, the magnetic port and the battery.
- [ ] **A USB power adapter** for the magnetic cable. Any phone charger will do.

## Swap version

### The cell

It has to be a **protected, button-top, rechargeable lithium-ion cell (3.6 or 3.7 V)**.

- **Protected:** the XIAO doesn't cut off a flat battery, so the cell's own protection circuit is the only thing that stops it being run down too far or shorted.
- **Button top:** the + contact sits 0.4 mm below a little ring, so a cell put in backwards can't touch it. A flat-top cell won't reach it either. Print the fit test's contact disc and try your cell before you print the barrel.
- **A − contact at least 10 mm across.** The spring presses the cell's − end in a ring about 9 mm across. A few protected cells have only a small disc there, inside an insulating ring, and those won't connect.
- **Never a CR123A or any other non-rechargeable cell,** even though it's the same size. The pod's charger would try to charge it, and it could catch fire. Never a LiFePO4 cell either, sometimes sold as a "3.2 V RCR123A": the pod charges to 4.2 V, which is too much for it. Avoid "3.0 V" RCR123A cells too.

One of these, plus a spare if you'll swap in the field:

- [ ] **16340 with its own USB-C port (recommended): Nitecore NL169R**, 950 mAh, 16.5 × 36.3 mm. [Nitecore Store](https://nitecorestore.com/products/nitecore-nl169r-950mah-usb-c-rechargeable-16340-battery), $10.95, or [18650battery.com](https://18650battery.com/products/nitecore-nl169r-16340-950mah-battery-protected-button-top), $9.95. The port is on its side, so you charge a spare with any USB-C cable. Nobody has tested this USB version's capacity yet; the plain NL169 below measured 924 to 940 mAh.
- [ ] **Or a plain 16340: Nitecore NL169**, 950 mAh, 16.6 × 34.1 mm. [Battery Junction](https://www.batteryjunction.com/products/nitecore-nl169), $6.95. It needs a charger (below), and because it's shorter, the spring holds it less firmly than the NL169R. The [Keeppower RCR123A 800 mAh](https://illumn.com/batteries/16340/16340-keeppower-800mah-icr16340-protected-button-top.html) at illumn, $6.50, is another good one.
- [ ] **Or an 18350, for longer runs: Keeppower P1835C2**, 1200 mAh (it measured 1140), 18.5 × 39.1 mm. [illumn](https://illumn.com/batteries/18350/18350-keeppower-p1835c2-1200mah-protected-button-top.html), $7.49 ($3.49 on sale when I looked). It needs a charger. It only fits the 18350 files.

The 16340 barrel takes cells up to 17.0 mm across and 36.6 mm long, and still holds a 33.5 mm one, though less firmly: the longer the cell, the harder the spring pushes it against the contacts. The 18350 barrel takes cells up to 19.1 × 39.9 mm, down to 38.3 mm long. Some cells are sold with the wrong top: the reviewer [HKJ](https://lygte-info.dk/info/batteryIndex.html) lists the Keeppower P1634C2 and P1835C3 as flat top even though stores call them button top.

Stay away from 16340s sold with big numbers, like "2800 mAh". Real ones hold 650 to 1000 mAh.

### A charger (only for cells without their own USB port)

- [ ] **XTAR ANT MC1 Plus**, USB-C, charges one 16340 or 18350 at 0.5 A in about two hours. [illumn](https://illumn.com/xtar-ant-mc1-plus-li-ion-usb-charger.html), $6.90 ($3.99 on sale when I looked). The [Nitecore UI1](https://18650battery.com/products/nitecore-ui1-portable-usb-c-charger), $6.99, works too.

### Barrel and cap

- [ ] **Pure nickel strip, 0.15 × 5 mm.** [SHONAN, Amazon B08RJ97W8P](https://www.amazon.com/dp/B08RJ97W8P), $9.99 for a 9.8 m roll. You need about 65 mm per tracker: one piece for each contact. Pure nickel takes solder with flux. A lot of "nickel strip" is nickel-plated steel, which rusts at the cut edges, so buy one that says pure (99.6%) nickel.
- [ ] **A conical spring, 0.7 mm wire**, 5.6 mm across at the narrow end and 10 mm at the wide end, 12 mm long. [Mardatt 123-piece conical spring kit, Amazon B0DRVJ87VW](https://www.amazon.com/dp/B0DRVJ87VW), $10.99. Use the 0.7 × 5.6–10 × 12 mm springs (there are 10). Not the 0.5 mm ones in the same kit, which are too soft to hold the cell against the contacts when the dog jumps. They're stainless, which is fine for contacts at these currents. For a different spring, set `SPRING` and export your own files ([Changing the design](customizing.md#your-cell)).
- [ ] **A flat washer for the cap.** Stainless, about 1.2 mm thick, with a hole between 4.7 and 5.3 mm. It floats on the small O-ring in the cap, and the post in the cap goes through its hole. A bigger hole would let the spring's narrow end drop through.
  - 16340: **20 mm across with a 5 mm hole.** [MECCANIXITY 5 × 20 × 1.2 mm, 20-pack, Amazon B0F4DLM7QJ](https://www.amazon.com/dp/B0F4DLM7QJ), $6.49.
  - 18350: **22.2 mm (7/8 in) across**, such as a #8 × 7/8 in stainless fender washer from a hardware store, or a #10 × 7/8 in one if its hole is no more than 5.3 mm (many are 5.6). I couldn't confirm a listing for one, so check a hardware store.
  - For any other washer, set `WASHER_D` (and `WASHER_HOLE`, `WASHER_T`) to its size and export your own files; the console tells you which cap O-ring it then needs.
- [ ] **Two O-rings for the cap, 1.5 mm cross-section:** the big one that seals the cap (20 mm inside diameter for a 16340, 22 mm for an 18350) and a small 12 mm one that the washer floats on. See [O-rings](#o-rings).

### Fuse and capacitor

Both are part of the swap build.

- [ ] **A resettable PTC fuse, 0.75 A hold, radial leads,** such as a Bourns MF-R075 or Littelfuse RXEF075, about $0.40 from [Mouser](https://www.mouser.com/c/?q=MF-R075) or DigiKey. It goes in the red battery wire and trips if something shorts, even if the cell's own protection has been bypassed.
- [ ] **A 220 µF electrolytic capacitor, 6.3 V or more, about 6 mm across,** such as a Panasonic EEU-FR1A221, about $0.30 from [Mouser](https://www.mouser.com/c/?q=EEU-FR1A221) or DigiKey. It goes across BAT+ and BAT− and carries the XIAO through a contact bouncing when the dog jumps.

Order them with the epoxy from Mouser, and they cost almost nothing to ship.

## Sealed version

- [ ] **3.7 V LiPo pouch cell, size 603040, with a protection board.** [eBay item 121868609784](https://www.ebay.com/itm/121868609784), $7.03 plus $2.99 shipping. It's sold as 800 mAh; expect a little less in use. Or [Liter on Amazon, B09WVDPGXL](https://www.amazon.com/dp/B09WVDPGXL), 603040 with a PH2.0 plug and a protection board. The plug doesn't matter, because you cut it off.

It has to have a protection board, for the same reason as the swap version's cell. When it arrives, check it reads 3.6 to 4.2 V, and send back any cell that's puffy. The pod is drawn for up to 6.2 × 30.5 × 44 mm, which leaves room for the protection board on the end.

Other sizes, if you export your own files or use the 803040 file:

- **803040** (8 mm thick, about 900 mAh): [eBay item 121868650322](https://www.ebay.com/itm/121868650322), $7.03 plus $2.99 shipping. The pod is 2 mm taller. There's a file for it.
- **503040** (5 mm thick, 500 to 600 mAh): [Adafruit #1578](https://www.adafruit.com/product/1578), $7.95, 29 × 36 × 4.75 mm with a protection board. The pod is 1 mm thinner.

## O-rings

All of them are nitrile (NBR 70), 1.5 mm cross-section, sold by inside diameter:

| O-ring | Swap, 16340 | Swap, 18350 | Sealed |
|---|---|---|---|
| Lid | 41 × 1.5 | 41 × 1.5 | 48 × 1.5 |
| Cap seal | 20 × 1.5 | 22 × 1.5 | |
| Under the cap's washer | 12 × 1.5 | 12 × 1.5 | |

- [ ] [eBay item 404934396757](https://www.ebay.com/itm/404934396757) sells packs of 10 of any size from 1 to 50 mm: choose the inside diameter. $4.48 a pack for the small sizes, about $6 for 41 mm and $6.38 for 48 mm. It ships from China and takes three or four weeks.
- Or [Global O-Ring & Seal](https://www.globaloring.com/product/n1-50x020/) sells them one at a time (N1.50X012, N1.50X020, N1.50X022, N1.50X041, N1.50X048), for 6 to 29 cents each, with a $5 order minimum.

A spare cap seal O-ring is worth having, because the cap comes off often. If you change the design, the OpenSCAD console tells you the new sizes.

## Supplies

- [ ] **Epoxy.** It goes round the magnetic connector, fills the potting pocket behind the barrel, and holds the barrel in its trough.
  - The best one for this is [MG Chemicals 832HD, 25 mL, Mouser 590-832HD-25ML](https://www.mouser.com/ProductDetail/590-832HD-25ML), $25.29. It's a potting epoxy that's made to insulate and to stay in water, and it gives you 45 minutes to work.
  - [Devcon 14250 5-minute, 25 mL, SkyGeek](https://skygeek.com/devcon-14250-5-minute-general-purpose-epoxy-25-ml-tube-8040-01-034-0401.html), $13.65, is cheaper and fine if you work in small batches.
- [ ] **Gel superglue (CA),** a small tube, to hold the nickel strips in the barrel and seal the slots they go through. Gel stays where you put it instead of wicking onto the contacts.
- [ ] **Flux,** a rosin flux pen, for soldering wires to the nickel strip, and a little **isopropyl alcohol** to clean it off afterwards.
- [ ] **Silicone dielectric grease.** [Permatex 81150, Amazon B000AL2RI2](https://www.amazon.com/dp/B000AL2RI2), $6.29. A thin film goes on the O-rings. It's safe on nitrile and on the printed plastic. Never use petroleum jelly, which makes nitrile swell.
- [ ] **Heat shrink tubing**, 1.5 to 3 mm, for every joint.
- [ ] **Thin double-sided tape**, about 0.2 mm thick, to hold the boards and the antenna in place. Not foam tape.
- [ ] **Kapton (polyimide) tape.** It holds the magnetic connector flush while its epoxy sets, and on the sealed version it covers the backs of the boards so they can't rub through the pouch cell. A piece of fish paper or thin PET film does that job too.
- [ ] **A 15 cm piece of thin nylon fishing line**, about 0.3 mm, to let the air out as the lid goes in.
- [ ] Only if your magnetic connector snaps on either way round: a **1N5817 Schottky diode**.

## Filament

- [ ] **PETG, 1 kg.** [Bambu Lab PETG Basic](https://us.store.bambulab.com/products/petg-basic), $22.99, or [Polymaker PETG](https://shop.polymaker.com/products/petg), $18.99. The swap version takes about 36 to 40 g and the sealed version about 22 g, so one spool builds a lot of them.
  - ASA works too and holds its color better in the sun. PETG is tougher when a dog bashes it into things.
  - Pick a bright color for the cap, so you can find it if it drops in the grass.

## Tools

- A 3D printer. Every file fits a 180 × 180 mm bed.
- Soldering iron with a fine tip, solder and flux.
- Multimeter.
- Flush cutters, wire strippers for 30 AWG, tweezers and small pliers.
- A heat gun for the heat shrink. It's safer than a lighter next to a cell.
- A craft knife, and fine sandpaper or a small file, for cleaning up prints and deburring the nickel strip.
- Toothpicks and a scrap of card, for mixing and placing epoxy.
- Calipers, if you want to measure your cells. They're handy but not essential.
- A computer with a USB-C cable and Chrome or Edge, to flash the firmware.

## Shopping list by store

The same parts, grouped by where to order them. Quantities are for one tracker.

### Seeed Studio

- [ ] [XIAO nRF52840 & Wio-SX1262 Kit, SKU 102010710](https://www.seeedstudio.com/XIAO-nRF52840-Wio-SX1262-Kit-for-Meshtastic-p-6400.html), × 1, $13.49
- [ ] [L76K GNSS Module for XIAO, SKU 109100021](https://www.seeedstudio.com/L76K-GNSS-Module-for-Seeed-Studio-XIAO-p-5864.html), × 1, $11.99

### eBay

- [ ] [2-pin magnetic charging connector and cable, item 305540009139](https://www.ebay.com/itm/305540009139), × 1 set, $10.50 (choose "2Pin")
- [ ] [Nitrile O-rings, 1.5 mm cross-section, item 404934396757](https://www.ebay.com/itm/404934396757), packs of 10: swap 41 mm, 12 mm, and 20 mm (16340) or 22 mm (18350); sealed 48 mm. $4.48 to $6.38 a pack.
- [ ] Sealed only: [603040 LiPo with protection board, item 121868609784](https://www.ebay.com/itm/121868609784), × 1, $7.03 plus $2.99 shipping (or the 803040, [item 121868650322](https://www.ebay.com/itm/121868650322))

### Adafruit

- [ ] [30 AWG silicone wire, black, #2001](https://www.adafruit.com/product/2001), and [red, #2003](https://www.adafruit.com/product/2003), × 1 each, $0.75 each
- [ ] Sealed with a 503040 only: [LiPo 500 mAh, #1578](https://www.adafruit.com/product/1578), × 1, $7.95

### Amazon

- [ ] Swap: [SHONAN pure nickel strip, 0.15 × 5 mm, B08RJ97W8P](https://www.amazon.com/dp/B08RJ97W8P), × 1 roll, $9.99
- [ ] Swap: [Mardatt conical spring kit, B0DRVJ87VW](https://www.amazon.com/dp/B0DRVJ87VW), × 1, $10.99 (use the 0.7 mm springs)
- [ ] Swap, 16340: [MECCANIXITY 5 × 20 × 1.2 mm washers, B0F4DLM7QJ](https://www.amazon.com/dp/B0F4DLM7QJ), × 1 pack of 20, $6.49
- [ ] [Permatex 81150 dielectric grease, B000AL2RI2](https://www.amazon.com/dp/B000AL2RI2), × 1, $6.29
- [ ] Sealed, instead of the eBay cell: [Liter 603040 LiPo, B09WVDPGXL](https://www.amazon.com/dp/B09WVDPGXL)

### Nitecore Store, Battery Junction, 18650battery.com or illumn

- [ ] Swap, 16340: [Nitecore NL169R](https://nitecorestore.com/products/nitecore-nl169r-950mah-usb-c-rechargeable-16340-battery), × 1 (or 2 with a spare), $10.95 ([$9.95 at 18650battery.com](https://18650battery.com/products/nitecore-nl169r-16340-950mah-battery-protected-button-top))
- [ ] Or: [Nitecore NL169 at Battery Junction](https://www.batteryjunction.com/products/nitecore-nl169), $6.95, plus a charger
- [ ] Swap, 18350: [Keeppower P1835C2 at illumn](https://illumn.com/batteries/18350/18350-keeppower-p1835c2-1200mah-protected-button-top.html), × 1 or 2, $7.49
- [ ] For cells without USB: [XTAR ANT MC1 Plus at illumn](https://illumn.com/xtar-ant-mc1-plus-li-ion-usb-charger.html), × 1, $6.90

### Mouser (or SkyGeek for the cheaper epoxy)

- [ ] [MG Chemicals 832HD potting epoxy, 25 mL, Mouser 590-832HD-25ML](https://www.mouser.com/ProductDetail/590-832HD-25ML), $25.29, or [Devcon 14250 at SkyGeek](https://skygeek.com/devcon-14250-5-minute-general-purpose-epoxy-25-ml-tube-8040-01-034-0401.html), $13.65
- [ ] Swap: a [0.75 A PTC fuse such as the Bourns MF-R075](https://www.mouser.com/c/?q=MF-R075), × 1, about $0.40
- [ ] Swap: a [220 µF capacitor such as the Panasonic EEU-FR1A221](https://www.mouser.com/c/?q=EEU-FR1A221), × 1, about $0.30

### Bambu Lab or Polymaker

- [ ] [PETG, 1 kg](https://us.store.bambulab.com/products/petg-basic), × 1, $22.99 (or [Polymaker PETG](https://shop.polymaker.com/products/petg), $18.99)

### Anywhere

- [ ] Gel superglue, a rosin flux pen, isopropyl alcohol, heat shrink, thin double-sided tape, Kapton tape, thin nylon fishing line
- [ ] Swap, 18350: a stainless washer 22.2 mm (7/8 in) across with a hole between 4.7 and 5.3 mm, such as a #8 × 7/8 in fender washer
- [ ] A USB power adapter (any phone charger)

## Alternatives

Other places to get the parts that are most likely to be out of stock or hard to find.

| Part | Also available from | Notes |
|---|---|---|
| 16340 cell with USB-C | [Fenix ARB-L16-800UP](https://www.batteryjunction.com/products/fenix-arb-l16-800up), $11.95, 16.7 × 35.0 mm; [XTAR 16340 900 mAh USB-C](https://18650battery.com/products/xtar-3-6v-16340-900mah-usb-c-protected-button-top), $7.99 | Both are protected button tops. The Fenix has its port on the side. XTAR doesn't give its length or say where its port is, so measure it (33.5 to 36.6 mm fits) and try it in the fit test first. |
| 18350 cell | [Fenix ARB-L18-1600](https://www.batteryjunction.com/products/fenix-arb-l18-1600), $11.95, 18.75 × 39.2 mm, 1600 mAh (not independently tested) | The longer USB-C 18350s (41 to 42 mm) don't fit. |
| O-rings | [Global O-Ring & Seal](https://www.globaloring.com/product/n1-50x020/), [uxcell on Amazon](https://www.amazon.com/dp/B00N3WTTFE) (named by outside diameter) | Any NBR 70 O-ring of the right inside diameter and 1.5 mm cross-section. |
| Magnetic connector | Adafruit's [#5412](https://www.adafruit.com/product/5412) cable ($4.95) and [#5358](https://www.adafruit.com/product/5358) connector set ($6.50) | 4-pin, so you'd use two of the pins, and it needs a bigger opening. Measure it and set `POGO_FACE`. |
| Epoxy | [J-B Weld ClearWeld](https://www.jbweld.com/product/clearweld-syringe), $7.99 | Cheaper. J-B Weld says it's an insulator but only rates it for "some" water resistance, so use it in small batches and keep it out of the pod's seals. |
