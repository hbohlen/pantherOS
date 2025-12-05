#!/usr/bin/env python3
import json
import os

# Function to extract disk info from facter.json
def extract_disk_info(facter_file):
    with open(facter_file, 'r') as f:
        data = json.load(f)

    disks = []
    if 'hardware' in data and 'disk' in data['hardware']:
        for disk in data['hardware']['disk']:
            disk_info = {
                'name': None,
                'model': disk.get('model', 'Unknown'),
                'driver': disk.get('driver', 'Unknown'),
                'size_bytes': None,
                'is_nvme': 'nvme' in disk.get('class_list', [])
            }

            # Extract device name
            if 'unix_device_names' in disk and len(disk['unix_device_names']) > 0:
                disk_info['name'] = disk['unix_device_names'][0]

            # Extract size from resources
            if 'resources' in disk:
                for res in disk['resources']:
                    if res.get('type') == 'size' and 'value_1' in res:
                        disk_info['size_bytes'] = res['value_1']

            disks.append(disk_info)

    return disks

# Extract info for all hosts
hosts = [
    ('zephyrus', '/home/hbohlen/Downloads/pantherOS-main/hosts/zephyrus/facter.json'),
    ('yoga', '/home/hbohlen/Downloads/pantherOS-main/hosts/yoga/facter.json'),
    ('hetzner-vps', '/home/hbohlen/Downloads/pantherOS-main/hosts/servers/hetzner-vps/facter.json'),
    ('contabo-vps', '/home/hbohlen/Downloads/pantherOS-main/hosts/servers/contabo-vps/facter.json'),
]

for host_name, facter_file in hosts:
    try:
        disks = extract_disk_info(facter_file)
        print(f"\n=== {host_name} ===")
        for disk in disks:
            size_gb = disk['size_bytes'] / (1024**3) if disk['size_bytes'] else 0
            print(f"  Device: {disk['name']}")
            print(f"  Model: {disk['model']}")
            print(f"  Driver: {disk['driver']}")
            print(f"  NVMe: {disk['is_nvme']}")
            print(f"  Size: {size_gb:.2f} GB ({disk['size_bytes']} bytes)")
            print()
    except Exception as e:
        print(f"Error processing {host_name}: {e}")
