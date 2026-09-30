# Firmware

The tracker is a MeshCore node on a Seeed XIAO nRF52840, so it runs the same firmware as any MeshCore node on that board. For it to be a useful tracker, the firmware has to do two things that nothing does yet on this board: **report where the pod is**, and **sleep between reports so a battery lasts weeks**. This page explains where that stands at the end of September 2026, what to watch for, and how long a battery lasts in each case.

- [Where things stand](#where-things-stand)
- [What "a few weeks" takes](#what-a-few-weeks-takes)
- [Battery life](#battery-life)
- [What to watch for](#what-to-watch-for)
- [Testing the hardware now with Meshtastic](#testing-the-hardware-now-with-meshtastic)
- [A GNSS build for MeshCore](#a-gnss-build-for-meshcore)
- [Flashing](#flashing)
- [Setting it up as a tracker](#setting-it-up-as-a-tracker)

## Where things stand

As of 29 September 2026:

- **MeshCore.** The latest release is v1.17.1 (14 August 2026).
  - Its builds for this board, such as the Bluetooth companion `Xiao_nrf52_companion_radio_ble`, still leave GNSS out (`-UENV_INCLUDE_GPS`), in both `main` and `dev`.
  - They also put I²C on D6 and D7, the pins the L76K's serial port needs. [MeshCore issue #1858](https://github.com/meshcore-dev/MeshCore/issues/1858) talks about giving those pins back to the serial port for a GNSS module.
  - A companion node keeps its LoRa radio listening all the time and its Bluetooth on. On similar nRF52840 boards that's about 7 to 9 mA.
  - There's no tracker mode yet, and no timed deep sleep for nRF52 boards. MeshCore's [nRF52 power management notes](https://github.com/meshcore-dev/MeshCore/blob/dev/docs/nrf52_power_management.md) list "deep sleep" and "scheduled wake-up" as planned. A pull request that tidies up how boards power off ([#3453](https://github.com/meshcore-dev/MeshCore/pull/3453)) adds a way into deep sleep on nRF52 that later work could build on, but nothing that wakes the board on a timer.
- **EasySkyMesh.** This is a [MeshCore fork](https://github.com/IoTThinks/EasySkyMesh) focused on power saving. Its latest full release is PowerSaving 17 (2 August 2026). A 17.1 pre-release came out on 15 August, and there have been test builds through September.
  - Its receive power saving cuts the current while the radio listens. PowerSaving 17's notes give a RAK4631 repeater 2.4 to 5.8 mA on its "balanced" setting and 0.9 to 6 mA on its most aggressive one, and about 3 to 5 mA for a ProMicro nRF52840 with an SX1262. There's no published figure for the XIAO.
  - Its GNSS power saving now works on any board with a GNSS enable or standby pin. But its XIAO nRF52840 builds still have GNSS switched off, like MeshCore's.
- **Meshtastic** already supports this exact kit with the L76K on these pins, and has a tracker mode that sleeps between reports. But it's a different mesh: a Meshtastic tracker can't talk to MeshCore nodes. See [Testing the hardware now with Meshtastic](#testing-the-hardware-now-with-meshtastic).

So today, with a stock MeshCore build, the pod is a normal MeshCore companion. You can message it and it shows in your contacts, but it can't say where it is, and it runs a battery flat in a few days.

Leave the L76K's wires unsoldered at the XIAO end until you have a GNSS build ([build guide, step 9](build-guide.md#9-wire-the-electronics)). A stock build would drive I²C into the L76K's serial pins, and nothing would put it on standby, so it would draw about 41 mA the whole time.

## What "a few weeks" takes

Three weeks is 504 hours. The 603040 pouch cell is sold as 800 mAh; allowing 85% of that for age and cold leaves 680 mAh, so to last three weeks the pod has to average about 1.35 mA. On the 18350's 1020 mAh (85% of 1200), it's about 2 mA. Here's where the current goes (datasheet and measured figures, sources below):

| Part | Doing what | Current |
|---|---|---|
| SX1262 LoRa radio | Listening (receive) | 4.6 to 5.3 mA |
| | Sleeping | about 1 µA |
| | Sending a position (about 0.3 s at 22 dBm) | 118 mA, but only for a moment |
| L76K GNSS module (Seeed's board with its active antenna) | Getting a fix or tracking | 41 mA |
| | Standby (D0 low) | 0.36 mA |
| nRF52840 on the XIAO | Sleeping on a timer | a few µA |

Listening all the time at the SX1262's normal receive current uses 110 to 130 mAh a day, several times the budget. Receive power saving like EasySkyMesh's brings that down, but even its best published figures are around 1 mA or more on average before the GNSS uses anything. So **a tracker that lasts weeks will almost certainly have to put its radio to sleep between reports**, like this:

1. Sleep, with the radio asleep and the L76K on standby.
2. Every so often, wake the L76K for a hot fix. That takes a few seconds under open sky if it has been on standby.
3. Send the position over the mesh, to a contact or a channel.
4. Listen for a few seconds in case someone has a request, then go back to sleep.

The catch is that you can't reach the pod between reports. That's the price of weeks of battery.

Here's what the average current works out to. Each report here is a 10 to 15 second fix (the L76K at 41 mA and the processor awake, about 44 mA together), one or two packets sent, and 5 seconds of listening. Between reports the pod sleeps at about 0.38 mA, nearly all of it the L76K on standby.

| Report every | Average current | 603040 (800 mAh) | 16340 (950 mAh) | 18350 (1200 mAh) |
|---|---|---|---|---|
| 10 minutes | 1.2 to 1.7 mA | 2½ to 3½ weeks | 3 to 4 weeks | 3½ to 5 weeks |
| 15 minutes | 1.0 to 1.2 mA | 3½ to 4 weeks | 4 to 5 weeks | 5 to 6 weeks |
| 30 minutes | 0.7 to 0.8 mA | 5 to 6 weeks | 6 to 7 weeks | 7½ to 8½ weeks |

These use 85% of each cell's rating, to allow for age and cold: 680, 810 and 1020 mAh.

The L76K's standby current is the biggest part of what's left. Seeed's module draws 0.36 mA on standby, which alone takes more than a quarter of the 603040's 680 mAh over three weeks. The bare L76K chip needs only about 8 µA in its backup mode, with its main power switched off, but Seeed's board has no switch for that. A future revision could add a small load switch on the L76K's power, driven by D0. That isn't in this design yet.

## Battery life

These are estimates from the figures above, not measurements on a pod. They assume 85% of each cell's rating (the rating it's sold with).

| What the firmware does | Average | 603040 (800 mAh) | 803040 (900 mAh) | 16340 (950 mAh) | 18350 (1200 mAh) |
|---|---|---|---|---|---|
| Stock MeshCore companion, GNSS off (today) | 7 to 9 mA | 3 to 4 days | 3½ to 4½ days | 4 to 5 days | 5 to 6 days |
| Listening with receive power saving, GNSS off (EasySkyMesh style) | 3 to 5 mA | 6 to 9 days | 6 to 10 days | 7 to 11 days | 8 to 14 days |
| GNSS on all the time | about 45 to 50 mA | about 14 hours | about 16 hours | about 17 hours | about 21 hours |
| A tracker that sleeps and reports every 15 minutes | 1.0 to 1.2 mA | 3½ to 4 weeks | 3¾ to 4½ weeks | 4 to 5 weeks | 5 to 6 weeks |

Charging in the pod is slow, because the XIAO's charger runs at 50 mA, or 100 mA if the firmware turns on its fast mode, and the node's own few mA come out of that while it charges. A flat 950 mAh cell takes about 11 hours at 100 mA or 22 at 50 mA, and a 1200 mAh one about 13 or 30. On the swap version it's quicker to take the cell out and charge it on its own USB-C port or in a USB charger, which takes about two hours.

## What to watch for

Any one of these would move the tracker along. Watch the [MeshCore releases](https://github.com/meshcore-dev/MeshCore/releases), the [EasySkyMesh releases](https://github.com/IoTThinks/EasySkyMesh/releases) and MeshCore's `variants/xiao_nrf52` folder.

1. **A XIAO nRF52840 build with GNSS**: serial on D6/D7, D0 as the GNSS enable pin, and I²C moved off D6/D7. That makes the pod report its location, though with the battery life of the first rows above.
2. **GNSS power saving for that build**, which EasySkyMesh already does on other boards: GNSS on long enough for a fix, then on standby.
3. **Timed deep sleep and a tracker mode** in MeshCore: sleep, wake, fix, send, sleep. That's what gets to weeks.

The first two could happen soon, because they're the same kind of change MeshCore and EasySkyMesh have already made for other boards. The third is new work.

## Testing the hardware now with Meshtastic

If you want to prove the hardware before the MeshCore side is ready, Meshtastic's firmware for this kit (`seeed_xiao_nrf52840_kit`) already expects the L76K on D6/D7, with its standby line on D0 and I²C moved to the XIAO's NFC pins. That's exactly how this pod is wired.

- Its **Tracker** role, with power saving on, sleeps the radio and the L76K between position reports. It can't receive while it sleeps.
- Its default build has no user button, because D0 is used for the L76K.
- It won't talk to your MeshCore nodes. You'd need a Meshtastic node or phone to see it.
- To go back to MeshCore later, flash MeshCore again. You may need the MeshCore flasher's **Erase device** option first, which wipes the node's settings and gives it a new identity, so you'd add it to your contacts again.

Nobody has published battery-life measurements for this kit on Meshtastic, so a test of your own would be worth sharing.

## A GNSS build for MeshCore

If you build firmware yourself, a MeshCore environment for the pod needs changes like these to the XIAO nRF52 companion environment:

```ini
; starting point only: this has not been compiled or tested
[env:Xiao_nrf52_companion_radio_ble_gnss]
extends = env:Xiao_nrf52_companion_radio_ble
build_flags = ${env:Xiao_nrf52_companion_radio_ble.build_flags}
  -D ENV_INCLUDE_GPS=1
  -D PIN_GPS_TX=D6        ; XIAO transmits to the L76K
  -D PIN_GPS_RX=D7        ; XIAO receives from the L76K
  -D PIN_GPS_EN=D0        ; L76K standby line: high = running, low = standby
  -D GPS_BAUD_RATE=9600
  -U PIN_WIRE_SCL
  -U PIN_WIRE_SDA
  -D PIN_WIRE_SDA=30      ; I2C off D6/D7, onto the NFC pins as Meshtastic does;
  -D PIN_WIRE_SCL=31      ; every XIAO header pin is already in use
```

The macro names are the ones MeshCore's other GNSS boards use. MeshCore's build for Seeed's Wio Tracker L1, which also has an L76K, uses the L76K's standby line as its GNSS enable pin, and MeshCore drives that pin high for on and low for off. The variant also sets `PIN_SERIAL1_RX` and `PIN_SERIAL1_TX` to 7 and 6, which may need a look.

I haven't compiled this or run it on a pod. Things to check:

- whether I²C on pins 30 and 31 builds and runs cleanly with nothing attached
- that pulling D0 low really puts the L76K on standby
- the current with GNSS off, which should be a few mA

If you get it working, please open an issue or a pull request with the environment and a UF2. I'll put it in this repo's releases so nobody else has to build it.

## Flashing

1. Plug the XIAO into your computer with a USB-C cable. Do this before it goes in the pod: once it's in, its USB port faces a wall.
2. Open the [MeshCore web flasher](https://flasher.meshcore.io) in Chrome or Edge, choose the Seeed XIAO nRF52840 and the Bluetooth companion firmware, and flash it.
3. For a custom build, double-tap the XIAO's reset button so it shows up as a USB drive, and copy the `.uf2` file onto it.
4. Pair it with the MeshCore app, and give it a name. Your dog's is a good one.
5. Change its Bluetooth PIN from the default.
6. Set the radio to match your local mesh.

To update it later, either take the XIAO out (it's only held by tape) or use a Bluetooth firmware update if your firmware supports it.

## Setting it up as a tracker

MeshCore can share a node's location in two ways:

- **in its adverts**, which go to everyone on the mesh
- **in answer to telemetry requests**, only from the contacts you've allowed to ask

For a tracker, use telemetry requests. Adverts would tell the whole mesh where your dog sleeps, which is where you live.

- Leave location out of the pod's adverts. Add your own node as a contact that's allowed to request its telemetry, including location.
- From your own node, ask for the dog's location when you want it.
- MeshCore's `dev` branch has just added a way for a contact to subscribe to a sensor node's telemetry and get updates pushed when they change. A tracker mode would likely build on that.

The app's menus change between releases, so check the MeshCore docs for where these settings are today.

### Sources

- MeshCore: [releases](https://github.com/meshcore-dev/MeshCore/releases), [XIAO nRF52 variant](https://github.com/meshcore-dev/MeshCore/blob/main/variants/xiao_nrf52/platformio.ini), [Wio Tracker L1 variant](https://github.com/meshcore-dev/MeshCore/blob/dev/variants/wio-tracker-l1/variant.h), [nRF52 power management](https://github.com/meshcore-dev/MeshCore/blob/dev/docs/nrf52_power_management.md), [issue #1858](https://github.com/meshcore-dev/MeshCore/issues/1858), [PR #3453](https://github.com/meshcore-dev/MeshCore/pull/3453)
- EasySkyMesh: [releases](https://github.com/IoTThinks/EasySkyMesh/releases) (PowerSaving 17's receive figures), [PowerSaving wiki](https://github.com/IoTThinks/EasySkyMesh/wiki/PowerSaving)
- Meshtastic: [the kit's variant](https://github.com/meshtastic/firmware/blob/develop/variants/nrf52840/seeed_xiao_nrf52840_kit/variant.h), [device settings](https://meshtastic.org/docs/configuration/radio/device/)
- Seeed: [L76K module](https://wiki.seeedstudio.com/get_start_l76k_gnss/) (41 mA tracking, 0.36 mA standby), [XIAO nRF52840](https://wiki.seeedstudio.com/XIAO_BLE/)
- Semtech SX1262 datasheet, rev 2.2 (receive, sleep and transmit currents); Nordic nRF52840 product specification (sleep current); Quectel L76K specification (backup current)
