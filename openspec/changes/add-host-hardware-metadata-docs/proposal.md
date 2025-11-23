# Change: Add host hardware metadata documentation

## Why

pantherOS manages multiple hosts (laptops and VPS). AI coding agents and humans
need a consistent, discoverable description of each host’s hardware to:

- Plan safe `disko` layouts and filesystem strategies.
- Decide where to run heavy workloads (containers, AI tools, etc.).
- Tune power profiles, GPU usage, and networking.

Right now, this information is either implicit, scattered, or missing. That
makes it harder for agents to follow the OpenSpec workflow of reading context
before changing specs or code. :contentReference[oaicite:1]{index=1}

## What Changes

- Introduce a new capability spec: `host-hardware-metadata`.
- Define requirements for host hardware documentation:
    - File location under `/docs/hosts/`.
    - Required sections (CPU, Memory, Storage, Graphics, Network, Virtualization,
      Special Hardware).
    - Conventions for handling unknown values and approximations.
- Define how AI agents should use these docs before planning host-specific
  infrastructure changes (e.g. `disko`, Tailscale, power profiles).
- Create initial hardware docs for:
    - `yoga`
    - `zephyrus`
    - `hetzner-vps`

## Impact

- Affected specs:
    - **ADDED** capability: `host-hardware-metadata`
- Affected docs:
    - `/docs/hosts/yoga.hardware.md`
    - `/docs/hosts/zephyrus.hardware.md`
    - `/docs/hosts/hetzner-vps.hardware.md`

No code changes are required as part of this proposal; it establishes a
documentation baseline and agent-facing requirements only.
