import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.audio

// Bar button: icon only. Click = open sound popup, scroll = volume, middle click = mute.
HoverButton {
    id: root

    readonly property var audio: Pipewire.defaultAudioSink?.audio
    readonly property real vol: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false

    hoverColor: Theme.surface
    implicitWidth: 26
    implicitHeight: 26

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            if (audio)
                audio.muted = !audio.muted;
        } else {
            Audio.panelOpen = !Audio.panelOpen;
        }
    } 

    onWheel: wheel => {
        if (!audio) return
        const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
        audio.volume = Math.max(0, Math.min(1, audio.volume + delta))
    }

    Text {
        anchors.centerIn: parent
        text: Audio.volumeIcon(root.vol, root.muted)
        color: root.muted ? Theme.muted : Theme.blue
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize + 2

    }
}
