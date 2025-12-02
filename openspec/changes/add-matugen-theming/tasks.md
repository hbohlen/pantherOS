## 1. Core Matugen Integration

- [ ] 1.1 Implement automatic theme generation on wallpaper changes
- [ ] 1.2 Implement automatic theme generation on theme switches
- [ ] 1.3 Add DMS_DISABLE_MATUGEN environment variable support
- [ ] 1.4 Generate GTK 3/4 theme files (dank-colors.css)
- [ ] 1.5 Generate Qt 5/6 theme files (matugen.conf)
- [ ] 1.6 Implement dank16 color palette generation alongside matugen colors

## 2. Custom Template Support

- [ ] 2.1 Support custom matugen templates from ~/.config/matugen/config.toml
- [ ] 2.2 Execute custom templates alongside built-in DMS templates
- [ ] 2.3 Validate template paths are absolute (not relative)
- [ ] 2.4 Ensure templates are under [config] section
- [ ] 2.5 Provide dank16 palette variables (hex, hex_stripped, r, g, b) in templates
- [ ] 2.6 Provide standard matugen color keywords in templates

## 3. GTK Application Theming

- [ ] 3.1 Generate ~/.config/gtk-3.0/dank-colors.css
- [ ] 3.2 Generate ~/.config/gtk-4.0/dank-colors.css
- [ ] 3.3 Add "Apply GTK Themes" toggle in Settings
- [ ] 3.4 Manage symlinks from dank-colors.css to gtk.css when toggle enabled
- [ ] 3.5 Document adw-gtk-theme prerequisite for Arch and Fedora
- [ ] 3.6 Support manual integration via @import url("dank-colors.css")

## 4. Qt Application Theming

- [ ] 4.1 Generate ~/.config/qt5ct/colors/matugen.conf
- [ ] 4.2 Generate ~/.config/qt6ct/colors/matugen.conf
- [ ] 4.3 Add "Apply Qt Themes" toggle in Settings
- [ ] 4.4 Manage symlinks to qt5ct/qt6ct configurations when toggle enabled
- [ ] 4.5 Document GTK passthrough option (QT_QPA_PLATFORMTHEME=gtk3)
- [ ] 4.6 Document dedicated Qt control option with qt6ct
- [ ] 4.7 Support niri and Hyprland environment variable configuration

## 5. Firefox Integration

- [ ] 5.1 Generate ~/.config/DankMaterialShell/firefox.css for Material Fox
- [ ] 5.2 Generate ~/.cache/wal/dank-pywalfox.json for Pywalfox
- [ ] 5.3 Document Material Fox installation and configuration
- [ ] 5.4 Document Pywalfox installation and extension setup
- [ ] 5.5 Document about:config settings for Firefox custom styles
- [ ] 5.6 Support both Material Fox and Pywalfox theme options

## 6. Editor Theming

- [ ] 6.1 Generate Dynamic Base16 DankShell theme for VSCode/VSCodium/VSCode-oss
- [ ] 6.2 Mix dank16 and matugen colors for editor colorful theme
- [ ] 6.3 Ensure contrast in editor interface
- [ ] 6.4 Document VSCode theme selection process

## 7. Terminal Application Theming

- [ ] 7.1 Generate ghostty theme (config-dankcolors)
- [ ] 7.2 Generate kitty theme (dank-tabs.conf, dank-theme.conf)
- [ ] 7.3 Generate foot theme (dank-colors.ini with absolute paths)
- [ ] 7.4 Generate alacritty theme (dank-theme.toml)
- [ ] 7.5 Use dank16 algorithm with matugen for 16 ANSI colors
- [ ] 7.6 Honor theme aesthetic in terminal color palettes
- [ ] 7.7 Document configuration for each terminal emulator

## 8. Troubleshooting and Documentation

- [ ] 8.1 Document GTK apps troubleshooting (adw-gtk-theme, symlinks, toggle)
- [ ] 8.2 Document Qt apps troubleshooting (environment vars, compositor restart, qt6ct, toggle)
- [ ] 8.3 Document Firefox troubleshooting (about:config, profile directory, extensions)
- [ ] 8.4 Document terminal troubleshooting (config lines, theme files, restart)
- [ ] 8.5 Add template variable reference documentation
- [ ] 8.6 Document generated file locations
- [ ] 8.7 Clarify "Apply GTK/Qt Themes" toggle behavior vs file generation

## 9. Testing and Verification

- [ ] 9.1 Test automatic theme generation on wallpaper change
- [ ] 9.2 Test automatic theme generation on theme switch
- [ ] 9.3 Test DMS_DISABLE_MATUGEN environment variable
- [ ] 9.4 Test GTK 3/4 application theming
- [ ] 9.5 Test Qt 5/6 application theming with both passthrough and dedicated options
- [ ] 9.6 Test Firefox theming with Material Fox
- [ ] 9.7 Test Firefox theming with Pywalfox
- [ ] 9.8 Test VSCode Dynamic Base16 DankShell theme
- [ ] 9.9 Test terminal theming (ghostty, kitty, foot, alacritty)
- [ ] 9.10 Test custom matugen templates with dank16 variables
- [ ] 9.11 Verify all generated files are created with correct paths
- [ ] 9.12 Verify theme toggles control symlinks correctly
