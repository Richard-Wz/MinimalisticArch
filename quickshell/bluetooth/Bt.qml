pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth state (BlueZ via Quickshell.Bluetooth).
Singleton {
    id: root

    property bool panelOpen: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property int connectedCount:
        adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    // Bar icon: off / connected / idle
    readonly property string icon: !powered ? "\uDB80\uDCB2"          // bluetooth-off (U+F00B2)
        : connectedCount > 0 ? "\uDB80\uDCB1"                         // bluetooth-connect (U+F00B1)
        : "\uDB80\uDCAF"                                              // bluetooth (U+F00AF)

    function togglePower() {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function setScanning(on) {
        if (adapter && adapter.enabled)
            adapter.discovering = on;
    }
}
