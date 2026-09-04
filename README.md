# Music Dock for Omarchy

A tray-style Spotify icon for the Omarchy bar, plus a "minimize" for Spotify.

Neither the Spotify web app (a Chromium app window) nor the native client
registers a tray icon, so once you hide Spotify nothing in the bar represents
it. This plugin adds that icon: it appears while a Spotify window exists,
lights up while music plays, shows the track as a tooltip, and a click shows
or hides the window.

Hyprland has no minimize, so hiding uses a special workspace: Spotify lives in
a drop-down (`special:music`) that overlays your current workspace and retracts
when you dismiss it. Playback carries on while it is hidden, which pairs well
with Omarchy's own `omarchy.media` bar widget for track info and controls.

Works with the native Spotify client and with the open.spotify.com web app in
Chromium app mode, which is what Omarchy on Apple Silicon Macs uses.

## Install

```
omarchy plugin add https://github.com/DataKnox/omarchy-music-dock.git --enable
```

Then add the Hyprland side. Copy the rules file into your config and load it:

```
cp ~/.config/omarchy/plugins/dataknox.music-dock/hypr/music-dock.lua ~/.config/hypr/
echo 'require("hypr.music-dock")' >> ~/.config/hypr/hyprland.lua
hyprctl reload
```

`music-dock.lua` declares the drop-down workspace, the window rule that parks
Spotify in it, and rebinds `Super + Shift + M` to the dock. Edit it if you want
a different key or inset.

Optional: enable Omarchy's built-in now-playing widget next to the icon with
`omarchy plugin enable omarchy.media --section right`.

## Use

- Click the icon, or press `Super + Shift + M`: show or hide Spotify. If it is
  not running, it launches straight into the drop-down.
- Middle-click: play or pause. Scroll: previous or next track.
- `~/.config/omarchy/plugins/dataknox.music-dock/bin/omarchy-music-dock show|hide|toggle`
  does the same from a terminal or another script.

## How it works

`MusicDock.qml` is a bar widget: it watches the Wayland toplevel list for a
Spotify window and the Omarchy media service for playback state, and runs
`bin/omarchy-music-dock` on click. The script asks Hyprland where the Spotify
window is, moves it into `special:music` if it is elsewhere, and toggles that
special workspace.
