
// TrayApps.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs
import qs.bar
import qs.common

Item {
    id: root

    property bool popupOpen: false

    readonly property int trayCount: SystemTray.items.values.length

    implicitWidth: 26
    implicitHeight: 26
    visible: true

    // System tray button
    HoverButton {
        anchors.fill: parent
        radius: 10

        onClicked: root.popupOpen = !root.popupOpen

        Text {
            anchors.centerIn: parent
            text: "󰕰"
            color: root.popupOpen ? Theme.blue : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }

    // Background applications panel
    PopupPanel {
        id: panel

        open: root.popupOpen
        grabKeyboard: false

        onCloseRequested: root.popupOpen = false

        cardWidth: 340
        cardHeight: Math.min(420, Math.max(110, 64 + list.contentHeight))

        // Header
        Item {
            id: header

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 12
            }

            height: 26

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: "Background applications"
                color: Theme.fg
                font.pixelSize: Theme.fontSize
                font.family: Theme.iconFont
                font.weight: Font.DemiBold
            }

            Text {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                text: trayCount + " running"
                color: Theme.muted
                font.family: Theme.iconFont
                font.pixelSize: Theme.fontSize - 2
            }
        }

        // Application list
        ListView {
            id: list

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 12
                topMargin: 8
            }

            spacing: 2
            clip: true
            model: SystemTray.items

            delegate: Item {
                id: appRow

                required property var modelData

                width: ListView.view.width
                height: 36

                Rectangle {
                    anchors.fill: parent

                    radius: Theme.radius - 2
                    color: appMouse.containsMouse
                        ? Theme.surface : "transparent"

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 8
                            rightMargin: 8
                        }

                        spacing: 10

                        // Application icon
                        Image {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20

                            source: appRow.modelData.icon
                            sourceSize.width: 32
                            sourceSize.height: 32
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        // Application name
                        Text {
                            Layout.fillWidth: true

                            text: appRow.modelData.title
                                || appRow.modelData.tooltipTitle
                                || appRow.modelData.id

                            color: Theme.fg
                            font.pixelSize: Theme.fontSize - 1
                            font.family: Theme.iconFont
                            elide: Text.ElideRight
                        }

                        // Open application
                        HoverButton {
                            Layout.preferredWidth: 52
                            Layout.preferredHeight: 25
                            radius: 6

                            onClicked: {
                                appRow.modelData.activate()
                                root.popupOpen = false
                            }

                            Text {
                                anchors.centerIn: parent

                                text: "Open"
                                color: Theme.blue
                                font.pixelSize: Theme.fontSize - 2
                                font.family: Theme.iconFont
                            }
                        }
                    }
                }

                MouseArea {
                    id: appMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    z: -1
                }
            }
        }

        // Empty state
        Text {
            anchors.centerIn: list

            visible: list.count === 0
            text: "No background applications"
            font.family: Theme.iconFont
            color: Theme.muted
            font.pixelSize: Theme.fontSize - 1
        }
    }
}
