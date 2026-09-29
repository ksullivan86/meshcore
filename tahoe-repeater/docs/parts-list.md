# Parts list

Everything you need to build one repeater, as a checklist. It's here twice: first by what each part is for, then [sorted by store](#shopping-list-by-store), which is the easier one to order from. [`parts.csv`](parts.csv) has the same list as a spreadsheet you can sort or filter by store or by mount, with a column for what version C needs extra. GitHub shows it as a searchable table, or you can open it in Excel or Google Sheets.

Most of it is the same for all nine files. The differences are in [Mounting hardware](#mounting-hardware), which depends on the mount style you picked, [Straps](#straps), and a few parts that version C needs two of, because it has two joints.

Prices are what these cost when I checked in late September 2026, before tax and shipping. They'll drift, and eBay and Amazon listings come and go, so check before you order. The links are just where I found each part, not endorsements. Anything with the same specs will do, and [Alternatives](#alternatives) lists some other places to get the harder-to-find parts.

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
- [ ] **Solar panel, Rebower 5 V 4 W (ETFE) with its round swivel mount.** [Amazon B0GZQ6PYRX](https://www.amazon.com/dp/B0GZQ6PYRX), $14.19, or a 2-pack as [B0GZQ4R3N9](https://www.amazon.com/dp/B0GZQ4R3N9), $22.49. It comes with a camera-style mount with a 55 mm round base, three screw holes and a long cable. Other 5 V camera panels with the same kind of mount work too. Check yours with the mount test disc before you print the bracket (see the [README](../README.md)).
- [ ] **U.FL (IPEX) to SMA-female bulkhead pigtail, about 20 cm (8 in), RG178.** This runs from the RAK4631's LoRa connector down through the floor. At 20 cm you can lift the sled out and set it beside the box without unplugging it. [eBay item 387516099576](https://www.ebay.com/itm/387516099576), $2.48: choose 8 in and SMA female, not RP-SMA. [Amazon B07TXH2N83](https://www.amazon.com/dp/B07TXH2N83) is the same thing. A shorter one, like the lead in the RAK kit if it's a bulkhead type with a nut, works too, but then you unplug the U.FL every time the sled comes out.

### Optional

- [ ] **RAK1901 temperature and humidity sensor** (Sensirion SHTC3). [Rokland](https://store.rokland.com/products/rak-wireless-rak1901-temperature-and-humidity-sensor-sensirion-shtc3-pid-100001), $7.97. It plugs into slot C or D on the underside of the RAK19003, and the sled leaves room for it. It measures the air inside the box, so it tells you about heat and condensation in there, not the weather outside.
- [ ] **Adafruit INA219 current sensor** (#904). [Mouser 485-904](https://www.mouser.com/ProductDetail/Adafruit/904?qs=GURawfaeGuDOI%2Fva45%252BkSg%3D%3D), $9.95. MeshCore can't see the real cell voltage because the RAK runs from the 5 V boost. The INA219 can report the cell's voltage and current in telemetry. Wiring it means tapping the RAK19003's I²C, which the build guide doesn't cover.
- [ ] **1000 µF low-ESR capacitor, 10 V or more, on a JST-PH 2-pin plug.** Only if the node reboots when it transmits. It plugs into the RAK's empty BAT port (see Troubleshooting in the build guide).
- [ ] **Bigger antenna: ALFA AOA-915-5ACM** (5 dBi, N-male), [Rokland](https://store.rokland.com/products/alfa-aoa-915-5acm-5-dbi-omni-outdoor-915mhz-802-11ah-mini-antenna-for-lora-halow-application), $14.97, plus an [SMA-male to N-female adapter](https://store.rokland.com/products/sma-male-to-n-female-connector-adapter-pigtail), $5.97. On a tree, it does best mounted higher up on a short run of coax.

## Enclosure

- [ ] **O-ring, EPDM 70A, AS568-153** (88.57 mm ID × 2.62 mm), 2 for A or B (one is a spare), 3 for C. Some places that sell it:
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
- [ ] **½ in hook-and-loop strap, 8 in long,** 1 of them, for the cell. [VELCRO One-Wrap 8 × ½ in, 5-pack, Home Depot 90438ACS](http://www.homedepot.com/p/VELCRO-brand-8-in-x-1-2-in-One-Wrap-Straps-Multicolor-5-Pack-90438ACS/202261928), $3.97. It has hooks on one side and loops on the other, so it closes on itself. A zip tie in the same slots works too, but you'd have to cut it to get the cell out.
- [ ] **Small black zip ties**, UV-rated, for the protection board, the wiring, the panel cable and the lock pin's tether.

## Screws, nuts and inserts for the enclosure

Stainless where you can. Most of these come in a basic M2/M3 assortment. Only the lock-tab nut is really needed: the latch and the printed buttons do the jobs the rest used to, and the screws are there if you'd rather use them.

- [ ] **Lock-tab nut:** 1 × plain M3 hex nut (DIN 934, 5.5 mm across flats, 2.4 mm thick), 2 for C. It gets sealed inside the base (A and C), the can (B) or the sleeve (C) during printing, so the lock screw has something to go into if you ever want it, and it can't be added later. It has to be a plain nut; the nylon-insert lock nuts in the bracket are too tall for the lock tab.
- [ ] **Lock screw (optional):** 1 × M3 × 20 socket-head screw, 1 × M3 split lock washer (DIN 127) and 1 × M3 flat washer (DIN 125), 2 of each for C. The split washer goes under the head, then the flat washer, so the split washer never bites into the plastic.
- [ ] **Sled (optional):** 2 × M3 × 8 or M3 × 10 socket-head screws and 2 × M3 heat-set inserts, 5 mm wide (the fit test checks the hole size). The sled clicks into the floor without them.
- [ ] **Boards (optional):** 8 × M2 × 5 screws with washers, and 8 × M2 heat-set inserts, 3.5 mm wide. That's four for the charger, one for the MiniBoost and three for the RAK19003. Only if you use screws instead of the printed turn buttons.

## Mounting hardware

Pick the section for your mount style. The #10 screws go into the tree, and all of them need pan heads, not flat heads, because the heads sit in flat-bottomed recesses. On thick-barked trees like Jeffrey pine, the screws need to get well through the bark into solid wood, so go for 3 in.

**The M3 screws into the panel mount** depend on how thick the mount's base is where the screws go through. With a flat washer under each head, use **M3 × 16 for a base up to 5 mm thick** and **M3 × 20 for 5.5 to 9 mm**. In between, use M3 × 18. On version A, don't go longer: the screw would reach the tree before its head seats.

**No thread-locker.** The bracket's nuts are nylon-insert lock nuts, and the wing nuts get split lock washers, so nothing needs glue. Liquid thread-lockers like Loctite 242 and 243 aren't meant for use on thermoplastics like ASA, because they can crack them.

**Tree-screw mount**

- [ ] 2 × #10 stainless pan-head screws, 3 in. For the keyhole and the rail. [Bolt Dropper #10 × 3 in, 25-pack, Amazon B07D1LK3QB](https://www.amazon.com/dp/B07D1LK3QB). For thinner bark, 2 in is enough: [Everbilt #10 × 2 in, Home Depot 802932](https://www.homedepot.com/p/Everbilt-10-x-2-in-Stainless-Steel-Phillips-Pan-Head-Sheet-Metal-Screw-20-Pack-802932/204275054), $6.87 for 20.
- [ ] 1 × stainless wood screw for the panel mount's top hole. Use a #6 if it fits the mount's hole, or drill that one hole out to 4.5 mm (3/16 in is fine too) and use a #8. It should be 3 in long for A and 3½ in for B and C, whose pad stands further out. Match the head to the mount's hole: flat head if the hole is countersunk.
- [ ] 2 × M3 socket-head screws (× 16 or × 20, see above) and 2 × M3 flat washers.
- [ ] 2 × M3 nylon-insert lock nuts (DIN 985, 5.5 mm across flats, 4 mm thick), sealed in the bracket.

**Bolt-on mount**

- [ ] 3 × #10 stainless pan-head screws, 3 in (or 2 in on thin bark). For the keyhole, the rail and the top.
- [ ] 3 × M3 socket-head screws (× 16 or × 20, see above) and 3 × M3 flat washers.
- [ ] 3 × M3 nylon-insert lock nuts (DIN 985), sealed in the bracket.
- [ ] Or, instead of the tree screws: 2 or 3 straps (see below).

**Wing-nut mount**

- [ ] 3 × #10 stainless pan-head screws, 3 in (or 2 in on thin bark). For the keyhole, the rail and the top.
- [ ] 3 × M3 × 25 hex-head bolts (DIN 933, fully threaded, stainless). The heads sit in hex pockets on the back of the bracket. On B and C, the three printed spacers in the file go in behind them. M3 × 25 suits a mount base up to 8 mm thick.
- [ ] 3 × M3 wing nuts (DIN 315, stainless). Hardware stores often only have M4 and up, so you may need to order these online.
- [ ] 3 × M3 split lock washers (DIN 127) and 3 × M3 flat washers (DIN 125), one of each under every wing nut: flat washer on the mount, split washer on that, then the wing nut.
- [ ] A strip of tape, to hold the bolts in the bracket while you hang it.
- [ ] Or, instead of the tree screws: 2 or 3 straps (see below).

## Straps

For any mount as extra hold, or instead of tree screws on the bolt-on and wing-nut mounts.

- [ ] Up to 3 × 1 in polyester cam-buckle straps, long enough to go round your tree with some to spare. The webbing must be no thicker than 2 mm so the enclosure slides over it. [Husky 1 in × 10 ft, 2-pack, Home Depot FH0904](https://www.homedepot.com/p/Husky-10-ft-x-1-in-Cam-Buckle-Tie-Down-Straps-with-S-Hook-2-Pack-FH0904/206802314), $7.98. Cut off the S-hooks. One pack covers one or two straps; get two packs for three.

How many: one strap in the middle channel as extra hold with tree screws. With no screws in the tree, two straps in the low and high channels, or all three. Use straps rather than screws on a tree that isn't yours.

## Filament

- [ ] **ASA, 1 kg,** white or light grey. [Polymaker ASA](https://shop.polymaker.com/products/asa), $29.99. Version A uses about 540 g, B about 645 g and C about 700 g, plus roughly 135 g for the test pieces. Use ASA rather than PLA or PETG, because it holds up to sun and heat. A light color keeps the box cooler in summer.

## Tools

- 3D printer that can print ASA, ideally enclosed, with a 256 × 256 mm bed. The brackets only fit on the diagonal. Everything here was sized for a Bambu Lab P1S.
- Calipers, for the panel mount's hole spacing. A ruler and a phone camera will get you close ([how](customizing.md#the-panel-mounts-holes)), and the mount test disc confirms it.
- Soldering iron, 60 W or more with a wide chisel tip for the cell tabs, plus solder and flux.
- Multimeter.
- Heat gun or lighter for the heat shrink.
- A 2.5 mm hex key for the M3 socket heads (and 1.5 mm if you use M2 screws for the boards), a Phillips screwdriver and small pliers. For B, long-nose pliers and a long 2.5 mm hex driver, because the can's floor is a long reach down.
- An 8 mm (5/16 in) nut driver for the SMA bulkhead nut.
- A craft knife, and 2.5 mm and 5 mm drill bits turned by hand, to clear a string of plastic from the lock screw or pin holes if needed. A 4.5 mm (3/16 in) bit if you need to open up the panel mount's top hole for a #8 screw.
- Drill with a 3 mm (1/8 in) bit for pilot holes in the tree.
- A computer with a USB-C cable and Chrome or Edge, to flash MeshCore.
- A freezer, for the cold cutoff test.

## Shopping list by store

The same parts, grouped by where to order them. Quantities are for one repeater. Where it depends on the mount, the numbers are given as tree-screw / bolt-on / wing-nut. Where version C needs more, that's noted.

### Rokland

- [ ] RAK WisBlock Mini starter kit, US915 (RAK19003 + RAK4631), [SKU 115093](https://store.rokland.com/products/rakwireless-mini-meshtastic-starter-kit-us915-rak19003-4631-sku-115093), × 1, $31.97
- [ ] Optional: [RAK1901 sensor](https://store.rokland.com/products/rak-wireless-rak1901-temperature-and-humidity-sensor-sensirion-shtc3-pid-100001), × 1, $7.97
- [ ] Optional: [ALFA AOA-915-5ACM antenna](https://store.rokland.com/products/alfa-aoa-915-5acm-5-dbi-omni-outdoor-915mhz-802-11ah-mini-antenna-for-lora-halow-application), × 1, $14.97, and [SMA-male to N-female adapter](https://store.rokland.com/products/sma-male-to-n-female-connector-adapter-pigtail), × 1, $5.97

### Mouser

- [ ] [Adafruit bq25185 charger, 485-6091](https://www.mouser.com/ProductDetail/Adafruit/6091?qs=a2MtRaTmNOTWXd0vZOQVyw%3D%3D), × 1, $6.95
- [ ] [Adafruit MiniBoost 5 V, 485-4654](https://www.mouser.com/ProductDetail/Adafruit/4654?qs=W%2FMpXkg%2BdQ5I%2FGLylc3f4Q%3D%3D), × 1, $3.95
- [ ] [Vishay NTCLE413E2103F102L thermistor](https://www.mouser.com/ProductDetail/Vishay-BC-Components/NTCLE413E2103F102L?qs=RECgZY%2BK1xLdr8BN5MEzIw%3D%3D), × 1, $1.47
- [ ] [Littelfuse 0251002.MXL 2 A fuse, 576-0251002.MXL](https://www.mouser.com/ProductDetail/Littelfuse/0251002MXL?qs=bpnLQM2ZShzafpYR%2Fng7qQ%3D%3D), × 2, $1.24 each
- [ ] [JST-PH 2-pin cable, female, 100 mm, 485-261](https://www.mouser.com/ProductDetail/Adafruit/261?qs=GURawfaeGuDeA9XsXeF0ug%3D%3D), × 3, $0.75 each
- [ ] [JST-PH 2-pin cable, male, 200 mm, 485-3814](https://www.mouser.com/en/ProductDetail/Adafruit/3814?qs=%252BEew9%252B0nqrBFmoDCETN4BA%3D%3D), × 1, $0.75
- [ ] [Amphenol LTW M12 vent, 523-VENT-PS1YBKN8001](https://www.mouser.com/ProductDetail/Amphenol-LTW/VENT-PS1YBK-N8001?qs=5aG0NVq1C4wAxWre7fChJA%3D%3D), × 1, $2.92
- [ ] [TE ATUM-6/2 adhesive heat shrink, 650-ATUM62](https://www.mouser.com/ProductDetail/TE-Connectivity-Raychem/ATUM-6-2-0-STK?qs=pKEKwWK3ewNoklO%2FUHxqaA%3D%3D), × 1, $9.96, if you don't have some
- [ ] Optional: [Adafruit INA219, 485-904](https://www.mouser.com/ProductDetail/Adafruit/904?qs=GURawfaeGuDOI%2Fva45%252BkSg%3D%3D), × 1, $9.95

### eBay

- [ ] [Gotion 33140 LiFePO4 cell, 15 Ah, item 398342236906](https://www.ebay.com/itm/398342236906), × 1, $5.00
- [ ] [U.FL to SMA-female bulkhead pigtail, RG178, item 387516099576](https://www.ebay.com/itm/387516099576), × 1, $2.48: choose 8 in and SMA female (not RP-SMA)

### Amazon

- [ ] [Rebower 5 V 4 W panel with round mount, B0GZQ6PYRX](https://www.amazon.com/dp/B0GZQ6PYRX), × 1, $14.19 (or the [2-pack B0GZQ4R3N9](https://www.amazon.com/dp/B0GZQ4R3N9), $22.49)
- [ ] [Teyleten 1S LiFePO4 protection boards, 10-pack, B0GCWCHGFX](https://www.amazon.com/dp/B0GCWCHGFX), × 1 pack, $6.99
- [ ] [DANCO silicone grease, B000DZFUPC](https://www.amazon.com/dp/B000DZFUPC), × 1, $5.48
- [ ] [Permatex 82180 Ultra Black silicone, B0002UEN1U](https://www.amazon.com/dp/B0002UEN1U), × 1, $7.56
- [ ] [Bolt Dropper #10 × 3 in stainless pan-head screws, 25-pack, B07D1LK3QB](https://www.amazon.com/dp/B07D1LK3QB), × 1 pack (you need 2 / 3 / 3)

### Home Depot

- [ ] [VELCRO One-Wrap straps, 8 × ½ in, 5-pack, 90438ACS](http://www.homedepot.com/p/VELCRO-brand-8-in-x-1-2-in-One-Wrap-Straps-Multicolor-5-Pack-90438ACS/202261928), × 1 pack (you need 1), $3.97
- [ ] [Husky 1 in × 10 ft cam-buckle straps, 2-pack, FH0904](https://www.homedepot.com/p/Husky-10-ft-x-1-in-Cam-Buckle-Tie-Down-Straps-with-S-Hook-2-Pack-FH0904/206802314), × 1 pack for one or two straps, × 2 for three, $7.98 a pack
- [ ] Thin bark only, instead of the 3 in screws: [Everbilt #10 × 2 in stainless pan-head, 20-pack, 802932](https://www.homedepot.com/p/Everbilt-10-x-2-in-Stainless-Steel-Phillips-Pan-Head-Sheet-Metal-Screw-20-Pack-802932/204275054), $6.87

### Mykin

- [ ] [EPDM 70A O-ring, AS568-153, MO-153-RE00170](https://mykin.com/as568-153-epdm-70.html), × 2 (× 3 for C), $1.29 each

### Polymaker

- [ ] [Polymaker ASA, 1 kg](https://shop.polymaker.com/products/asa), × 1, $29.99

### Bolt Depot

Bolt Depot sells metric stainless hardware by the piece. Everything here is 18-8 (A2) stainless.

- [ ] [M3 nylon-insert lock nuts, DIN 985, 4 mm thick](https://boltdepot.com/Product-Details?product=4792), × 2 / 3 / 0, $0.07 each
- [ ] [M3 flat washers](https://boltdepot.com/Product-Details?product=4513), × 2 / 3 / 3 for the panel mount, plus 1 for each lock screw (2 for C)
- [ ] [M3 split lock washers](https://boltdepot.com/Browse?Category=Washers&F_Size=3mm&Subcategory=Lock_washers&Units=Metric), × 0 / 0 / 3 for the wing nuts, plus 1 for each lock screw (2 for C)
- [ ] [M3 socket-head screws](https://boltdepot.com/Browse?Category=Socket_screws&F_Diameter=3mm&Units=Metric): × 2 / 3 / 0 at 16 or 20 mm for the panel mount; optionally × 1 at 20 mm for the lock screw (2 for C) and × 2 at 8 or 10 mm for the sled
- [ ] M3 hex nut, plain (DIN 934), × 1 (2 for C): the lock-tab nut
- [ ] [M3 × 25 fully threaded hex bolts (tap bolts, DIN 933)](https://boltdepot.com/Browse?Category=Hex_bolts&F_Diameter=3mm&Units=Metric), × 0 / 0 / 3
- [ ] Optional, instead of the turn buttons: M2 × 5 screws and M2 washers, × 8 each

### boltsandnuts.com

- [ ] Wing-nut mount only: [M3 stainless wing nuts, DIN 315](https://boltsandnuts.com/products/m3-0-5-stainless-steel-wing-nuts), × 3, $0.68 each. Bolt Depot's M3 wing nuts are zinc-plated steel, which will rust on a tree.

### Anywhere

These are common enough that any electronics or hardware supplier, or an Amazon assortment, will have them.

- [ ] Optional: M3 heat-set inserts, 5 mm wide, × 2 (to screw the sled down), and M2 heat-set inserts, 3.5 mm wide, × 8 (to screw the boards down)
- [ ] ¼" NPT IP68 cable gland for a 3.5 to 4 mm cable, × 1
- [ ] Tree-screw mount only: a #6 or #8 stainless wood screw, 3 in (A) or 3½ in (B and C), × 1
- [ ] Small black UV-rated zip ties and a small silica gel packet
- [ ] Optional: a 1000 µF low-ESR capacitor, 10 V or more, on a JST-PH 2-pin plug

## Alternatives

Other places to get the parts that are most likely to be out of stock or hard to find.

| Part | Also available from | Notes |
|---|---|---|
| RAK WisBlock Mini starter kit | [Amazon B0DFMMTQZM](https://www.amazon.com/RAKwireless-WisBlock-Meshtastic-Starter-RAK19003/dp/B0DFMMTQZM) | Same kit with the RAK19003 base. The bigger RAK19007 kit won't fit the sled. |
| Adafruit bq25185, MiniBoost, JST cables, INA219 | [Adafruit](https://www.adafruit.com/product/6091) directly, or Digi-Key | Search by the Adafruit product number (6091, 4654, 261, 3814, 904). |
| O-ring, AS568-153 EPDM | [The O-Ring Store](https://www.theoringstore.com/store/index.php?main_page=product_info&products_id=6695), [Gallagher Seals](https://www.gallagherseals.com/epdm-70a-o-ring-size-153-3-487-id-x-0-103-cs.html) | Any EPDM 70 in size 153 is the same part. |
| M3 stainless hardware | McMaster-Carr, or an M3 stainless assortment on Amazon | Make sure the lock nuts are DIN 985 (4 mm thick, nylon insert). |
| 1 in straps | Any polyester cam-buckle or ratchet strap | Webbing no thicker than 2 mm. Avoid nylon webbing, which stretches when it's wet. |
| ½ in cell strap | [VELCRO One-Wrap, 8 × ½ in, black 25-pack, Amazon B0006BB9MG](https://www.amazon.com/dp/B0006BB9MG), or any ½ in hook-and-loop cable strap about 8 in long | It must be ½ in (12.7 mm) wide or narrower to fit the slots and the gap behind the charger. |
| U.FL to SMA pigtail | [Amazon B07TXH2N83](https://www.amazon.com/dp/B07TXH2N83), or any 20 cm RG178 U.FL to SMA-female bulkhead lead | Check it's SMA, not RP-SMA, and comes with a nut. |
| Solar panel | Other 5 V camera panels with a round three-hole mount | Print the mount test disc to check the hole spacing first. |
| M12 vent | Other M12 × 1.5 breather vents | The floor's pocket fits a nut up to 16 mm across flats. |
