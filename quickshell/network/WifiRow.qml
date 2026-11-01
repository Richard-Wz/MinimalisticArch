import QtQuick
import Quickshell.Networking
import qs
import qs.bar

// One Wi-Fi network. Click = connect / disconnect. Hover = forget (if saved).
Rectangle {
    id: row

    required property var net
    property bool asking: false      // password box visible
    property bool failed: false

    readonly property bool secured: net.security !== WifiSecurityType.Open
    readonly property bool needsPsk: net.security === WifiSecurityType.WpaPsk
        || net.security === WifiSecurityType.Wpa2Psk
        || net.security === WifiSecurityType.Sae

    height: asking ? 28 + 36 : 28
    radius: Theme.radius - 2
    color: hover.hovered && !asking ? Theme.hover : "transparent"
    clip: true

    Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    function activate() {
        if (net.connected) {
            net.disconnect();
            return;
        }
        failed = false;
        if (net.known || !needsPsk) {
            net.connect();
            return;
        }
        asking = true;
        pw.forceActiveFocus();
    }

    function submit() {
        if (pw.text === "")
            return;
        failed = false;
        net.connectWithPsk(pw.text);
        pw.text = "";
        asking = false;
    }

    // Saved password was wrong / missing: ask again
    Connections {
        target: row.net
        function onConnectionFailed() {
            row.failed = true;
            if (row.needsPsk) {
                row.asking = true;
                pw.forceActiveFocus();
            }
        }
    }

    HoverHandler { id: hover }

    Item {
        id: top
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 28

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (row.asking)
                    row.asking = false;
                else
                    row.activate();
            }
        }

        Text {
            id: sig
            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
            text: Net.signalIcon(row.net.signalStrength)
            color: row.net.connected ? Theme.blue : Theme.fgDim
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }

        Text {
            anchors {
                left: sig.right
                leftMargin: 8
                right: tail.left
                rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            text: row.net.name
            color: row.net.connected ? Theme.blue : Theme.fg
            font.pixelSize: Theme.fontSize - 1
            font.weight: row.net.connected ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }

        Row {
            id: tail
            anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
            spacing: 6

            Text {
                visible: row.net.stateChanging
                text: "…"
                color: Theme.muted
                font.pixelSize: Theme.fontSize
            }
            Text {
                visible: row.net.connected && !row.net.stateChanging
                text: "\uDB80\uDD2C"          // nf-md-check (U+F012C)
                color: Theme.green
                font.family: Theme.iconFont
                font.pixelSize: Theme.iconSize - 2
            }
            Text {
                visible: row.secured && !row.net.connected && !row.net.known
                text: "\uDB80\uDF3E"          // nf-md-lock (U+F033E)
                color: Theme.muted
                font.family: Theme.iconFont
                font.pixelSize: Theme.iconSize - 4
            }
            HoverButton {
                visible: hover.hovered && row.net.known
                width: 22
                height: 22
                radius: 7
                onClicked: row.net.forget()

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

    // Password box (unsaved secured networks)
    Rectangle {
        visible: row.asking
        anchors {
            top: top.bottom
            left: parent.left
            right: parent.right
            leftMargin: 8
            rightMargin: 8
        }
        height: 28
        radius: Theme.radius - 2
        color: Theme.bg
        border.width: 1
        border.color: row.failed ? Theme.red : Theme.blue

        TextInput {
            id: pw
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            color: Theme.fg
            selectionColor: Theme.blue
            selectedTextColor: Theme.bg
            font.pixelSize: Theme.fontSize - 1
            clip: true
            onAccepted: row.submit()

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: pw.text === ""
                text: row.failed ? "Couldn't connect, try again" : "Password, Enter to connect"
                color: row.failed ? Theme.red : Theme.muted
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }
}
