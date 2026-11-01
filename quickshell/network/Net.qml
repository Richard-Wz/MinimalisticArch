pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

// Wi-Fi / ethernet state (NetworkManager via Quickshell.Networking).
Singleton {
    id: root

    property bool panelOpen: false

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected:
        devices.some(d => d.type === DeviceType.Wired && d.connected)
    readonly property var activeWifi: wifiDevice
        ? (wifiDevice.networks.values.find(n => n.connected) ?? null) : null

    // nf-md wifi-strength-1..4 (U+F091F, F0922, F0925, F0928)
    function signalIcon(s) {
        return s > 0.75 ? "\uDB82\uDD28"
             : s > 0.5  ? "\uDB82\uDD25"
             : s > 0.25 ? "\uDB82\uDD22"
             :            "\uDB82\uDD1F";
    }

    // Bar icon: ethernet wins, then Wi-Fi strength, then off / no-signal states
    readonly property string icon: {
        if (wiredConnected)
            return "\uDB80\uDE00";                  // nf-md-ethernet (U+F0200)
        if (!wifiDevice || !wifiEnabled)
            return "\uDB81\uDDAA";                  // nf-md-wifi_off (U+F05AA)
        if (!activeWifi)
            return "\uDB82\uDD2F";                  // nf-md-wifi_strength_outline (U+F092F)
        return signalIcon(activeWifi.signalStrength);
    }

    readonly property bool online: wiredConnected || activeWifi !== null

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function setScanning(on) {
        if (wifiDevice)
            wifiDevice.scannerEnabled = on;
    }
}
