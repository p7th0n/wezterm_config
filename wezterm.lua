-- wezterm-new.lua - Merged configuration
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- === Font & Appearance ===
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 18.0
config.color_scheme = "Campbell (Gogh)"
config.window_background_opacity = 0.95
config.initial_cols = 120
config.initial_rows = 28
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- === WSL Domain Detection ===
local has_pwsh = false
local has_powershell = false
local has_cmd = false

local wsl_domains = wezterm.default_wsl_domains()
local first_wsl_name = nil

for _, dom in ipairs(wsl_domains) do
	dom.default_cwd = "~"
end

if #wsl_domains > 0 then
	first_wsl_name = wsl_domains[1].name
	config.default_domain = first_wsl_name
end

local pwsh_path = nil
local powershell_path = nil

-- Try 64-bit PowerShell first for better SSH support
local pwsh_64_path = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
local powershell_64_path = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"

local ok, _ = wezterm.run_child_process({ pwsh_64_path, "-Version" })
if ok then
	pwsh_path = pwsh_64_path
	has_pwsh = true
else
	-- Fallback to where.exe for 32-bit or alternative installations
	ok, stdout = wezterm.run_child_process({ "where.exe", "pwsh.exe" })
	if ok and stdout then
		pwsh_path = stdout:match("([^\r\n]+)")
		has_pwsh = true
	end
end

ok, _ = wezterm.run_child_process({ powershell_64_path, "-Version" })
if ok then
	powershell_path = powershell_64_path
	has_powershell = true
else
	-- Fallback to where.exe
	ok, stdout = wezterm.run_child_process({ "where.exe", "powershell.exe" })
	if ok and stdout then
		powershell_path = stdout:match("([^\r\n]+)")
		has_powershell = true
	end
end

ok, _ = wezterm.run_child_process({ "where.exe", "cmd.exe" })
has_cmd = ok

if has_pwsh and pwsh_path then
	config.default_prog = { pwsh_path, "-NoLogo" }
elseif has_powershell and powershell_path then
	config.default_prog = { powershell_path, "-NoLogo" }
end

-- === Launch Menu ===
local launch_menu = {}

if has_pwsh and pwsh_path then
	table.insert(launch_menu, {
		label = "PowerShell (pwsh)",
		domain = { DomainName = "local" },
		args = { pwsh_path, "-NoLogo" },
	})
end

if has_powershell and powershell_path then
	table.insert(launch_menu, {
		label = "PowerShell (Windows)",
		domain = { DomainName = "local" },
		args = { powershell_path, "-NoLogo" },
	})
end

if has_cmd then
	table.insert(launch_menu, {
		label = "Command Prompt",
		domain = { DomainName = "local" },
		args = { "cmd.exe" },
	})
end

for _, dom in ipairs(wsl_domains) do
	table.insert(launch_menu, {
		label = "WSL: " .. dom.distribution,
		domain = { DomainName = dom.name },
	})
end

config.launch_menu = launch_menu

-- === Keybindings ===
local keys = {}

-- Pane splitting
table.insert(keys, { key = "d", mods = "CTRL", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { key = "d", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) })

-- Pane navigation (vim-style)
table.insert(keys, { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") })
table.insert(keys, { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") })
table.insert(keys, { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") })
table.insert(keys, { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") })

-- Pane resize
table.insert(keys, { key = "LeftArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Left", 5 }) })
table.insert(keys, { key = "RightArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Right", 5 }) })
table.insert(keys, { key = "UpArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Up", 5 }) })
table.insert(keys, { key = "DownArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Down", 5 }) })

-- New tab (current domain)
table.insert(keys, { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") })

-- New WSL tab
if first_wsl_name then
	table.insert(keys, {
		key = "w",
		mods = "CTRL|ALT",
		action = act.SpawnTab({ DomainName = first_wsl_name }),
	})
else
	table.insert(keys, {
		key = "w",
		mods = "CTRL|ALT",
		action = act.SpawnCommandInNewTab({ args = { "wsl.exe" } }),
	})
end

-- New PowerShell tab
if has_pwsh and pwsh_path then
	table.insert(keys, {
		key = "p",
		mods = "CTRL|ALT",
		action = act.SpawnCommandInNewTab({
			domain = { DomainName = "local" },
			args = { pwsh_path, "-NoLogo" },
		}),
	})
elseif has_powershell and powershell_path then
	table.insert(keys, {
		key = "q",
		mods = "CTRL|ALT",
		action = act.SpawnCommandInNewTab({
			domain = { DomainName = "local" },
			args = { powershell_path, "-NoLogo" },
		}),
	})
end

-- New cmd tab
if has_cmd then
	table.insert(keys, {
		key = "e",
		mods = "CTRL|ALT",
		action = act.SpawnCommandInNewTab({
			domain = { DomainName = "local" },
			args = { "cmd.exe" },
		}),
	})
end

-- Tab switching
for i = 1, 9 do
	table.insert(keys, {
		key = tostring(i),
		mods = "ALT|CTRL",
		action = act.ActivateTab(i - 1),
	})
end

table.insert(keys, { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) })
table.insert(keys, { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) })

-- Close tab (Ctrl+W) / Close pane (Ctrl+Shift+W)
table.insert(keys, { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) })
table.insert(keys, { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = true }) })

-- Utilities
table.insert(keys, { key = "v", mods = "CTRL|SHIFT", action = act.ActivateCopyMode })
table.insert(keys, { key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") })
table.insert(keys, { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") })
table.insert(keys, { key = "n", mods = "CTRL|SHIFT", action = act.ToggleFullScreen })
table.insert(keys, { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration })

config.keys = keys

-- === ssh
config.ssh_backend = "Ssh2"

return config
