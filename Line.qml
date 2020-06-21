import QtQuick 2.14
import './Algorithm.js' as Algorithm

Rectangle {
    id: line

    border.color: "red"
    color: "transparent"

    property var points: []
    property point calibration: Qt.point(0, 0)
    property point destination: Qt.point(0, 0)

    property color lineColor: Qt.rgba(0, 0, 0)

    signal movingAnimationFinished()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            let brush = getContext("2d");

            brush.lineWidth = 2;
            brush.strokeStyle = line.lineColor;

            brush.beginPath();
            brush.moveTo(points[0].x - line.calibration.x, points[0].y - line.calibration.y);
            brush.lineTo(points[1].x - line.calibration.x, points[1].y - line.calibration.y);
            brush.stroke();
        }
    }

    onLineColorChanged: {
        canvas.requestPaint();
    }

    ParallelAnimation {
        id: movingAnimation
        running: true

        NumberAnimation {
            target: line
            property: "x"
            duration: 5000
            from: line.x
            to: line.destination.x
        }

        NumberAnimation {
            target: line
            property: "y"
            duration: 5000
            from: line.y
            to: line.destination.y
        }

        onFinished: {
            line.movingAnimationFinished();
        }
    }
}
