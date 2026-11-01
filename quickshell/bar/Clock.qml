import QtQuick
import Quickshell
import qs

Text {
    text: Qt.formatDateTime(clock.date, "dd:MM:yyyy | hh:mm AP")
    color: Theme.fg
    font.pixelSize: Theme.fontSize
    font.weight: Font.Medium

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
