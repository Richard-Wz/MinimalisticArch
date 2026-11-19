
import QtQuick

Item {
    id: root

    property string mode: "default"
    property color color: "white"
    property color bg: "black"

    implicitWidth: 28
    implicitHeight: 20

    // Default display
    Item {
        visible: root.mode === "default"
        anchors.fill: parent

        Rectangle {
            x: 4
            y: 1
            width: 20
            height: 13
            radius: 2
            color: "transparent"
            border.width: 1.5
            border.color: root.color
        }

        Rectangle {
            x: 12
            y: 14
            width: 4
            height: 3
            color: root.color
        }

        Rectangle {
            x: 8
            y: 17
            width: 12
            height: 2
            radius: 1
            color: root.color
        }
    }

    // External display
    Item {
        visible: root.mode === "external"
        anchors.fill: parent

        Rectangle {
            x: 4
            y: 1
            width: 20
            height: 13
            radius: 2
            color: "transparent"
            border.width: 1.5
            border.color: root.color
        }

        Rectangle {
            x: 12
            y: 14
            width: 4
            height: 3
            color: root.color
        }

        Rectangle {
            x: 8
            y: 17
            width: 12
            height: 2
            radius: 1
            color: root.color
        }

        Rectangle {
            x: 21
            y: 0
            width: 5
            height: 5
            radius: 2.5
            color: root.color
        }
    }
}
