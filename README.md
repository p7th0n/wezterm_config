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

| Setting        | Value              |
| -------------- | ------------------ |
| Font           | Hack Nerd Font     |
| Font Size      | 18.0               |
| Color Scheme   | Campbell (Gogh)    |
| Window Opacity | 95%                |
| Default Size   | 120 cols × 28 rows |

## Shell Detection

The config detects these shells at startup and conditionally enables features:

| Shell              | Executable       | Used For                                  |
| ------------------ | ---------------- | ----------------------------------------- |
| PowerShell 7       | `pwsh.exe`       | Default program, launch menu, Ctrl+Alt+Q  |
| Windows PowerShell | `powershell.exe` | Fallback default, launch menu, Ctrl+Alt+Q |
| Command Prompt     | `cmd.exe`        | Launch menu, Ctrl+Alt+E                   |

> **Bug notes:**
>
> - Claude (Anthropic) detected a bug where shell detection used `"where"` instead of `"where.exe"` in `wezterm.run_child_process` calls. On Windows, `"where"` (without `.exe` extension) was not found by the process launcher, causing all three `has_*` flags to stay `false`. This silently disabled all shell-specific key bindings (Ctrl+Alt+Q, Ctrl+Alt+E) and the launch menu entries. Fixed by using `"where.exe"` explicitly.
> - **SSH Fix:** Claude fixed an issue where WezTerm's 32-bit process would find 32-bit PowerShell via `where.exe`, breaking SSH functionality. Updated shell detection to prioritize 64-bit PowerShell installations at standard paths (`C:\Program Files\PowerShell\7\pwsh.exe`, `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`) with fallback to `where.exe` discovery for portability.
> - **SSH Agent Fix (Windows 11):** WezTerm's mux overwrites the `SSH_AUTH_SOCK` environment variable in spawned shells, pointing it to an internal path (`~/.local/share/wezterm/`) instead of the Windows OpenSSH agent's named pipe. This caused `ssh` commands inside WezTerm to prompt for a passphrase even when the OpenSSH Authentication Agent service was running and keys were loaded via `ssh-add`.
>
>   [wezterm/wezterm Discussion #3772](https://github.com/wezterm/wezterm/discussions/3772) covers a related but distinct problem: `wezterm ssh` (WezTerm's built-in SSH client) not picking up the agent. Its top suggestion — `config.ssh_backend = "Ssh2"` — was tried first but did **not** fix the `SSH_AUTH_SOCK` clobbering issue for regular `ssh` invocations in a spawned shell on Windows 11.
>
>   The fix that worked was to disable the mux SSH agent entirely and point the auth sock to the Windows OpenSSH named pipe:
>   ```lua
>   config.mux_enable_ssh_agent = false
>   config.default_ssh_auth_sock = [[\.\pipe\openssh-ssh-agent]]
>   ```
>   Note: requires a **full WezTerm restart** (not just `Ctrl+Shift+R` config reload) to take effect.

## Keybindings

### Panes

| Shortcut           | Action                                 |
| ------------------ | -------------------------------------- |
| `Ctrl+D`           | Split pane horizontally                |
| `Ctrl+Shift+D`     | Split pane vertically                  |
| `Ctrl+Shift+H`     | Focus left pane                        |
| `Ctrl+Shift+J`     | Focus down pane                        |
| `Ctrl+Shift+K`     | Focus up pane                          |
| `Ctrl+Shift+L`     | Focus right pane                       |
| `Ctrl+Alt+←/→/↑/↓` | Resize pane (5 cells)                  |
| `Ctrl+Shift+W`     | Close current pane (with confirmation) |

### Tabs

| Shortcut         | Action                                |
| ---------------- | ------------------------------------- |
| `Ctrl+T`         | New tab (current domain)              |
| `Ctrl+Alt+W`     | New WSL tab                           |
| `Ctrl+Alt+Q`     | New PowerShell tab                    |
| `Ctrl+Alt+E`     | New Command Prompt tab                |
| `Ctrl+Alt+1-9`   | Switch to tab 1-9                     |
| `Ctrl+Tab`       | Next tab                              |
| `Ctrl+Shift+Tab` | Previous tab                          |
| `Ctrl+W`         | Close current tab (with confirmation) |

### Utilities

| Shortcut       | Action               |
| -------------- | -------------------- |
| `Ctrl+Shift+V` | Enter copy mode      |
| `Ctrl+Shift+N` | Toggle fullscreen    |
| `Ctrl+Shift+R` | Reload configuration |

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/)
- [Hack Nerd Font](https://www.nerdfonts.com/font-downloads) installed on the system
- Windows with WSL enabled (optional but recommended)
