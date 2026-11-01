import QtQuick
import Quickshell.Services.Notifications
import qs
import qs.bar

// One notification. Used for both toasts and the history list.
Rectangle {
    id: card

    required property var notif
    property bool toast: false

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical

    height: col.implicitHeight + 20
    radius: Theme.radius
    color: Theme.surface
    border.width: 1
    border.color: critical ? Theme.red : Theme.border

    // Toasts auto-hide (critical ones stay until dismissed). History keeps them.
    Timer {
        running: card.toast && !card.critical
        interval: card.notif.expireTimeout > 0 ? card.notif.expireTimeout * 1000 : 5000
        onTriggered: Notifs.dismissPopup(card.notif)
    }

    Column {
        id: col
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
        spacing: 2

        Item {
            width: parent.width
            height: 20

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 28
                text: card.notif.appName
                color: Theme.muted
                font.pixelSize: Theme.fontSize - 3
                elide: Text.ElideRight
            }

            HoverButton {
                width: 20
                height: 20
                radius: 6
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    if (card.toast)
                        Notifs.dismissPopup(card.notif);
                    else
                        card.notif.dismiss();
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uDB80\uDD56"   // nf-md-close (U+F0156)
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.fontSize
                    color: Theme.fgDim
                }
            }
        }

        Text {
            width: parent.width
            text: card.notif.summary
            color: Theme.fg
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: card.notif.body
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 2
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Row {
            spacing: 6
            visible: card.notif.actions.length > 0

            Repeater {
                model: card.notif.actions

                delegate: Rectangle {
                    id: actionBtn
                    required property var modelData
                    visible: modelData.text !== ""
                    height: 20
                    width: label.implicitWidth + 16
                    radius: 6
                    color: actionMouse.containsMouse ? Theme.border : Theme.hover

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: actionBtn.modelData.text
                        color: Theme.fg
                        font.pixelSize: Theme.fontSize - 3
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: actionBtn.modelData.invoke()
                    }
                }
            }
        }
    }
}
