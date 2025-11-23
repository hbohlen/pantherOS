## ADDED Requirements

### Requirement: Host hardware docs location and naming

Each managed host in pantherOS SHALL have a hardware documentation file at:

- `/docs/hosts/<host-slug>.hardware.md`

Where:

- `<host-slug>` matches the flake / NixOS `networking.hostName` or another
  stable identifier chosen for that host.
- Each hardware doc MUST be stored in the Git repository and version-controlled.

#### Scenario: New host added to pantherOS

- **WHEN** a new host is added to pantherOS (e.g. a laptop or VPS)
- **THEN** the contributor SHALL create `/docs/hosts/<host-slug>.hardware.md`
- **AND** the file SHALL be committed as part of the onboarding work for that host.

#### Scenario: Existing host without hardware doc

- **WHEN** an existing host is discovered without a corresponding hardware
  documentation file under `/docs/hosts/`
- **THEN** the contributor or agent SHALL add the missing file
- **AND** follow the required structure defined in this capability.

### Requirement: Host hardware doc structure

Each host hardware doc SHALL contain, at minimum, the following sections in
this order:

1. Header with host identity:

    ```md
    # <Friendly Host Name> Hardware Specifications

    **Host Name**: <host-slug>  
    **Form Factor**: laptop | desktop | vps  
    **Primary Role**: short phrase (e.g. "codespace-server")
    ```

## CPU

## Memory

## Storage

## Graphics (or ## Graphics (if applicable) if the host has no GPU)

## Network

## Virtualization

## Special Hardware / Notes (for host-specific details)

Each section SHALL describe only the hardware characteristics relevant to
infrastructure decisions (e.g., performance, power, networking, input devices).

Scenario: Creating a hardware doc for a new laptop

WHEN a contributor adds a new laptop host

THEN they SHALL document:

CPU model and core/thread counts

Total RAM and upgradeability

Internal SSD(s) and any important performance/role notes

Integrated/dedicated GPU presence and driver expectations

Wired and wireless networking capabilities

Any virtualization capabilities or limitations

Laptop-specific hardware (battery, touchpad, fingerprint reader, etc.)

AND they SHALL use the section structure and header format listed above.

Requirement: Handling unknown and approximate values

The host hardware docs SHALL:

Use explicit placeholders when a value is unknown:

Example: **Unknown** (TODO: verify via lscpu).

Allow approximate values where exact numbers are not critical, as long as the
approximation is clearly indicated (e.g., ~3000 MB/s read).

Contributors MUST NOT invent precise-looking values without verification.

Scenario: Missing exact SSD performance numbers

WHEN a contributor does not know the exact SSD read/write speeds for a host

THEN they MAY document approximate speeds (e.g. based on typical model specs)

BUT they SHALL mark them as approximate (e.g., ~3000 MB/s read, ~2000 MB/s write)

AND they SHALL NOT present unverified values as exact numbers.

Requirement: Agent usage of host hardware docs

AI coding agents working on host-specific changes (under OpenSpec workflow)
SHALL read the host’s hardware doc before proposing or modifying:

Disk layouts (disko specs, partitioning, filesystems).

Performance-related profiles (CPU governor, power profiles).

GPU or display-related configuration (NVIDIA enabling, hybrid modes).

Networking assumptions (wired vs Wi-Fi vs VPS, public IP presence).

Agents SHOULD reference the hardware doc path in their reasoning or comments.

Scenario: Agent planning a new disko layout for zephyrus

WHEN an agent is asked to design or modify the disko configuration for
the zephyrus host

THEN the agent SHALL first read /docs/hosts/zephyrus.hardware.md

AND the agent SHALL base decisions (e.g., which NVMe drive is used for OS
vs data) on the information in that document

AND if the document is missing or incomplete, the agent SHALL call this
out and request clarification or a doc update rather than guessing.

Requirement: Keeping hardware docs and reality aligned

When significant hardware changes occur for a host (e.g., RAM upgraded, disks
replaced, GPU added/removed), contributors SHALL update the corresponding
hardware doc to reflect the new reality.

Scenario: Upgrading RAM in a laptop host

WHEN the RAM in yoga is upgraded from 16 GiB to 32 GiB

THEN the contributor SHALL update /docs/hosts/yoga.hardware.md

AND adjust the Memory section to show the new capacity and any changes in
configuration (e.g., dual-channel DIMM layout)

AND mention any relevant implications (e.g., device now suitable for
heavier container workloads).
