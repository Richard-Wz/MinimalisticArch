import QtQuick
import Quickshell
import qs
import qs.bar
import qs.common

// Clipboard history. Click (or Enter on the first match) copies the entry.
PopupPanel {
    id: panel

    open: Clip.panelOpen
    grabKeyboard: true
    onCloseRequested: Clip.panelOpen = false

    cardWidth: 340
    cardHeight: 420

    readonly property var filtered: Clip.entries.filter(
        e => e.text.toLowerCase().includes(search.text.toLowerCase()))

    function pick(entry) {
        Clip.copy(entry);
        Clip.panelOpen = false;
    }

    onOpenChanged: {
        if (open) {
            search.text = "";
            Clip.refresh();
            search.forceActiveFocus();
        }
    }

    Rectangle {
        id: searchBox
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
        height: 30
        radius: Theme.radius - 2
        color: Theme.surface
        border.width: search.activeFocus ? 1 : 0
        border.color: Theme.blue

        TextInput {
            id: search
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            selectionColor: Theme.blue
            selectedTextColor: Theme.bg
            font.pixelSize: Theme.fontSize - 1
            clip: true
            onAccepted: if (panel.filtered.length > 0) panel.pick(panel.filtered[0])

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: search.text === ""
                text: "Search clipboard"
                color: Theme.muted
                font.pixelSize: Theme.fontSize - 1
            }
        }
    }

    ListView {
        id: list
        anchors {
            top: searchBox.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
            topMargin: 8
        }
        spacing: 2
        clip: true
        model: panel.filtered

        delegate: Rectangle {
            id: row
            required property var modelData

            width: ListView.view.width
            height: 28
            radius: Theme.radius - 2
            color: rowHover.hovered ? Theme.hover : "transparent"

            HoverHandler { id: rowHover }
            MouseArea {
                anchors.fill: parent
                onClicked: panel.pick(row.modelData)
            }

            Text {
                anchors { fill: parent; leftMargin: 10; rightMargin: 34 }
                verticalAlignment: Text.AlignVCenter
                text: row.modelData.isImage ? "[ image ]" : row.modelData.text
                color: row.modelData.isImage ? Theme.muted : Theme.fg
                font.pixelSize: Theme.fontSize - 1
                elide: Text.ElideRight
            }

            HoverButton {
                visible: rowHover.hovered
                width: 22
                height: 22
                radius: 7
                anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                onClicked: Clip.remove(row.modelData)

                Text {
                    anchors.centerIn: parent
                    text: "\uDB80\uDDB4"   // nf-md-delete (U+F01B4)
                    color: Theme.red
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.fontSize + 1
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: panel.filtered.length === 0
        text: "Nothing here"
        color: Theme.muted
        font.pixelSize: Theme.fontSize - 1
    }
}
