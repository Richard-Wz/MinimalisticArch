import QtQuick
import QtQuick.Effects
import Quickshell.Services.Mpris
import qs
import qs.bar

Item {
    id: root

    readonly property int maxTextWidth: 155

    property var player: {
    const list = Mpris.players.values;
    const isKew = p => ((p.identity || "") + (p.dbusName || "")).toLowerCase().includes("kew");
    return list.find(p => p.isPlaying && isKew(p))
        ?? list.find(p => p.isPlaying)
        ?? list.find(isKew)
        ?? list[0] ?? null;
    }

    readonly property string songTitle:
        player && player.trackTitle ? player.trackTitle : "Nothing playing"

    readonly property string songArtist:
        player && player.trackArtist ? player.trackArtist : "MUSIC"

    readonly property bool canPrev: !!player && player.canGoPrevious
    readonly property bool canNext: !!player && player.canGoNext
    readonly property bool canToggle: !!player && player.canTogglePlaying

    implicitWidth: pill.width
    implicitHeight: pill.height

    Rectangle {
        id: pill

        width: Math.min(contentRow.implicitWidth + 28, 420)
        height: 30
        radius: 10
        color: Theme.bg

        // Mouse shortcuts (declared first so the buttons stay on top and keep their clicks)
        //   middle click -> play / pause
        //   right click  -> raise the player window
        //   scroll       -> volume
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton | Qt.RightButton

            onClicked: mouse => {
                if (!root.player)
                    return;
                if (mouse.button === Qt.MiddleButton && root.canToggle)
                    root.player.togglePlaying();
                else if (mouse.button === Qt.RightButton && root.player.canRaise)
                    root.player.raise();
            }

            onWheel: wheel => {
                if (root.player && root.player.volumeSupported && root.player.canControl) {
                    const step = (wheel.angleDelta.y / 120) * 0.05;
                    root.player.volume = Math.max(0, Math.min(1, root.player.volume + step));
                }
            }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 9

            // Album art, falls back to the music note if there is no art or it fails to load
            Item {
                id: artBox
                width: 22
                height: 22
                anchors.verticalCenter: parent.verticalCenter

                readonly property bool hasArt: art.status === Image.Ready

                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(64, 64)
                    asynchronous: true
                    smooth: true
                    visible: false
                }

                // Rounded-corner mask for the art
                Rectangle {
                    id: artMask
                    anchors.fill: parent
                    radius: 6
                    layer.enabled: true
                    visible: false
                }

                MultiEffect {
                    anchors.fill: parent
                    source: art
                    maskEnabled: true
                    maskSource: artMask
                    visible: artBox.hasArt
                }

                Text {
                    anchors.centerIn: parent
                    visible: !artBox.hasArt
                    text: "♫"
                    color: Theme.blue
                    font.pixelSize: 12
                }
            }

            // Track details: shrinks to fit short titles, capped at maxTextWidth
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(Math.max(titleText.implicitWidth, artistText.implicitWidth),
                                root.maxTextWidth)
                spacing: 1

                Item {
                    id: titleClip
                    width: parent.width
                    height: titleText.implicitHeight
                    clip: true

                    readonly property bool overflow: titleText.implicitWidth > width
                    readonly property bool scrolling: overflow && titleHover.hovered

                    HoverHandler { id: titleHover }

                    Text {
                        id: titleText
                        x: 0
                        width: titleClip.scrolling ? implicitWidth : titleClip.width
                        text: root.songTitle
                        color: Theme.fg
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: titleClip.scrolling ? Text.ElideNone : Text.ElideRight

                        onTextChanged: x = 0
                    }

                    // Scroll to the end, pause, snap back, repeat (only while hovering a long title)
                    SequentialAnimation {
                        running: titleClip.scrolling
                        loops: Animation.Infinite

                        PauseAnimation { duration: 500 }
                        NumberAnimation {
                            target: titleText
                            property: "x"
                            to: -(titleText.implicitWidth - titleClip.width)
                            duration: Math.max(1, (titleText.implicitWidth - titleClip.width) * 25)
                            easing.type: Easing.Linear
                        }
                        PauseAnimation { duration: 700 }
                        PropertyAction { target: titleText; property: "x"; value: 0 }

                        onRunningChanged: if (!running) titleText.x = 0
                    }
                }

                Text {
                    id: artistText
                    width: parent.width
                    text: root.songArtist
                    color: Theme.fgDim
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                width: 2
                height: 23
                color: Theme.border
                anchors.verticalCenter: parent.verticalCenter
            }

            // Previous
            HoverButton {
                width: 26
                height: 26
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                mouseEnabled: root.canPrev
                onClicked: root.player.previous()

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: root.canPrev ? Theme.fgDim : Theme.muted
                    font.pixelSize: 18
                }
            }

            // Play / pause
            HoverButton {
                width: 26
                height: 26
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                baseColor: Theme.blue
                hoverColor: Theme.cyan
                mouseEnabled: root.canToggle
                onClicked: root.player.togglePlaying()
                readonly property bool playing: root.player && root.player.isPlaying

                Text {
                    anchors.centerIn: parent
                    text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                    color: Theme.bg
                }
            }

            // Next
            HoverButton {
                width: 26
                height: 26
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                mouseEnabled: root.canNext
                onClicked: root.player.next()

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: root.canNext ? Theme.fgDim : Theme.muted
                    font.pixelSize: 18
                }
            }
        }
    }
}