# ROG Zephyrus M16 GU603ZW — Hardware Profile

## Summary

Primary mobile development workstation based on an **ASUS ROG Zephyrus M16 GU603ZW** laptop.  
Used for NixOS-based pantherOS development, AI tooling, and general-purpose Linux work.

- **Form factor:** Laptop
- **Vendor:** ASUSTeK COMPUTER INC.
- **Model:** ROG Zephyrus M16 GU603ZW
- **BIOS:** American Megatrends, version GU603ZW.311 (2022-12-22)

---

## CPU

- **Model:** 12th Gen Intel(R) Core(TM) i9-12900H
- **Architecture:** x86_64
- **Cores:** 14
- **Threads (siblings):** 20
- **Features (high level):**
  - 64-bit, SSE/SSE2/SSSE3/SSE4.1/SSE4.2
  - AVX / AVX2 / AVX VNNI
  - AES-NI, SHA, FMA
  - VT-x with EPT (virtualization)
  - HWP, HWP_EPP (modern Intel power management)

**Notes / Implications**

- Needs **Intel microcode** enabled.
- Supports **hardware virtualization**: should be enabled in firmware + NixOS (KVM, libvirt, etc., if used).
- Includes Spectre/Meltdown-era mitigations; some can be tuned in kernel params if needed for perf.

---

## Memory

- **Total RAM (reported):** 40 GiB
- **Configuration:**
  - 32 GiB Corsair SODIMM (CMSX32GX5M1A4800C40)
  - 8 GiB Samsung SODIMM (M425R1GB4BB0-CQKOD)
- **Type:** DDR5-4800 (SODIMM, synchronous)
- **Slots:** 2 total (both populated)

**Notes**

- Mixed DIMMs (32 + 8) — capacity asymmetry may have minor perf impact but is fine for dev.
- Plan system defaults assuming **40 GiB usable** for RAM-heavy workloads (VMs, LLM clients, etc.).

---

## Storage

There are **two NVMe SSDs**:

### nvme0 — CT2000P310SSD8

- **Model:** Crucial CT2000P310SSD8
- **Capacity:** ~2 TB (3,907,029,168 sectors × 512 bytes)
- **Bus:** PCIe / NVMe
- **Device paths:**
  - `/dev/nvme0n1`
  - `/dev/disk/by-id/nvme-CT2000P310SSD8_24514D0F486C*`

### nvme1 — Micron_2450_MTFDKBA1T0TFK

- **Model:** Micron 2450 (MTFDKBA1T0TFK)
- **Capacity:** ~1 TB (2,000,409,264 sectors × 512 bytes)
- **Bus:** PCIe / NVMe
- **Device paths:**
  - `/dev/nvme1n1`
  - `/dev/disk/by-id/nvme-Micron_2450_MTFDKBA1T0TFK_2146334B7D47*`

**Notes / Intended Use (to be refined in other specs)**

- Decide which device is:
  - Primary OS disk (likely **2 TB Crucial**).
  - Secondary disk for data, VMs, build caches, or scratch.
- NixOS/disko specs should refer to **by-id** names for stability.

---

## Graphics

This is a **hybrid graphics** laptop.

### iGPU — Intel

- **Device:** Intel display controller (iGPU)
- **PCI ID:** 8086:46a6
- **Driver:** `i915`
- **Outputs:** Internal panel and possibly some external ports (depending on muxing).

### dGPU — NVIDIA

- **Device:** NVIDIA discrete GPU (RTX-class, PCI ID 10de:24a0)
- **Driver (in use):** `nvidia`
- **Alternative:** Nouveau (present in driver database but **not active**)

### Displays

1. **Internal panel**
   - Vendor: BOE CQ
   - Resolution: 2560×1600
   - Refresh: up to 165 Hz
   - Size: 16" class (344 mm × 215 mm)
2. **External monitor**
   - Vendor: LG ELECTRONICS
   - Model: LG ULTRAGEAR
   - Resolution: 1920×1080
   - Refresh: up to 144 Hz

**Notes / Requirements**

- Needs **hybrid graphics support**:
  - Intel iGPU as primary for battery life.
  - NVIDIA dGPU for GPU workloads (gaming, CUDA, etc.) via PRIME offload.
- High-refresh displays (144–165 Hz) — compositor and X11/Wayland config should support >60 Hz modes.

---

## Audio

Two HDA devices:

1. **Intel HDA**
   - PCI: 8086:51c8
   - Driver: `snd_hda_intel` (with `snd_soc_avs` active)
2. **NVIDIA HDA (HDMI/DP audio)**
   - PCI: 10de:228b
   - Driver: `snd_hda_intel`

**Notes**

- Internal speakers + headphone jack handled by **Intel HDA**.
- External monitor audio (over HDMI/DP) via **NVIDIA HDA**.

---

## Networking

### Wired Ethernet

- **Controller:** Realtek RTL8125 (2.5 GbE-class)
- **PCI:** 10ec:8125
- **Driver:** `r8169`
- **Interface name:** `eno2`

### Wi-Fi

- **Controller:** Intel WLAN (PCI 8086:51f0)
- **Driver:** `iwlwifi`
- **Interface name:** `wlan0`
- **Bands:**
  - 2.4 GHz: channels 1–13
  - 5 GHz: channels 36–140
- **Auth modes:** open, WEP, WPA-PSK, WPA-EAP
- **Encryption:** WEP40/104, TKIP, CCMP

### Bluetooth

- **Controller:** Intel Bluetooth (USB vendor 8087:0033)
- **Driver:** `btusb`

**Notes / Requirements**

- Tailscale + firewall rules should treat **both `wlan0` and `eno2`** as first-class network uplinks.
- `iwlwifi`, `r8169`, and `btusb` must be available in initrd or early boot if networking is used for unlock/remote access.

---

## USB / Input Devices

### Keyboards

- **Internal:** ASUSTeK N-KEY device (multiple HID interfaces)
- **External:** Keychron Link receiver (keyboard + mouse over 2.4 GHz dongle)

### Pointing Devices

- **External mouse:** via Keychron Link USB HID
- **Internal touchpad:** I²C touchpad (vendor 04f3:31fb)

### USB Controllers

- Multiple Intel xHCI controllers (USB 2/3) and Thunderbolt controller.

**Notes**

- Touchpad is on I²C (`intel-lpss` stack) — may need extra quirks in some DEs.
- Thunderbolt controller present — can be configured for external docks/eGPUs.

---

## Power / Chassis

- **Chassis type:** Notebook
- **Power / thermal state:** SMBIOS reports “Safe”
- **Battery connectors:** BATT A and B indicated in SMBIOS ports list

**Implications for NixOS**

- Laptop profile should enable:
  - `tlp` or equivalent power management.
  - Screen brightness control.
  - Suspend/hibernate hooks.
  - Battery monitoring and thermal throttling awareness.

---

## Open Questions / TODOs

- Final decision on **disk roles** (which NVMe is OS vs data).
- Desired **encryption strategy** (LUKS full-disk, split data, etc.).
- Preferred **GPU mode**:
  - Always-on hybrid,
  - iGPU-only (battery),
  - dGPU-prefer (performance),
  - or switchable via boot profiles.
- Specific **display layout presets** (internal-only, external-only, dual-monitor profiles).
