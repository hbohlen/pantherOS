#!/usr/bin/env fish

# Test critical hardware components are detected
function test_cpu_detection
    if grep -q "Model name" /tmp/hardware-inventory.txt
        echo "✓ CPU detection: PASSED"
    else
        echo "✗ CPU detection: FAILED"
    end
end

function test_storage_detection
    if grep -q "nvme" /tmp/hardware-inventory.txt
        echo "✓ NVMe detection: PASSED"  
    else
        echo "✗ NVMe detection: FAILED"
    end
end

function test_power_detection
    if grep -q "asusctl: INSTALLED" /tmp/hardware-inventory.txt
        echo "✓ ASUS power tools: PASSED"
    else
        echo "✗ ASUS power tools: FAILED - Install asusctl"
    end
end

function test_rog_detection
    if grep -q "ASUS WMI: DETECTED" /tmp/hardware-inventory.txt
        echo "✓ ROG platform: PASSED"
    else
        echo "✗ ROG platform: FAILED - Check kernel modules"
    end
end

function test_output_structure
    set sections "CPU Information" "GPU Information" "Memory Information" "Storage Devices" "BTRFS Information" "Power Management" "ROG Specific Hardware"
    for section in $sections
        if grep -q "$section" /tmp/hardware-inventory.txt
            echo "✓ Section found: $section"
        else
            echo "✗ Section missing: $section"
        end
    end
end

# Run inventory first to ensure /tmp/hardware-inventory.txt exists
hardware-inventory.fish > /tmp/hardware-inventory.txt

# Run all tests
echo "=== Running Verification Tests ==="
test_cpu_detection
test_storage_detection  
test_power_detection
test_rog_detection
test_output_structure
