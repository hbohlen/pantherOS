# Hardware Specifications Report

**Host:** final-test-host  
**Scan Date:** Wed Nov 19 19:19:38 UTC 2025

## System Information

## System Information

- **Hostname:** c-691e17b5-010d8d8e-80bb5c25de49
- **Kernel:** 4.19.91-c8dfc93.al7.x86_64
- **Architecture:** x86_64
- **OS:** Debian GNU/Linux 12 (bookworm)
- **Uptime:** up 2 minutes

## CPU Information

| Property | Value |
|----------|-------|
| Architecture | x86_64 |
| Address sizes | 46 bits physical, 48 bits virtual |
| Byte Order | Little Endian |
| Vendor ID | GenuineIntel |
| Model name | Intel(R) Xeon(R) Processor @ 2.50GHz |
| CPU family | 6 |
| Model | 85 |
| Stepping | 7 |
| BogoMIPS | 4999.99 |
| Flags | fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault invpcid_single ssbd ibrs ibpb stibp ibrs_enhanced fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves umip avx512_vnni md_clear arch_capabilities |
| Hypervisor vendor | KVM |
| Virtualization type | full |
| Vulnerability Itlb multihit | Not affected |
| Vulnerability Mds | Not affected |
| Vulnerability Meltdown | Not affected |
| Vulnerability Spec store bypass | Mitigation; Speculative Store Bypass disabled via prctl and seccomp |
| Vulnerability Tsx async abort | Not affected |

## Memory Information

### Memory Summary:
```
               total        used        free      shared  buff/cache   available
Mem:           534Mi       288Mi        34Mi        36Ki       221Mi       245Mi
Swap:             0B          0B          0B
```

## Storage Information

### Block Devices:
```
NAME       SIZE TYPE MOUNTPOINT FSTYPE
zram0        0B disk            
vda         10G disk            
pmem0      168M disk            
└─pmem0p1  159M part            
```

### Disk Information (Tree Format):
```
NAME      FSTYPE FSVER LABEL UUID FSAVAIL FSUSE% MOUNTPOINTS
zram0                                            
vda                                              
pmem0                                            
└─pmem0p1                                        
```

### SMART Information:
smartctl or lsblk not available

## Motherboard Information

## Graphics Information

### Graphics Information:
lspci not available

## Network Information

### Network Interfaces:
```
No network interface tools available
```

## USB Information

### USB Controllers and Devices:
```
lspci not available

lsusb not available
```

## Firmware Information


## NixOS Configuration Notes

### For disko.nix setup considerations:

- **Available storage devices:** List the block devices that could be used for partitioning
- **Boot requirements:** Check if UEFI or legacy BIOS is needed based on system firmware
- **Filesystem preferences:** Based on current filesystems in use
- **Swap configuration:** Consider memory size and usage patterns

