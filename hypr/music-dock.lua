-- Music Dock: Spotify's "minimize". Spotify lives in a drop-down special
-- workspace that overlays the current workspace, so hiding it is instant and
-- playback carries on. Shown and hidden by bin/omarchy-music-dock (bound to a
-- key below, and by the Music Dock icon in the bar).
--
-- Install: copy this file to ~/.config/hypr/music-dock.lua and add
--   require("hypr.music-dock")
-- to ~/.config/hypr/hyprland.lua after the Omarchy defaults are loaded.

local dock = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/dataknox.music-dock/bin/omarchy-music-dock"

-- Inset the drop-down so the dimmed desktop stays visible around it, and skip
-- the focus border: like the scratchpad, it is only ever focused while open.
hl.workspace_rule({
  workspace = "special:music",
  gaps_in = 0,
  gaps_out = { top = 0, right = 48, bottom = 32, left = 48 },
  no_border = true,
})

-- Park every Spotify window in the drop-down as it opens: the native client
-- and the open.spotify.com web app in Chromium app mode.
o.window({ class = "^([Ss]potify|chrome-open\\.spotify\\.com__-Default)$" }, { workspace = "special:music" })

-- Show, hide, or launch Spotify. Omarchy binds this key to its own Spotify
-- launcher, so release it first.
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Music", dock .. " toggle")
