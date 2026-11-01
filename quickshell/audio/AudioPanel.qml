import QtQuick
import Quickshell
import qs
import qs.bar
import qs.common

// Volume slider + output device picker, opened from the bar's volume button.
PopupPanel {
    id: panel

    open: Audio.panelOpen
    onCloseRequested: Audio.panelOpen = false

    cardWidth: 340
    cardHeight: Math.min(440, 112 + list.contentHeight)

    readonly property var audio: Audio.sink?.audio
    readonly property real vol: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false

    function setVolume(v) {
        if (audio)
            audio.volume = Math.max(0, Math.min(1, v));
    }

    Text {
        id: title
        anchors { top: parent.top; left: parent.left; topMargin: 12; leftMargin: 12 }
        text: "Sound"
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.weight: Font.DemiBold
    }

    // [mute icon]  ----o------  72%
    Item {
        id: volRow
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: 12
            topMargin: 10
        }
        height: 28

        HoverButton {
            id: muteBtn
            width: 26
            height: 26
            radius: Theme.radius
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            onClicked: {
                if (panel.audio)
                    panel.audio.muted = !panel.audio.muted;
            }

            Text {
                anchors.centerIn: parent
                text: Audio.volumeIcon(panel.vol, panel.muted)
                color: panel.muted ? Theme.muted : Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: Theme.iconSize
            }
        }

        Text {
            id: pct
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: 36
            horizontalAlignment: Text.AlignRight
            text: Math.round(panel.vol * 100) + "%"
            color: panel.muted ? Theme.muted : Theme.fg
            font.pixelSize: Theme.fontSize
        }

        Item {
            id: slider
            anchors {
                left: muteBtn.right
                leftMargin: 10
                right: pct.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            height: 20

            Rectangle {
                id: track
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                height: 6
                radius: 3
                color: Theme.border
            }

            Rectangle {
                id: fill
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: knob.x + knob.width / 2
                height: 6
                radius: 3
                color: panel.muted ? Theme.muted : Theme.blue
            }

            Rectangle {
                id: knob
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: 7
                color: Theme.fg
                x: panel.vol * (slider.width - width)
            }

            MouseArea {
                anchors.fill: parent

                function seek(mx) {
                    panel.setVolume((mx - knob.width / 2) / (slider.width - knob.width));
                }

                onPressed: mouse => seek(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed)
                        seek(mouse.x);
                }
                onWheel: wheel => panel.setVolume(panel.vol + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
            }
        }
    }

    Text {
        id: outLabel
        anchors { top: volRow.bottom; left: parent.left; topMargin: 14; leftMargin: 12 }
        text: "OUTPUT"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 3
        font.letterSpacing: 1
    }

    ListView {
        id: list
        anchors {
            top: outLabel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
            topMargin: 6
        }
        spacing: 2
        clip: true

        model: ScriptModel { values: Audio.sinks }

        delegate: SinkRow {
            required property var modelData
            node: modelData
            width: ListView.view.width
        }
    }

    Text {
        anchors.centerIn: list
        visible: list.count === 0
        text: "No output devices"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 1
    }
}
