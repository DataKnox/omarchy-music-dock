import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Ui

// A tray-style icon for Spotify. Neither the Spotify web app (a Chromium app
// window) nor the native client registers a StatusNotifierItem, so once
// Spotify is hidden nothing in the bar represents it. This widget stands in
// for that icon: it appears while a Spotify window exists, lights up while
// music plays, shows the track as a tooltip, and a click shows or hides the
// window in its drop-down workspace (see bin/omarchy-music-dock).
BarWidget {
  id: root
  moduleName: "dataknox.music-dock"

  // The helper script ships inside the plugin folder, so no PATH setup is
  // needed wherever the plugin was cloned to.
  readonly property string script: Qt.resolvedUrl("bin/omarchy-music-dock").toString().replace(/^file:\/\//, "")

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
      if (t && isSpotify(t.appId)) return t
    }
    return null
  }

  readonly property bool playing: player !== null && player.isPlaying
  readonly property string track: player && (player.trackTitle || player.trackArtist)
    ? (player.trackTitle || "") + (player.trackArtist ? " — " + player.trackArtist : "")
    : ""

  visible: spotify !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    active: root.playing
    tooltipText: root.track !== "" ? root.track : "Spotify: click to show or hide"
    onPressed: function(b) {
      if (b === Qt.MiddleButton) {
        if (root.mediaService) root.mediaService.runAction("playPause", false)
      } else {
        root.bar.run("'" + root.script + "' toggle")
      }
    }
    onWheelMoved: function(delta) {
      if (!root.mediaService) return
      root.mediaService.runAction(delta > 0 ? "previous" : "next", false)
    }
  }
}
