import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Controls

RowLayout {
    id: root
    property int value: 5
    property int min: 0
    property int max: 10
    property int lineNb: 1
    property int maxNbChars: 10
    property string fontFamily: "Pixelon"
    property real fontSize: 10
    property int fontWeight: 500
    property color color: "white"
    property string character: "|"
    property int loaded: loadedValue()
    property int empty: emptyValue()

    spacing: 0

    Text {
        id: loadedPortion
        text: {
            var txt = root.character.repeat(root.loaded);
            var txt2 = "\n" + txt;
            return txt + (txt2).repeat(root.lineNb - 1);
        }
        color: root.color
        font.family: root.fontFamily
        font.pointSize: root.fontSize
        font.weight: root.fontWeight
    }

    Text {
        id: emptyPortion
        text: {
            var txt = root.character.repeat(root.empty);
            var txt2 = "\n" + txt;
            return txt + (txt2).repeat(root.lineNb - 1);
        }
        color: root.color
        font.family: root.fontFamily
        font.pointSize: root.fontSize
        font.weight: root.fontWeight
        opacity: 0.4
    }

    function loadedValue() {
        var nbChars = value / max;
        nbChars *= maxNbChars;
        nbChars = Math.floor(nbChars);
        return nbChars;
    }

    function emptyValue() {
        var nbChars = maxNbChars - loadedValue();
        return nbChars;
    }
}
