-- Ignore undefined global warnings for Hammerspoon
---@diagnostic disable: undefined-global

-- Modifier key combo
MEH = { "shift", "ctrl", "alt" }

-- These install the `hs` cli interface. I was using it for notification popups
-- hs.ipc.cliInstall("/opt/homebrew/bin")
-- require("hs.ipc")

-- Timers could get messy here but so far its working.  slight lag but usable.  could tune down further maybe?
-- may interfear with my nvim space+w save option if I dont pause on my space hold too long
local function gotoTmuxGroup(key)
	local app = hs.application.get("Ghostty")

	if not app then
		hs.application.launchOrFocus("Ghostty")
		hs.timer.usleep(5000)
		app = hs.application.get("Ghostty")
	end

	app:activate(true)
	hs.timer.usleep(5000)

	hs.eventtap.keyStroke({ "ctrl" }, "space")
	hs.timer.usleep(1000)

	hs.eventtap.keyStroke({}, "g")
	hs.timer.usleep(1000)

	hs.eventtap.keyStroke({}, key)
end

hs.hotkey.bind(MEH, "w", function()
	gotoTmuxGroup("w")
end)
hs.hotkey.bind(MEH, "h", function()
	gotoTmuxGroup("h")
end)
hs.hotkey.bind(MEH, "r", function()
	gotoTmuxGroup("r")
end)

-- hs.hotkey.bind(MEH, "w", function()
-- 	-- hs.execute("/Applications/Ghostty.app/Contents/MacOS/ghostty -e tmux new-session -A -s Wiki > /dev/null 2>&1 &")
-- 	hs.execute("open -a Ghostty --args -e tmux new-session -A -s Wiki")
-- end)

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

-- Hotkey reference popup (HTML webview so section titles can be underlined)
local helpWebview = nil
local helpEscapeHotkey = nil

local function htmlEscape(s)
	return (
		s:gsub("[&<>\"']", {
			["&"] = "&amp;",
			["<"] = "&lt;",
			[">"] = "&gt;",
			['"'] = "&quot;",
			["'"] = "&#39;",
		})
	)
end

local function helpRow(keys, desc)
	return string.format(
		'<div class="row"><span class="keys">%s</span><span class="desc">%s</span></div>',
		htmlEscape(keys),
		htmlEscape(desc)
	)
end

local function helpSection(title, body, className)
	return string.format(
		'<section class="section %s"><h2>%s</h2><div class="rows">%s</div></section>',
		className or "",
		htmlEscape(title),
		body
	)
end

local function closeHotkeyHelp()
	if helpEscapeHotkey ~= nil then
		helpEscapeHotkey:delete()
		helpEscapeHotkey = nil
	end
	if helpWebview ~= nil then
		helpWebview:delete()
		helpWebview = nil
	end
end

local function showHotkeyHelp()
	if helpWebview ~= nil then
		closeHotkeyHelp()
		return
	end

	-- Stable key order for app launchers
	local appKeys = {}
	for key in pairs(appHotkeys) do
		table.insert(appKeys, key)
	end
	table.sort(appKeys)

	local appRows = {}
	for _, key in ipairs(appKeys) do
		table.insert(appRows, helpRow("MEH + " .. key:upper(), "Launch " .. appHotkeys[key]))
	end
	table.insert(appRows, helpRow("MEH + /", "Show / hide this reference"))

	local body = table.concat({
		helpSection(
			"Window management",
			helpRow("⌘ + H", "Left half") .. helpRow("⌘ + L", "Right half") .. helpRow("⌘ + K", "Maximize"),
			"window"
		),
		helpSection("App launchers", table.concat(appRows), "apps"),
		helpSection(
			"Tmux sessions",
			helpRow("MEH + H", "Home session")
				.. helpRow("MEH + R", "Remote session")
				.. helpRow("MEH + W", "Wiki session"),
			"tmux"
		),
		helpSection(
			"Keyboard (Kanata)",
			helpRow("Caps tap", "Escape")
				.. helpRow("Caps double-tap", "Escape")
				.. helpRow("Caps triple-tap", "Toggle Caps Lock")
				.. helpRow("Caps hold", "Ctrl")
				.. helpRow("Space hold", "MEH (shift+ctrl+alt)")
				.. helpRow("Both Shifts", "Reload Kanata config"),
			"kanata"
		),
	}, "\n")

	-- Avoid string.format here: CSS uses '%' (e.g. 42%) which breaks format specs.
	local html = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<style>
  :root {
    color-scheme: dark;
    --bg: #1e1e2e;
    --panel: #181825;
    --fg: #cdd6f4;
    --muted: #a6adc8;
    --accent: #89b4fa;
    --border: #313244;
    --keys: #a6e3a1;
  }
  * { box-sizing: border-box; }
  html, body {
    margin: 0;
    padding: 0;
    background: var(--bg);
    color: var(--fg);
    font: 12px/1.35 -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", sans-serif;
    overflow: hidden;
  }
  .wrap {
    padding: 14px 16px 12px;
    height: 100vh;
    display: flex;
    flex-direction: column;
  }
  .header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 10px;
    flex-shrink: 0;
  }
  h1 {
    margin: 0;
    font-size: 15px;
    font-weight: 700;
  }
  .sub {
    margin: 0;
    color: var(--muted);
    font-size: 11px;
    white-space: nowrap;
  }
  .grid {
    flex: 1;
    display: grid;
    grid-template-columns: 1.1fr 1fr 1.15fr;
    grid-template-rows: auto 1fr;
    gap: 10px 14px;
    min-height: 0;
  }
  .section {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 8px 10px 10px;
    min-width: 0;
  }
  .section.apps {
    grid-column: 2;
    grid-row: 1 / span 2;
  }
  .section.window { grid-column: 1; grid-row: 1; }
  .section.tmux { grid-column: 1; grid-row: 2; }
  .section.kanata { grid-column: 3; grid-row: 1 / span 2; }
  h2 {
    margin: 0 0 6px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    text-decoration: underline;
    text-underline-offset: 2px;
    color: var(--accent);
  }
  .rows { display: flex; flex-direction: column; gap: 1px; }
  .row {
    display: grid;
    grid-template-columns: minmax(108px, 42%) 1fr;
    gap: 6px;
    padding: 2px 4px;
    border-radius: 4px;
  }
  .section.kanata .row {
    grid-template-columns: minmax(128px, 48%) 1fr;
  }
  .section.apps .row {
    grid-template-columns: minmax(88px, 38%) 1fr;
  }
  .row:nth-child(odd) { background: rgba(49, 50, 68, 0.35); }
  .keys {
    font-family: Menlo, ui-monospace, monospace;
    font-size: 11px;
    color: var(--keys);
    white-space: nowrap;
  }
  .desc {
    color: var(--fg);
    font-size: 12px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .footer {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid var(--border);
    color: var(--muted);
    font-size: 11px;
    flex-shrink: 0;
  }
  kbd {
    font-family: Menlo, ui-monospace, monospace;
    color: #f9e2af;
  }
</style>
</head>
<body>
  <div class="wrap">
    <div class="header">
      <h1>Hammerspoon Hotkey reference</h1>
      <p class="sub">Press <kbd>Esc</kbd> or <kbd>MEH + /</kbd> to close</p>
    </div>
    <div class="grid">
      __BODY__
    </div>
    <div class="footer">MEH = shift + ctrl + alt</div>
  </div>
</body>
</html>
]]
	html = html:gsub("__BODY__", body, 1)

	local screen = hs.screen.mainScreen()
	local frame = screen:frame()
	local width, height = 1100, 430
	local rect = hs.geometry.rect(frame.x + (frame.w - width) / 2, frame.y + (frame.h - height) / 2, width, height)

	helpWebview = hs.webview
		.new(rect, {
			javaScriptEnabled = false,
			developerExtrasEnabled = false,
		})
		:windowStyle({ "titled", "closable" })
		:windowTitle("Hotkey reference")
		:deleteOnClose(true)
		:allowNewWindows(false)
		:allowGestures(false)
		:level(hs.drawing.windowLevels.floating)
		:html(html)
		:show()
		:bringToFront(true)

	-- closeOnEscape is unreliable when the webview is not key-focused (and with
	-- Kanata remaps). Bind Escape globally while the help panel is open.
	helpEscapeHotkey = hs.hotkey.bind({}, "escape", closeHotkeyHelp)

	helpWebview:windowCallback(function(action)
		if action == "closing" then
			if helpEscapeHotkey ~= nil then
				helpEscapeHotkey:delete()
				helpEscapeHotkey = nil
			end
			helpWebview = nil
		end
	end)
end

hs.hotkey.bind(MEH, "/", showHotkeyHelp)
