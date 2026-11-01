pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon + shared state.
// Make sure no other daemon (dunst, mako, swaync...) is running.
Singleton {
    id: root

    property bool panelOpen: false
    property bool dnd: false           // do not disturb: no toasts (critical still shows)
    property var popups: []            // notifications currently shown as toasts

    readonly property var history: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    function dismissPopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function clearAll() {
        server.trackedNotifications.values.slice().forEach(n => n.dismiss());
        popups = [];
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;                                  // keep in history
            n.closed.connect(() => root.dismissPopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [...root.popups, n];
        }
    }
}
