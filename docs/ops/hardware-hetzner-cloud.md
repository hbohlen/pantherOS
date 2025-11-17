# Hetzner Cloud VPS – System Profile

## Host Identity

- **Hostname:** `nixos`
- **Provider / Platform:** Hetzner Cloud (QEMU/KVM)
- **System:** Hetzner `vServer v20171111`
- **Virtualization:** KVM (`pc-q35-8.2`)
- **Chassis:** QEMU virtual machine (type 1)
- **UEFI:** Hetzner `v20171111` (2017-11-11)
- **Console:** `pty pts/1`
- **Machine UUID:** `22e0430f-2d41-4c22-8f18-696233fb4819`

## Operating System

- **Distro:** NixOS 25.05 (Warbler)
- **Kernel:** `6.12.31` (x86_64, 64-bit)
  - Compiler: `gcc v14.2.1`
  - Clocksource: `kvm-clock` (avail: `tsc`, `hpet`, `acpi_pm`)
- **Init system:** `systemd v257`
  - Default target: `multi-user`
  - Tooling: `systemctl`
- **Package manager:** `nix`
  - System packages: `387`
  - Libraries: `61`
  - User packages: `0`
  - Default packages: `0`
- **Compiler:** `gcc v14.2.1`
- **Shell:**
  - Running: `bash v5.2.37` (in SSH `pty pts/1`)
- **Diagnostic tools:**
  - `inxi v3.3.38`
- **Boot parameters:**
  - `BOOT_IMAGE=/boot//nix/store/2l23lk60khahkx3k6i8hhlblhx5gmw8a-linux-6.12.31/bzImage`
  - `init=/nix/store/75ksfdnr6fij180p63yshs2b6hjda2yn-nixos-system-nixos-25.05.803396.8f1b52b04f2c/init`
  - `root=LABEL=nixos-minimal-25.05-x86_64`
  - `boot.shell_on_fail nohibernate loglevel=4 lsm=landlock,yama,bpf`

## CPU

- **Model:** AMD EPYC-Genoa
- **Architecture:** x86_64 (Zen 4, gen 4, v4)
- **Process:** TSMC n5 (5nm)
- **Family:** `0x19` (25), Model ID: `0x11` (17), Stepping: `0`
- **Microcode:** `0x1000065`
- **vCPUs:** 12
- **Cores (topology):** 12 cores, 1 die, 1 cluster
  - SMT: not supported
- **Clock:**
  - Base/Boost: N/A
  - Observed: `2.4 GHz` on all 12 cores
- **BogoMIPS:** `57,599`
- **Cache:**
  - L1d: `12 × 32 KiB` (total 384 KiB)
  - L1i: `12 × 32 KiB` (total 384 KiB)
  - L2: `12 × 1 MiB` (total 12 MiB)
  - L3: `1 × 32 MiB`
- **Flags (basic):** `avx`, `avx2`, `ht`, `lm`, `nx`, `pae`, `sse`, `sse2`, `sse3`, `sse4_1`, `sse4_2`, `sse4a`, `ssse3`

### CPU Vulnerabilities (Summary)

- **Not affected:** gather_data_sampling, indirect_target_selection, itlb_multihit, l1tf, mds, meltdown, mmio_stale_data, reg_file_data_sampling, retbleed, srbds, tsx_async_abort
- **Mitigated:**
  - spec_rstack_overflow: Safe RET
  - spec_store_bypass: Speculative Store Bypass disabled via prctl
  - spectre_v1: usercopy/swapgs barriers and `__user` pointer sanitization
  - spectre_v2: Enhanced / Automatic IBRS; IBPB: conditional; STIBP: disabled; PBRSB-eIBRS: Not affected; BHI: Not affected

## Memory

- **Total RAM:** 23.43 GiB
- **Available:** 22.91 GiB
- **In use:** ~2.73 GiB (~11.9%)
- **Swap:** None configured

## Storage

- **Physical disk:**
  - Device: `/dev/sda` (QEMU `HARDDISK`)
  - Vendor: QEMU
  - Size: `457.77 GiB`
  - Scheme: `GPT`
  - Block size: 512B (physical & logical)
  - Technology: SSD
  - Firmware: `2.5+`

### Partition Layout

- **Partitions:** No partition data found (likely still in installation/configuration phase)

- **Local storage usage (overall):**
  - Total: `457.77 GiB`
  - Used: `637.5 MiB` (~0.1%)

- **SMART:** Not available

## Network

- **Primary interface:** `enp1s0`
  - State: `up`
  - Speed: `-1` (not reported by virt layer)
  - Duplex: `unknown`
  - MAC: `<redacted>`
- **Virtual devices:**
  - Red Hat Virtio 1.0 network – driver: `virtio-pci` v1 (modules: `virtio_pci`)
  - Bus: `01:00.0` (`1af4:1041`)
  - PCIe: Gen 1, 2.5 GT/s, 1 lane
- **Network services:**
  - `sshd`
  - `systemd-timesyncd`

## Graphics

- **GPU (virtual):** Red Hat Virtio 1.0 GPU
  - Driver: `virtio-pci` v1 (alt: `virtio_pci`)
  - Bus: `00:01.0` (`1af4:1050`)
  - Output: `Virtual-1`
    - Model: `QEMU Monitor` (built 2014)
    - Resolution: `1280×800`
    - DPI: `100`
    - Size: `325×203mm` (12.8" × 7.99")
    - Diagonal: `383mm` (15.1")
    - Aspect ratio: `16:10`
    - Gamma: `1.2`
    - Console: `114×21` (tty)
    - Modes: max `1280×800`, min `640×480`
- **Display server:** none (console/headless context)
- **Graphics API:** No API data available (headless machine)
- **Graphics tools:** None found

## Audio

- **Devices:** None reported

## Sensors & Power

- **Sensors:** no data from `/sys/class/hwmon`
- **Uptime:** 27 minutes (at time of capture)
- **Processes:** 238
- **Power states:**
  - Suspend: `s2idle`
  - Available states: `freeze`, `mem`
  - Hibernate: disabled
  - Hibernate image size: `9.15 GiB`
  - Wakeups: `0`

## Notes

- Designed as a **headless** cloud host (no active GUI, no audio).
- Currently in early configuration stage (no partitions mounted yet).
- Good headroom on:
  - **CPU** (12 vCPUs, AMD EPYC-Genoa Zen 4)
  - **RAM** (~23 GiB total, ~88% free)
  - **Disk** (457.77 GiB, only 637.5 MiB used)
- Running NixOS minimal ISO from live environment (root label: `nixos-minimal-25.05-x86_64`)
