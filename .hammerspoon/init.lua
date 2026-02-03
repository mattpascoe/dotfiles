-- Ignore undefined global warnings for Hammerspoon
---@diagnostic disable: undefined-global

-- Modifier key combo
MEH = { "shift", "ctrl", "alt" }

-- These install the `hs` cli interface. I was using it for notification popups
-- hs.ipc.cliInstall("/opt/homebrew/bin")
-- require("hs.ipc")

-- Define app hotkeys in a table
-- This will add a binding for MEH + key
local appHotkeys = {
	a = "Spotify",
	b = "Brave Browser",
	c = "Calculator",
	d = "Beekeeper Studio",
	f = "Finder",
	g = "Ghostty",
	m = "Messages",
	p = "1Password",
	s = "Slack",
	t = "Telegram",
	z = "Zoom.us",
}

-- Bind each app hotkey dynamically
for key, appName in pairs(appHotkeys) do
	hs.hotkey.bind(MEH, key, function()
		hs.application.launchOrFocus(appName)
	end)
end

-- Load local config if present
if hs.fs.attributes(hs.configdir .. "/local-config.lua") then
	require("local-config")
end

-- Window management hotkeys
hs.hotkey.bind({ "cmd" }, "h", function()
	local win = hs.window.focusedWindow()
	if win then
		local screen = win:screen()
		local frame = screen:frame()
		win:setFrame({ x = frame.x, y = frame.y, w = frame.w / 2, h = frame.h })
	end
end)

hs.hotkey.bind({ "cmd" }, "l", function()
	local win = hs.window.focusedWindow()
	if win then
		local screen = win:screen()
		local frame = screen:frame()
		win:setFrame({ x = frame.w / 2, y = frame.y, w = frame.w / 2, h = frame.h })
	end
end)

hs.hotkey.bind({ "cmd" }, "k", function()
	local win = hs.window.focusedWindow()
	if win then
		win:maximize()
	end
end)

-- Show dynamic hotkey reference
hs.hotkey.bind(MEH, "/", function()
	local helpText = [[
WINDOW MANAGEMENT:
⌘ + h   → Move window to left half
⌘ + l   → Move window to right half
⌘ + k   → Maximize window

APP LAUNCHERS:
]]

	for key, appName in pairs(appHotkeys) do
		helpText = helpText .. string.format("MEH + %s   → Launch %s\n", key:upper(), appName)
	end

	helpText = helpText .. "\nMEH + /   → Show this hotkey reference\n\nMEH = { shift, ctrl, alt }"

	hs.dialog.blockAlert("Hammerspoon Hotkey Reference", helpText, "Close")
end)
