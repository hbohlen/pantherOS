## ADDED Requirements

### Requirement: Matugen Automatic Theme Generation

The system SHALL automatically generate theme files for native applications when matugen is enabled in DankMaterialShell.

#### Scenario: Theme Generation Triggers

- **WHEN** wallpaper is changed or theme is switched
- **THEN** matugen generates theme files for all configured applications
- **AND** theme files are created in their respective configuration directories
- **AND** generation occurs regardless of "Apply GTK/Qt Themes" toggle state

#### Scenario: Disable Theme Generation

- **WHEN** DMS_DISABLE_MATUGEN environment variable is set to 1
- **THEN** automatic theme generation is completely disabled
- **AND** existing theme files are not modified or removed

#### Scenario: Generated File Locations

- **WHEN** matugen theme generation runs
- **THEN** GTK 3 theme is created at ~/.config/gtk-3.0/dank-colors.css
- **AND** GTK 4 theme is created at ~/.config/gtk-4.0/dank-colors.css
- **AND** Qt 5 theme is created at ~/.config/qt5ct/colors/matugen.conf
- **AND** Qt 6 theme is created at ~/.config/qt6ct/colors/matugen.conf

### Requirement: Custom Matugen Templates

The system SHALL support custom matugen templates for theming additional applications beyond built-in support.

#### Scenario: Custom Template Configuration

- **WHEN** user creates ~/.config/matugen/config.toml
- **THEN** custom templates are defined under [config] section
- **AND** each template has input_path and output_path with absolute paths
- **AND** templates execute alongside DMS built-in templates

#### Scenario: Template Path Validation

- **WHEN** custom templates are configured
- **THEN** input_path must be absolute (e.g., /home/username/...)
- **AND** output_path must be absolute (e.g., /home/username/...)
- **AND** relative paths like ./templates/ are not supported

#### Scenario: Template Variable Access

- **WHEN** custom templates are executed
- **THEN** all standard matugen color keywords are available
- **AND** dank16 palette colors (color0-color15) are available
- **AND** each dank16 color provides hex, hex_stripped, r, g, and b values
- **AND** templates use handlebars syntax (e.g., {{colors.primary.default.hex}}, {{dank16.color0.hex}})

### Requirement: GTK Application Theming

The system SHALL provide dynamic theming for GTK 3 and GTK 4 applications through generated CSS files and symlink management.

#### Scenario: GTK Theme File Generation

- **WHEN** matugen runs
- **THEN** dank-colors.css is generated for GTK 3 in ~/.config/gtk-3.0/
- **AND** dank-colors.css is generated for GTK 4 in ~/.config/gtk-4.0/
- **AND** files contain Material Design color definitions from current theme

#### Scenario: GTK Theme Toggle

- **WHEN** "Apply GTK Themes" toggle is enabled in Settings
- **THEN** symlinks are created from dank-colors.css to gtk.css
- **AND** GTK 3 applications use ~/.config/gtk-3.0/gtk.css symlink
- **AND** GTK 4 applications use ~/.config/gtk-4.0/gtk.css symlink

#### Scenario: GTK Prerequisites

- **WHEN** enabling GTK theming
- **THEN** adw-gtk-theme must be installed on the system
- **AND** installation instructions are provided for Arch (pacman -S adw-gtk-theme)
- **AND** installation instructions are provided for Fedora (dnf install adw-gtk3-theme)

#### Scenario: Manual GTK Integration

- **WHEN** user manages their own GTK theme
- **THEN** dank-colors.css can be imported with @import url("dank-colors.css")
- **AND** import is added to ~/.config/gtk-3.0/gtk.css or gtk-4.0/gtk.css
- **AND** DMS colors are available without full theme replacement

### Requirement: Qt Application Theming

The system SHALL provide dynamic theming for Qt 5 and Qt 6 applications through generated configuration files and environment variable setup.

#### Scenario: Qt Theme File Generation

- **WHEN** matugen runs
- **THEN** matugen.conf is generated for Qt 5 in ~/.config/qt5ct/colors/
- **AND** matugen.conf is generated for Qt 6 in ~/.config/qt6ct/colors/
- **AND** files contain Material Design color definitions from current theme

#### Scenario: Qt Theme Toggle

- **WHEN** "Apply Qt Themes" toggle is enabled in Settings
- **THEN** symlinks are created to qt5ct/qt6ct configurations
- **AND** Qt 5 applications use linked matugen color scheme
- **AND** Qt 6 applications use linked matugen color scheme

#### Scenario: Qt GTK Passthrough

- **WHEN** using simple Qt theming approach
- **THEN** QT_QPA_PLATFORMTHEME environment variable is set to "gtk3"
- **AND** QT_QPA_PLATFORMTHEME_QT6 environment variable is set to "gtk3"
- **AND** Qt applications use GTK theme for passthrough styling
- **AND** environment variables are configured in niri or Hyprland compositor config

#### Scenario: Qt Dedicated Control

- **WHEN** using advanced Qt theming approach
- **THEN** qt6ct-kde package is installed
- **AND** QT_QPA_PLATFORMTHEME environment variable is set to "qt6ct"
- **AND** QT_QPA_PLATFORMTHEME_QT6 environment variable is set to "qt6ct"
- **AND** compositor session is restarted for environment changes to take effect
- **AND** "Apply Qt Themes" toggle is enabled in Settings

### Requirement: Firefox Browser Theming

The system SHALL provide dynamic theming for Firefox through Material Fox theme or Pywalfox extension integration.

#### Scenario: Firefox Material Fox Integration

- **WHEN** using Material Fox theme option
- **THEN** ~/.config/DankMaterialShell/firefox.css is generated with dynamic colors
- **AND** about:config settings are documented (toolkit.legacyuserprofilecustomizations.stylesheets, svg.context-properties.content.enabled, userChrome.theme-material)
- **AND** Material Fox theme download and installation instructions are provided
- **AND** symlink from firefox.css to chrome/theme-material-blue.css is documented
- **AND** Firefox profile directory is detected with find ~/.mozilla/firefox command

#### Scenario: Firefox Pywalfox Integration

- **WHEN** using Pywalfox extension option
- **THEN** ~/.cache/wal/dank-pywalfox.json is generated
- **AND** Pywalfox installation instructions are provided for Arch (paru -S python-pywalfox)
- **AND** browser extension installation from Firefox Add-ons is documented
- **AND** symlink from dank-pywalfox.json to colors.json is required
- **AND** DMS restart is needed to generate palette

#### Scenario: Firefox Troubleshooting

- **WHEN** Firefox theme is not working
- **THEN** troubleshooting checks about:config settings
- **AND** troubleshooting verifies theme files exist in profile directory
- **AND** troubleshooting suggests disabling conflicting theme extensions
- **AND** troubleshooting recommends Firefox restart after changes

### Requirement: Code Editor Theming

The system SHALL provide dynamic theming for code editors with Material Design colors and dank16 palette integration.

#### Scenario: VSCode Theme Generation

- **WHEN** matugen runs
- **THEN** Dynamic Base16 DankShell theme is generated for VSCode/VSCodium/VSCode-oss
- **AND** theme uses mix of dank16 and matugen colors
- **AND** theme provides colorful appearance with proper contrast
- **AND** theme honors current Material Design theme aesthetic

#### Scenario: VSCode Theme Selection

- **WHEN** applying editor theme
- **THEN** user opens command palette with ctrl+shift+p
- **AND** user selects Preferences: Color Scheme
- **AND** user picks Dynamic Base16 DankShell from available themes

### Requirement: Terminal Application Theming

The system SHALL provide dynamic theming for terminal applications using dank16 color algorithm with matugen integration.

#### Scenario: Ghostty Terminal Theming

- **WHEN** theming ghostty terminal
- **THEN** config-dankcolors file is generated
- **AND** user adds "config-file = ./config-dankcolors" to ~/.config/ghostty/config
- **AND** optional app-notifications setting can disable excessive notifications

#### Scenario: Kitty Terminal Theming

- **WHEN** theming kitty terminal
- **THEN** dank-tabs.conf is generated for tab styling
- **AND** dank-theme.conf is generated for color scheme
- **AND** user adds "include dank-tabs.conf" to ~/.config/kitty/kitty.conf
- **AND** user adds "include dank-theme.conf" to ~/.config/kitty/kitty.conf

#### Scenario: Foot Terminal Theming

- **WHEN** theming foot terminal
- **THEN** dank-colors.ini is generated with absolute paths
- **AND** user edits ~/.config/foot/foot.ini to add include in [main] section
- **AND** include path is absolute: include=/home/<USERNAME>/.config/foot/dank-colors.ini

#### Scenario: Alacritty Terminal Theming

- **WHEN** theming alacritty terminal
- **THEN** dank-theme.toml is generated
- **AND** user adds import to [general] section in ~/.config/alacritty/alacritty.toml
- **AND** import path is: ~/.config/alacritty/dank-theme.toml

#### Scenario: Terminal Color Palette

- **WHEN** generating terminal themes
- **THEN** dank16 algorithm generates 16 ANSI colors (color0-color15)
- **AND** colors honor Material Design theme aesthetic
- **AND** colors provide proper contrast for readability
- **AND** colors integrate with matugen color generation

#### Scenario: Terminal Theme Updates

- **WHEN** wallpaper or theme changes
- **THEN** terminal theme files are automatically regenerated
- **AND** terminal applications must be reloaded or restarted
- **AND** changes are immediately visible in new terminal instances

### Requirement: Theme Toggle Behavior

The system SHALL clearly separate theme file generation from application theme activation through toggle controls.

#### Scenario: File Generation Independence

- **WHEN** matugen is enabled
- **THEN** all theme files are always generated on wallpaper/theme changes
- **AND** generation occurs regardless of "Apply GTK/Qt Themes" toggle state
- **AND** files remain available for manual integration

#### Scenario: GTK Theme Toggle Behavior

- **WHEN** "Apply GTK Themes" toggle is enabled
- **THEN** DankMaterialShell manages symlinks from dank-colors.css to gtk.css
- **AND** GTK applications automatically use DMS theme
- **WHEN** toggle is disabled
- **THEN** symlinks are removed or not created
- **AND** dank-colors.css files remain available for manual use

#### Scenario: Qt Theme Toggle Behavior

- **WHEN** "Apply Qt Themes" toggle is enabled
- **THEN** DankMaterialShell manages symlinks to qt5ct/qt6ct configurations
- **AND** Qt applications automatically use DMS theme
- **WHEN** toggle is disabled
- **THEN** symlinks are removed or not created
- **AND** matugen.conf files remain available for manual use

### Requirement: Theming Troubleshooting Support

The system SHALL provide comprehensive troubleshooting guidance for common theming issues.

#### Scenario: GTK Troubleshooting Steps

- **WHEN** GTK applications are not themed
- **THEN** verify adw-gtk-theme is installed
- **AND** check symlinks exist with ls -la ~/.config/gtk-3.0/gtk.css
- **AND** ensure "Apply GTK Themes" toggle is enabled in Settings
- **AND** restart GTK applications after configuration changes

#### Scenario: Qt Troubleshooting Steps

- **WHEN** Qt applications are not themed
- **THEN** verify environment variables are set in compositor config
- **AND** restart compositor session after changing environment
- **AND** check qt6ct is installed if using dedicated Qt control
- **AND** ensure "Apply Qt Themes" toggle is enabled in Settings

#### Scenario: Terminal Troubleshooting Steps

- **WHEN** terminal colors are not updating
- **THEN** verify config lines are added to terminal config file
- **AND** check theme files exist in ~/.config/DankMaterialShell/
- **AND** restart terminal application to apply changes
- **AND** verify terminal config uses correct file paths
