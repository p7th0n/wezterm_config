# WezTerm Configuration

Personal WezTerm terminal emulator configuration for Windows + WSL environments.

> Original source: [pasanec/wezterm_win](https://github.com/pasanec/wezterm_win)

## Features

- **WSL Integration** — Auto-detects WSL distributions and sets WSL as the default domain
- **Shell Detection** — Dynamically detects available Windows shells (PowerShell 7, Windows PowerShell, CMD)
- **Vim-style Pane Navigation** — Ctrl+Shift + H/J/K/L for pane focus
- **Pane Splitting & Resizing** — Ctrl/Ctrl+Alt based shortcuts
- **Launch Menu** — Context-aware menu with available shells and WSL distros

## Appearance

| Setting | Value |
|---|---|
| Font | Hack Nerd Font |
| Font Size | 18.0 |
| Color Scheme | Campbell (Gogh) |
| Window Opacity | 95% |
| Default Size | 120 cols × 28 rows |

## Shell Detection

The config detects these shells at startup and conditionally enables features:

| Shell | Executable | Used For |
|---|---|---|
| PowerShell 7 | `pwsh.exe` | Default program, launch menu, Ctrl+Alt+Q |
| Windows PowerShell | `powershell.exe` | Fallback default, launch menu, Ctrl+Alt+Q |
| Command Prompt | `cmd.exe` | Launch menu, Ctrl+Alt+E |

> **Bug note:** Claude (Anthropic) detected a bug where shell detection used `"where"` instead of `"where.exe"` in `wezterm.run_child_process` calls. On Windows, `"where"` (without `.exe` extension) was not found by the process launcher, causing all three `has_*` flags to stay `false`. This silently disabled all shell-specific key bindings (Ctrl+Alt+Q, Ctrl+Alt+E) and the launch menu entries. Fixed by using `"where.exe"` explicitly.

## Keybindings

### Panes

| Shortcut | Action |
|---|---|
| `Ctrl+D` | Split pane horizontally |
| `Ctrl+Shift+D` | Split pane vertically |
| `Ctrl+Shift+H` | Focus left pane |
| `Ctrl+Shift+J` | Focus down pane |
| `Ctrl+Shift+K` | Focus up pane |
| `Ctrl+Shift+L` | Focus right pane |
| `Ctrl+Alt+←/→/↑/↓` | Resize pane (5 cells) |
| `Ctrl+Shift+W` | Close current pane (with confirmation) |

### Tabs

| Shortcut | Action |
|---|---|
| `Ctrl+T` | New tab (current domain) |
| `Ctrl+Alt+W` | New WSL tab |
| `Ctrl+Alt+Q` | New PowerShell tab |
| `Ctrl+Alt+E` | New Command Prompt tab |
| `Ctrl+Alt+1-9` | Switch to tab 1-9 |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Ctrl+W` | Close current tab (with confirmation) |

### Utilities

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+V` | Enter copy mode |
| `Ctrl+Shift+N` | Toggle fullscreen |
| `Ctrl+Shift+R` | Reload configuration |

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/)
- [Hack Nerd Font](https://www.nerdfonts.com/font-downloads) installed on the system
- Windows with WSL enabled (optional but recommended)

