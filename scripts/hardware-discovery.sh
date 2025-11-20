#!/usr/bin/env bash
# Hardware Discovery Script for pantherOS
# Run this on each host to gather all required information

HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="hardware-discovery-${HOSTNAME}-${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

echo "=== Hardware Discovery for $HOSTNAME ==="
echo "Output directory: $OUTPUT_DIR"
echo ""

# 1. System Overview
echo "1. System Overview..."
uname -a > "$OUTPUT_DIR/01-system-overview.txt"
cat /etc/os-release >> "$OUTPUT_DIR/01-system-overview.txt"

# 2. CPU Information
echo "2. CPU Information..."
lscpu > "$OUTPUT_DIR/02-cpu-info.txt"
cat /proc/cpuinfo >> "$OUTPUT_DIR/02-cpu-info.txt"

# 3. Memory Information
echo "3. Memory Information..."
free -h > "$OUTPUT_DIR/03-memory-info.txt"
cat /proc/meminfo >> "$OUTPUT_DIR/03-memory-info.txt"
swapon --show >> "$OUTPUT_DIR/03-memory-info.txt"

# 4. Storage Devices (Critical for disko.nix)
echo "4. Storage Devices..."
lsblk -f > "$OUTPUT_DIR/04-storage-devices.txt"
echo "" >> "$OUTPUT_DIR/04-storage-devices.txt"
echo "=== Disk Details ===" >> "$OUTPUT_DIR/04-storage-devices.txt"
lsblk -d -o name,size,rota,type,mountpoint,disc-gran,disc-max >> "$OUTPUT_DIR/04-storage-devices.txt"

# Partition information
echo "" >> "$OUTPUT_DIR/04-storage-devices.txt"
echo "=== Partition Information ===" >> "$OUTPUT_DIR/04-storage-devices.txt"
fdisk -l >> "$OUTPUT_DIR/04-storage-devices.txt" 2>/dev/null

# SMART data for health check
echo "" >> "$OUTPUT_DIR/04-storage-devices.txt"
echo "=== SMART Status ===" >> "$OUTPUT_DIR/04-storage-devices.txt"
if command -v smartctl >/dev/null 2>&1; then
    for disk in $(lsblk -d -o name,size | grep -E "^(sd|nvme|hd)" | awk '{print $1}'); do
        echo "=== /dev/$disk SMART Info ===" >> "$OUTPUT_DIR/04-storage-devices.txt"
        smartctl -i /dev/$disk >> "$OUTPUT_DIR/04-storage-devices.txt" 2>/dev/null || echo "SMART info not available for /dev/$disk" >> "$OUTPUT_DIR/04-storage-devices.txt"
        echo "" >> "$OUTPUT_DIR/04-storage-devices.txt"
    done
else
    echo "smartctl not available" >> "$OUTPUT_DIR/04-storage-devices.txt"
fi

# Block device queue information
echo "" >> "$OUTPUT_DIR/04-storage-devices.txt"
echo "=== Block Device Queue Info ===" >> "$OUTPUT_DIR/04-storage-devices.txt"
for disk in /sys/block/sd* /sys/block/nvme*; do
    if [ -e "$disk/queue" ]; then
        echo "$(basename $disk):" >> "$OUTPUT_DIR/04-storage-devices.txt"
        echo "  Scheduler: $(cat $disk/queue/scheduler 2>/dev/null || echo "Unknown")" >> "$OUTPUT_DIR/04-storage-devices.txt"
        echo "  Rotational: $(cat $disk/queue/rotational 2>/dev/null || echo "Unknown")" >> "$OUTPUT_DIR/04-storage-devices.txt"
        echo "  Scheduler: $(cat $disk/queue/scheduler 2>/dev/null || echo "Unknown")" >> "$OUTPUT_DIR/04-storage-devices.txt"
    fi
done 2>/dev/null

# 5. Filesystem Information
echo "5. Filesystem Information..."
df -h > "$OUTPUT_DIR/05-filesystems.txt"
mount | grep -E "(ext4|btrfs|xfs)" >> "$OUTPUT_DIR/05-filesystems.txt"

# 6. GPU Information
echo "6. GPU Information..."
lspci -k | grep -A 3 -i vga > "$OUTPUT_DIR/06-gpu-info.txt"
lspci -nnk | grep -i vga >> "$OUTPUT_DIR/06-gpu-info.txt"

# More comprehensive GPU detection
echo "=== All Graphics Devices ===" >> "$OUTPUT_DIR/06-gpu-info.txt"
lspci | grep -E "(VGA|3D|Display)" >> "$OUTPUT_DIR/06-gpu-info.txt"

# OpenGL information
if command -v glxinfo >/dev/null 2>&1; then
    echo "=== OpenGL Information ===" >> "$OUTPUT_DIR/06-gpu-info.txt"
    glxinfo -B >> "$OUTPUT_DIR/06-gpu-info.txt" 2>/dev/null
else
    echo "glxinfo not available" >> "$OUTPUT_DIR/06-gpu-info.txt"
fi

# Vulkan information
if command -v vulkaninfo >/dev/null 2>&1; then
    echo "=== Vulkan Information ===" >> "$OUTPUT_DIR/06-gpu-info.txt"
    vulkaninfo --summary >> "$OUTPUT_DIR/06-gpu-info.txt" 2>/dev/null
else
    echo "vulkaninfo not available" >> "$OUTPUT_DIR/06-gpu-info.txt"
fi

# Check for Wayland/X11
echo "=== Display Server ===" >> "$OUTPUT_DIR/06-gpu-info.txt"
echo "XDG_SESSION_TYPE: $XDG_SESSION_TYPE" >> "$OUTPUT_DIR/06-gpu-info.txt"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY" >> "$OUTPUT_DIR/06-gpu-info.txt"
echo "DISPLAY: $DISPLAY" >> "$OUTPUT_DIR/06-gpu-info.txt"

# 7. Network Interfaces
echo "7. Network Interfaces..."
ip addr > "$OUTPUT_DIR/07-network-interfaces.txt"
ip link show >> "$OUTPUT_DIR/07-network-interfaces.txt"
ip route show >> "$OUTPUT_DIR/07-network-interfaces.txt"

# Wireless information (modern approach)
if command -v iw >/dev/null 2>&1; then
    echo "=== Wireless Interfaces ===" >> "$OUTPUT_DIR/07-network-interfaces.txt"
    iw dev >> "$OUTPUT_DIR/07-network-interfaces.txt" 2>/dev/null || echo "No wireless interfaces detected" >> "$OUTPUT_DIR/07-network-interfaces.txt"
    
    # Get wireless details for each interface
    for iface in $(iw dev 2>/dev/null | grep Interface | awk '{print $2}'); do
        echo "=== $iface Details ===" >> "$OUTPUT_DIR/07-network-interfaces.txt"
        iw "$iface" info >> "$OUTPUT_DIR/07-network-interfaces.txt" 2>/dev/null
        iw "$iface" link >> "$OUTPUT_DIR/07-network-interfaces.txt" 2>/dev/null
    done
else
    echo "iw command not available" >> "$OUTPUT_DIR/07-network-interfaces.txt"
fi

# Fallback to iwconfig if available
iwconfig 2>/dev/null >> "$OUTPUT_DIR/07-network-interfaces.txt" || echo "iwconfig not available" >> "$OUTPUT_DIR/07-network-interfaces.txt"

# Network device details
echo "=== Network Device Details ===" >> "$OUTPUT_DIR/07-network-interfaces.txt"
ethtool -i wlan0 2>/dev/null >> "$OUTPUT_DIR/07-network-interfaces.txt" || echo "No wlan0 interface" >> "$OUTPUT_DIR/07-network-interfaces.txt"
ethtool -i eth0 2>/dev/null >> "$OUTPUT_DIR/07-network-interfaces.txt" || echo "No eth0 interface" >> "$OUTPUT_DIR/07-network-interfaces.txt"

# 8. All PCI Devices
echo "8. PCI Devices..."
lspci -nnk > "$OUTPUT_DIR/08-pci-devices.txt"
lspci -v >> "$OUTPUT_DIR/08-pci-devices.txt"

# 9. USB Devices
echo "9. USB Devices..."
lsusb > "$OUTPUT_DIR/09-usb-devices.txt"
lsusb -v >> "$OUTPUT_DIR/09-usb-devices.txt"

# 10. Audio Devices
echo "10. Audio Devices..."
aplay -l > "$OUTPUT_DIR/10-audio-devices.txt"
cat /proc/asound/cards >> "$OUTPUT_DIR/10-audio-devices.txt"

# 11. Battery/Power (Laptops)
echo "11. Power Management..."
upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null > "$OUTPUT_DIR/11-power-management.txt" || echo "No battery found" > "$OUTPUT_DIR/11-power-management.txt"

# Additional battery information
echo "=== Additional Battery Info ===" >> "$OUTPUT_DIR/11-power-management.txt"
if [ -f /sys/class/power_supply/BAT0/status ]; then
    echo "Status: $(cat /sys/class/power_supply/BAT0/status)" >> "$OUTPUT_DIR/11-power-management.txt"
    echo "Capacity: $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "Unknown")%" >> "$OUTPUT_DIR/11-power-management.txt"
    echo "Health: $(cat /sys/class/power_supply/BAT0/health 2>/dev/null || echo "Unknown")" >> "$OUTPUT_DIR/11-power-management.txt"
    echo "Power Now: $(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo "Unknown") µW" >> "$OUTPUT_DIR/11-power-management.txt"
    echo "Energy Now: $(cat /sys/class/power_supply/BAT0/energy_now 2>/dev/null || echo "Unknown") µWh" >> "$OUTPUT_DIR/11-power-management.txt"
    echo "Energy Full: $(cat /sys/class/power_supply/BAT0/energy_full 2>/dev/null || echo "Unknown") µWh" >> "$OUTPUT_DIR/11-power-management.txt"
else
    echo "No battery status information available" >> "$OUTPUT_DIR/11-power-management.txt"
fi

# Check for AC adapter
if [ -f /sys/class/power_supply/AC/online ]; then
    echo "AC Adapter: $(cat /sys/class/power_supply/AC/online)" >> "$OUTPUT_DIR/11-power-management.txt"
fi

# 12. Kernel Modules
echo "12. Kernel Modules..."
lsmod > "$OUTPUT_DIR/12-kernel-modules.txt"

# 13. Firmware Information
echo "13. Firmware Information..."
dmesg | grep -i firmware > "$OUTPUT_DIR/13-firmware.txt"

# Additional hardware detection
echo "14. Additional Hardware Detection..." > "$OUTPUT_DIR/14-additional-hardware.txt"

# Check for fingerprint readers
echo "=== Fingerprint Readers ===" >> "$OUTPUT_DIR/14-additional-hardware.txt"
lsusb | grep -i fingerprint >> "$OUTPUT_DIR/14-additional-hardware.txt" 2>/dev/null || echo "No fingerprint readers detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"

# Check for touchscreens
echo "=== Touchscreens ===" >> "$OUTPUT_DIR/14-additional-hardware.txt"
lsusb | grep -i touchscreen >> "$OUTPUT_DIR/14-additional-hardware.txt" 2>/dev/null || echo "No touchscreens detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"
xinput list 2>/dev/null | grep -i touchscreen >> "$OUTPUT_DIR/14-additional-hardware.txt" || echo "No X11 touchscreens detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"

# Check for special laptop features
echo "=== Laptop Features ===" >> "$OUTPUT_DIR/14-additional-hardware.txt"
# Check for backlight control
if [ -d /sys/class/backlight ]; then
    echo "Backlight devices:" >> "$OUTPUT_DIR/14-additional-hardware.txt"
    ls /sys/class/backlight >> "$OUTPUT_DIR/14-additional-hardware.txt"
else
    echo "No backlight control detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"
fi

# Check for thermal zones
if [ -d /sys/class/thermal ]; then
    echo "Thermal zones:" >> "$OUTPUT_DIR/14-additional-hardware.txt"
    ls /sys/class/thermal/thermal_zone* 2>/dev/null | wc -l | xargs echo "Thermal zones found:" >> "$OUTPUT_DIR/14-additional-hardware.txt"
else
    echo "No thermal zones detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"
fi

# Check for accelerometer (for tablet/2-in-1 detection)
echo "=== Accelerometer ===" >> "$OUTPUT_DIR/14-additional-hardware.txt"
lsusb | grep -i accelerometer >> "$OUTPUT_DIR/14-additional-hardware.txt" 2>/dev/null || echo "No accelerometer detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"
if [ -e /sys/devices/platform/iio:device0 ]; then
    echo "IIO accelerometer detected" >> "$OUTPUT_DIR/14-additional-hardware.txt"
fi

# 15. Systemd Hardware
echo "15. Systemd Hardware Info..."
systemd-detect-virt > "$OUTPUT_DIR/15-virtualization.txt"
hostnamectl >> "$OUTPUT_DIR/15-virtualization.txt"

# 16. Comprehensive Overview (inxi alternative)
echo "16. Comprehensive Overview..."
if command -v inxi >/dev/null 2>&1; then
    inxi -Fazy > "$OUTPUT_DIR/16-comprehensive-overview.txt"
else
    echo "inxi not installed, using alternatives..." > "$OUTPUT_DIR/16-comprehensive-overview.txt"
    neofetch 2>/dev/null >> "$OUTPUT_DIR/16-comprehensive-overview.txt" || echo "neofetch not available" >> "$OUTPUT_DIR/16-comprehensive-overview.txt"
fi

# 17. Disk Performance (for SSD optimization)
echo "17. Disk Performance..."
echo "=== Disk Performance Metrics ===" > "$OUTPUT_DIR/17-disk-performance.txt"

# Test read speed of main disk
MAIN_DISK=$(lsblk -d -o name,size | grep -E "^(sd|nvme|hd)" | head -1 | awk '{print $1}')
if [ -n "$MAIN_DISK" ]; then
    echo "Testing /dev/$MAIN_DISK performance..." >> "$OUTPUT_DIR/17-disk-performance.txt"
    # Simple read test (first 1GB)
    if command -v dd >/dev/null 2>&1; then
        echo "Read speed test (first 1GB):" >> "$OUTPUT_DIR/17-disk-performance.txt"
        dd if=/dev/$MAIN_DISK of=/dev/null bs=1M count=1024 2>&1 | grep -E "(copied|MB/s)" >> "$OUTPUT_DIR/17-disk-performance.txt" || echo "Read test failed" >> "$OUTPUT_DIR/17-disk-performance.txt"
    fi
else
    echo "No suitable disk found for performance testing" >> "$OUTPUT_DIR/17-disk-performance.txt"
fi

# Check for TRIM support (SSD optimization)
echo "=== TRIM Support ===" >> "$OUTPUT_DIR/17-disk-performance.txt"
if command -v lsblk >/dev/null 2>&1; then
    lsblk -D >> "$OUTPUT_DIR/17-disk-performance.txt" 2>/dev/null || echo "lsblk -D not available" >> "$OUTPUT_DIR/17-disk-performance.txt"
fi

# Check scheduler
echo "=== I/O Scheduler ===" >> "$OUTPUT_DIR/17-disk-performance.txt"
for disk in /sys/block/sd* /sys/block/nvme*; do
    if [ -e "$disk/queue/scheduler" ]; then
        echo "$(basename $disk): $(cat $disk/queue/scheduler)" >> "$OUTPUT_DIR/17-disk-performance.txt"
    fi
done 2>/dev/null

# Create summary
echo ""
echo "=== Hardware Discovery Summary ==="
echo "Host: $HOSTNAME"
echo "Timestamp: $TIMESTAMP"
echo "Output saved to: $OUTPUT_DIR/"
echo ""

# Generate quick summary
cat > "$OUTPUT_DIR/SUMMARY.txt" << EOF
Hardware Discovery Summary for $HOSTNAME
Generated: $(date)

=== Key Specifications ===
CPU: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)
Cores: $(nproc)
Memory: $(free -h | grep Mem | awk '{print $2}')
Storage Devices: $(lsblk -d -o name,size | grep -E "^(sd|nvme|hd)" | wc -l)
GPU: $(lspci | grep -i vga | cut -d: -f3 | xargs)

=== Storage Layout ===
$(lsblk -f)

=== Network Interfaces ===
Physical Interfaces: $(ip addr show | grep -E "^[0-9]+:" | cut -d: -f2 | xargs)
Wireless: $(iw dev 2>/dev/null | grep Interface | awk '{print $2}' | tr '\n' ' ' || echo "None detected")

=== Special Hardware ===
Battery: $([ -f /sys/class/power_supply/BAT0/status ] && echo "Yes ($(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "Unknown")%)" || echo "No")
Fingerprint Reader: $(lsusb | grep -i fingerprint >/dev/null 2>&1 && echo "Yes" || echo "No")
Touchscreen: $(lsusb | grep -i touchscreen >/dev/null 2>&1 && echo "Yes" || echo "No")
Backlight Control: $([ -d /sys/class/backlight ] && echo "Yes" || echo "No")

=== System Type ===
Virtualization: $(systemd-detect-virt)
Form Factor: $([ -f /sys/class/dmi/id/chassis_type ] && echo "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "Unknown")" || echo "Not detectable")
EOF

echo "Summary created: $OUTPUT_DIR/SUMMARY.txt"
echo ""
echo "Files created:"
ls -la "$OUTPUT_DIR/"
echo ""
echo "Next steps:"
echo "1. Review the SUMMARY.txt file"
echo "2. Check storage-devices.txt for disk layout planning"
echo "3. Review gpu-info.txt for graphics driver requirements"
echo "4. Copy results to your pantherOS repository"