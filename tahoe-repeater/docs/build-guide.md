# Build guide

This is the whole build, start to finish, in the order I'd do it. Read it through once before you start. Several steps depend on things you did earlier, and the battery steps need care.

Everything here applies to all three versions. Where they differ, it says so. **A** has a fixed top and a base that screws up into it. **B** has a fixed can and a lid that screws on top. **C** has a fixed sleeve, with A's base screwed into its bottom and B's lid on its top.

- [1. Before you start](#1-before-you-start)
- [2. Print the parts](#2-print-the-parts)
- [3. Check the fit](#3-check-the-fit)
- [4. Set up the charger](#4-set-up-the-charger)
- [5. Build the cell harness](#5-build-the-cell-harness)
- [6. Test the cold cutoff](#6-test-the-cold-cutoff)
- [7. Fit out the floor](#7-fit-out-the-floor)
- [8. Bring in the panel cable](#8-bring-in-the-panel-cable)
- [9. Hose-test the empty enclosure](#9-hose-test-the-empty-enclosure)
- [10. Build up the sled](#10-build-up-the-sled)
- [11. Put it all in](#11-put-it-all-in)
- [12. Flash MeshCore](#12-flash-meshcore)
- [13. Bench-test it for a day](#13-bench-test-it-for-a-day)
- [14. Close it up](#14-close-it-up)
- [15. Mount it](#15-mount-it)
- [16. Opening it later](#16-opening-it-later)
- [17. Troubleshooting](#17-troubleshooting)
- [Why it's hard to set on fire](#why-its-hard-to-set-on-fire)
- [Power budget](#power-budget)

<img src="../images/inside-A.png" alt="Version A's base with the sled, boards and cell fitted">

## 1. Before you start

1. **Pick your file.** The [README](../README.md#pick-a-file) explains the nine. If you're at altitude or in snow country, build A.
2. **Measure your panel mount.** Take the round mount off the panel and measure between the centers of two of its three screw holes, with calipers if you have them ([no calipers?](customizing.md#the-panel-mounts-holes)). The brackets are drawn for 36 mm. If yours is different, follow [Changing the design](customizing.md) to export a bracket that matches. Either way, print the mount test disc and check it (section 3) before you print the bracket. While you have the mount out, measure how thick its base is at the holes. With a washer under each head, M3 × 16 screws suit a base up to 5 mm thick, and M3 × 20 from 5.5 to 9 mm.
3. **Get the parts together.** The [parts list](parts-list.md) is a checklist, and it's also [sorted by store](parts-list.md#shopping-list-by-store) for ordering.
4. **Respect the cell.** A 15 Ah cell can push well over 100 A into a short. Keep its tabs covered whenever you're not working on them, don't let tools bridge them, and fit the fuse before anything else touches it.

## 2. Print the parts

### Settings

ASA, 0.4 mm nozzle, 0.2 mm layers (first layer 0.2 mm too), 7 walls, 30% gyroid infill, 5 top and 5 bottom layers. Keep the P1S door and lid closed, because ASA warps in drafts. A brim isn't needed on a clean plate, but use glue stick if your ASA tends to lift. If your first layers tend to squish out, turn on elephant-foot compensation. The rim of the top, the lid or the sleeve is the first layer, and it has to be round.

### Split the file into plates

Load your file in Bambu Studio, right-click it and choose **Split > To objects**. You get ten parts for A or B and twelve for C, plus three small spacers with the wing-nut mount on B or C. The parts that take a nut do it at different heights, so give each one its own plate and every plate needs at most one pause.

| Plate | A | B | C |
|---|---|---|---|
| 1 | Test pieces and the lock pin | Test pieces, the lock pin and any wing-nut spacers | Test pieces, both lock pins and any wing-nut spacers |
| 2 | Top | Can, sled and buttons: **pause at 134.8 mm** | Sleeve: **pause at 126.8 mm** |
| 3 | Base, sled and buttons: **pause at 4.8 mm** | Lid, with supports | Base, sled and buttons: **pause at 4.8 mm** |
| 4 | Bracket: **pause at 9.2 mm** | Bracket: **pause at 29.2 mm** | Lid, with supports |
| 5 | | | Bracket: **pause at 29.2 mm** |

The wing-nut brackets don't need a pause. The test pieces are the two thread test rings, the fit-test bar and the mount test disc. The bracket is already turned 45° in the file so it fits the bed diagonally. Keep it that way, and if you use Arrange, don't let it rotate parts.

**Lid (B and C):** turn on supports for that plate: tree supports, **build plate only**. They fill the inside of the lid under its sloped roof and snap out afterwards. Nothing else needs supports.

**Buttons:** the nine turn buttons print flat on a thin spine. Snap them off it afterwards and trim any nub with a knife.

### Print the test pieces first

Plate 1 takes about five hours. Section 3 shows what to check. It's much better to find a fit problem here than after a nine-hour print.

### Add the pauses

The A and C base, the B can and the C sleeve each have a hex pocket in a lock tab, which takes a plain M3 hex nut for the lock screw: the lock-tab nut. It can't be added after printing, so put it in even if you don't plan to use the screw. If you're sure you never will, you can leave it out and skip that pause. The tree-screw and bolt-on brackets have two or three deeper pockets under the panel mount, which take M3 nylon-insert lock nuts. Each nut goes in partway through the print, and then the printer prints over it and seals it in.

1. Slice the plate and switch to **Preview**.
2. Drag the vertical layer slider to the height in the table: the first layer that closes over the pockets.
3. Right-click the **+** next to the slider and choose **Add Pause**.
4. Check: step one layer down and you should see the pockets still open.

| Part | Pause at | Nuts |
|---|---|---|
| A or C base | 4.8 mm | 1 lock-tab nut (plain hex) |
| B can | 134.8 mm (near the end) | 1 lock-tab nut (plain hex) |
| C sleeve | 126.8 mm (near the top) | 1 lock-tab nut (plain hex) |
| Bracket A, tree-screw | 9.2 mm | 2 lock nuts |
| Bracket A, bolt-on | 9.2 mm | 3 lock nuts |
| Bracket B or C, tree-screw | 29.2 mm | 2 lock nuts |
| Bracket B or C, bolt-on | 29.2 mm | 3 lock nuts |
| Any wing-nut bracket | no pause | none |

These heights assume 0.2 mm layers from the first layer up. If you print with different layers, look for the layer that first covers the pockets in the preview.

### When it pauses

The printer stops before the covering layer, with the pockets open.

- **Bracket:** drop an M3 nylon-insert lock nut into each pocket, **nylon side down**, so the plain metal face is on top. The screws come in from the front of the bracket, which is the top of the print, so this way they meet the metal thread first and the nylon grips them on the way through.
- **Base, can or sleeve:** drop the lock-tab nut, a plain M3 hex nut, into the pocket in the lock tab.

Each nut should fall in flat and sit a little below the top of its pocket. Push it down with a small screwdriver so it's level and nothing sticks up, then resume. The nozzle passes about half a millimetre over the nut, so one sitting proud will get hit.

<img src="../images/pause-bracket.png" width="49%" alt="Bracket at its pause: the lock nuts sit in hex pockets in the round foot under the panel mount"> <img src="../images/pause-base.png" width="49%" alt="A base at its pause: the nut sits in the lock tab">

*What the bracket (left) and the A base (right) look like at the pause, with the nuts in. The bracket prints tree-side down, so at the pause it's just the feet. The can and the sleeve look like the base, but near the top of the print.*

## 3. Check the fit

<img src="../images/test-prints.png" alt="The two thread test rings with the O-ring, the fit-test bar and the mount test disc">

**Mount test disc.** This is the bracket's pad, cut down to 4 mm thick. Set your panel's round mount into the pocket with its top hole at the tab. The base should drop in and sit flat without forcing. Then push an M3 screw through each of the mount's three holes: all three should go straight through the disc as well.

<img src="../images/mount-test.png" alt="The mount test disc on its own, and with a panel mount dropped in and M3 screws through its holes">

- If the base won't go in, or rattles around, change `MOUNT_D`.
- If the holes don't line up, measure again, change `MOUNT_HOLE_SPACING` (and `MOUNT_HOLE_ANG` if the holes aren't evenly spaced) and print a new disc. [Changing the design](customizing.md#the-panel-mounts-holes) shows how.
- Once the disc fits, the bracket will too, as long as you export the bracket with the same settings.

**Fit-test bar.** Press an M3 heat-set insert into each of the three larger holes (4.1, 4.3 and 4.5 mm) and an M2 insert into each of the smaller ones (3.0, 3.1 and 3.2 mm). The file uses 4.3 for the M3 inserts in the floor and 3.1 for the M2 inserts in the sled. Both are only needed if you screw the sled or the boards down instead of using the prongs and buttons. If another size holds better, change `INSERT_D` or `M2_INSERT_D` in the source ([how](customizing.md)). An M3 nylon-insert lock nut should drop easily into the pocket marked *nut* and sit below the surface, and so should a plain M3 nut. The pocket marked *bolt* opens on the underside. A wing-nut bolt's head should push into it snugly.

**Thread test rings.** These are the joint, cut off short, with the same lock tabs as the enclosure. Their nut pocket doesn't need a nut, so skip the pause. Grease the O-ring lightly and roll it into the groove at the foot of the male ring's spigot. Line up the female ring's tab with the nub on the male ring, set it on and push down. It only drops in at that one angle. Turn it clockwise (seen from above), about a quarter turn. Near the end the latch arm rides up over its post, then clicks in behind it, and the ring stops with the two tabs lined up and the O-ring out of sight in the bore.

- It should turn by hand, getting firmer over the last part as the O-ring goes into the bore.
- If it's very stiff, check it's the right O-ring (AS568-153) and that it's greased. Then look at the female ring's rim: if the first layers bulged inward, scrape the inside edge back with a knife.
- If it feels loose, it'll still seal, because the O-ring does the sealing. Just check it can't be pulled apart without turning.
- **Try the latch.** Turn the female ring back the other way. The latch should stop it. Pull the latch tab straight out, away from the ring, about 2 mm, and start turning. Once it's moved a few degrees you can let go of the tab.
- **Try the pin.** Close the rings again, push the lock pin down through the slot in the female ring's tab until it clicks into the male ring, then pull it back out by its ring. It should take a firm tug.

## 4. Set up the charger

On the back of the Adafruit bq25185:

1. **Cut the VS jumper and bridge the 3.65 V pad.** That sets the charge voltage for LiFePO4. Left as it comes, it charges to 4.2 V, which is for lithium-ion and will damage this cell.
2. **Cut the TH jumper and solder the thermistor's two leads to TH and GND.** With the thermistor on the cell, the charger won't charge when it's too cold or too hot.
3. **Leave IS alone.** The default 500 mA suits this cell and panel.

## 5. Build the cell harness

The cell has flat copper tabs on its ends, not screw terminals.

1. **Best:** have a short nickel strip spot-welded to each tab (a battery or e-bike shop will do it, or use a handheld welder), then solder your leads to the strips, away from the cell.
2. **Otherwise,** solder the leads straight to the tabs, quick and hot. Use a 60 W or stronger iron with a wide chisel tip at about 400 °C. Tin the tab with one touch of two or three seconds, tin the lead, then join them in a second or two. Let the cell cool between joints. **Never hold the iron on the cell.**
3. Wire it in this order: cell **+** → 2 A fuse, within 2 cm of the tab → protection board **B+**. Cell **−** → protection board **B−**. Protection board **P+** and **P−** → a JST-PH female lead. The cell will stand positive end up, and the protection board sits near the top of the sled, so leave the leads long enough to reach.
4. Check the polarity with a meter against the **BATT** marking on the charger before you plug anything in.
5. Seal the fuse and every splice in adhesive-lined heat shrink.

## 6. Test the cold cutoff

Do this on the bench, before the cell goes anywhere near the radio.

1. Plug the cell into **BATT** and feed the charger 5 V through its USB-C port. The orange CHRG light comes on.
2. Put the thermistor in a sealed bag in the freezer, or in salted ice water at −5 °C or colder (plain ice water sits right at the trip point).
3. Within a few minutes, charging should stop and the red FAULT light come on. It starts again once the thermistor warms up past about 6 °C.
4. If charging never stops, the TH jumper isn't fully cut.

Then unplug the cell from **BATT**. Tape the thermistor flat against the side of the cell and keep its two leads apart. Sleeve the protection board in heat shrink.

## 7. Fit out the floor

Everything here goes in the floor of the base (A and C, the same part) or the can (B). Do it in this order, while the part still sits flat on the bench.

**On B,** the floor is about 13 cm down inside the can, through an 84 mm opening. A long 2.5 mm hex driver, long-nose pliers and a slim soldering-iron tip make it much easier.

1. **Inserts (optional).** The sled clicks into the floor, so these are only for screwing it down as well. Press the two M3 inserts into the two round bosses on the floor. Use a soldering iron at around 240 °C and let each one sink in under its own weight, flush with the top. Don't push hard.
2. **Vent.** From inside, push the vent's threaded stem down through the 12.4 mm hole, with its O-ring against the floor. From underneath, drop its nut into the hex pocket. Then turn the vent body from inside to screw it into the nut until snug. Amphenol specifies only 0.6 to 0.8 N·m, which is not much more than firm finger-tight.
3. **Cable gland.** Push the ¼" gland up through its hole from underneath, with its sealing ring on the outside. Tighten the lock nut inside, in its shallow round pocket.
4. **Antenna socket.** Put a thin bead of the sensor-safe silicone round the SMA bulkhead's flange. Push it down through the floor of its pocket from inside. Hold it with long-nose pliers while you tighten the lock washer and nut from below with a hollow 8 mm (5/16") nut driver. Wipe off any silicone that squeezes out inside, and let it cure.

## 8. Bring in the panel cable

1. Cut the plug off the panel's cable, leaving plenty of length. You won't need the USB adapter.
2. With the panel in the sun, find **+** and **−** with a meter. Tape off any other wires.
3. Push the cable up through the gland from below and tighten the gland's dome nut on it.
4. Solder the JST-PH female lead on inside, and seal the joints with heat shrink.

From here on, the panel and the base (or can) stay joined by this cable.

## 9. Hose-test the empty enclosure

Do this now, with no electronics inside, so a leak only wets a paper towel.

1. Put a dry paper towel inside, and screw the antenna (or an SMA dust cap) onto the bulkhead underneath, so no water gets into the connector.
2. Grease the O-ring and roll it into the groove at the foot of the spigot. Check it isn't twisted.
3. Put the two halves together (see [Close it up](#14-close-it-up) for how the tabs and nub line up) and turn until the latch clicks. On C, test both joints: fit the sleeve to the base and the lid to the sleeve.
4. Spray it from every side with a garden hose for 10 minutes. Aim up at the joint, the gland, the vent and the antenna socket.
5. Open it and check the towel. If it's dry, move on. If not, find the wet spot and fix that seal.

## 10. Build up the sled

The boards can be held by the printed turn buttons or by M2 screws. The buttons need no tools and no inserts. The steps below use the buttons, with the screw way in brackets.

1. **Cell strap.** Do this before the charger goes on. Thread the ½ in hook-and-loop strap in through one of the two long slots at the sides of the sled, across the front of the sled where the charger will sit, and out through the other slot. Pull it through until the ends hanging out the back are about the same length. It lies flat against the sled, behind the charger, in the only band across the front that's clear of every standoff and post.
2. **Sensor (optional).** If you have a RAK1901, plug it into slot C or D on the underside of the RAK19003 and screw it down before the board goes on the sled.
3. **Buttons.** Snap the nine turn buttons off their spine. Press one onto each post beside the board positions. The C-shaped end clicks over the post's head and then turns stiffly on it.
4. **Boards.** Swing the buttons out of the way. Set the RAK19003 (with the RAK4631 plugged in on top) on its three standoffs, the charger on its four and the MiniBoost on its one, and swing each button back over its board, so its foot sits on the pad round the mounting hole. That's four buttons for the charger, three for the RAK19003 and two for the MiniBoost. (With screws instead: press the eight M2 inserts into the standoffs, the same way as the M3s, and screw the boards down with M2 × 5 screws and washers.)
5. **Protection board.** Zip-tie it to the sled in the empty space at the top left, through the two slots there.
6. **Power path.**
   - Solder the JST-PH male lead to the charger's **DC in** pads. The panel plugs into it.
   - Run **LOAD** to the MiniBoost's **VIN** and GND on a JST-PH pigtail.
   - Cut the USB-A end off the kit's USB-C cable. Solder red to the MiniBoost's **5 V** and black to **GND**, and insulate the data wires. Plug the USB-C end into the RAK19003.
   - **Never connect the cell, or any battery, to the RAK's BAT or SOLAR connectors.** The RAK's own charger is for lithium-ion. The optional 1000 µF capacitor in [Troubleshooting](#17-troubleshooting) is the only thing that ever goes on BAT.
7. Put adhesive heat shrink on every splice, and zip-tie the leads through the sled's small slots.

## 11. Put it all in

1. **Antenna lead.** Plug the U.FL end of the pigtail onto the RAK4631's LoRa connector (not the Bluetooth one). Leave the little Bluetooth antenna on its own connector so you can update over the air later. Coil any spare length of the pigtail in front of the boards.
2. **Sled and cell.** The cell goes in its cup behind the sled, positive end up, with its negative lead coming out through the gap at the front of the cup. The sled's two prongs go into the two sockets in the floor.
   - **A and C (the base):** stand the cell in its cup first. Then lower the sled straight down in front of it until the prongs click, and wrap the two ends of the strap round the back of the cell and press them together, pulling it snug.
   - **B (the can):** it's hard to reach behind the cell down in the can, so strap the cell to the sled first and lower the two together. Put the cell's bottom end 3 to 5 mm above the bottom edge of the sled (not counting the prongs), with its middle 5 mm left of the sled's middle, seen from the board side. The cup's sloped rim steers the cell in the last millimetre or two. Push the sled straight down until it clicks.

   Keep the fuse and leads clear of board edges. If you fitted the M3 inserts, you can also screw the sled's feet down with two M3 × 8 (or × 10) screws.
3. **Antenna.** Smear a little silicone grease on the bulkhead's outer thread (not inside the connector) and screw the antenna on underneath, by hand. It hangs straight down, which works as well as pointing up. **Never power the radio without an antenna on.**
4. Now plug the cell's lead into **BATT**, and the panel lead into the charger's DC in lead.

## 12. Flash MeshCore

1. Unplug the power lead from the RAK's USB-C port and plug your computer in instead.
2. Open [flasher.meshcore.co.uk](https://flasher.meshcore.co.uk) in Chrome or Edge and install **RAK 4631 Repeater** (1.17.1 or newer).
3. Set the node's name, an admin password and the radio settings for your mesh.
4. From the repeater's command line, over USB or from the app once you're logged in as admin, run `powersaving on`. It cuts what the radio draws by about half.
5. Plug the power lead back in.

If you fitted a RAK1901, check the node's telemetry in the MeshCore app. Recent MeshCore builds for the RAK4631 look for common I²C sensors at startup, including the RAK1901's SHTC3. If it doesn't show up, your build doesn't include it.

## 13. Bench-test it for a day

Leave it open on the bench with the panel in the sun, and send plenty of traffic through the node for 24 hours.

- Check the charge current once with a meter in the battery lead. It should be up to about 0.5 A in full sun.
- The cell should settle at 3.65 V or less. **If it climbs past 3.65 V, unplug the cell at once** and check the VS jumper is fully cut and the 3.65 V pad bridged. Only the protection board's 3.75 V cutoff stands between an unset charger and the cell.
- The repeater's uptime should never reset when it transmits. If it does, see [Troubleshooting](#17-troubleshooting).
- After six hours of charging without a break, the charger's safety timer stops it and lights FAULT. Unplugging the input clears it. Outdoors, the dark resets it every night.

## 14. Close it up

Do this indoors, where the air is dry, and carry it out closed. All three versions go onto the bracket in one piece.

1. Drop a small silica gel packet in.
2. Wipe the O-ring and the bore (C has two of each), give each O-ring a fresh thin film of silicone grease, and check it's sitting straight in its groove.
3. **A:** stand the base on the edge of the bench so the antenna hangs over. Set the top down over it with the top's nub right above the base's tab, and push down until it drops in. Turn the top clockwise (seen from above), about a quarter turn. Near the end you'll feel the latch arm ride up over its post, and it clicks just before the joint stops with the tabs one above the other.
4. **B:** set the lid on the can with its tab right above the can's nub. Push down and turn it clockwise (seen from above) until the latch clicks and it stops over the can's tab.
5. **C:** close the bottom joint first, the same way as A, with the sleeve as the top. Then put the lid on the sleeve the same way as B.
6. **Lock pin (optional).** Push the pin down through the slot in the upper tab until it clicks into the lower tab. Thread a small zip tie through its ring and the hole next to the latch arm, and close it loosely, so the pin can't get lost when it's out.
7. **Lock screw (optional).** Put the split lock washer and then the flat washer on the M3 × 20 lock screw, and screw it down through the slot in the upper tab into the lock-tab nut sealed in the lower tab. Stop when the split washer has pressed flat. That's plenty.

## 15. Mount it

<img src="../images/steps-A.png" alt="Mounting A: bracket, then the closed enclosure slides down the rail, then the panel mount and panel">
<img src="../images/steps-B.png" alt="Mounting B: bracket, then the closed enclosure slides down the rail, then the panel mount and panel">
<img src="../images/steps-C.png" alt="Mounting C: bracket, then the closed enclosure slides down the rail, then the panel mount and panel">

### Where

- On the south side of the tree, where the panel will get midday sun in winter. The sun is low then, and a panel in shade for most of the day won't keep up.
- High enough to be out of casual reach, low enough to service from a ladder.
- **A and C:** leave about 20 cm clear below the antenna tip. The base drops about 17 cm to come out, and the antenna comes with it.
- **B and C:** leave room beside the lid to slide it off.

### Hang the bracket

**Wing-nut bracket first:** push the three M3 × 25 bolts into the hex pockets on the back, threads out the front. Nothing was printed into this bracket, so this is where the bolts go in. **On B and C,** push one of the printed spacers in behind each bolt head. Put a strip of tape over the back so nothing falls out. Once the bracket is on the tree, the tree holds them in, and you can't get at them again without taking the bracket down.

**Hanging it on straps only?** Skip to [Straps](#straps). Otherwise:

1. **Keyhole screw.** Hold the bracket where you want it, plumb, and mark the top of the keyhole's slot. Drill a pilot hole and drive a #10 pan-head screw there. Leave the underside of its head 9.5 mm (just under ⅜") off the bark.
2. Put the head through the round part of the keyhole and let the bracket drop 12 mm onto it. It now hangs on its own.
3. **Rail screw.** Drill a pilot through the hole in the rail and drive a #10 screw through the counterbore until the head sits below the face of the rail.
4. **Top screw.**
   - **Tree-screw mount:** this one goes in with the panel mount later.
   - **Bolt-on and wing-nut:** drive a #10 through the counterbored hole above the pad.
5. Tighten the keyhole screw through the front. Its head sits in a recess you can reach with a screwdriver.
6. **Cable ties.** Thread a zip tie loosely through each pair of small slots down the right-hand side of the bracket (as you face the tree), and leave them open. Once the enclosure is on, the slots are behind it, and you'll close these round the panel cable at the end.

### Straps

<img src="../images/straps-A.png" alt="The bracket's three strap channels, one strap as extra hold with the tree screws, and three straps with no screws in the tree">

The bracket has three strap channels across its front: low, middle and high.

- **As extra hold,** with the screws in: one strap in the middle channel.
- **Instead of tree screws,** on the bolt-on and wing-nut brackets: two straps in the low and high channels, or all three. The tree-screw bracket always needs its one screw through the panel mount.

1. Fit the straps before the enclosure goes on. It slides down the rail over them.
2. Hold the bracket where you want it, plumb, and loosely buckle a strap round the trunk and across the front of the bracket, lying flat in its channel. Without screws, start with the high channel.
3. Add the others the same way. Keep each one flat and untwisted across the bracket, and turn the buckles round to the side of the tree where you can reach them.
4. Check the bracket is still plumb, then pull each strap tight, the high one last.
5. Tie off or tuck the loose ends so they don't flap in the wind.
6. Thread the cable ties through the slot pairs now, as in step 6 above.

ASA creeps a little under a tight strap, so snug them again after the first warm spell. Check them every season, and let them out a little each year so they don't cut into the tree as it grows. [Version B with straps](../images/straps-B.png) looks the same, and so does C.

### Put the enclosure on

Rest the panel on the ground at the end of its cable. Lift the closed enclosure above the bracket, line the slot in its back up with the rail and slide it down until it stops. A has to travel about 8 cm down the rail, and B and C about 6 cm. If you're using straps, they're already on, and the enclosure slides down over them.

### Fit the panel mount and panel

Set the mount's round base in the pocket with its holes lined up. On A, this is also what stops the top from being lifted off the rail.

- **Tree-screw:** put a flat washer on each of two M3 screws (× 16 or × 20, see [Before you start](#1-before-you-start)) and screw them through the two lower holes into the sealed lock nuts. They get stiff when they reach the nylon. That's the lock working, so keep turning until the mount is firm. Then drill a 3 mm pilot through the top hole and the bracket into the tree, and drive the long wood screw.
- **Bolt-on:** three M3 screws with washers into the sealed lock nuts, the same way.
- **Wing-nut:** the mount goes over the three bolts. On each one, put a flat washer, then a split lock washer, then the wing nut. Tighten by hand until the split washer is flat.

Don't put thread-locker on any of these. The lock nuts and lock washers do that job, and liquid thread-lockers can crack ASA.

Fit the panel to the mount and aim it south. Around 55° from horizontal favors winter sun at Tahoe's latitude. **On B and C, keep the tilt at about 62° or flatter,** or the panel gets in the way of the lid when you take it off.

### Tidy the cable

1. Run the cable down the right-hand side of the bracket (as you face the tree), and close the zip ties you threaded through the slot pairs round it. You can reach them from the side, in the gap between the enclosure and the bracket.
2. Let it hang in a loop that dips below the gland before it goes up into it, so water drips off the bottom of the loop instead of running into the gland.
3. **A and C:** leave about 30 cm of slack in that loop, so the base can come down for service with the cable still attached.

## 16. Opening it later

First take out the lock pin and the lock screw, if you used them. The pin stays tied on.

**Undoing the latch.** Pull the tab on the end of the latch arm straight out, away from the box, about 2 mm, and start turning. Once the joint has moved a few degrees, the hook is past the post and you can let go of the tab.

**A.** Turn the base about a quarter turn, so its tab swings from the front round to the left, then lower it straight down. It's firm for the first part of the turn while the O-ring comes out of the bore, then easy.

**B.** Turn the lid about a quarter turn, so its tab swings from the front round to the right. Lift it about a centimetre to clear the thread and slide it off sideways. To take the whole can down, take the lid off first, then lift the can about 6 cm up off its rail. It clears the panel arm.

**C.** The base comes out the bottom like A's, and the lid comes off the top like B's. Each joint has its own latch. To take the sleeve down, take the lid off, then lift the sleeve, with the base still in it, about 6 cm up off its rail.

**Taking the sled out.** With the base in your hands (A and C), or the lid off (B), unplug the panel lead at the charger and pull the sled straight up by its handle. It takes a firm pull to unclip the prongs. The cell comes with it, strapped on, because its leads run to the protection board on the sled. With the 20 cm antenna lead you can set the sled beside the base without unplugging the antenna. With a shorter one, unplug the U.FL connector by lifting it straight off with a fingernail or a U.FL tool.

The panel cable goes through the gland with its plug soldered on inside, so the base or can stays tied to the panel. To take it away from the tree, either take the panel off its mount and bring it along, or cut the plug off inside, loosen the gland and pull the cable out. You'll solder a new plug on when it goes back.

**Closing it on the tree.** Wipe the O-ring and the bore, and add a little fresh grease if they look dry. Pick a dry day, and swap the silica gel packet.

- **A, or C's base:** the top (or sleeve) stays put and the base turns. Hold the base up under it with the base's tab under the nub on the left, push up until the thread drops in, and turn the base so its tab comes round to the front, until the latch clicks and it stops.
- **B, or C's lid:** set the lid on with its tab over the nub on the right, push down until the thread drops in, and turn it so the tab comes round to the front, until the latch clicks and it stops.

Put the pin or the screw back if you use them.

While you're up there, check that the wing nuts (if you have them) are still tight and the straps (if you used them) are snug but not biting into the bark.

## 17. Troubleshooting

**The thread won't start.** It only goes together at one angle. Line the moving part's tab up with the nub on the fixed part and push before you turn.

**It's too stiff to turn all the way.** Grease the O-ring and check it's size 153: a 152 is too small and a 154 too big. Check the rim of the upper part for a bulge from the first layers and scrape the inside edge if you find one. The thread test rings are the place to sort this out.

**It stops, but the tabs don't quite line up.** A few degrees off is fine. The joint lands a little differently from print to print, and the slots in the upper tab allow for it. If it's a lot more, something is stopping it short: a pinched O-ring or dirt in the thread.

**The latch doesn't click.** It clicks 3 or 4 degrees before the joint stops, so turn until it stops. If it stops before the latch clicks, look for a pinched O-ring or dirt in the thread. If it's clean and still stops short, your thread has less play than mine: see [Changing the design](customizing.md#the-lock). If the arm doesn't spring back in, run a knife along the gap between the arm and its tab to clear any stringing from the print.

**The latch won't let go.** Pull the tab straight out, away from the box, not sideways. It only has to move about 2 mm. Don't pull it much further than it needs to go; it's a spring, not a hinge.

**The lock pin won't go in.** Check the latch has clicked, so the joint is fully closed. The pin's split end has to squeeze through the lower tab before it clicks into its groove, so it takes a firm push. If the hole has a string of plastic across it from printing, clear it with a 5 mm drill bit turned by hand.

**The sled won't click in, or the boards rattle.** Push the sled straight down, not at an angle, so both prongs go into their sockets together. If a board rattles, check its buttons are swung fully over their pads.

**The nozzle hit a nut after the pause.** The nut wasn't flat in its pocket. It should sit below the top of the pocket, so push each one down before you resume. If they won't go down, check the nut pocket on the fit-test bar.

**A panel-mount screw gets stiff partway in.** That's the nylon in the lock nut, and it's supposed to happen. Keep turning. If a screw stops dead before the mount is tight, it's too long and has reached the tree (on A). Use a shorter one; see [Before you start](#1-before-you-start).

**The enclosure won't slide down over a strap.** The strap is twisted, isn't lying flat in its channel, or its webbing is thicker than 2 mm. Straighten it, or swap it for thinner webbing.

**The lock screw won't bite.** A string of plastic may have been printed across the hole above the nut. Clear it with a pick or a 2.5 mm drill bit turned by hand, and stop when you reach the nut. Drilling into the nut would ruin its thread, and it can't be replaced.

**The node reboots when it transmits.** Running a RAK from USB with nothing on the BAT port is how desk nodes run, but its charger chip cycles on and off with no battery there. Plug a 1000 µF low-ESR capacitor on a JST-PH plug into the empty BAT port (it's in the parts list).

**MeshCore says the battery is always full.** That's expected. It measures the RAK's own supply, which the boost holds steady, not the cell. The optional INA219 can report the real cell voltage and current if you're comfortable wiring it into the RAK19003's I²C.

**It stops charging in winter.** The thermistor pauses charging below about 0 °C and lets it resume above about 6 °C. That's on purpose: LiFePO4 mustn't be charged below freezing. A month of runtime covers long cold spells.

**The charger's FAULT light is on.** After six hours of charging without a break, its safety timer stops it. Nightfall resets it. If it's on in the cold, that's the thermistor doing its job.

**Water or fog inside.** Check the O-ring is seated and greased, the gland's dome nut is tight on the cable, and the vent and antenna socket are snug. Then replace the silica gel.

## Why it's hard to set on fire

Nothing here depends on one part working. If one fails, another one stops things before they get hot.

- **LiFePO4 cell.** It's far harder to push into thermal runaway than the lithium-ion cells most solar nodes use, and it gives off much less oxygen to feed a fire if it's abused.
- **One charger, set right.** The bq25185 is the only thing that charges the cell, and it's jumpered to 3.65 V. The RAK's own lithium-ion charger never connects to it.
- **Backup cutoffs.** The protection board stops charging at 3.75 V and discharge at 2.1 V, and trips on a short.
- **Fuse at the cell.** A 2 A fast fuse within 2 cm of the positive tab turns a pinched wire into a blown fuse.
- **Temperature limits.** The thermistor pauses charging at about 0 °C and above about 60 °C, and you tested the cold cutoff before closing it up.
- **Cool charging.** A 5 V panel keeps the charger's loss to about 1 W at most. The chip also throttles itself at 100 °C and shuts off at 150 °C.
- **No deep discharge.** The charger disconnects the radio at 3.0 V and reconnects it when the sun comes back.
- **Solid connections.** Welded strips or quick, hot solder joints on the tabs, adhesive heat shrink on every splice, and a meter check of polarity before anything is plugged in.
- **Cell held still.** It sits in its cup with a strap round its middle, clear of board edges, so wind vibration can't rub through its wrap.

## Power budget

| | |
|---|---|
| Radio, MeshCore repeater with powersaving on | 6 to 7.5 mA |
| Drawn from the cell, after the boost and the RAK's input stage | about 15 to 18 mA |
| Per day | 0.36 to 0.43 Ah |
| Cell: nominal / above the 3.0 V cutoff / at −10 °C | 15 / 14 / 11 Ah |
| Runtime with no sun (powersaving off: 17 to 22 days) | about 25 to 39 days |
| Charging from the 4 W panel at the charger's 500 mA limit, 3 to 5 hours of good sun | 1.5 to 2.5 Ah a day |

The charger's six-hour timer caps a day's charge at 3 Ah. One sunny day puts back four to six days of use, and a full cell runs it for about a month with no sun at all.
