# Hardware Detection System

## Overview
The `zephyrus` host utilizes a custom hardware detection system to inventory, parse, and verify the laptop's hardware components. This ensures that the NixOS configuration is tailored to the specific hardware present (ASUS ROG Zephyrus G15).

## Components

### 1. Scripts
Located in `hosts/zephyrus/scripts/`:

-   **`hardware-inventory.fish`**:
    -   **Purpose**: Gathers raw hardware information.
    -   **Tools Used**: `lscpu`, `lsblk`, `lspci`, `lsusb`, `dmidecode`, `asusctl`, `supergfxctl`.
    -   **Output**: JSON-formatted hardware inventory (via `jq` if available, or structured text).

-   **`parse-hardware.fish`**:
    -   **Purpose**: Parses the raw inventory into a structured format usable by other tools or for human inspection.
    -   **Functionality**: Extracts key metrics like CPU model, GPU models (Integrated + Discrete), RAM size, and NVMe drive details.

-   **`verify-hardware.fish`**:
    -   **Purpose**: Runs assertions against the detected hardware to ensure it matches the expected configuration for the Zephyrus G15.
    -   **Checks**:
        -   CPU is Intel Core i9-12900H.
        -   NVIDIA RTX 3060/3070 is present.
        -   Dual NVMe drives are detected.
        -   ASUS-specific devices (keyboard, touchpad) are present.

### 2. Nix Integration
-   **Packaging**: The scripts are packaged as a Nix derivation in `hosts/zephyrus/scripts/default.nix`.
    -   **Dependencies**: `util-linux`, `pciutils`, `usbutils`, `dmidecode`, `jq`, `asusctl`, `supergfxctl` are available in the script's `PATH` via `wrapProgram`.
-   **System Installation**: The package is added to `environment.systemPackages` in `hosts/zephyrus/default.nix`.

## Usage
To verify the hardware configuration on the running system:
```bash
verify-hardware.fish
```

## Maintenance
-   If hardware changes (e.g., RAM upgrade, new SSD), update `verify-hardware.fish` to reflect the new expected state.
-   If new hardware tools are needed, add them to the `buildInputs` in `hosts/zephyrus/scripts/default.nix`.
