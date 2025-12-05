#!/usr/bin/env python3
import json

# Load facter data
with open('hosts/zephyrus/facter.json', 'r') as f:
    zephyrus = json.load(f)

with open('hosts/yoga/facter.json', 'r') as f:
    yoga = json.load(f)

with open('hosts/servers/hetzner-vps/facter.json', 'r') as f:
    hetzner = json.load(f)

with open('hosts/servers/contabo-vps/facter.json', 'r') as f:
    contabo = json.load(f)

# Detection logic (Python version)
def detect_zephyrus(data):
    disks = data.get('hardware', {}).get('disk', [])
    has_nvme0n1 = any(any('nvme0n1' in name for name in d.get('unix_device_names', [])) for d in disks)
    has_nvme1n1 = any(any('nvme1n1' in name for name in d.get('unix_device_names', [])) for d in disks)
    return has_nvme0n1 and has_nvme1n1

def detect_yoga(data):
    disks = data.get('hardware', {}).get('disk', [])
    has_nvme0n1 = any(any('nvme0n1' in name for name in d.get('unix_device_names', [])) for d in disks)
    has_nvme1n1 = any(any('nvme1n1' in name for name in d.get('unix_device_names', [])) for d in disks)
    return has_nvme0n1 and not has_nvme1n1

def detect_hetzner(data):
    disks = data.get('hardware', {}).get('disk', [])
    for d in disks:
        driver = d.get('driver', '')
        resources = d.get('resources', [])
        size = next((r for r in resources if r.get('type') == 'size'), None)
        if size:
            size_bytes = size.get('value_1', 0)
            is_virtio = 'virtio' in driver or 'scsi' in driver or driver == 'virtio_scsi'
            is_hetzner_size = (500_000_000 <= size_bytes <= 1_500_000_000) or \
                              (450_000_000_000 <= size_bytes <= 500_000_000_000)
            if is_virtio and is_hetzner_size:
                return True
    return False

def detect_contabo(data):
    disks = data.get('hardware', {}).get('disk', [])
    for d in disks:
        driver = d.get('driver', '')
        resources = d.get('resources', [])
        size = next((r for r in resources if r.get('type') == 'size'), None)
        if size:
            size_bytes = size.get('value_1', 0)
            is_virtio = 'virtio' in driver or 'scsi' in driver or driver == 'virtio_scsi'
            is_contabo_size = (900_000_000 <= size_bytes <= 1_100_000_000) or \
                              (530_000_000_000 <= size_bytes <= 540_000_000_000)
            if is_virtio and is_contabo_size:
                return True
    return False

def select_storage_profile(data):
    if detect_zephyrus(data):
        return "dev-laptop"
    elif detect_yoga(data):
        return "light-laptop"
    elif detect_hetzner(data):
        return "production-vps"
    elif detect_contabo(data):
        return "staging-vps"
    else:
        return "unknown"

# Run tests
print("=== Hardware Detection Test Results ===")
print(f"Task 2.1 (Zephyrus detection): {'PASS' if detect_zephyrus(zephyrus) else 'FAIL'}")
print(f"Task 2.2 (Yoga detection): {'PASS' if detect_yoga(yoga) else 'FAIL'}")
print(f"Task 2.3a (Hetzner detection): {'PASS' if detect_hetzner(hetzner) else 'FAIL'}")
print(f"Task 2.3b (Contabo detection): {'PASS' if detect_contabo(contabo) else 'FAIL'}")
print(f"Task 2.4a (Zephyrus profile): {'PASS' if select_storage_profile(zephyrus) == 'dev-laptop' else 'FAIL'} ({select_storage_profile(zephyrus)})")
print(f"Task 2.4b (Yoga profile): {'PASS' if select_storage_profile(yoga) == 'light-laptop' else 'FAIL'} ({select_storage_profile(yoga)})")
print(f"Task 2.4c (Hetzner profile): {'PASS' if select_storage_profile(hetzner) == 'production-vps' else 'FAIL'} ({select_storage_profile(hetzner)})")
print(f"Task 2.4d (Contabo profile): {'PASS' if select_storage_profile(contabo) == 'staging-vps' else 'FAIL'} ({select_storage_profile(contabo)})")
print("=== All Tests Complete ===")
