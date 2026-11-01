import QtQuick
import qs
import qs.bluetooth

Item {
    // no adapter -> no button (RowLayout skips invisible items)
    visible: Bt.available
    implicitWidth: visible ? btn.width : 0
    implicitHeight: btn.height

    HoverButton {
        id: btn
        width: 26
        height: 26
        radius: Theme.radius
        onClicked: Bt.panelOpen = !Bt.panelOpen

        Text {
            anchors.centerIn: parent
            text: Bt.icon
            color: !Bt.powered ? Theme.muted
                 : Bt.panelOpen || Bt.connectedCount > 0 ? Theme.blue
                 : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }
}
