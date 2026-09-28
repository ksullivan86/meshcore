# Parts list

Everything you need to build one repeater, as a checklist. Most of it is the same for all six files. The differences are in [Mounting hardware](#mounting-hardware), which depends on the mount style you picked.

Prices are what these cost when I checked in late September 2026, before tax and shipping. They'll drift, and eBay and Amazon listings come and go, so check before you order. The links are just where I found each part, not endorsements. Anything with the same specs will do.

The boxes can't be ticked on GitHub itself. Print the page, or paste the list into an issue, where they can.

## Radio and power

- [ ] **RAK WisBlock Mini starter kit, US915** (RAK19003 base + RAK4631 core). [Rokland, SKU 115093](https://store.rokland.com/products/rakwireless-mini-meshtastic-starter-kit-us915-rak19003-4631-sku-115093), $31.97. It comes with a small SMA antenna, a U.FL-to-SMA lead and a USB-C cable, which you'll cut up to make the power lead. Get the frequency band that's legal where you live.
- [ ] **LiFePO4 cell, Gotion 33140, 3.2 V 15 Ah.** [eBay item 398342236906](https://www.ebay.com/itm/398342236906), $5.00. 33.6 × 140 mm and 268 g. It has flat copper tabs on both ends, not screw terminals. When it arrives, weigh it and check it rests at 3.2 to 3.35 V. Send back one that's much lighter or reads under 2.5 V.
- [ ] **Adafruit bq25185 solar charger** (#6091). [Mouser 485-6091](https://www.mouser.com/ProductDetail/Adafruit/6091?qs=a2MtRaTmNOTWXd0vZOQVyw%3D%3D), $6.95. This is the only thing that ever charges the cell. You'll set it for LiFePO4 with two solder jumpers.
- [ ] **Adafruit MiniBoost 5 V** (#4654, TPS61023). [Mouser 485-4654](https://www.mouser.com/ProductDetail/Adafruit/4654?qs=W%2FMpXkg%2BdQ5I%2FGLylc3f4Q%3D%3D), $3.95. It turns the charger's output into 5.2 V for the RAK's USB-C port.
- [ ] **10 kΩ NTC thermistor, B 3435** (Vishay NTCLE413E2103F102L). [Mouser](https://www.mouser.com/ProductDetail/Vishay-BC-Components/NTCLE413E2103F102L?qs=RECgZY%2BK1xLdr8BN5MEzIw%3D%3D), $1.47. It's taped to the cell, and the charger stops charging when the cell is too cold or too hot.
- [ ] **2 A fast fuse, Littelfuse PICO II** (0251002.MXL), 2 of them. [Mouser 576-0251002.MXL](https://www.mouser.com/ProductDetail/Littelfuse/0251002MXL?qs=bpnLQM2ZShzafpYR%2Fng7qQ%3D%3D), $1.24 each. One goes on the cell's positive lead, the other is a spare.
- [ ] **1S LiFePO4 protection board.** [Teyleten 10-pack, Amazon B0GCWCHGFX](https://www.amazon.com/dp/B0GCWCHGFX), $6.99. It's the backup: it cuts charging at 3.75 V, cuts the load at 2.1 V and trips on a short. One per node, so the pack covers future builds.
- [ ] **JST-PH 2-pin cable, female plug, 100 mm**, 3 of them. [Mouser 485-261](https://www.mouser.com/ProductDetail/Adafruit/261?qs=GURawfaeGuDeA9XsXeF0ug%3D%3D), $0.75 each. For the cell, the charger's LOAD output and the panel lead.
- [ ] **JST-PH 2-pin cable, male, 200 mm.** [Mouser 485-3814](https://www.mouser.com/en/ProductDetail/Adafruit/3814?qs=%252BEew9%252B0nqrBFmoDCETN4BA%3D%3D), $0.75. The panel lead plugs into it at the charger, so the sled can come out without cutting anything.
- [ ] **Solar panel, Rebower 5 V 4 W (ETFE) with its round swivel mount.** [Amazon B0GZQ6PYRX](https://www.amazon.com/dp/B0GZQ6PYRX), $14.19, or a 2-pack as [B0GZQ4R3N9](https://www.amazon.com/dp/B0GZQ4R3N9), $22.49. It comes with a camera-style mount with a 55 mm round base, three screw holes and a long cable. Other 5 V camera panels with the same kind of mount work too, but check the hole spacing (see the note in the [README](../README.md)).
- [ ] **U.FL (IPEX) to SMA-female bulkhead pigtail, about 10 cm.** This runs from the RAK4631's LoRa connector straight down through the floor. The lead in the RAK kit may do if it's a bulkhead type with a nut.

### Optional

- [ ] **RAK1901 temperature and humidity sensor** (Sensirion SHTC3). [Rokland](https://store.rokland.com/products/rak-wireless-rak1901-temperature-and-humidity-sensor-sensirion-shtc3-pid-100001), $7.97. It plugs into slot C or D on the underside of the RAK19003, and the sled leaves room for it. It measures the air inside the box, so it tells you about heat and condensation in there, not the weather outside.
- [ ] **Adafruit INA219 current sensor** (#904). [Mouser 485-904](https://www.mouser.com/ProductDetail/Adafruit/904?qs=GURawfaeGuDOI%2Fva45%252BkSg%3D%3D), $9.95. MeshCore can't see the real cell voltage because the RAK runs from the 5 V boost. The INA219 can report the cell's voltage and current in telemetry. Wiring it means tapping the RAK19003's I²C, which the build guide doesn't cover.
- [ ] **1000 µF low-ESR capacitor, 10 V or more, on a JST-PH 2-pin plug.** Only if the node reboots when it transmits. It plugs into the RAK's empty BAT port (see Troubleshooting in the build guide).
- [ ] **Bigger antenna: ALFA AOA-915-5ACM** (5 dBi, N-male), [Rokland](https://store.rokland.com/products/alfa-aoa-915-5acm-5-dbi-omni-outdoor-915mhz-802-11ah-mini-antenna-for-lora-halow-application), $14.97, plus an [SMA-male to N-female adapter](https://store.rokland.com/products/sma-male-to-n-female-connector-adapter-pigtail), $5.97. On a tree, it does best mounted higher up on a short run of coax.

## Enclosure

- [ ] **O-ring, EPDM 70A, AS568-153** (88.57 mm ID × 2.62 mm), 2 of them (one spare). Some places that sell it:
  - [Mykin MO-153-RE00170](https://mykin.com/as568-153-epdm-70.html), $1.29
  - [The O-Ring Store E70153](https://www.theoringstore.com/store/index.php?main_page=product_info&products_id=6695)
  - [Gallagher Seals](https://www.gallagherseals.com/epdm-70a-o-ring-size-153-3-487-id-x-0-103-cs.html), $2.26, but they quoted 7 to 8 weeks

  It has to be size 153. The groove is sized for it, and a 152 or 154 won't seal properly. EPDM handles cold, ozone and sun better than nitrile (Buna-N).
- [ ] **M12 breather vent, Amphenol LTW VENT-PS1YBK-N8001.** [Mouser 523-VENT-PS1YBKN8001](https://www.mouser.com/ProductDetail/Amphenol-LTW/VENT-PS1YBK-N8001?qs=5aG0NVq1C4wAxWre7fChJA%3D%3D), $2.92. It lets the box breathe through big day-night temperature swings without pulling in water.
- [ ] **¼" NPT cable gland, IP68.** It has to grip your panel's cable, which is usually 3.5 to 4 mm.
- [ ] **Silicone grease.** [DANCO, Amazon B000DZFUPC](https://www.amazon.com/dp/B000DZFUPC), $5.48. A thin film on the O-ring lets the joint turn smoothly. Use silicone grease, never petroleum jelly, which makes EPDM swell.
- [ ] **Sensor-safe silicone, Permatex 82180 Ultra Black.** [Amazon B0002UEN1U](https://www.amazon.com/dp/B0002UEN1U), $7.56. It seals the antenna bulkhead where it goes through the floor. Ordinary 100% silicone gives off acetic acid while it cures, and that corrodes wiring.
- [ ] **Adhesive-lined heat shrink.** [TE ATUM-6/2, Mouser 650-ATUM62](https://www.mouser.com/ProductDetail/TE-Connectivity-Raychem/ATUM-6-2-0-STK?qs=pKEKwWK3ewNoklO%2FUHxqaA%3D%3D), $9.96, if you don't have some. It goes on the fuse and every splice.
- [ ] **A small silica gel packet** to go inside when you close it up.
- [ ] **Small black zip ties**, UV-rated, for the cell and the panel cable.

## Screws, nuts and inserts for the enclosure

Stainless where you can. Most of these come in a basic M2/M3 assortment.

- [ ] **Lock screw:** 1 × M3 × 20 socket-head screw and 1 × M3 washer (a standard thin one, DIN 125).
- [ ] **Lock nut:** 1 × M3 hex nut (DIN 934, 5.5 mm across flats, 2.4 mm thick). This one gets sealed inside the base (A) or can (B) during printing.
- [ ] **Sled:** 2 × M3 × 8 or M3 × 10 socket-head screws and 2 × M3 heat-set inserts, 5 mm wide (the fit test checks the hole size).
- [ ] **Boards:** 8 × M2 × 5 screws with washers, and 8 × M2 heat-set inserts, 3.5 mm wide. That's four for the charger, one for the MiniBoost and three for the RAK19003.

## Mounting hardware

Pick the section for your mount style. The #10 screws go into the tree, and all of them need pan heads, not flat heads, because the heads sit in flat-bottomed recesses. On thick-barked trees like Jeffrey pine, the screws need to get well through the bark into solid wood, so go for 3 in.

**Tree-screw mount**

- [ ] 2 × #10 stainless pan-head screws, 3 in. For the keyhole and the rail. [Bolt Dropper #10 × 3 in, 25-pack, Amazon B07D1LK3QB](https://www.amazon.com/dp/B07D1LK3QB). For thinner bark, 2 in is enough: [Everbilt #10 × 2 in, Home Depot 802932](https://www.homedepot.com/p/Everbilt-10-x-2-in-Stainless-Steel-Phillips-Pan-Head-Sheet-Metal-Screw-20-Pack-802932/204275054), $6.87 for 20.
- [ ] 1 × stainless wood screw for the panel mount's top hole. Use a #6 if it fits the mount's hole, or drill that one hole out to 4.5 mm (3/16 in is fine too) and use a #8. It should be 3 in long for A and 3½ in for B, whose pad stands further out. Match the head to the mount's hole: flat head if the hole is countersunk.
- [ ] 2 × M3 × 16 socket-head screws and 2 × M3 hex nuts (sealed in the bracket). M3 × 16 suits a mount base up to 6 mm thick at the holes. From 6 to 10 mm, use M3 × 20; the hole carries on past the nut.

**Bolt-on mount**

- [ ] 3 × #10 stainless pan-head screws, 3 in (or 2 in on thin bark). For the keyhole, the rail and the top.
- [ ] 3 × M3 × 16 socket-head screws and 3 × M3 hex nuts (sealed in the bracket). Same note on length as above.
- [ ] Or, instead of the tree screws: 2 straps (see below).

**Wing-nut mount**

- [ ] 3 × #10 stainless pan-head screws, 3 in (or 2 in on thin bark). For the keyhole, the rail and the top.
- [ ] 3 × M3 × 25 hex-head bolts (DIN 933, fully threaded, stainless). The heads sit in hex pockets on the back of the bracket. On B, the three printed spacers in the file go in behind them.
- [ ] 3 × M3 wing nuts (DIN 315, stainless) and 3 × M3 washers. Hardware stores often only have M4 and up, so you may need to order these online.
- [ ] A strip of tape, to hold the bolts in the bracket while you hang it.
- [ ] Or, instead of the tree screws: 2 straps (see below).

**Straps** (bolt-on or wing-nut, or as extra hold on any of them)

- [ ] 2 × 1 in cam-buckle straps, long enough to go round your tree. [Husky 1 in × 10 ft, 2-pack, Home Depot FH0904](https://www.homedepot.com/p/Husky-10-ft-x-1-in-Cam-Buckle-Tie-Down-Straps-with-S-Hook-2-Pack-FH0904/206802314), $7.98. Cut off the S-hooks. Use straps rather than screws on a tree that isn't yours.

## Filament

- [ ] **ASA, 1 kg,** white or light grey. [Polymaker ASA](https://shop.polymaker.com/products/asa), $29.99. Version A uses about 530 g and B about 630 g, plus roughly 115 g for the test pieces. Use ASA rather than PLA or PETG, because it holds up to sun and heat. A light color keeps the box cooler in summer.

## Tools

- 3D printer that can print ASA, ideally enclosed, with a 256 × 256 mm bed. The brackets only fit on the diagonal. Everything here was sized for a Bambu Lab P1S.
- Soldering iron, 60 W or more with a wide chisel tip for the cell tabs, plus solder and flux.
- Multimeter.
- Heat gun or lighter for the heat shrink.
- 1.5 mm and 2.5 mm hex keys (for the M2 and M3 socket heads), a Phillips screwdriver and small pliers. For B, a long 2.5 mm hex driver and long-nose pliers, because the can's floor is a long reach down.
- An 8 mm (5/16 in) nut driver for the SMA bulkhead nut.
- A craft knife, and 2.5 mm and 3 mm drill bits turned by hand, to clean up holes if needed.
- Drill with a 3 mm (1/8 in) bit for pilot holes in the tree.
- A computer with a USB-C cable and Chrome or Edge, to flash MeshCore.
- A freezer, for the cold cutoff test.
