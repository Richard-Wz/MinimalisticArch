import QtQuick

// Small pictograms for the four projection modes (drawn, no icon font needed).
Item {
    id: root

    property string mode: "laptop"
    property color color: "white"
    property color bg: "black"      // row background, hides the back screen in "mirror"

    implicitWidth: 28
    implicitHeight: 20

    // PC screen only: laptop
    Item {
        visible: root.mode === "laptop"
        anchors.fill: parent
        Rectangle { x: 5; y: 2; width: 18; height: 11; radius: 2; color: "transparent"; border.width: 1.5; border.color: root.color }
        Rectangle { x: 1; y: 15; width: 26; height: 2; radius: 1; color: root.color }
    }

    // Second screen only: monitor with stand
    Item {
        visible: root.mode === "external"
        anchors.fill: parent
        Rectangle { x: 4; y: 1; width: 20; height: 12; radius: 2; color: "transparent"; border.width: 1.5; border.color: root.color }
        Rectangle { x: 12; y: 13; width: 4; height: 3; color: root.color }
        Rectangle { x: 8; y: 16; width: 12; height: 2; radius: 1; color: root.color }
    }

    // Extend: two screens side by side
    Item {
        visible: root.mode === "extend"
        anchors.fill: parent
        Rectangle { x: 1; y: 4; width: 12; height: 11; radius: 2; color: "transparent"; border.width: 1.5; border.color: root.color }
        Rectangle { x: 15; y: 4; width: 12; height: 11; radius: 2; color: "transparent"; border.width: 1.5; border.color: root.color }
    }

    // Duplicate: two overlapping screens
    Item {
        visible: root.mode === "mirror"
        anchors.fill: parent
        Rectangle { x: 2; y: 1; width: 16; height: 11; radius: 2; color: "transparent"; border.width: 1.5; border.color: root.color }
        Rectangle { x: 10; y: 7; width: 16; height: 11; radius: 2; color: root.bg; border.width: 1.5; border.color: root.color }
    }
}
