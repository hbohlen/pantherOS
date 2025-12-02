# Change: Add Matugen Dynamic Theming

## Why

To provide comprehensive dynamic theming support for native applications through matugen integration with DankMaterialShell, enabling automatic theme generation from wallpapers and seamless theming across GTK, Qt, Firefox, editors, and terminal applications using Material Design color palettes and the custom dank16 color scheme.

## What Changes

- Add matugen automatic theme generation on wallpaper changes and theme switches
- Support custom matugen templates for user-defined applications via ~/.config/matugen/config.toml
- Generate theme files for GTK 3/4, Qt 5/6, Firefox, VSCode, and terminal applications (ghostty, kitty, foot, alacritty)
- Provide dank16 color palette (16 ANSI colors) alongside standard matugen color variables
- Implement environment variable DMS_DISABLE_MATUGEN for disabling theme generation
- Add "Apply GTK/Qt Themes" toggles in Settings to control symlink management
- Support both GTK passthrough and dedicated Qt control for Qt application theming
- Provide Firefox integration via Material Fox theme or Pywalfox extension
- Generate editor themes for VSCode/VSCodium with Dynamic Base16 DankShell scheme
- Include troubleshooting guidance for common theming issues

## Dependencies

- Depends on: `add-dank-material-shell` (must be completed first)

## Impact

- Affected specs: shell-configuration (new theming capability)
- Affected code:
  - DankMaterialShell matugen integration (theme generation logic)
  - GTK 3/4 configuration files (~/.config/gtk-3.0/dank-colors.css, gtk-4.0/dank-colors.css)
  - Qt 5/6 configuration files (~/.config/qt5ct/colors/matugen.conf, qt6ct/colors/matugen.conf)
  - Firefox theme files (~/.config/DankMaterialShell/firefox.css, ~/.cache/wal/dank-pywalfox.json)
  - Terminal theme files (ghostty, kitty, foot, alacritty configs)
  - VSCode theme configuration (Dynamic Base16 DankShell)
- Introduces dependencies on matugen (already covered by enableDynamicTheming), adw-gtk-theme, qt6ct-kde (optional), pywalfox (optional), Material Fox (optional)
- Enables consistent Material Design theming across all desktop applications
- Provides advanced customization through user-defined matugen templates
- Does not affect server configurations
