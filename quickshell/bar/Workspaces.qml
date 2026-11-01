import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs

Item {
    id: root

    property int activeIndex: 0

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    RowLayout {
        id: row
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: 3

        Repeater {
            id: repeater
            model: Hyprland.workspaces

            delegate: HoverButton {
                id: ws

                required property var modelData
                required property int index

                readonly property bool active:
                    Hyprland.focusedWorkspace?.id === modelData.id

                implicitWidth: 32
                implicitHeight: 28
                radius: 5

                // Keep the sliding pill pointed at the focused workspace
                onActiveChanged: if (active) root.activeIndex = index
                Component.onCompleted: if (active) root.activeIndex = index

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                    } else if (mouse.button === Qt.RightButton) {
                        Hyprland.dispatch("hl.dsp.window.move({ workspace = " + modelData.id + " })")
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: ws.modelData.id
                    color: ws.active ? Theme.blue
                         : ws.hovered ? Theme.cyan
                         : Theme.fgDim
                    font.pixelSize: Theme.fontSize
                    font.weight: ws.active ? Font.DemiBold : Font.Normal

                    Behavior on color { ColorAnimation { duration: 140 } }
                }
            }
        }
    }

    // Sliding pill indicator
    Rectangle {
        id: pill
        width: 12
        height: 2
        radius: 2
        color: Theme.blue
        y: row.height

        x: {
            void repeater.count
            const item = repeater.itemAt(root.activeIndex)
            return item ? item.x + (item.width - width) / 2 : 0
        }

        Behavior on x {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }
}
