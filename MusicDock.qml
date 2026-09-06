import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Ui

// A tray-style icon for Spotify. Neither the Spotify web app (a Chromium app
// window) nor the native client registers a StatusNotifierItem, so once
// Spotify is hidden nothing in the bar represents it. This widget stands in
// for that icon. Unlike a tray icon it stays put when Spotify is closed,
// dimmed, so a click can open Spotify as well as show or hide it; it lights
// up while music plays and shows the track as a tooltip. Show/hide/launch is
// done by bin/omarchy-music-dock, which parks Spotify in a drop-down workspace.
BarWidget {
  id: root
  moduleName: "io.github.dataknox.music-dock"

  // The helper script ships inside the plugin folder, so no PATH setup is
  // needed wherever the plugin was cloned to.
  readonly property string script: Qt.resolvedUrl("bin/omarchy-music-dock").toString().replace(/^file:\/\//, "")

  // Nerd Font "md-spotify", the glyph Omarchy's own menu uses for Spotify.
  readonly property string glyph: String.fromCodePoint(0xF04C7)

  readonly property var mediaService: bar?.shell?.firstPartyServiceFor("omarchy.media")
  readonly property var player: mediaService ? mediaService.activePlayer : null
  readonly property var toplevels: ToplevelManager.toplevels ? ToplevelManager.toplevels.values : []

  function isSpotify(appId) {
    var id = (appId || "").toLowerCase()
    return id === "spotify" || id.indexOf("open.spotify.com") !== -1
  }

  readonly property var spotify: {
    for (var i = 0; i < toplevels.length; i++) {
      var t = toplevels[i]
      if (t && root.isSpotify(t.appId)) return t
    }
    return null
  }

  readonly property bool running: spotify !== null
  readonly property bool playing: running && player !== null && player.isPlaying
  readonly property string playingColor: String(setting("activeColor", "theme"))
  readonly property string track: player && (player.trackTitle || player.trackArtist)
    ? (player.trackTitle || "") + (player.trackArtist ? " — " + player.trackArtist : "")
    : ""

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.glyph
    active: root.playing
    useActiveColor: root.playingColor !== "monochrome"
    activeColor: root.playingColor === "spotify" ? "#1DB954"
               : (bar ? bar.urgent : foreground)
    opacity: root.running ? 1.0 : 0.6
    tooltipText: !root.running ? "Spotify: click to open"
               : (root.track !== "" ? root.track : "Spotify: click to show or hide")
    onPressed: function(b) {
      if (b === Qt.MiddleButton) {
        if (root.running && root.mediaService) root.mediaService.runAction("playPause", false)
      } else {
        root.bar.run("'" + root.script + "' toggle")
      }
    }
    onWheelMoved: function(delta) {
      if (!root.running || !root.mediaService) return
      root.mediaService.runAction(delta > 0 ? "previous" : "next", false)
    }
    Behavior on opacity { NumberAnimation { duration: 160 } }
  }
}
