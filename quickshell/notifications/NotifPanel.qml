import QtQuick
import Quickshell
import qs
import qs.bar
import qs.common

// Notification history, opened from the bar button.
PopupPanel {
    id: panel

    open: Notifs.panelOpen
    onCloseRequested: Notifs.panelOpen = false

    cardWidth: 340
    cardHeight: Math.min(480, Math.max(110, 62 + list.contentHeight))

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        height: 26

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Notifications"
            color: Theme.fg
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 4

            // Do not disturb
            HoverButton {
                width: 24
                height: 24
                radius: 8
                onClicked: Notifs.dnd = !Notifs.dnd

                Text {
                    anchors.centerIn: parent
                    // bell-off (U+F009B) / bell (U+F009A)
                    text: Notifs.dnd ? "\uDB80\uDC9B" : "\uDB80\uDC9A"
                    color: Notifs.dnd ? Theme.yellow : Theme.fgDim
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }

            // Clear all
            HoverButton {
                width: 24
                height: 24
                radius: 8
                onClicked: Notifs.clearAll()

                Text {
                    anchors.centerIn: parent
                    text: "\uDB80\uDF9F"   // nf-md-notification_clear_all (U+F039F)
                    color: Theme.fgDim
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }
        }
    }

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
        spacing: 8
        clip: true

        // newest first
        model: ScriptModel { values: [...Notifs.history.values].reverse() }

        delegate: NotifCard {
            required property var modelData
            notif: modelData
            width: ListView.view.width
        }
    }

    Text {
        anchors.centerIn: parent
        visible: Notifs.count === 0
        text: "No notifications"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 1
    }
}
