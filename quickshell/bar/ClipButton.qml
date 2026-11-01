import QtQuick
import qs
import qs.clipboard

Item {
    implicitWidth: btn.width
    implicitHeight: btn.height

    HoverButton {
        id: btn
        width: 26
        height: 26
        radius: Theme.radius
        onClicked: Clip.panelOpen = !Clip.panelOpen

        Text {
            anchors.centerIn: parent
            text: "\uDB80\uDD92"   // nf-md-content_paste (U+F0192)
            color: Clip.panelOpen ? Theme.blue : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
    }
}
