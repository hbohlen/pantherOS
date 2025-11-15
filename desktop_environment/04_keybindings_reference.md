# Dank Linux Keybindings Reference

**Last Updated:** 2025-11-15 10:16:10  
**Author:** MiniMax Agent  
**Purpose:** Complete reference for DMS keybindings and customization

## Default Keybindings

### Window Management
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + Return` | Launch Terminal | Open default terminal |
| `Super + Q` | Close Window | Close active window |
| `Super + Shift + Q` | Quit DMS | Log out/shutdown menu |
| `Alt + F4` | Close Window | Alternative close window |
| `Super + D` | Show Desktop | Minimize all windows |
| `Alt + Tab` | Cycle Windows | Switch between windows |
| `Alt + Shift + Tab` | Cycle Windows (Reverse) | Switch windows reverse |
| `Super + Tab` | Application Switcher | Switch between applications |

### Workspace Management  
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + 1-9` | Switch Workspace | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move Window to Workspace | Move active window to workspace |
| `Super + Ctrl + Left/Right` | Switch Workspace (Cyclic) | Navigate workspaces cyclically |
| `Super + Mouse Wheel` | Workspace Scroll | Scroll through workspaces |

### Layout and Navigation
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + F` | Toggle Fullscreen | Make window fullscreen |
| `Super + Space` | Toggle Floating | Make window floating |
| `Super + H` | Split Horizontal | Split layout horizontally |
| `Super + V` | Split Vertical | Split layout vertically |
| `Super + W` | Tabbed Layout | Change to tabbed layout |
| `Super + E` | Tiling Layout | Change to tiling layout |
| `Super + S` | Stacking Layout | Change to stacking layout |
| `Ctrl + Super + Space` | Toggle Layout | Cycle through layouts |

### Resizing and Moving
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + Right Click` | Resize Window | Resize floating window |
| `Super + Left Click` | Move Window | Move floating window |
| `Super + Middle Click` | Toggle Floating | Toggle window floating |
| `Alt + Right Click` | Resize Window | Alternative resize |
| `Alt + Left Click` | Move Window | Alternative move |

### Launchers and Search
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + Space` | Application Launcher | Open application launcher |
| `Super + F` | File Search | Open danksearch |
| `Super + Shift + F` | Web Search | Open web browser search |
| `Super + P` | Power Menu | Show power/session menu |
| `Super + Shift + P` | System Menu | Show system control center |

### System Controls
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + L` | Lock Screen | Lock the screen |
| `Super + Delete` | Log Out | Show logout options |
| `Print Screen` | Screenshot | Take screenshot |
| `Super + Print Screen` | Screenshot (Selection) | Select area screenshot |
| `Shift + Print Screen` | Screenshot (Window) | Screenshot active window |

### Media Controls
| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86AudioPlay` | Play/Pause | Media play/pause |
| `XF86AudioNext` | Next Track | Next media track |
| `XF86AudioPrev` | Previous Track | Previous media track |
| `XF86AudioMute` | Toggle Mute | Mute/unmute audio |
| `XF86AudioLowerVolume` | Volume Down | Decrease volume |
| `XF86AudioRaiseVolume` | Volume Up | Increase volume |

### Brightness and Power
| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86MonBrightnessUp` | Brightness Up | Increase screen brightness |
| `XF86MonBrightnessDown` | Brightness Down | Decrease screen brightness |
| `XF86KbdBrightnessUp` | Keyboard Brightness Up | Increase keyboard backlight |
| `XF86KbdBrightnessDown` | Keyboard Brightness Down | Decrease keyboard backlight |

## Custom Keybindings

### Configuration Structure
Keybindings are configured in `~/.config/dms/config.json`:

```json
{
  "keybindings": {
    "default": {
      "super+space": "launcher",
      "super+return": "terminal",
      "super+q": "close_window",
      "alt+tab": "cycle_windows"
    },
    "custom": [
      {
        "command": "firefox",
        "key": "super+shift+f",
        "description": "Launch Firefox"
      },
      {
        "command": "danksearch --interactive",
        "key": "super+f",
        "description": "File search"
      }
    ]
  }
}
```

### Adding Custom Keybindings

#### Method 1: Edit Configuration File
```bash
# Edit DMS configuration
nano ~/.config/dms/config.json

# Add custom keybindings to the "custom" array
```

#### Method 2: Command Line
```bash
# Add keybinding using dms command
dms keybinding add "super+shift+t" "dgop tui"

# Remove keybinding
dms keybinding remove "super+shift+t"

# List keybindings
dms keybinding list
```

### Advanced Customization

#### Multi-Command Keybindings
```json
{
  "custom_keybindings": [
    {
      "command": ["polybar-msg cmd hide", "dms workspace down"],
      "key": "super+minus",
      "description": "Hide bars and go to previous workspace"
    }
  ]
}
```

#### Conditional Keybindings
```json
{
  "conditional_keybindings": [
    {
      "key": "super+shift+w",
      "condition": "workspace_focused",
      "command": "danksearch --web",
      "description": "Web search when workspace focused"
    }
  ]
}
```

## Application-Specific Keybindings

### Terminal Keybindings
```json
{
  "terminal_keybindings": {
    "ctrl+shift+t": "new_tab",
    "ctrl+shift+n": "new_window", 
    "ctrl+shift+q": "close_tab",
    "ctrl+shift+return": "split_horizontal",
    "ctrl+shift+minus": "split_vertical"
  }
}
```

### Browser Keybindings
```json
{
  "browser_keybindings": {
    "ctrl+t": "new_tab",
    "ctrl+w": "close_tab",
    "ctrl+r": "reload",
    "ctrl+f": "find",
    "ctrl+shift+t": "restore_tab",
    "alt+left": "back",
    "alt+right": "forward"
  }
}
```

### Text Editor Keybindings
```json
{
  "editor_keybindings": {
    "ctrl+s": "save",
    "ctrl+z": "undo",
    "ctrl+y": "redo",
    "ctrl+f": "find",
    "ctrl+h": "replace",
    "ctrl+/": "toggle_comment"
  }
}
```

## Global Application Shortcuts

### System Commands
```json
{
  "system_commands": {
    "super+l": "lock_screen",
    "super+delete": "power_menu",
    "ctrl+alt+l": "lock_screen",
    "ctrl+alt+delete": "system_menu",
    "print": "screenshot_full",
    "shift+print": "screenshot_selection",
    "ctrl+print": "screenshot_clipboard"
  }
}
```

### File Management
```json
{
  "file_commands": {
    "super+e": "file_manager",
    "super+shift+e": "home_folder",
    "ctrl+h": "toggle_hidden_files",
    "f2": "rename_file",
    "f5": "refresh_view"
  }
}
```

### Development Tools
```json
{
  "development_commands": {
    "super+shift+c": "code_editor",
    "super+shift+t": "terminal",
    "super+shift+g": "git_client",
    "super+shift+b": "web_browser"
  }
}
```

## Special Key Combinations

### Function Keys
| Keybinding | Default Action | Customizable |
|------------|----------------|--------------|
| `F1` | Help/Documentation | ✅ |
| `F2` | Rename | ✅ |
| `F3` | Search in File | ✅ |
| `F4` | Close | ✅ |
| `F5` | Refresh/Reload | ✅ |
| `F6` | Address Bar | ✅ |
| `F7` | Spell Check | ✅ |
| `F8` | Fullscreen Toggle | ✅ |
| `F9` | Menu Bar Toggle | ✅ |
| `F10` | Fullscreen Menu | ✅ |
| `F11` | Fullscreen | ✅ |
| `F12` | Developer Tools | ✅ |

### Navigation Keys
```json
{
  "navigation_keys": {
    "home": "beginning_of_line",
    "end": "end_of_line", 
    "page_up": "page_up",
    "page_down": "page_down",
    "insert": "toggle_insert",
    "delete": "delete_character_forward",
    "backspace": "delete_character_backward"
  }
}
```

### Modifier Key Combinations
| Modifier | Description | Example |
|----------|-------------|---------|
| `Super` | Windows/Command key | `super+space` |
| `Alt` | Alternate/Meta key | `alt+tab` |
| `Ctrl` | Control key | `ctrl+c` |
| `Shift` | Shift key | `shift+delete` |
| `Ctrl+Alt` | Control+Alternate | `ctrl+alt+delete` |
| `Ctrl+Shift` | Control+Shift | `ctrl+shift+t` |
| `Super+Ctrl` | Windows+Control | `ctrl+super+space` |

## Accessibility Keybindings

### Screen Reader Support
```json
{
  "accessibility": {
    "screen_reader": {
      "super+alt+z": "toggle_screen_reader",
      "super+alt+h": "read_current_line",
      "super+alt+j": "read_next_line",
      "super+alt+k": "read_previous_line"
    }
  }
}
```

### High Contrast Mode
```json
{
  "accessibility": {
    "high_contrast": {
      "super+alt+c": "toggle_high_contrast",
      "super+alt+b": "toggle_bold_text"
    }
  }
}
```

### Magnifier Controls
```json
{
  "accessibility": {
    "magnifier": {
      "super+alt+="": "zoom_in",
      "super+alt+-": "zoom_out",
      "super+alt+0": "zoom_reset",
      "super+alt+m": "toggle_magnifier"
    }
  }
}
```

## Keybinding Conflicts and Resolution

### Common Conflicts
1. **Browser shortcuts** conflicting with system shortcuts
2. **IDE shortcuts** overlapping with window management
3. **Terminal shortcuts** conflicting with global commands

### Resolution Strategies
```json
{
  "conflict_resolution": {
    "priority": "application",  // application, system, global
    "scope": "workspace",       // workspace, global, application_specific
    "fallback": "prompt"        // prompt, system_default, ignore
  }
}
```

### Conflict Detection
```bash
# Detect keybinding conflicts
dms keybinding check-conflicts

# Show conflicting keybindings
dms keybinding list-conflicts

# Auto-resolve conflicts
dms keybinding auto-resolve
```

## Keybinding Testing and Validation

### Testing Commands
```bash
# Test keybinding
dms keybinding test "super+space"

# Show keybinding binding
dms keybinding show "super+f"

# Validate configuration
dms keybinding validate
```

### Debug Mode
```bash
# Enable keybinding debug logging
DMS_DEBUG=keybindings dms

# Test keypresses
dms keybinding debug --watch

# Monitor keypresses
dms keybinding monitor
```

## Backup and Restore

### Export Keybindings
```bash
# Backup current keybindings
dms keybinding export > ~/.dms-keybindings-backup.json

# Export specific workspace
dms keybinding export --workspace 1 > workspace-1-keys.json
```

### Import Keybindings
```bash
# Restore from backup
dms keybinding import < ~/.dms-keybindings-backup.json

# Import specific workspace
dms keybinding import --workspace 2 < workspace-2-keys.json
```

### Reset to Defaults
```bash
# Reset all keybindings
dms keybinding reset

# Reset specific action
dms keybinding reset "close_window"
```

## Tips and Best Practices

### Efficiency Tips
1. **Use Super key combinations** for most actions to avoid conflicts
2. **Group related functions** under similar key combinations
3. **Keep muscle memory** by maintaining consistent patterns
4. **Test new keybindings** thoroughly before adopting them

### Customization Guidelines
1. **Avoid conflicts** with common application shortcuts
2. **Document changes** for future reference
3. **Backup before major changes**
4. **Use descriptive keybinding names**

### Performance Considerations
```json
{
  "performance": {
    "keybinding_delay": 50,        // milliseconds
    "key_repeat_rate": 30,         // keys per second
    "debounce_time": 100           // milliseconds
  }
}
```

---

**Related Documents:**
- [Dank Linux Master Guide](./00_dank_linux_master_guide.md)
- [Advanced Configuration](./advanced_configuration.md)