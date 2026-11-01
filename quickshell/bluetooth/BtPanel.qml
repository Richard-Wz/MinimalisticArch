import QtQuick
import Quickshell
import qs
import qs.bar
import qs.common

// Bluetooth panel: power, scan, connect / pair, forget.
PopupPanel {
    id: panel

    open: Bt.panelOpen
    onCloseRequested: Bt.panelOpen = false
    onOpenChanged: Bt.setScanning(open)      // scan while the panel is open

    cardWidth: 340
    cardHeight: Math.min(480, Math.max(150, 64 + list.contentHeight))

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        height: 26

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Bluetooth"
            color: Theme.fg
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
        }

        Row {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: 4

            // Scan on / off
            HoverButton {
                visible: Bt.powered
                width: 24
                height: 24
                radius: 8
                onClicked: Bt.setScanning(!Bt.adapter.discovering)

                Text {
                    anchors.centerIn: parent
                    text: "\uDB81\uDC50"      // nf-md-refresh (U+F0450)
                    color: Bt.adapter && Bt.adapter.discovering ? Theme.blue : Theme.fgDim
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }

            // Power on / off
            HoverButton {
                width: 24
                height: 24
                radius: 8
                onClicked: Bt.togglePower()

                Text {
                    anchors.centerIn: parent
                    // bluetooth (U+F00AF) / bluetooth-off (U+F00B2)
                    text: Bt.powered ? "\uDB80\uDCAF" : "\uDB80\uDCB2"
                    color: Bt.powered ? Theme.blue : Theme.muted
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize - 1
                }
            }
        }
    }

    ListView {
        id: list
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
            topMargin: 8
        }
        spacing: 2
        clip: true

        // connected first, then paired, then nearby; skip nameless (MAC-only) devices
        model: ScriptModel {
            values: {
                const a = Bt.adapter;
                if (!a || !a.enabled)
                    return [];
                return [...a.devices.values]
                    .filter(d => d.paired || d.connected
                        || (d.name && d.name.replace(/-/g, ":") !== d.address))
                    .sort((x, y) => (y.connected - x.connected)
                        || (y.paired - x.paired)
                        || x.name.localeCompare(y.name));
            }
        }

        delegate: BtRow {
            required property var modelData
            dev: modelData
            width: ListView.view.width
        }
    }

    Text {
        anchors.centerIn: list
        visible: list.count === 0
        text: !Bt.available ? "No Bluetooth adapter"
            : !Bt.powered ? "Bluetooth is off"
            : "Looking for devices"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 1
    }
}
