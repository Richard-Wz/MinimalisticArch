// Bar.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.music

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    color: Theme.bg
    implicitHeight: Theme.barHeight

    // LEFT
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        Clock {}
        MusicPill { Layout.alignment: Qt.AlignVCenter }
    }

    // CENTER
    Workspaces {
        anchors.centerIn: parent
    }

    // RIGHT
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        NetButton { Layout.alignment: Qt.AlignVCenter }
        BtButton { Layout.alignment: Qt.AlignVCenter }
        NotifButton { Layout.alignment: Qt.AlignVCenter }
        ClipButton { Layout.alignment: Qt.AlignVCenter }
        Volume {}
        PowerMode {}
        PowerMenu {}
        Battery {}
    }
}