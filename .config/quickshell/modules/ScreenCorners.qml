import qs.assets
import qs.bar
import qs.services
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick 2.15
import QtQuick.Window 2.15
import Quickshell.Wayland

Loader {
    active: Style.screenCorners || NiriService.inOverview
    // active: Style.screenCorners && (!ToplevelManager.activeToplevel.maximized || NiriService.inOverview)
    sourceComponent: PanelWindow {
        id: root
        visible: true
        // implicitWidth: 1920
        // implicitHeight: 1080
        // implicitHeight: 946 //1080 - Bar.root_bar.barHeight

        // Window background must be transparent so holes show wallpaper / what's behind
        color: "transparent"
        // flags: Qt.FramelessWindowHint
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        WlrLayershell.namespace: "quickshell:screenCorners"
        // WlrLayershell.layer: WlrLayer.Overlay
        // exclusionMode: ExclusionMode.Ignore
        mask: Region {
            item: null
        }

        Canvas {
            id: canvas
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            property int inset: 0
            property int border: 0
            property int radius: Style.screenCornerRadius + 6
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                // account for devicePixelRatio for crisp edges
                var dpr = canvas.devicePixelRatio || 1;
                ctx.scale(dpr, dpr);
                ctx.clearRect(0, 0, 1920, 1080);

                // // 1) draw the full red rectangle (the "original" rectangle)
                if (NiriService.inOverview) {
                    ctx.fillStyle = Qt.rgba(13 / 255, 13 / 255, 14 / 255, 0.6);
                } else if (!NiriService.activeToplevelMaximized) {
                    ctx.fillStyle = Qt.rgba(13 / 255, 13 / 255, 14 / 255, 0.88);
                } else {
                    ctx.fillStyle = Style.bgDark;
                }
                ctx.fillRect(0, 0, canvas.width + 0.7, canvas.height + 0.2);

                // 2) erase a rounded-rect hole (destination-out makes the shape transparent)
                ctx.save();
                ctx.globalCompositeOperation = "destination-out";
                ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
                ctx.beginPath();
                roundedRect(ctx, canvas.inset, canvas.inset, canvas.width - canvas.inset * 2, canvas.height - canvas.inset * 2, canvas.radius);
                ctx.fill();
                ctx.restore();

                // optional: draw a stroked blue rounded border (not filled, so still transparent)
                if (canvas.border) {
                    ctx.beginPath();
                    roundedRect(ctx, canvas.inset, canvas.inset, canvas.width - canvas.inset * 2, canvas.height - canvas.inset * 2, canvas.radius);
                    ctx.lineWidth = canvas.border;
                    ctx.strokeStyle = Style.border;
                    ctx.stroke();
                }
            }

            function roundedRect(ctx, x, y, w, h, r) {
                ctx.moveTo(x + r, y);
                ctx.arcTo(x + w, y, x + w, y + r, r);
                ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
                ctx.arcTo(x, y + h, x, y + h - r, r);
                ctx.arcTo(x, y, x + r, y, r);
                ctx.closePath();
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        Connections {
            target: NiriService
            function onInOverviewChanged() {
                canvas.requestPaint();
            }
            function onActiveToplevelMaximizedChanged() {
                canvas.requestPaint();
            }
        }
    }
}
