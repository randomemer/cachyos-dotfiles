-- =============================================================================
--  Keybinds — migrated from the NixOS/caelestia config
--  (~/Downloads/nixos-config-main/configs/hypr/hyprland/keybinds.conf +
--   variables.conf), translated to Hyprland's Lua config and DMS.
--
--  NOTE: `dms setup` may overwrite this file. If that happens, this content
--  can be moved to dms/binds-user.lua verbatim (it uses the same API).
-- =============================================================================

local mainMod = "SUPER"

-- Apps
local terminal     = "kitty"
local browser      = "vivaldi"
local editor       = "zed"
local fileExplorer = "dfiles"

local volumeStep = 10 -- percent, was $volumeStep

-- 10 groups of 10 workspaces, same scheme as the NixOS config:
--   group 1 -> workspaces  1..10, group 2 -> 11..20, ...
-- The NixOS config shelled out to scripts/wsaction.fish for this. That script
-- cannot work here: under a Lua config `hyprctl dispatch` evaluates its argument
-- as Lua, so `hyprctl dispatch workspace 13` is a syntax error. Computed inline
-- instead — no subprocess, no jq.
local function activeWs()
    local ws = hl.get_active_workspace()
    return (ws and ws.id and ws.id > 0) and ws.id or 1
end

-- Workspace n within the current group
local function wsInGroup(n)
    return math.floor((activeWs() - 1) / 10) * 10 + n
end

-- Same slot, but in group n
local function wsInOtherGroup(n)
    return (n - 1) * 10 + activeWs() % 10
end

-- Modifier aliases, mirroring the $kb* variables from variables.conf
local kbGoToWs            = mainMod                          -- + digit
local kbGoToWsGroup       = "CTRL + " .. mainMod             -- + digit
local kbMoveWinToWs       = mainMod .. " + SHIFT"            -- + digit
local kbMoveWinToWsGroup  = "CTRL + " .. mainMod .. " + ALT" -- + digit

-------------------------------------------------------------------------------
-- SHELL (was caelestia:* globals -> DMS ipc)
-------------------------------------------------------------------------------

-- Launcher. The NixOS config opened it on a bare Super tap (caelestia:launcher
-- + launcherInterrupt). DMS has no interrupt counterpart, so a tap-to-open bind
-- would fire on every Super+<key> release. Bound to Super+Space instead, which
-- is also what dms/binds-user.lua sets.
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { description = "Launcher: Toggle" })

hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call powermenu toggle"),      { description = "Session menu" })
hl.bind("CTRL + ALT + C",      hl.dsp.exec_cmd("dms ipc call notifications clearAll"), { locked = true, description = "Clear notifications" })
hl.bind(mainMod .. " + K",     hl.dsp.exec_cmd("dms ipc call bar toggleReveal"),      { description = "Show/hide panels" })
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd("dms ipc call lock lock"),             { description = "Lock" })

-- Restore lock (was: restart caelestia shell, then re-lock)
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("dms ipc call lock forceReset"), { locked = true, description = "Restore lock" })

-- Restart / kill the shell
hl.bind("CTRL + " .. mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("dms kill"),    { release = true, description = "Kill DMS shell" })
hl.bind("CTRL + " .. mainMod .. " + ALT + R",   hl.dsp.exec_cmd("dms restart"), { release = true, description = "Restart DMS shell" })

-------------------------------------------------------------------------------
-- HARDWARE CONTROLS
-------------------------------------------------------------------------------

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("dms ipc call brightness increment"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement"), { locked = true, repeating = true })

-- Volume
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true })
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("dms ipc call audio increment " .. volumeStep), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("dms ipc call audio decrement " .. volumeStep), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("dms ipc call mic mute"), { locked = true })

-- Media
hl.bind("CTRL + " .. mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPlay",                    hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPause",                   hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("CTRL + " .. mainMod .. " + Equal", hl.dsp.exec_cmd("dms ipc call mpris next"),      { locked = true })
hl.bind("XF86AudioNext",                    hl.dsp.exec_cmd("dms ipc call mpris next"),      { locked = true })
hl.bind("CTRL + " .. mainMod .. " + Minus", hl.dsp.exec_cmd("dms ipc call mpris previous"),  { locked = true })
hl.bind("XF86AudioPrev",                    hl.dsp.exec_cmd("dms ipc call mpris previous"),  { locked = true })
hl.bind("XF86AudioStop",                    hl.dsp.exec_cmd("dms ipc call mpris stop"),      { locked = true })

-------------------------------------------------------------------------------
-- WORKSPACES
-------------------------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- 10 -> key 0
    -- Go to workspace # (within the current group of 10)
    hl.bind(kbGoToWs .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = wsInGroup(i) }))
    end)
    -- Go to workspace group #
    hl.bind(kbGoToWsGroup .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = wsInOtherGroup(i) }))
    end)
    -- Move window to workspace #
    hl.bind(kbMoveWinToWs .. " + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = wsInGroup(i), follow = true }))
    end)
    -- Move window to workspace group #
    hl.bind(kbMoveWinToWsGroup .. " + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = wsInOtherGroup(i), follow = true }))
    end)
end

-- Go to workspace -1/+1
hl.bind(mainMod .. " + mouse_down",         hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + mouse_up",           hl.dsp.focus({ workspace = "+1" }))
hl.bind("CTRL + " .. mainMod .. " + Left",  hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("CTRL + " .. mainMod .. " + Right", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
hl.bind(mainMod .. " + Page_Up",            hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind(mainMod .. " + Page_Down",          hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Go to workspace group -1/+1
hl.bind("CTRL + " .. mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "-10" }))
hl.bind("CTRL + " .. mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "+10" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))

-- Move window to workspace -1/+1
hl.bind(mainMod .. " + ALT + Page_Up",             hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind(mainMod .. " + ALT + Page_Down",           hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind(mainMod .. " + ALT + mouse_down",          hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + mouse_up",            hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL + " .. mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind("CTRL + " .. mainMod .. " + SHIFT + Right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })

-- Move window to/from the special workspace
hl.bind("CTRL + " .. mainMod .. " + SHIFT + Up",   hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + " .. mainMod .. " + SHIFT + Down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind(mainMod .. " + ALT + S",                   hl.dsp.window.move({ workspace = "special:special" }))

-------------------------------------------------------------------------------
-- WINDOW GROUPS
-------------------------------------------------------------------------------

hl.bind("ALT + Tab",                hl.dsp.window.cycle_next(),               { repeating = true })
hl.bind("SHIFT + ALT + Tab",        hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind("CTRL + ALT + Tab",         hl.dsp.group.next(),                      { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(),                      { repeating = true })
hl.bind(mainMod .. " + Comma",         hl.dsp.group.toggle())
hl.bind(mainMod .. " + U",             hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + SHIFT + Comma", hl.dsp.group.lock({ action = "toggle" }))

-------------------------------------------------------------------------------
-- WINDOW ACTIONS
-------------------------------------------------------------------------------

-- Focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))

-- Move within the layout
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))

-- Split ratio
hl.bind(mainMod .. " + Minus", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind(mainMod .. " + Equal", hl.dsp.layout("splitratio +0.1"), { repeating = true })

-- Move & resize with the mouse (or Super+Z / Super+X held). These were `bindm`;
-- window.drag()/resize() already hold until release, so no extra flag is needed
-- (`mouse = true` is not a real hl.bind option — Hyprland ignores it).
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + Z",         hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
hl.bind(mainMod .. " + X",         hl.dsp.window.resize())

-- Center / center at a fixed size
hl.bind("CTRL + " .. mainMod .. " + Backslash", hl.dsp.window.center())
-- Was `resizeactive exact 55% 70%` + centerwindow. hl.window.resize takes pixels
-- only, so this is 55%/70% of the 2560x1440 DP-2 panel.
hl.bind("CTRL + " .. mainMod .. " + ALT + Backslash", function()
    hl.dispatch(hl.dsp.window.resize({ x = 1408, y = 1008 }))
    hl.dispatch(hl.dsp.window.center())
end, { description = "Resize to 55%x70% and center" })

-- Picture-in-picture. caelestia had a dedicated `caelestia resizer pip`; this is
-- an approximation: float, shrink, park it bottom-right.
hl.bind(mainMod .. " + ALT + Backslash", function()
    hl.dispatch(hl.dsp.window.float({ action = "on" }))
    hl.dispatch(hl.dsp.window.resize({ x = 640, y = 360 }))
    hl.dispatch(hl.dsp.window.move({ x = 1900, y = 1050 }))
end, { description = "Picture-in-picture" })

hl.bind(mainMod .. " + P",           hl.dsp.window.pin())
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen({ mode = "maximized" })) -- fullscreen with borders
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + C",           hl.dsp.window.close())

-------------------------------------------------------------------------------
-- SPECIAL WORKSPACE TOGGLES
-------------------------------------------------------------------------------

-- caelestia's `toggle <name>` opened a named scratchpad and spawned its app if
-- empty. These toggle the same scratchpads; you populate them yourself
-- (Super+Shift+<digit> etc. or a window rule).
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + D", hl.dsp.workspace.toggle_special("communication"))
hl.bind(mainMod .. " + R", hl.dsp.workspace.toggle_special("todo"))

-- System monitor: DMS's own process list replaces the caelestia sysmon scratchpad.
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("dms ipc call processlist toggle"))

-------------------------------------------------------------------------------
-- APPS
-------------------------------------------------------------------------------

hl.bind(mainMod .. " + Q",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W",       hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T",       hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + E",       hl.dsp.exec_cmd(fileExplorer))
hl.bind(mainMod .. " + G",       hl.dsp.exec_cmd("github-desktop")) -- not installed
hl.bind(mainMod .. " + ALT + E", hl.dsp.exec_cmd("nemo"))           -- not installed
hl.bind("CTRL + ALT + Escape",   hl.dsp.exec_cmd(terminal .. " -e btop")) -- was qps
hl.bind("CTRL + ALT + V",        hl.dsp.exec_cmd("pavucontrol"))

-------------------------------------------------------------------------------
-- UTILITIES
-------------------------------------------------------------------------------

-- Screen capture (DMS ships its own screenshot backend — no grim/slurp needed)
hl.bind("Print",                         hl.dsp.exec_cmd("dms screenshot full"),   { locked = true, description = "Screenshot: full screen" })
hl.bind(mainMod .. " + SHIFT + S",       hl.dsp.exec_cmd("dms screenshot region"), { description = "Screenshot: region" })
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("dms screenshot window"), { description = "Screenshot: window" })

-- Colour picker (was hyprpicker -a)
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("dms color pick"))

-- Screen recording. No backend is installed and DMS has none; these use
-- wf-recorder and stay dead until you `sudo pacman -S wf-recorder`.
-- Pressing a bind again stops the running recording.
local function record(args)
    return hl.dsp.exec_cmd("pkill -INT -x wf-recorder || wf-recorder " .. args)
end
hl.bind(mainMod .. " + ALT + R",         record("--audio"),          { description = "Record screen with sound" })
hl.bind("CTRL + ALT + R",                record(""),                 { description = "Record screen" })
hl.bind(mainMod .. " + SHIFT + ALT + R", record('-g "$(slurp)"'),    { description = "Record region" })

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
-- Super+Alt+V was `caelestia clipboard -d` (delete-from-history mode) and
-- Ctrl+Shift+Alt+V was a ydotool re-paste. DMS's clipboard has neither; delete
-- entries from inside the Super+V panel.

-- Emoji picker: caelestia had one on Super+Period, DMS does not ship one.
-- hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("..."))

-- Sleep
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"))

-------------------------------------------------------------------------------
-- TESTING
-------------------------------------------------------------------------------

hl.bind(mainMod .. " + ALT + F12", hl.dsp.exec_cmd(
    "notify-send -u low -i dialog-information-symbolic 'Test notification' " ..
    "\"Here's a really long message to test truncation and wrapping\" " ..
    "-a 'Shell' -A 'Test1=I got it!' -A 'Test2=Another action'"
), { locked = true })
