import QtQuick
import qs
import qs.notifications

Item {
    implicitWidth: btn.width
    implicitHeight: btn.height

    HoverButton {
        id: btn
        width: 26
        height: 26
        radius: Theme.radius
        onClicked: Notifs.panelOpen = !Notifs.panelOpen

        Text {
            anchors.centerIn: parent
            // bell-off (U+F009B) / bell (U+F009A)
            text: Notifs.dnd ? "\uDB80\uDC9B" : "\uDB80\uDC9A"
            color: Notifs.dnd ? Theme.yellow
                 : Notifs.panelOpen || Notifs.count > 0 ? Theme.blue
                 : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }

        // small dot when there is something in the history
        Rectangle {
            visible: Notifs.count > 0 && !Notifs.dnd
            width: 6
            height: 6
            radius: 3
            color: Theme.red
            anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 4 }
        }
    }
}
