
import QtQuick
import qs

// One output device. Click = make it the default output.
Rectangle {
    id: row

    required property var node
    readonly property bool current: Audio.sink !== null && Audio.sink?.id === node.id

    height: 28
    radius: Theme.radius - 2
    color: hover.hovered ? Theme.hover : "transparent"

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        onClicked: Audio.select(row.node)
    }

    // Output device icon — stays fixed while the name scrolls.
    // Fixed-width icon column for consistent alignment.
    Item {
        id: iconSlot

        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        width: 18
        height: parent.height

        Text {
            id: ico
            anchors.centerIn: parent

            text: Audio.nodeIcon(row.node)
            color: row.current ? Theme.blue : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }

    // Device name — scroll horizontally on hover if it overflows.
    Item {
        id: titleClip

        anchors {
            left: iconSlot.right
            leftMargin: 8
            right: check.left
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }

        height: parent.height
        clip: true

        readonly property bool overflow:
            titleText.implicitWidth > width

        readonly property bool scrolling:
            overflow && hover.hovered

        Text {
            id: titleText

            x: 0
            anchors.verticalCenter: parent.verticalCenter

            width: titleClip.scrolling
                ? implicitWidth
                : titleClip.width

            text: Audio.nodeName(row.node)
            color: row.current ? Theme.blue : Theme.fg
            font.pixelSize: Theme.fontSize - 1
            font.weight: row.current ? Font.DemiBold : Font.Normal

            elide: titleClip.scrolling
                ? Text.ElideNone
                : Text.ElideRight

            onTextChanged: x = 0
        }

        SequentialAnimation {
            running: titleClip.scrolling
            loops: Animation.Infinite

            // Pause before scrolling.
            PauseAnimation {
                duration: 500
            }

            // Scroll to the end of the device name.
            NumberAnimation {
                target: titleText
                property: "x"
                to: -(titleText.implicitWidth - titleClip.width)
                duration: Math.max(
                    1,
                    (titleText.implicitWidth - titleClip.width) * 25
                )
                easing.type: Easing.Linear
            }

            // Pause at the end.
            PauseAnimation {
                duration: 700
            }

            // Return to the beginning.
            PropertyAction {
                target: titleText
                property: "x"
                value: 0
            }

            onRunningChanged: {
                if (!running)
                    titleText.x = 0
            }
        }
    }

    // Checkmark — remains fixed on the right.
    Text {
        id: check

        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }

        visible: row.current
        text: "\uDB80\uDD2C" // nf-md-check (U+F012C)
        color: Theme.green
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize - 2
    }
}
