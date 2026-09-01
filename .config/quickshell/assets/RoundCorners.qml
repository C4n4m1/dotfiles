import QtQuick

Item {
    id: root

    enum CornerEnum { TopLeft, TopRight, BottomLeft, BottomRight }

    property var corner: RoundCorners.TopLeft // Default start at top left
    property int size: Style.screenCornerRadius
    property color color: Style.bgDark

    width: root.size
    height: root.size

    onColorChanged: {
        canvas.requestPaint();
    }
    onCornerChanged: {
        canvas.requestPaint();
    }

    Canvas {
        id: canvas

        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            var radius = root.size;
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.beginPath()
            switch (root.corner) {
                case RoundCorners.CornerEnum.TopLeft:
                    ctx.arc(radius, radius, radius, Math.PI, 3*Math.PI/2);
                    ctx.lineTo(0, 0);
                    break;
                case RoundCorners.CornerEnum.TopRight:
                    ctx.arc(0, radius, radius, 3*Math.PI/2, 2*Math.PI);
                    ctx.lineTo(radius, 0);
                    break;
                case RoundCorners.CornerEnum.BottomLeft:
                    ctx.arc(radius, 0, radius, Math.PI/2, Math.PI);
                    ctx.lineTo(0, radius);
                    break;
                case RoundCorners.CornerEnum.TopLeft:
                    ctx.arc(0, 0, radius, 0, Math.PI/2);
                    ctx.lineTo(radius, radius);
                    break;
            }

            ctx.closePath()
            ctx.fillStyle = root.color
            ctx.fill()
        }
    }

    // :TODO → animations
}
