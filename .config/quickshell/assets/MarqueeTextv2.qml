import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string text: "This is a smooth marquee text scrolling endlessly in QML 🚀"
    property int speed: 40   // pixels per second
    property int spacing: 50 // space between repetitions
    property int pauseDuration: 5000

    // font customization
    property int pixelSize: 14
    property string family: "Inter Medium"
    property int weight: 600
    property color textColor: "white"

    property bool animationEnabled: text1.contentWidth > width
    anchors.verticalCenter: parent.verticalCenter

    // compute total width dynamically
    width: text1.width + text2.width + spacing

    // Animation that loops forever
    SequentialAnimation on x {
        loops: root.animationEnabled ? Animation.Infinite : 0

        // scroll left
        NumberAnimation {
            from: 0
            to: -text1.width - root.spacing
            duration: (text1.width + root.spacing) * 1000 / root.speed
            easing.type: Easing.Linear
        }

        // pause when reset
        PauseAnimation {
            duration: root.pauseDuration
        }

        // reset position instantly before restarting
        PropertyAction {
            property: "x"
            value: 0
        }
    }

    // first copy of the text
    Text {
        id: text1
        // visible: root.animationEnabled
        text: root.text
        font.pixelSize: root.pixelSize
        color: root.textColor
        font.family: root.family
        font.weight: root.weight
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
    }

    // second copy that follows after the first to create seamless loop
    Text {
        id: text2
        visible: root.animationEnabled
        text: root.text
        font.pixelSize: root.pixelSize
        color: root.textColor
        font.family: root.family
        font.weight: root.weight
        anchors.verticalCenter: parent.verticalCenter
        x: text1.width + root.spacing
    }
}
