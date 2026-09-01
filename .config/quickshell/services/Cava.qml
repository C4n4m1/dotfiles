pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Mpris
import qs.assets
import qs.services

Singleton {
    id: root

    property int lenght: 6
    property list<int> array: new Array(lenght).fill(0)
    property var player: MprisService.activePlayer
    property string cavaCmd: `printf '[general]\\nmode=normal\\nframerate=25\\nautosens=0\\nsensitivity=30\\nbars=${lenght}\\nlower_cutoff_freq=50\\nhigher_cutoff_freq=12000\\n[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nchannels=mono\\nmono_option=average\\n[smoothing]\\nnoise_reduction=45\\nintegral=90\\ngravity=95\\nignore=2\\nmonstercat=1.5' | cava -p /dev/stdin`

    Process {
        id: cavaProcess
        running: root.player != null
        command: ["sh", "-c", cavaCmd]

        onRunningChanged: {
            if (!running) {
                root.array = Array(root.lenght).fill(0);
            }
        }

        stdout: SplitParser {
            onRead: data => {
                root.array = data.split(";").filter(x => x != "").map(x => parseInt(x));
            }
        }
    }
}
