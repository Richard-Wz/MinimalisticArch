import QtQuick
import Quickshell
import Quickshell.Networking
import qs
import qs.bar
import qs.common

// Wi-Fi / ethernet panel: toggle, scan, connect, forget.
PopupPanel {
    id: panel

    open: Net.panelOpen
    grabKeyboard: true                       // needed to type a Wi-Fi password
    onCloseRequested: Net.panelOpen = false
    onOpenChanged: Net.setScanning(open)     // scan while the panel is open

    cardWidth: 340
    cardHeight: Math.min(480, Math.max(150,
        64 + (Net.wiredConnected ? 36 : 0) + list.contentHeight))

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        height: 26

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Network"
            color: Theme.fg
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 4

            // Scan on / off
            HoverButton {
                visible: Net.wifiEnabled && Net.wifiDevice !== null
                width: 24
                height: 24
                radius: 8
                onClicked: Net.setScanning(!Net.wifiDevice.scannerEnabled)

                Text {
                    anchors.centerIn: parent
                    text: "\uDB81\uDC50"      // nf-md-refresh (U+F0450)
                    color: Net.wifiDevice && Net.wifiDevice.scannerEnabled ? Theme.blue : Theme.fgDim
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }

            // Wi-Fi on / off
            HoverButton {
                width: 24
                height: 24
                radius: 8
                onClicked: Net.toggleWifi()

                Text {
                    anchors.centerIn: parent
                    // wifi (U+F05A9) / wifi-off (U+F05AA)
                    text: Net.wifiEnabled ? "\uDB81\uDDA9" : "\uDB81\uDDAA"
                    color: Net.wifiEnabled ? Theme.blue : Theme.muted
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }
        }
    }

    Rectangle {
        id: wiredRow
        visible: Net.wiredConnected
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: 12
            topMargin: 8
        }
        height: visible ? 28 : 0
        radius: Theme.radius - 2
        color: Theme.surface

        Row {
            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
            spacing: 8

            Text {
                text: "\uDB80\uDE00"           // nf-md-ethernet (U+F0200)
                color: Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: Theme.iconSize
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Ethernet connected"
                color: Theme.fg
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }

    ListView {
        id: list
        anchors {
            top: wiredRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
            topMargin: 8
        }
        spacing: 2
        clip: true

        // connected first, then by signal strength
        model: ScriptModel {
            values: Net.wifiDevice && Net.wifiEnabled
                ? [...Net.wifiDevice.networks.values]
                    .filter(n => n.name !== "")
                    .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
                : []
        }

        delegate: WifiRow {
            required property var modelData
            net: modelData
            width: ListView.view.width
        }
    }

    Text {
        anchors.centerIn: list
        visible: list.count === 0
        text: !Net.wifiDevice ? "No Wi-Fi adapter"
            : !Net.wifiEnabled ? "Wi-Fi is off"
            : "Looking for networks"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 1
    }
}
