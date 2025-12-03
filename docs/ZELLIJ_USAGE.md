# Zellij Terminal Multiplexer Guide

Zellij is configured as the default terminal multiplexer for pantherOS, providing a keyboard-driven workflow for managing terminal sessions.

## Quick Start

### Basic Commands

```bash
# Start a new session
zellij

# Start with a specific layout
zellij --layout development
zellij --layout compact

# List all sessions
zellij list-sessions
# or use alias:
zjl

# Attach to an existing session
zellij attach <session-name>
# or use alias:
zja <session-name>

# Kill a session
zellij kill-session <session-name>
# or use alias:
zjk <session-name>
```

### Shell Aliases

The following aliases are available in fish shell:

- `zj` - shorthand for `zellij`
- `zja` - attach to session
- `zjl` - list sessions
- `zjk` - kill session

## Keybindings

Zellij uses a modal system with Ctrl+g as the default prefix. After pressing Ctrl+g, you enter command mode.

### Essential Keybindings

- `Ctrl+g` - Enter command mode
- `Ctrl+g` + `p` - Pane mode (split, move, resize)
- `Ctrl+g` + `t` - Tab mode (new, rename, close)
- `Ctrl+g` + `n` - New pane
- `Ctrl+g` + `x` - Close pane
- `Ctrl+g` + `q` - Quit zellij
- `Ctrl+g` + `d` - Detach from session

### Pane Navigation

- `Ctrl+g` + `h/j/k/l` - Move between panes (vim-style)
- `Ctrl+g` + `Left/Down/Up/Right` - Move between panes (arrow keys)

### Pane Management

- `Ctrl+g` + `n` - New pane (splits horizontally)
- `Ctrl+g` + `d` - Split down (horizontal split)
- `Ctrl+g` + `r` - Split right (vertical split)
- `Ctrl+g` + `x` - Close focused pane
- `Ctrl+g` + `f` - Toggle pane fullscreen

### Tab Management

- `Ctrl+g` + `c` - Create new tab
- `Ctrl+g` + `1-9` - Switch to tab by number
- `Ctrl+g` + `[` / `]` - Switch to previous/next tab

## Layouts

Two layouts are pre-configured:

### Development Layout

Optimized for development work with three panes:
- Large editor pane (60% width)
- Command terminal (top right, 60% height)
- Monitoring/logs pane (bottom right)

Start with: `zellij --layout development`

### Compact Layout

Simple single-pane layout for general terminal work.

Start with: `zellij --layout compact` (default)

## Features

- **Session Persistence**: Sessions survive terminal closes and can be reattached
- **Mouse Support**: Click to switch panes and tabs
- **Scrollback**: Large scroll buffer (10,000 lines) for reviewing output
- **Fish Integration**: Configured to use fish shell by default
- **Ghostty Compatible**: Tested and optimized for use with Ghostty terminal

## Tips

1. **Detaching**: Use `Ctrl+g` + `d` to detach from a session without closing it
2. **Multiple Sessions**: Run multiple independent zellij sessions for different projects
3. **Layout Switching**: You can switch layouts within a running session
4. **Customization**: Layouts are stored in `~/.config/zellij/layouts/` and can be customized

## Troubleshooting

### Zellij not starting

Check that zellij is installed:
```bash
which zellij
zellij --version
```

### Configuration not loading

Verify configuration file exists:
```bash
ls ~/.config/zellij/
```

### Layout not found

List available layouts:
```bash
ls ~/.config/zellij/layouts/
```

## Integration with Existing Tools

Zellij works seamlessly with:
- **Fish shell**: Default shell configured
- **fzf**: Works for fuzzy finding
- **eza**: Directory listings display correctly
- **nvim**: Full terminal UI support
- **Ghostty**: Optimized for ghostty terminal emulator

## References

- [Official Zellij Documentation](https://zellij.dev/)
- [Zellij GitHub Repository](https://github.com/zellij-org/zellij)
