import Quickshell
import qs.bar
import qs.notifications
import qs.clipboard
import qs.network
import qs.bluetooth
import qs.audio
import qs.projection

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // One instance each (not per screen). Referencing them here also starts the
    // notification server and the clipboard watchers.
    NotifToasts {}
    NotifPanel {}
    ClipPanel {}
    NetPanel {}
    BtPanel {}
    AudioPanel {}
    ProjectionPanel {}
}
