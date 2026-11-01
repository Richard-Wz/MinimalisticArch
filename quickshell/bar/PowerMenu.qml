import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Item {
    id: root

    property bool open: false
    readonly property var barWindow: QsWindow.window

    implicitWidth: 26
    implicitHeight: 26

    // Power button
    HoverButton {
        anchors.fill: parent
        radius: 10
        onClicked: root.open = !root.open

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            anchors.horizontalCenterOffset: 1
            text: "󰐥" 
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize + 1
            color: parent.hovered ? Theme.red : Theme.blue

            Behavior on color { ColorAnimation { duration: 140 } }
        }
    }

    // Popup, drawn outside the bar's height
    PopupWindow {
        color: "transparent"

        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow ? root.barWindow.width - width - 12 : 0
        anchor.rect.y: root.barWindow ? root.barWindow.height + 6 : 0

        implicitWidth: 190
        implicitHeight: column.implicitHeight + 16

        visible: root.open
        grabFocus: true

        onVisibleChanged: {
            if (!visible && root.open)
                root.open = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Theme.bg
            border.width: 1
            border.color: Theme.border

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 8
                spacing: 3

                Text {
                    text: "SESSION"
                    color: Theme.muted
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    Layout.leftMargin: 9
                    Layout.topMargin: 2
                    Layout.bottomMargin: 3
                }

                // Add or remove entries here
                Repeater {
                    model: [
                        { label: "Lock screen", icon: "󰌾", color: Theme.cyan,   cmd: ["hyprlock"] },
                        { label: "Reboot",      icon: "󰜉", color: Theme.yellow, cmd: ["systemctl", "reboot"] },
                        { label: "Power off",   icon: "󰐥", color: Theme.red,    cmd: ["systemctl", "poweroff"], danger: true }
                    ]

                    delegate: HoverButton {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        hoverColor: modelData.danger ? Theme.redHover : Theme.hover

                        onClicked: {
                            root.open = false
                            Quickshell.execDetached(modelData.cmd)
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 10

                            Text {
                                text: modelData.icon
                                color: modelData.color
                                font.pixelSize: Theme.iconSize
                            }

                            Text {
                                text: modelData.label
                                color: modelData.danger ? Theme.red : Theme.fg
                                font.pixelSize: Theme.fontSize
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
