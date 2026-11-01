import QtQuick
import qs

// Generic hoverable, clickable rectangle. Put content (Text, RowLayout...) inside it.
Rectangle {
    id: root

    property color baseColor: "transparent"
    property color hoverColor: Theme.hover
    property alias mouseEnabled: mouse.enabled
    readonly property bool hovered: mouse.containsMouse

    signal clicked(var mouse)
    signal wheel(var wheel)

    radius: Theme.radius
    color: hovered ? hoverColor : baseColor

    Behavior on color {
        ColorAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: m => root.clicked(m)
        onWheel: w => root.wheel(w)
    }
}
