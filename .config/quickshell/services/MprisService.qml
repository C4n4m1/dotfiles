pragma Singleton
pragma ComponentBehavior

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

// NOTE: The some() array's method is used to check if any element in the array satisfies a condition.

Singleton {
    id: root

    readonly property list<MprisPlayer> availablePlayers: Mpris.players.values

    property MprisPlayer activePlayer: availablePlayers.find(p => p.isPlaying) ?? availablePlayers.find(p => p.canControl && p.canPlay) ?? null

    readonly property var _browserHints: ["firefox", "zen", "chrome", "chromium", "brave", "vivaldi", "edge", "opera"]
    readonly property var _videoExts: ["mp4", "mkv", "webm", "avi", "mov", "m4v", "mpeg", "mpg", "wmv", "flv"]
    readonly property var _videoHints: ["mpv", "vlc", "celluloid", "io.github.celluloid_player.celluloid", "org.gnome.totem", "smplayer", "mplayer", "haruna", "kodi", "io.github.iwalton3.jellyfin-media-player", "jellyfin", "plex"]
    readonly property var _videoPatterns: ["youtube.com/watch", "laracasts.com/", "youtu.be/", "netflix.com", "primevideo.com", "osnplus.com", "vimeo.com", "twitch.tv", "hulu.com", "disneyplus.com", "crunchyroll.com", "max.com", "hbomax.com"]
    readonly property var _audioOnlyPatterns: ["music.youtube.com", "spotify.com", "soundcloud.com", "music.apple.com", "deezer.com", "tidal.com", "bandcamp.com"]

    // Audio.pipewireVideoActive is to check if there is a video stream from the computer ( example : OBS )
    readonly property bool pipewireVideoActive: (Pipewire.linkGroups?.values ?? []).some(lg => lg?.source?.type === PwNodeType.VideoSource)

    // if ohter Mpris player which are not the active or focused one are playing video
    readonly property bool _hasPlayingVideo: availablePlayers.some(p => p?.playbackState === MprisPlaybackState.Playing && (_isVideoApp(p) || (_isBrowserApp(p) && _isVideoUrl(_getUrl(p)))))

    // if the active player is a video player or a browser playing a video url
    readonly property bool _activeIsVideo: activePlayer && (_isVideoApp(activePlayer) || (_isBrowserApp(activePlayer) && _isVideoUrl(_getUrl(activePlayer))))

    readonly property bool anyVideoPlaying: _hasPlayingVideo || (pipewireVideoActive && _activeIsVideo)

    function _getUrl(p) {
        return p?.metadata?.["xesam:url"] ?? p?.metadata?.["xesam:URL"] ?? "";
    }

    function _isBrowserApp(p) {
        const src = String((p?.desktopEntry ?? "") + (p?.identity ?? "")).toLowerCase();
        return _browserHints.some(h => src.includes(h));
    }

    function _isVideoApp(p) {
        const src = String((p?.desktopEntry ?? "") + (p?.identity ?? "")).toLowerCase();
        return _videoHints.some(h => src.includes(h));
    }

    function _isVideoUrl(url) {
        if (!url)
            return false;
        const lower = String(url).toLowerCase();
        if (_audioOnlyPatterns.some(p => lower.includes(p)))
            return false;
        if (_videoPatterns.some(p => lower.includes(p)))
            return true;
        const match = lower.match(/\.([a-z0-9]{2,5})(?:\?|#|$)/);
        return !!(match && _videoExts.includes(match[1]));
    }

    property int recordDuration: 0
    // property int recordDurationSeconds

    Timer {
        id: recorderTimer
        running: root.pipewireVideoActive
        repeat: true
        interval: 1000 // 100 centiemes → 1 sec
        onTriggered: {
            root.recordDuration++;
        }
    }

    onPipewireVideoActiveChanged: {
        if (!root.pipewireVideoActive) {
            root.recordDuration = 0;
        }
    }

    function recordDurationFormatting(duration) {
        var time = parseInt(duration);
        var hours = Math.floor(time / 3600);
        var mins = Math.floor((time % 3600) / 60);
        var sec = time % 60;

        if (duration < 3600) {
            return String(mins).padStart(2, '0') + ":" + String(sec).padStart(2, '0');
        } else {
            return String(hours).padStart(2, '0') + ":" + String(mins).padStart(2, '0');
        }
    }
}
