## 1. Flake Configuration

- [x] 1.1 Add niri input to flake.nix from <https://github.com/sodiboo/niri-flake>
- [x] 1.2 Configure niri input with nixpkgs follows
- [x] 1.3 Update flake outputs to include niri input

## 2. Personal Device Integration

- [x] 2.1 Add niri homeModules import to zephyrus host configuration
- [x] 2.2 Enable DankMaterialShell niri integration on zephyrus (enableKeybinds, enableSpawn)
- [x] 2.3 Disable niri-flake polkit agent on zephyrus to prevent conflicts with DankMaterialShell
- [x] 2.4 Add niri homeModules import to yoga host configuration
- [x] 2.5 Enable DankMaterialShell niri integration on yoga (enableKeybinds, enableSpawn)
- [x] 2.6 Disable niri-flake polkit agent on yoga to prevent conflicts with DankMaterialShell

## 3. Window Manager Configuration

- [x] 3.1 Configure Niri as default window manager on zephyrus
- [x] 3.2 Configure Niri as default window manager on yoga
- [x] 3.3 Verify Niri starts automatically with DankMaterialShell

## 4. Validation

- [x] 4.1 Test flake build with new niri input
- [x] 4.2 Verify Niri window manager functionality on personal devices
- [x] 4.3 Test DankMaterialShell keybindings integration with Niri
