Item {
    id: barLayout
    anchors.fill: parent

    // Left section
    RowLayout {
        id: leftSection
        anchors {
            left: parent.left
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }
        spacing: 15

        WrapperRectangle {
            color: "transparent"
            Layout.fillHeight: true

            RowLayout {
                spacing: 15
                ClockWidget {
                    color: Style.textMuted
                    Layout.fillHeight: true
                    Layout.minimumHeight: parent.height
                    verticalAlignment: Text.AlignVCenter
                    Layout.alignment: Qt.AlignLeft
                    font.pixelSize: Style.fontSize
                    font.family: Style.fontFamily
                    font.weight: Style.fontWeight
                }

                Workspaces {
                    bar: barBackground
                    Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }

    // Middle section - TRULY CENTERED
    WrapperRectangle {
        id: middleSection
        color: "transparent"
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: Math.min(parent.width * 0.4, 600)
        height: parent.height

        Text {
            anchors.centerIn: parent
            text: NiriService.focusedWindowTitle || ""
            color: Style.textMuted
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            font.pixelSize: Style.fontSize
            font.family: Style.fontFamily
            font.weight: Style.fontWeight

            width: parent.width
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    // Right section
    RowLayout {
        id: rightSection
        anchors {
            right: parent.right
            rightMargin: 5
            verticalCenter: parent.verticalCenter
        }
        spacing: 14

        WrapperRectangle {
            color: "transparent"
            Layout.fillHeight: true

            RowLayout {
                spacing: 15

                // audio icon and value
                RowLayout {
                    id: audio
                    WrapperMouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: true
                        onClicked: {
                            BarPopupManager.toggleAudioPopup();
                        }
                        child: RowLayout {
                            Text {
                                text: Audio.icon
                                font.pixelSize: Style.iconFontSize - 5
                                font.family: Style.iconFontFamily
                                font.weight: Style.iconFontWeight + 400

                                Layout.fillHeight: true
                                Layout.minimumHeight: parent.height
                                verticalAlignment: Text.AlignVCenter
                                color: (Audio.volume > 100) ? Style.red : Style.textMuted
                            }

                            Text {
                                text: parseInt(Audio.volume * 100) + "%"
                                Layout.fillHeight: true
                                Layout.minimumHeight: parent.height
                                verticalAlignment: Text.AlignVCenter
                                Layout.alignment: Qt.AlignRight

                                font.pixelSize: 14
                                font.weight: Style.fontWeight
                                font.family: Style.fontFamily
                                color: (Audio.volume > 100) ? Style.red : Style.textMuted
                            }
                        }
                    }
                }

                BatteryIcon {
                    Layout.rightMargin: 35
                }

                // ressource usage
                RowLayout {
                    id: ressourceUsage
                    property var color: (memory.text > 95) ? Style.red : Style.textMuted
                    WrapperMouseArea {
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: true
                        onClicked: {
                            BarPopupManager.toggleRessourcePopup();
                            // console.log("show ressourceUsage", BarPopupManager.showRessourcePopup);
                        }
                        child: RowLayout {
                            Text {
                                text: "􀫦"
                                font.pixelSize: Style.iconFontSize - 5
                                font.family: Style.iconFontFamily
                                font.weight: Style.iconFontWeight + 400

                                Layout.fillHeight: true
                                Layout.minimumHeight: parent.height
                                verticalAlignment: Text.AlignVCenter
                                color: ressourceUsage.color
                            }

                            Text {
                                id: memory
                                text: parseInt(RessourceUsage.memoryUsedPercentage * 100) + "%"
                                Layout.fillHeight: true
                                Layout.minimumHeight: parent.height
                                verticalAlignment: Text.AlignVCenter
                                Layout.alignment: Qt.AlignRight

                                font.pixelSize: 14
                                font.weight: Style.fontWeight
                                font.family: Style.fontFamily
                                color: ressourceUsage.color
                            }
                        }
                    }
                }

                SysTray {
                    bar: root_bar
                    visible: true
                    Layout.fillWidth: false
                    Layout.fillHeight: true
                }
            }
        }
    }
}
