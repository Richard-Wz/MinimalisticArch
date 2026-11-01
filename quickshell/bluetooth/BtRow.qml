import QtQuick
import qs
import qs.bar

// One Bluetooth device. Click = connect / disconnect / pair. Hover = forget (if paired).
Rectangle {
    id: row

    required property var dev

    height: 28
    radius: Theme.radius - 2
    color: hover.hovered ? Theme.hover : "transparent"

    function activate() {
        if (dev.connected)
            dev.disconnect();
        else if (dev.paired)
            dev.connect();
        else
            dev.pair();
    }

    // After a fresh pairing: trust it (so it can reconnect by itself) and connect
    Connections {
        target: row.dev
        function onPairedChanged() {
            if (row.dev.paired) {
                row.dev.trusted = true;
                row.dev.connect();
            }
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        onClicked: row.activate()
    }

    Text {
        id: ico
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
        // bluetooth-connect (U+F00B1) / bluetooth (U+F00AF)
        text: row.dev.connected ? "\uDB80\uDCB1" : "\uDB80\uDCAF"
        color: row.dev.connected ? Theme.blue : row.dev.paired ? Theme.fgDim : Theme.muted
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
    }

    Text {
        anchors {
            left: ico.right
            leftMargin: 8
            right: tail.left
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }
        text: row.dev.name
        color: row.dev.connected ? Theme.blue : Theme.fg
        font.pixelSize: Theme.fontSize - 1
        font.weight: row.dev.connected ? Font.DemiBold : Font.Normal
        elide: Text.ElideRight
    }

    Row {
        id: tail
        anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
        height: 22                      // fixed height, so the row never resizes
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: row.dev.pairing
            text: "pairing…"
            color: Theme.muted
            font.pixelSize: Theme.fontSize - 3
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: row.dev.connected && row.dev.batteryAvailable
            text: Math.round(row.dev.battery * 100) + "%"
            color: Theme.fgDim
            font.pixelSize: Theme.fontSize - 3
        }
        HoverButton {
            visible: row.dev.paired
            opacity: hover.hovered ? 1 : 0
            enabled: hover.hovered
            width: 22
            height: 22
            radius: 7
            onClicked: row.dev.forget()

            Text {
                anchors.centerIn: parent
                text: "\uDB80\uDDB4"      // nf-md-delete (U+F01B4)
                color: Theme.red
                font.family: Theme.iconFont
                font.pixelSize: Theme.fontSize + 1
            }
        }
    }
}
