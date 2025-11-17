# Lenovo Yoga 7 2-in-1 – System Profile

## Host Identity

- **Hostname:** (not specified)
- **Manufacturer:** Lenovo
- **System:** Yoga 7 2-in-1 14AKP10
- **Model:** `83JR`
- **Chassis:** Convertible (type 31)
- **Motherboard:** Lenovo `LNVNB161216` rev: SDK0T76574WIN
- **Part number:** `LENOVO_MT_83JR_BU_idea_FM_Yoga 7 2-in-1 14AKP10`
- **UUID:** `20250618-7cfa-80f3-a9fa-7cfa80f3a9fb`
- **UEFI:** Lenovo `QXCN19WW` (2025-07-31)

## Operating System

- **Distro:** CachyOS (based on Arch Linux)
- **Kernel:** `6.17.7-3-cachyos` (x86_64, 64-bit)
  - Compiler: `clang v21.1.4`
  - Clocksource: `tsc` (avail: `hpet`, `acpi_pm`)
- **Init system:** `systemd v258`
  - Default target: `graphical`
  - Tooling: `systemctl`
- **Package managers:**
  - `pacman`: 1,219 packages, 299 libraries
  - Tools: `octopi`, `paru`, `yay`
  - `nix`: 0 packages (available but not in use)
- **Compilers:**
  - `clang v21.1.5`
  - `gcc v15.2.1`
- **Shell:**
  - Default: `bash v5.3.3`
  - Sudo: `sudo v1.9.17p2`
- **Desktop Environment:**
  - WM: `niri` (Wayland compositor)
  - Display Manager: `SDDM`
  - Lock screen: `swaylock` (available)
- **Diagnostic tools:**
  - `inxi v3.3.39`
- **Boot parameters:**
  - `BOOT_IMAGE=/@/boot/vmlinuz-linux-cachyos`
  - `root=UUID=d098c4d4-96d5-49f1-9407-ff06e621e8b0`
  - `rootflags=subvol=@`
  - `nowatchdog nvme_load=YES zswap.enabled=0 splash loglevel=3`

## CPU

- **Model:** AMD Ryzen AI 7 350 w/ Radeon 860M
- **Socket:** FP8LPDDR5x
- **Architecture:** x86_64 (Zen 5, gen 5, v4)
- **Process:** TSMC n4 (4nm)
- **Family:** `0x1A` (26), Model ID: `0x60` (96), Stepping: `0`
- **Microcode:** `0xB60000E`
- **Cores & threads:** 8 cores, 16 threads (SMT enabled)
- **Topology:** 1 die, 1 cluster, 2 threads per core
- **Clock:**
  - Base/Boost: `2.0 GHz / 5.05 GHz`
  - Max (observed): `5.091 GHz / 3.506 GHz`
  - Current (idle): ~`623 MHz` on all cores
  - Scaling driver: `amd-pstate-epp`
  - Governor: `performance`
  - Voltage: `1.2V`
  - External clock: `100 MHz`
- **BogoMIPS:** `63,879`
- **Cache:**
  - L1d: `8 × 48 KiB` (total 384 KiB)
  - L1i: `8 × 32 KiB` (total 256 KiB)
  - L2: `8 × 1 MiB` (total 8 MiB)
  - L3: `1 × 16 MiB`
- **Flags (basic):** `avx`, `avx2`, `ht`, `lm`, `nx`, `pae`, `sse`, `sse2`, `sse3`, `sse4_1`, `sse4_2`, `sse4a`, `ssse3`, `svm`

### CPU Vulnerabilities (Summary)

- **Not affected:** gather_data_sampling, ghostwrite, indirect_target_selection, itlb_multihit, l1tf, mds, meltdown, mmio_stale_data, old_microcode, reg_file_data_sampling, retbleed, srbds, tsa, tsx_async_abort
- **Mitigated:**
  - spec_rstack_overflow: IBPB on VMEXIT only
  - spec_store_bypass: Speculative Store Bypass disabled via prctl
  - spectre_v1: usercopy/swapgs barriers and `__user` pointer sanitization
  - spectre_v2: Enhanced / Automatic IBRS; IBPB: conditional; STIBP: always-on; PBRSB-eIBRS: Not affected; BHI: Not affected
  - vmscape: IBPB on VMEXIT

## Memory

- **Total RAM:** 16 GiB (estimated available: 14.78 GiB)
- **In use:** ~6.5 GiB (~44.0%)
- **Swap:**
  - Type: `zram`
  - Size: `14.78 GiB`
  - Usage: `96 KiB` (~0.0%)
  - Priority: `100`
  - Compression: `zstd` (options: `lzo-rle`, `lzo`, `lz4`, `lz4hc`, `deflate`, `842`)
  - Device: `/dev/zram0`
- **Kernel VM tunables:**
  - Swappiness: `150` (default 60)
  - Cache pressure: `50` (default 100)
  - zswap: disabled

## Storage

- **Physical disk:**
  - Device: `/dev/nvme0n1`
  - Vendor: Western Digital
  - Model: `WD PC SN7100S SDFPMSL-1T00-1101`
  - Size: `953.87 GiB` (1TB)
  - Technology: NVMe PCIe 4.0 SSD
  - Speed: `63.2 Gb/s` (4 lanes)
  - Block size: 512B (physical & logical)
  - Temperature: `40.9°C`
  - Firmware: `7611M001`
  - Scheme: `GPT`

### Partition Layout

- **EFI System Partition**
  - Mount: `/boot/efi`
  - Device: `/dev/nvme0n1p1`
  - Size: `300 MiB` (used: `9.7 MiB` ~3.2%)
  - FS: `vfat`
  - Block size: `512 B`

- **Main Btrfs Volume**
  - Device: `/dev/nvme0n1p2`
  - Size: `953.57 GiB` (used: `26.65 GiB` ~2.8%)
  - FS: `btrfs`
  - Block size: `4096 B`
  - Subvolumes (same device, different mountpoints):
    - `/` (root) – subvol: `@`
    - `/home`
    - `/var/log`
    - `/var/tmp`

- **Local storage usage (overall):**
  - Total: `953.87 GiB`
  - Used: `26.66 GiB` (~2.8%)

- **SMART:** Yes
  - Health: `PASSED`
  - Power-on hours: `32h`
  - Power cycles: `1,872`
  - Data read: `2,808,382 units` (~1.43 TB)
  - Data written: `5,763,124 units` (~2.95 TB)

## Graphics

- **GPU:** AMD Radeon 860M Graphics (Krackan)
  - Vendor: Lenovo
  - Driver: `amdgpu` v: kernel
  - Bus: `04:00.0` (`1002:1114`)
  - PCIe: Gen 4, 16 GT/s, 16 lanes
  - Temperature: `52.0°C`
  - Active ports: `eDP-1`
  - Inactive ports: `DP-1`, `DP-2`, `DP-3`, `DP-4`, `DP-5`, `DP-6`, `DP-7`, `HDMI-A-1`, `Writeback-1`

- **Integrated Camera:**
  - Model: Chicony Integrated Camera
  - Driver: `hid-sensor-hub`, `usbhid`, `uvcvideo`
  - Bus: USB `1-1:2` (`04f2:b83c`)
  - Speed: `480 Mb/s` (USB 2.0)

- **Display:**
  - Server: `X.org v1.21.1.20` with `Xwayland v24.1.9`
  - Compositor: `niri` (Wayland)
  - Driver: `amdgpu` (X: loaded), `radeonsi` (DRI)
  - Display ID: `:1`

- **Monitor:**
  - Model: Samsung `0x4208` (built 2024)
  - Interface: `eDP-1`
  - Resolution: `1920×1200`
  - DPI: `161`
  - Size: `302×189mm` (11.89" × 7.44")
  - Diagonal: `356mm` (14")
  - Aspect ratio: `16:10`
  - Gamma: `1.2`
  - Modes: max `1920×1200`, min `640×480`

- **Graphics APIs:**
  - **EGL:** v1.5
    - Driver: `amd radeonsi`
    - Platforms: device (0: radeonsi, 1: swrast), gbm (radeonsi), surfaceless (radeonsi)
    - Inactive: wayland, x11
  - **OpenGL:** v4.6 (compat: v4.5)
    - Vendor: Mesa `v25.2.6-cachyos1.2`
    - Renderer: AMD Radeon 860M Graphics (radeonsi gfx1152 LLVM 21.1.4 DRM 3.64), llvmpipe (LLVM 21.1.4 256 bits)
    - Note: incomplete (EGL sourced)
  - **Vulkan:** No data available

- **Graphics tools:**
  - API: `eglinfo`, `glxinfo`, `vulkaninfo`
  - Wayland: `wlr-randr`
  - X11: `xdpyinfo`, `xprop`, `xrandr`

## Audio

- **Device-1:** AMD Radeon High Definition Audio [Rembrandt/Strix]
  - Driver: `snd_hda_intel` v: kernel
  - Bus: `04:00.1` (`1002:1640`)
  - PCIe: Gen 4, 16 GT/s, 16 lanes

- **Device-2:** AMD Audio Coprocessor
  - Vendor: Lenovo
  - Driver: `snd_acp_pci` v: kernel
  - Alternates: `snd_pci_acp3x`, `snd_rn_pci_acp3x`, `snd_pci_acp5x`, `snd_pci_acp6x`, `snd_rpl_pci_acp6x`, `snd_pci_ps`, `snd_sof_amd_*`
  - Bus: `04:00.5` (`1022:15e2`)
  - PCIe: Gen 4, 16 GT/s, 16 lanes

- **Device-3:** AMD Family 17h/19h/1ah HD Audio
  - Vendor: Lenovo
  - Driver: `snd_hda_intel` v: kernel
  - Bus: `04:00.6` (`1022:15e3`)
  - PCIe: Gen 4, 16 GT/s, 16 lanes

- **Audio stack:**
  - **ALSA:** v: `k6.17.7-3-cachyos` (kernel API)
    - Tools: `alsactl`, `alsamixer`, `amixer`
  - **sndiod:** v: N/A (status: off)
    - Tools: `aucat`, `midicat`, `sndioctl`
  - **JACK:** v1.9.22 (status: off)
  - **PipeWire:** v1.4.9
    - `pipewire-pulse`: active
    - `wireplumber`: active
    - `pipewire-alsa`: plugin type
    - Tools: `pactl`, `pw-cat`, `pw-cli`, `wpctl`

## Network

- **WiFi Adapter:** Realtek RTL8922AE 802.11be PCIe
  - Vendor: Lenovo
  - Driver: `rtw89_8922ae` v: kernel
  - Bus: `03:00.0` (`10ec:8922`)
  - PCIe: Gen 2, 5 GT/s, 1 lane
  - Port: `2000`
  - Interface: `wlan0`
    - State: `up`
    - MAC: `<redacted>`

- **VPN Interface:**
  - `tailscale0`
    - State: `unknown`
    - Speed: `-1`
    - Duplex: `full`

- **Network services:**
  - `NetworkManager`
  - `systemd-timesyncd`
  - `wpa_supplicant`

## Bluetooth

- **Adapter:** Realtek Bluetooth Radio
  - Driver: `btusb` v0.8
  - Bus: USB `3-5:4` (`0bda:d922`)
  - Speed: `12 Mb/s` (USB 1.1)
  - Bluetooth version: `5.3`
  - LMP version: `12`
- **Status (hci0):**
  - State: `up`
  - Address: `<redacted>`
  - Discoverable: `no`
  - Pairing: `no`
  - Class ID: `6c0000`

## Battery & Power

- **Battery (BAT0):**
  - Model: Sunwoda `L24D4PK5` (Li-poly)
  - Charge: `71.9 Wh` (99.1%)
  - Condition: `72.6 / 70 Wh` (103.7% health)
  - Power draw: `0.4W`
  - Voltage: `17.65V` (min: `15.48V`)
  - Status: `discharging`
  - Charging modes: `standard` (current), `long_life` (available)
  - Cycles: `25`

- **Logitech MX Master 3S (hidpp_battery_0):**
  - Charge: `45%`
  - Rechargeable: `yes`
  - Status: `discharging`

- **Power states:**
  - Suspend: `s2idle`
  - Available states: `freeze`, `mem`, `disk`
  - Hibernate (platform): available modes: `shutdown`, `reboot`, `suspend`, `test_resume`
  - Hibernate image size: `5.89 GiB`
  - Wakeups: `0`

- **Power management services:**
  - `power-profiles-daemon`
  - `upowerd`

## Sensors & Uptime

- **Temperatures:**
  - CPU: `59.4°C`
  - GPU (amdgpu): `52.0°C`
  - Motherboard: N/A
- **Fans:** No data available
- **Uptime:** 3h 18m (at time of capture)
- **Processes:** 388

## Notes

- High-performance **2-in-1 convertible laptop** with AMD Zen 5 architecture
- Running **CachyOS** (Arch-based, performance-focused distro) with **niri** Wayland compositor
- Modern specs:
  - **CPU:** 8-core/16-thread Ryzen AI 7 350 (Zen 5, up to 5.05 GHz)
  - **GPU:** Integrated Radeon 860M (RDNA 3.5)
  - **Display:** 14" 1920×1200 @ 161 DPI (16:10)
  - **Storage:** 1TB WD NVMe PCIe 4.0 (low usage: ~2.8%)
  - **RAM:** 16GB LPDDR5x (44% in use)
  - **Connectivity:** WiFi 6E (802.11be), Bluetooth 5.3, Tailscale VPN
- **Battery:** Excellent health (103.7%), 25 cycles, ~72Wh capacity
- **Audio:** Full PipeWire stack with ALSA/JACK compatibility
- **Package management:** Primarily `pacman` (1,219 packages), `nix` available but unused
- Compiled with **LLVM/Clang 21** instead of GCC for potential performance benefits
- Btrfs filesystem with subvolume layout for `/`, `/home`, `/var/log`, `/var/tmp`
