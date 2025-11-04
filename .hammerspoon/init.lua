MEH = { "shift", "ctrl", "alt" }

-- Bind Cmd + Alt + B to launch or focus Brave Browser
hs.hotkey.bind(MEH, "a", function()
	hs.application.launchOrFocus("Spotify")
end)
hs.hotkey.bind(MEH, "b", function()
	hs.application.launchOrFocus("Brave Browser")
end)
hs.hotkey.bind(MEH, "c", function()
	hs.application.launchOrFocus("Calculator")
end)
hs.hotkey.bind(MEH, "f", function()
	hs.application.launchOrFocus("Finder")
end)
hs.hotkey.bind(MEH, "g", function()
	hs.application.launchOrFocus("Ghostty")
end)
hs.hotkey.bind(MEH, "d", function()
	hs.application.launchOrFocus("Beekeeper Studio")
end)
hs.hotkey.bind(MEH, "m", function()
	hs.application.launchOrFocus("Messages")
end)
hs.hotkey.bind(MEH, "s", function()
	hs.application.launchOrFocus("Slack")
end)
hs.hotkey.bind(MEH, "t", function()
	hs.application.launchOrFocus("Telegram")
end)
hs.hotkey.bind(MEH, "p", function()
	hs.application.launchOrFocus("1Password")
end)
hs.hotkey.bind(MEH, "z", function()
	hs.application.launchOrFocus("Zoom.us")
end)

-- Load local config if there is one
-- This is so some configs can be outside of version control
-- add it to ~/.hammerspoon/local-config.lua
--
-- For example I have a zoom meeting with passwords in it
-- Open Bedrock zoom meeting
-- hs.hotkey.bind(MEH, "x", function()
--     hs.urlevent.openURL("https://us06web.zoom.us/j/<meetingid>?pwd=<passwordhere>")
-- end)
if hs.fs.attributes(hs.configdir .. "/local-config.lua") then
	require("local-config")
end

-- Move window to left half
hs.hotkey.bind({ "cmd" }, "h", function()
	local win = hs.window.focusedWindow()
	if win then
		local screen = win:screen()
		local frame = screen:frame()

		win:setFrame({
			x = frame.x,
			y = frame.y,
			w = frame.w / 2,
			h = frame.h,
		})
	end
end)

-- Move window to right half
hs.hotkey.bind({ "cmd" }, "l", function()
	local win = hs.window.focusedWindow()
	if win then
		local screen = win:screen()
		local frame = screen:frame()

		win:setFrame({
			x = frame.w / 2,
			y = frame.y,
			w = frame.w / 2,
			h = frame.h,
		})
	end
end)

-- Maximize window
hs.hotkey.bind({ "cmd" }, "k", function()
	local win = hs.window.focusedWindow()
	if win then
		win:maximize()
	end
end)

-- Cmd + Alt + H to show hotkey cheat sheet
hs.hotkey.bind(MEH, "/", function()
	local hotkeys = [[

WINDOW MANAGEMENT:
⌘ + h   → Move window to left half
⌘ + l   → Move window to right half
⌘ + k   → Maximize window

APP lAUNCHERS:
MEH + A   → Launch Spotify
MEH + B   → Launch Brave Browser
MEH + C   → Launch Calculator
MEH + D   → Launch Beekeeper Studio
MEH + F   → Launch Finder
MEH + G   → Launch Ghostty
MEH + M   → Launch Messages
MEH + P   → Launch 1Password
MEH + S   → Launch Slack
MEH + T   → Launch Telegram
MEH + Z   → Launch Zoom
MEH + /   → Show this hotkey reference

MEH = { "shift", "ctrl", "alt" }

]]

	hs.dialog.blockAlert("Hammerspoon Hotkey Reference", hotkeys, "Close")
end)
