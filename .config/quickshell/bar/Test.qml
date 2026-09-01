import QtQuick
import Quickshell

Rectangle {
    width: 100
    height: 100
    color: "red"
    Text {
        text: "Hello World"
        anchors.centerIn: parent
    }
    Rectangle {
        width: 2
        height: height
        color: "black"
        anchors.left: parent.left
        anchors.leftMargin: 10
    }
    Rectangle {
        width: 2
        height: height
        color: "black"
        anchors.right: parent.right
        anchors.rightMargin: 10
    }
    Rectangle {
        width: 2
        height: height
        color: "black"
        anchors.top: parent.top
        anchors.topMargin: 10
    }
    Rectangle {
        width: 2
        height: height
        color: "black"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
    }
}
