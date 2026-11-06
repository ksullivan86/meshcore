# Parts list

Everything for one case, as a checklist. [`parts.csv`](parts.csv) has the same list as a spreadsheet, with a column for each size. GitHub shows it as a searchable table, or you can open it in Excel or Google Sheets.

Prices are what these cost when I checked in early November 2026, before tax and shipping. They'll drift, and listings come and go, so check before you order. The links are just where I found each part, not endorsements. Anything with the same specs will do.

The boxes can't be ticked on GitHub itself. Print the page, or paste the list into an issue, where they can.

## Per node (one for each bay)

- [ ] **Seeed Studio XIAO ESP32S3 & Wio-SX1262 kit** (Seeed 102010611). [Rokland](https://store.rokland.com/products/seeed-studio-xiao-esp32s3-wio-sx1262-kit-for-meshtastic-lora), $15.97 (sold out when I checked), or [Seeed](https://www.seeedstudio.com) and [Digi-Key](https://www.digikey.com/en/products/detail/seeed-technology-co-ltd/102010611/25835813). It comes with the stock WiFi FPC antenna. Get the version for the LoRa band that's legal where you live.
- [ ] **U.FL (IPEX / MHF1) to SMA-female bulkhead pigtail, 1.13 mm cable, about 10 cm.** [onelinkmore 5-pack, Amazon B0GTY4HP34](https://www.amazon.com/dp/B0GTY4HP34), about $6.70 for the 3.94 in (10 cm) size, which you pick on the page. It must be **1.13 mm** cable: RG178 and RG316 are stiff enough to pull the U.FL off the Wio board. **SMA**, not RP-SMA, and **MHF1 / U.FL**, not MHF4.
- [ ] **LoRa antenna, SMA male**, for your band (915 MHz in the US). Any that suits you; the case is weighted for a full-size one.
- [ ] **USB-C cable and a 5 V USB power supply.**

### Only with the RP-SMA WiFi option

- [ ] **U.FL to RP-SMA-female bulkhead pigtail, 1.13 mm cable, about 10 cm**, and a **2.4 GHz RP-SMA antenna**. Instead of the stock FPC antenna.

## For the case

- [ ] **M6 fender washers, 6.4 × 18 × 1.6 mm (DIN 9021)**, 16 for the 2- or 3-bay, 8 for the 1-bay. [boltsandnuts.com, M6x18x1.6 zinc](https://boltsandnuts.com/products/m6x18x1-6-grade-a-flat-fender-washers-zinc), about $0.07 each in a 200-pack. They stack 4 to a pin in the base. Steel or lead shot, or anything else heavy, can go in the open middle chamber.
- [ ] **PETG filament**, at most about 45 g for the 1-bay, 75 g for the 2-bay and 100 g for the 3-bay (less with normal infill).

Nothing else: no screws, nuts, inserts or glue.

## Optional

- [ ] **Kapton tape**, a short strip over each U.FL once it's seated, if it still pops off.
