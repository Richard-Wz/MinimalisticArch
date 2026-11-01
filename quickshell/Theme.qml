// Tokyo-Night Theme Theme.qml

pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // Tokyo Night palette
    readonly property color bg: "#1a1b26"
    readonly property color surface: "#24283b"
    readonly property color hover: "#292e42"
    readonly property color border: "#414868"
    readonly property color fg: "#c0caf5"
    readonly property color fgDim: "#a9b1d6"
    readonly property color muted: "#565f89"
    readonly property color blue: "#7aa2f7"
    readonly property color cyan: "#7dcfff"
    readonly property color green: "#9ece6a"
    readonly property color yellow: "#e0af68"
    readonly property color red: "#f7768e"
    readonly property color redHover: "#3b2638"

    // Sizes
    readonly property int barHeight: 34
    readonly property int fontSize: 12
    readonly property int iconSize: 16
    readonly property int radius: 10

    // Icon Font
    readonly property string iconFont: "JetBrainsMono Nerd Font" 
}
