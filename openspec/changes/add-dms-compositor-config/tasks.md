## 1. Layer Shell Namespace Documentation

- [ ] 1.1 Document Wayland layer shell protocol usage in DMS
- [ ] 1.2 Document namespace prefix convention (dms:)
- [ ] 1.3 Create complete namespace reference for modal components (15+ modals)
- [ ] 1.4 Create complete namespace reference for popout components (7+ popouts)
- [ ] 1.5 Create complete namespace reference for misc components (11+ components)
- [ ] 1.6 Document plugin namespace convention (dms-plugin:)
- [ ] 1.7 Document fallback namespaces (dms:modal, dms:popout, dms-plugin:plugin)
- [ ] 1.8 Provide namespace discovery methods (hyprctl layers)

## 2. Niri Compositor Configuration

- [ ] 2.1 Document niri KDL configuration format and non-repeatable settings
- [ ] 2.2 Create dms/binds.kdl include file for keybindings
- [ ] 2.3 Create dms/colors.kdl include file for color synchronization
- [ ] 2.4 Create dms/layout.kdl include file for layout settings
- [ ] 2.5 Document layout configuration (gaps, transparent background)
- [ ] 2.6 Document layer rules for wallpaper backdrop integration
- [ ] 2.7 Document layer rules for blur wallpaper backdrop
- [ ] 2.8 Document startup commands (clipboard, DMS, polkit)
- [ ] 2.9 Document environment variables for Wayland apps
- [ ] 2.10 Document window rules (GNOME apps, terminals, floating, opacity)
- [ ] 2.11 Provide complete niri keybinding configuration with hotkey-overlay

## 3. Hyprland Compositor Configuration

- [ ] 3.1 Document Hyprland configuration file location and format
- [ ] 3.2 Document startup commands (exec-once for DMS and services)
- [ ] 3.3 Document misc settings (disable logo and splash)
- [ ] 3.4 Document environment variables for Wayland apps
- [ ] 3.5 Document layer rules for animations and blur
- [ ] 3.6 Document general layout settings (gaps, borders, colors)
- [ ] 3.7 Document decoration settings (rounding, opacity, shadows, blur)
- [ ] 3.8 Configure blur parameters (size, passes, optimizations, vibrancy)
- [ ] 3.9 Document window rules (opacity, rounding, borders, floating)
- [ ] 3.10 Provide complete Hyprland keybinding configuration
- [ ] 3.11 Document blur performance tuning (passes, size, xray mode)
- [ ] 3.12 Document disabling DMS animations for compositor animations
- [ ] 3.13 Document regex patterns for layer rules

## 4. Sway Compositor Configuration

- [ ] 4.1 Document Sway i3-compatible configuration format
- [ ] 4.2 Document startup commands for DMS and services
- [ ] 4.3 Document environment variables for Wayland apps
- [ ] 4.4 Provide Sway keybinding examples with bindsym
- [ ] 4.5 Document layer rules (if supported)
- [ ] 4.6 Document window rules for tiling behavior
- [ ] 4.7 Create complete Sway configuration example

## 5. dwl/MangoWC Compositor Configuration

- [ ] 5.1 Document MangoWC dynamic tiling compositor basics
- [ ] 5.2 Document startup commands for DMS
- [ ] 5.3 Document environment variables for Wayland apps
- [ ] 5.4 Reference MangoWC layer rules wiki
- [ ] 5.5 Provide MangoWC keybinding configuration format
- [ ] 5.6 Create configuration examples when format is finalized

## 6. labwc Compositor Configuration

- [ ] 6.1 Document labwc Openbox-inspired configuration
- [ ] 6.2 Document startup commands for DMS
- [ ] 6.3 Document environment variables for Wayland apps
- [ ] 6.4 Reference labwc documentation for configuration
- [ ] 6.5 Provide labwc keybinding configuration format
- [ ] 6.6 Create configuration examples

## 7. Generic Wayland Compositor Support

- [ ] 7.1 Document protocol requirements (layer shell, session lock, ext-workspace-v1, wlr-output-management)
- [ ] 7.2 Document basic DMS integration steps for any compositor
- [ ] 7.3 Provide generic startup command examples
- [ ] 7.4 Provide generic keybinding examples with IPC
- [ ] 7.5 Document environment variable setup
- [ ] 7.6 Document limitations for unsupported compositors

## 8. Updated IPC Command Format

- [ ] 8.1 Update all IPC examples to use `dms ipc call` format
- [ ] 8.2 Document new IPC modules (dankdash, hypr)
- [ ] 8.3 Document new IPC actions (focusOrToggle)
- [ ] 8.4 Update keybinding examples across all compositors
- [ ] 8.5 Update IPC command reference documentation

## 9. Layer Rule Configuration

- [ ] 9.1 Document blur layer rules with regex patterns
- [ ] 9.2 Document animation layer rules with compositor-specific syntax
- [ ] 9.3 Document dim layer rules for modal backgrounds
- [ ] 9.4 Provide layer rule examples for each component category
- [ ] 9.5 Document layer rule variables for easier management
- [ ] 9.6 Document compositor-specific layer rule differences

## 10. Window Rule Configuration

- [ ] 10.1 Document opacity rules for inactive windows
- [ ] 10.2 Document rounding rules for application categories
- [ ] 10.3 Document border rules (noborder for specific apps)
- [ ] 10.4 Document floating rules for dialogs and utilities
- [ ] 10.5 Document DMS component floating behavior (org.quickshell)
- [ ] 10.6 Provide application-specific rule examples (GNOME, terminals)

## 11. Environment Variable Configuration

- [ ] 11.1 Document QT_QPA_PLATFORM for Wayland Qt apps
- [ ] 11.2 Document ELECTRON_OZONE_PLATFORM_HINT for Electron apps
- [ ] 11.3 Document QT_QPA_PLATFORMTHEME for Qt theming
- [ ] 11.4 Document XDG_CURRENT_DESKTOP for desktop identification
- [ ] 11.5 Document compositor-specific environment variable syntax

## 12. Performance Optimization

- [ ] 12.1 Document blur performance impact and tuning
- [ ] 12.2 Provide optimization steps (reduce passes, size, xray mode)
- [ ] 12.3 Document real-time blur testing commands
- [ ] 12.4 Document DMS animation disable for compositor animations
- [ ] 12.5 Document dim background toggle for performance

## 13. Troubleshooting

- [ ] 13.1 Document DMS auto-start troubleshooting (check logs, manual start)
- [ ] 13.2 Document keybinding troubleshooting (DMS running, syntax, pgrep)
- [ ] 13.3 Document layer rule troubleshooting
- [ ] 13.4 Document blur effect issues
- [ ] 13.5 Document protocol compatibility issues
- [ ] 13.6 Provide compositor log inspection guidance

## 14. Testing and Verification

- [ ] 14.1 Test niri configuration with all layer rules
- [ ] 14.2 Test Hyprland configuration with blur and animations
- [ ] 14.3 Test Sway configuration with keybindings
- [ ] 14.4 Verify layer shell namespaces are correctly applied
- [ ] 14.5 Verify window rules work for all application categories
- [ ] 14.6 Verify environment variables are correctly set
- [ ] 14.7 Test DMS auto-start on all compositors
- [ ] 14.8 Verify keybindings work on all compositors
- [ ] 14.9 Test blur performance on different hardware
- [ ] 14.10 Verify protocol requirements are met
