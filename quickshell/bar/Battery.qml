import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Services.UPower
import qs

// Horizontal battery, Android style: outline + nub on the right, fill follows the
// level, number drawn inside (dark on the filled part, light on the empty part).
RowLayout {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property real level: Math.max(0, Math.min(1, device?.percentage ?? 0))
    readonly property bool charging:
        device?.state === UPowerDeviceState.Charging
        || device?.state === UPowerDeviceState.FullyCharged
        || device?.state === UPowerDeviceState.PendingCharge

    readonly property color fillColor: {
        if (charging) return Theme.green
        if (level <= 0.15) return Theme.red
        if (level <= 0.30) return Theme.yellow
        return Theme.green
    }

    readonly property string label: Math.round(level * 100).toString()

    spacing: 4

    // charging bolt (only while plugged in)
    Shape {
        visible: root.charging
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 8
        Layout.preferredHeight: 12

        ShapePath {
            fillColor: Theme.green
            strokeColor: "transparent"
            startX: 5
            startY: 0
            PathLine { x: 0; y: 7 }
            PathLine { x: 3.5; y: 7 }
            PathLine { x: 2.5; y: 12 }
            PathLine { x: 8; y: 4.5 }
            PathLine { x: 4.5; y: 4.5 }
            PathLine { x: 5; y: 0 }
        }
    }

    Item {
        id: battery
        Layout.alignment: Qt.AlignVCenter

        readonly property real pad: 2.5          // gap between outline and fill
        implicitWidth: body.width + nub.width + 1
        implicitHeight: body.height

        // outline + empty area
        Rectangle {
            id: body
            width: 32
            height: 16
            radius: 4
            color: Theme.surface
            border.width: 1.5
            border.color: Theme.fgDim
        }

        // terminal nub
        Rectangle {
            id: nub
            x: body.width + 1
            anchors.verticalCenter: body.verticalCenter
            width: 2.5
            height: 6
            radius: 1
            color: Theme.fgDim
        }

        // inner area: fill + number
        Item {
            id: inner
            x: battery.pad
            y: battery.pad
            width: body.width - 2 * battery.pad
            height: body.height - 2 * battery.pad

            Rectangle {
                id: fillRect
                width: root.level * inner.width
                height: inner.height
                radius: 2
                color: root.fillColor
            }

            // number on the filled part (dark)
            Item {
                width: fillRect.width
                height: inner.height
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: (inner.width - width) / 2
                    text: root.label
                    color: Theme.bg
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Font.Bold
                }
            }

            // number on the empty part (light)
            Item {
                x: fillRect.width
                width: inner.width - fillRect.width
                height: inner.height
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: (inner.width - width) / 2 - fillRect.width
                    text: root.label
                    color: Theme.fg
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Font.Bold
                }
            }
        }
    }
}
