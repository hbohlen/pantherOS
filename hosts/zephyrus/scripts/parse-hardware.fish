#!/usr/bin/env fish

# Parse hardware inventory output into structured data
function parse_cpu_info
    echo "=== CPU SPECIFICATIONS ==="
    grep "Model name" /tmp/hardware-inventory.txt | cut -d: -f2 | string trim
    grep "CPU(s)" /tmp/hardware-inventory.txt | head -1 | cut -d: -f2 | string trim
    grep "Core" /tmp/hardware-inventory.txt | cut -d: -f2 | string trim
end

function parse_gpu_info
    echo "=== GPU SPECIFICATIONS ==="
    grep -E "VGA|3D|Display" /tmp/hardware-inventory.txt
end

function parse_memory_info
    echo "=== MEMORY SPECIFICATIONS ==="
    grep "Size:" /tmp/hardware-inventory.txt | head -4
    grep "MemTotal" /proc/meminfo
end

function parse_storage_info
    echo "=== STORAGE SPECIFICATIONS ==="
    grep -A20 "Storage Devices" /tmp/hardware-inventory.txt | grep -v "Storage Devices"
end

# Run hardware inventory and parse
# Assumes hardware-inventory.fish is in PATH
hardware-inventory.fish > /tmp/hardware-inventory.txt
parse_cpu_info
echo ""
parse_gpu_info  
echo ""
parse_memory_info
echo ""
parse_storage_info
