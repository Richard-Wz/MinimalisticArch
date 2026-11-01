import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// Popup toasts, top-right under the bar.
PanelWindow {
    visible: Notifs.popups.length > 0 && !Notifs.panelOpen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 8; right: 12 }

    implicitWidth: 320
    implicitHeight: Math.max(1, toastColumn.implicitHeight)

    Column {
        id: toastColumn
        width: parent.width
        spacing: 8

        Repeater {
            model: ScriptModel { values: Notifs.popups }

            delegate: NotifCard {
                required property var modelData
                notif: modelData
                toast: true
                width: toastColumn.width
            }
        }
    }
}
