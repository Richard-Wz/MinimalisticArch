
import QtQuick
import Quickshell
import qs
import qs.common
import qs.projection

PopupPanel {
    id: panel

    open: Projection.panelOpen
    grabKeyboard: true

    onCloseRequested: Projection.panelOpen = false

    onOpenChanged: {
        if (open)
            keys.forceActiveFocus();
    }

    cardWidth: 320
    cardHeight: 64 + Projection.monitors.length * 52 + 8

    // -----------------------------------------
    // KEYBOARD CONTROLS
    // -----------------------------------------

    Item {
        id: keys

        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            const k = event.key;

            if (
                k === Qt.Key_Down ||
                k === Qt.Key_Tab ||
                k === Qt.Key_J
            ) {
                Projection.step(1);
                event.accepted = true;

            } else if (
                k === Qt.Key_Up ||
                k === Qt.Key_Backtab ||
                k === Qt.Key_K
            ) {
                Projection.step(-1);
                event.accepted = true;

            } else if (
                k === Qt.Key_Return ||
                k === Qt.Key_Enter ||
                k === Qt.Key_Space
            ) {
                Projection.applySelected();
                event.accepted = true;

            } else if (k === Qt.Key_Escape) {
                Projection.panelOpen = false;
                event.accepted = true;

            } else if (
                k === Qt.Key_R
            ) {
                Projection.refresh();
                event.accepted = true;
            }
        }
    }

    // -----------------------------------------
    // HEADER
    // -----------------------------------------

    Column {
        id: content

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 12
        }

        spacing: 10

        Row {
            width: parent.width
            spacing: 6

            Text {
                text: "Select Display"

                color: Theme.fg
                font.pixelSize: Theme.fontSize
                font.family: Theme.iconFont
                font.weight: Font.DemiBold
            }

            Item {
                width: 1
                height: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Projection.monitors.length + " detected"

                color: Theme.muted
                font.pixelSize: Theme.fontSize - 2
                font.family: Theme.iconFont
            }
        }

        // -------------------------------------
        // MONITOR LIST
        // -------------------------------------

        Column {
            id: monitorList

            width: parent.width
            spacing: 4

            Repeater {
                model: Projection.monitors

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    readonly property bool highlighted:
                        Projection.selected === index

                    readonly property bool isCurrent:
                        Projection.selectedMonitor === modelData.name

                    readonly property bool isDefault:
                        Projection.defaultMonitor === modelData.name

                    width: monitorList.width
                    height: 48

                    radius: Theme.radius - 2

                    color: highlighted
                        ? Theme.hover
                        : "transparent"

                    ModeIcon {
                        id: icon

                        anchors {
                            left: parent.left
                            leftMargin: 10
                            verticalCenter: parent.verticalCenter
                        }

                        mode: row.isDefault ? "default" : "external"

                        color: row.isCurrent
                            ? Theme.blue
                            : Theme.fgDim

                        bg: row.highlighted
                            ? Theme.hover
                            : Theme.bg
                    }

                    Column {
                        anchors {
                            left: icon.right
                            leftMargin: 12
                            right: status.left
                            rightMargin: 6
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 1

                        Text {
                            width: parent.width

                            text: modelData.description

                            color: row.isCurrent
                                ? Theme.blue
                                : Theme.fg

                            font.pixelSize: Theme.fontSize
                            font.family: Theme.iconFont
                            font.weight: Font.DemiBold

                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width

                            text: modelData.name
                                + " · "
                                + Projection.getResolution(modelData)
                                + (Projection.getRefreshRate(modelData) !== ""
                                    ? " · " + Projection.getRefreshRate(modelData)
                                    : "")

                            color: Theme.muted

                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fontSize - 2

                            elide: Text.ElideRight
                        }
                    }

                    Column {
                        id: status

                        anchors {
                            right: parent.right
                            rightMargin: 10
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 2

                        Text {
                            anchors.right: parent.right

                            visible: row.isCurrent

                            text: "\uDB80\uDD2C"

                            color: Theme.green

                            font.family: Theme.iconFont
                            font.pixelSize: Theme.iconSize
                        }

                        Text {
                            anchors.right: parent.right

                            visible: row.isDefault && !row.isCurrent

                            text: "DEFAULT"

                            color: Theme.muted

                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fontSize - 4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        hoverEnabled: true

                        onEntered: {
                            Projection.selected = row.index;
                        }

                        onClicked: {
                            Projection.apply(row.modelData.name);
                        }
                    }
                }
            }
        }

        // -------------------------------------
        // FOOTER
        // -------------------------------------

        Text {
            width: parent.width

            text: "↑ ↓ Navigate   Enter Select   Esc Close"

            color: Theme.muted

            font.pixelSize: Theme.fontSize - 3
            font.family: Theme.iconFont

            horizontalAlignment: Text.AlignHCenter
        }
    }
}
