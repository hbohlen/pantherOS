#!/usr/bin/env fish

# CachyOS ROG Zephyrus Hardware Inventory (NixOS Adapted)
echo "=== CachyOS Hardware Inventory ===" 
echo "Generated: "(date)
echo ""

echo "=== CPU Information ==="
lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core|MHz|CPU max|CPU min"
echo ""

echo "=== GPU Information ==="
lspci | grep -E "VGA|3D|Display"
if command -v nvidia-smi >/dev/null
    nvidia-smi
else
    echo "NVIDIA drivers not detected"
end
echo ""

echo "=== Memory Information ==="
if command -v dmidecode >/dev/null
    sudo dmidecode -t memory | grep -E "Size:|Speed:|Type:" | head -8
else
    echo "dmidecode not found"
end
free -h
echo ""

echo "=== Storage Devices ==="
lsblk -d -o NAME,SIZE,MODEL,ROTA,TRAN
echo ""
echo "NVMe Details:"
find /sys/block/nvme* -name model 2>/dev/null | while read model_path
    echo (basename (dirname $model_path))": "(cat $model_path)
end
echo ""

echo "=== BTRFS Information ==="
if command -v btrfs >/dev/null
    sudo btrfs subvolume list / 2>/dev/null; or echo "Not BTRFS or need root permissions"
else
    echo "btrfs command not found"
end
mount | grep btrfs
echo ""

echo "=== Power Management ==="
if command -v asusctl >/dev/null
    echo "asusctl: INSTALLED"
else
    echo "asusctl: NOT FOUND"
end

if command -v powerprofilesctl >/dev/null
    echo "power-profiles-daemon: INSTALLED"
else
    echo "power-profiles-daemon: NOT FOUND"
end

# Check for battery charge control support in sysfs
if test -n (find /sys/class/power_supply/BAT* -name charge_control_end_threshold 2>/dev/null)
    echo "Battery charge control: SUPPORTED"
else
    echo "Battery charge control: NOT SUPPORTED"
end
echo ""

echo "=== Network Devices ==="
lspci | grep -i network
echo ""

echo "=== ROG Specific Hardware ==="
if test -f /sys/devices/platform/asus-nb-wmi/kbd_backlight
    echo "Keyboard backlight: SUPPORTED"
else
    echo "Keyboard backlight: NOT DETECTED"
end

if test -d /sys/devices/platform/asus-nb-wmi
    echo "ASUS WMI: DETECTED"
else
    echo "ASUS WMI: NOT DETECTED"
end
echo ""

echo "=== Thermal Zones ==="
for zone in /sys/class/thermal/thermal_zone*
    if test -f $zone/type
        echo (basename $zone)": "(cat $zone/type)" - "(cat $zone/temp 2>/dev/null)"C"
    end
end
echo ""

echo "=== Audio System ==="
lspci | grep -i audio
if command -v pactl >/dev/null
    pactl info 2>/dev/null | grep "Server Name"; or echo "PulseAudio not running"
else
    echo "pactl not found"
end
echo ""
