import QtQuick
import Quickshell
import qs
import qs.common
import qs.projection

// Alt+P popup: pick how the laptop screen and the external monitor are used.
// Keys: Up/Down/Tab or Alt+P again = move, Enter/Space = apply, 1-4 = apply directly, Esc = close.
PopupPanel {
    id: panel

    open: Projection.panelOpen
    grabKeyboard: true
    onCloseRequested: Projection.panelOpen = false
    onOpenChanged: {
        if (open)
            keys.forceActiveFocus();
    }

    cardWidth: 300
    cardHeight: 56 + Projection.modes.length * 52 + 8

    Item {
        id: keys
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            const k = event.key;
            if (k === Qt.Key_Down || k === Qt.Key_Tab || k === Qt.Key_J) {
                Projection.step(1);
                event.accepted = true;
            } else if (k === Qt.Key_Up || k === Qt.Key_Backtab || k === Qt.Key_K) {
                Projection.step(-1);
                event.accepted = true;
            } else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
                Projection.apply(Projection.modes[Projection.selected].id);
                event.accepted = true;
            } else if (k >= Qt.Key_1 && k < Qt.Key_1 + Projection.modes.length) {
                Projection.apply(Projection.modes[k - Qt.Key_1].id);
                event.accepted = true;
            }
        }
    }

    Text {
        id: title
        anchors { top: parent.top; left: parent.left; topMargin: 12; leftMargin: 12 }
        text: "Project"
        color: Theme.fg
        font.pixelSize: Theme.fontSize
        font.weight: Font.DemiBold
    }

    Column {
        id: modeList
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            margins: 12
            topMargin: 12
        }
        spacing: 4

        Repeater {
            model: Projection.modes

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                readonly property bool available: Projection.modeAvailable(modelData.id)
                readonly property bool highlighted: Projection.selected === index
                readonly property bool isCurrent: Projection.current === modelData.id

                width: modeList.width
                height: 48
                radius: Theme.radius - 2
                color: highlighted ? Theme.hover : "transparent"
                opacity: available ? 1 : 0.4

                ModeIcon {
                    id: icon
                    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    mode: row.modelData.id
                    color: row.isCurrent ? Theme.blue : Theme.fgDim
                    bg: row.highlighted ? Theme.hover : Theme.bg
                }

                Column {
                    anchors {
                        left: icon.right
                        leftMargin: 14
                        right: check.left
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 1

                    Text {
                        width: parent.width
                        text: row.modelData.title
                        color: row.isCurrent ? Theme.blue : Theme.fg
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: row.available ? row.modelData.subtitle : "No external display"
                        color: Theme.muted
                        font.pixelSize: Theme.fontSize - 2
                        elide: Text.ElideRight
                    }
                }

                Text {
                    id: check
                    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                    visible: row.isCurrent
                    text: "\uDB80\uDD2C"          // nf-md-check (U+F012C)
                    color: Theme.green
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.iconSize
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: row.available
                    hoverEnabled: true
                    onEntered: Projection.selected = row.index
                    onClicked: Projection.apply(row.modelData.id)
                }
            }
        }
    }
}
