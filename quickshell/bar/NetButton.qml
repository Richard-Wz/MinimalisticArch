import QtQuick
import qs
import qs.network

Item {
    implicitWidth: btn.width
    implicitHeight: btn.height

    HoverButton {
        id: btn
        width: 26
        height: 26
        radius: Theme.radius
        onClicked: Net.panelOpen = !Net.panelOpen

        Text {
            anchors.centerIn: parent
            text: Net.icon
            color: Net.panelOpen || Net.online ? Theme.blue : Theme.muted
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }
}
