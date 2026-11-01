import QtQuick
import Quickshell.Services.UPower
import qs

HoverButton {
    id: root
    
    //skip Performance if the hardware/driver does not offer it
    readonly property var profiles: PowerProfiles.hasPerformanceProfile
    ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    : [PowerProfile.PowerSaver, PowerProfile.Balanced]

    function iconFor(p) {
        if (p === PowerProfile.PowerSaver) return "󰌪"
        if (p === PowerProfile.Performance) return "󰓅"
        return "󰾅"
    }

    function colorFor(p) {
        if (p === PowerProfile.PowerSaver) return Theme.green
        if (p === PowerProfile.Performance) return Theme.red
        return Theme.blue
    }

    implicitWidth: 26
    implicitHeight: 26

    // Left click: next profile. Right click: previous profile 
    onClicked: mouse => {
        const step = mouse.button === Qt.RightButton ? -1 : 1
        const i = profiles.indexOf(PowerProfiles.profile)
        const n = profiles.length
        PowerProfiles.profile = profiles[(i + step + n) % n]
    }

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 0.5
        text: root.iconFor(PowerProfiles.profile)
        color: root.colorFor(PowerProfiles.profile)
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize
        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }
}