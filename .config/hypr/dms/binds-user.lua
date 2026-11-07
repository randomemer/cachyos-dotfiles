-- DMS user keybind overrides (edit via Control Center or dms; do not remove this header)

hl.unbind("SUPER + Space")
hl.bind("SUPER + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { description = "Default Launcher: Toggle" })

-- Interactive kill (click a window to force-kill it).
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("hyprctl kill"), { description = "Kill: interactive (click a window)" })
