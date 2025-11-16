# OVH Cloud VPS – System Profile

## Host Identity

- **Hostname:** `OVH Cloud VPS`
- **Provider / Platform:** OpenStack (QEMU/KVM)
- **System:** OpenStack Nova `19.3.2`
- **Virtualization:** KVM (`pc-i440fx-9.2`)
- **Chassis:** QEMU virtual machine
- **BIOS:** SeaBIOS `1.16.3-debian-1.16.3-2~bpo12+1` (2014-04-01)
- **Console:** `pty pts/1`

## Operating System

- **Distro:** Fedora Linux 42 (Cloud Edition)
- **Kernel:** `6.17.5-200.fc42.x86_64` (x86_64, 64-bit)
- **Init system:** `systemd v257`
  - Default target: `multi-user`
  - Tooling: `systemctl`
- **Package manager:** `rpm`
  - Frontends: `dnf`, `yum`
- **Shell:**
  - Default: `bash v5.2.37`
  - Sudo: `sudo v1.9.17p1`
- **Diagnostic tools:**
  - `inxi v3.3.39`

## CPU

- **Model:** Intel Core (Haswell, no TSX)
- **Architecture:** x86_64 (Haswell, v3)
- **vCPUs:** 8
- **Cores (reported):** 1 core, 1 die, 1 cluster (SMP virtual topology)
- **Clock:**
  - Base/Boost: `2.0 GHz / 2.0 GHz`
  - Observed: ~`2.993 GHz` on all 8 vCPUs
- **Cache:**
  - L1: `8 × 64 KiB` (split `32K data + 32K instruction`)
  - L2: `8 × 4 MiB` (total 32 MiB)
  - L3: `8 × 16 MiB` (total 128 MiB)
- **Flags (basic):** `avx`, `avx2`, `lm`, `nx`, `pae`, `sse`, `sse2`, `sse3`, `sse4_1`, `sse4_2`, `ssse3`, `vmx`

### CPU Vulnerabilities (Summary)

- **Mitigated / Not affected:** l1tf, meltdown (PTI), mds, gather_data_sampling, ghostwrite, mmio_stale_data, old_microcode, reg_file_data_sampling, retbleed, spec_rstack_overflow, tsa, tsx_async_abort, vmscape
- **Spectre:**
  - v1: mitigated (usercopy/swapgs barriers, `__user` ptr sanitization)
  - v2: mitigated (Retpolines, RSB filling; STIBP disabled)
- **Spec Store Bypass:** **Vulnerable**
- **SRBDS:** unknown (hypervisor-dependent)

## Memory

- **Total RAM:** 23.44 GiB
- **Available:** 22.9 GiB
- **In use:** ~645.8 MiB (~2.8%)
- **Swap:**
  - Type: `zram`
  - Size: `8 GiB`
  - Usage: `0 KiB`
  - Compression: `lzo-rle` (options: `lzo`, `lz4`, `lz4hc`, `zstd`, `deflate`, `842`)
  - Device: `/dev/zram0`
- **Kernel VM tunables:**
  - Swappiness: `60`
  - Cache pressure: `100`
  - zswap: disabled

## Storage

- **Physical disk:**
  - Device: `/dev/sda` (QEMU `HARDDISK`)
  - Size: `200 GiB`
  - Scheme: `GPT`
  - Block size: 512B (physical & logical)

### Partition Layout

- **EFI System Partition**
  - Mount: `/boot/efi`
  - Device: `/dev/sda2`
  - Size: `100 MiB` (used: `17 MiB` ~17%)
  - FS: `vfat`
  - Block size: `512 B`

- **Boot Partition**
  - Mount: `/boot`
  - Device: `/dev/sda3`
  - Size: `1000 MiB` (used: `163.2 MiB` ~16.9%)
  - FS: `ext4`
  - Block size: `4096 B`

- **Main Btrfs Volume**
  - Device: `/dev/sda4`
  - Size: `198.92 GiB` (used: `~824.6 MiB` ~0.4%)
  - FS: `btrfs`
  - Block size: `4096 B`
  - Subvolumes (same device, same size, different mountpoints):
    - `/` (root)
    - `/home`
    - `/var`
  - Mount options (kernel cmdline): `rootflags=subvol=root`

- **Local storage usage (overall):**
  - Total: `200 GiB`
  - Used: `~1004.7 MiB` (~0.5%)

- **SMART:** `smartctl` not installed (no SMART data available)

## Network

- **Primary interface:** `ens3`
  - State: `up`
  - Speed: `-1` (not reported by virt layer)
  - Duplex: `unknown`
  - MAC: `<redacted>`
- **Virtual devices:**
  - Intel 82371AB/EB/MB PIIX4 ACPI (bridge) – driver: `piix4_smbus` (module: `i2c_piix4`)
  - Virtio network – driver: `virtio-pci` (`00:03.0`, `1af4:1000`)
- **Network services:**
  - `NetworkManager`
  - `sshd`

## Graphics

- **GPU (virtual):** Cirrus Logic GD 5446 (QEMU)
  - Driver: `cirrus-qemu` (alt: `cirrus_qemu`)
  - Bus: `00:02.0` (`1013:00b8`)
  - Output: `Virtual-1`
    - Console modes: `640x480`–`800x600`
- **Display server:** none (console/headless context)
- **X11 tools available:** `xdpyinfo`, `xprop`, `xrandr` (for when X is used)

## Audio

- **API:** ALSA (`k6.17.5-200.fc42.x86_64`)
- **Status:** inactive
- **Devices:** none reported

## Sensors & Power

- **Sensors:** no data from `/sys/class/hwmon` or `lm-sensors`
- **Uptime:** ~9 minutes (at time of capture)
- **Power states:**
  - Suspend: `s2idle`
  - Hibernate (platform): `shutdown`, `reboot`, `suspend`, `test_resume`
  - Hibernate image size: `9.14 GiB`
  - Wakeups: `0`

## Notes

- Designed as a **headless** cloud host (no active GUI, no audio).
- Btrfs root with subvolume-based layout (`/`, `/home`, `/var`) on a single 200 GiB virtual disk.
- Good headroom on:
  - **CPU** (low usage at capture time)
  - **RAM** (~23 GiB total, almost all free)
  - **Disk** (only ~1 GiB used)
