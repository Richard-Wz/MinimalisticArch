import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// Shared popup: transparent fullscreen overlay (click outside or Esc closes)
// with a card in the top-right corner, just under the bar.
PanelWindow {
    id: win

    property bool open: false
    property bool grabKeyboard: false   // true = exclusive keyboard focus (for search fields)
    property int cardWidth: 340
    property int cardHeight: 400
    property int topOffset: Theme.barHeight + 8
    property int rightOffset: 12        // same as the bar's right margin
    default property alias content: card.data

    signal closeRequested()

    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: !open ? WlrKeyboardFocus.None
        : grabKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
    anchors { top: true; bottom: true; left: true; right: true }

    Shortcut {
        sequence: "Escape"
        enabled: win.open
        onActivated: win.closeRequested()
    }

    // click outside the card -> close
    MouseArea {
        anchors.fill: parent
        onClicked: win.closeRequested()
    }

    Rectangle {
        id: card
        anchors {
            top: parent.top
            right: parent.right
            topMargin: win.topOffset
            rightMargin: win.rightOffset
        }
        width: win.cardWidth
        height: win.cardHeight
        radius: Theme.radius + 2
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        // swallow clicks inside the card
        MouseArea { anchors.fill: parent }
    }
}
