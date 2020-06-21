import QtQuick 2.14
import './Algorithm.js' as Algorithm

Rectangle {
    id: polygon
    border.color: "blue"
    color: "transparent"

    property var points: []
    property point calibration: Algorithm.calibration(polygon.points)

    property color lineColor: Qt.rgba(0, 0, 0)

    property bool idleAnimationRunning: true
    property bool idleAnimationPaused: false

    //property real widthScale:  1
    //property real heightScale: 1

    signal paintThis()
    signal removeThis()

    signal appearAnimationFinished()

    signal clicked()

    MouseArea {
        id: mouseArea
        width:  polygon.width
        height: polygon.height

        propagateComposedEvents: true

        Canvas {
            id: canvas
            width:  polygon.width
            height: polygon.height

            visible: false

            property int step: polygon.points.length

            onPaint: {
                let brush = getContext("2d");

                brush.lineWidth = 2;
                brush.strokeStyle = polygon.lineColor;

                brush.beginPath();

                brush.beginPath();
                brush.moveTo(polygon.points[0].x - calibration.x, polygon.points[0].y - calibration.y);

                for (let i = 1; i <= polygon.points.length - canvas.step; ++i)
                    if (i !== polygon.points.length)
                        brush.lineTo(polygon.points[i].x - calibration.x, polygon.points[i].y - calibration.y);
                    else
                        brush.lineTo(polygon.points[0].x - calibration.x, polygon.points[0].y - calibration.y);

                brush.stroke();
            }

            NumberAnimation {
                id: appearAnimation
                target: canvas
                property: "step"
                duration: 2000
                from: canvas.step
                to: 0

                onFinished: {
                    polygon.appearAnimationFinished();
                }
            }
        }

        onClicked: {
            mouse.accepted = false;
            polygon.clicked();
        }
    }

    onPaintThis: {
        canvas.visible = true;
        appearAnimation.running = true;
        console.log("paintThis()");
    }

    onRemoveThis: {
        mouseArea.enabled = false;
        pulsation.running = false;

        canvas.visible = false;
    }

    onLineColorChanged: {
        canvas.requestPaint();
    }

    SequentialAnimation {
        id: gradient
        running: true
        loops: Animation.Infinite

        ColorAnimation {
            target: polygon
            properties: "lineColor"
            from: Qt.rgba(1, 0, 0)
            to:   Qt.rgba(0, 1, 0)
            duration: 2000
        }

        ColorAnimation {
            target: polygon
            properties: "lineColor"
            from: Qt.rgba(0, 1, 0)
            to:   Qt.rgba(0, 0, 1)
            duration: 2000
        }

        ColorAnimation {
            target: polygon
            properties: "lineColor"
            from: Qt.rgba(0, 0, 1)
            to:   Qt.rgba(1, 0, 0)
            duration: 2000
        }
    }

    SequentialAnimation {
        id: pulsation
        running: polygon.idleAnimationRunning
        paused: polygon.idleAnimationPaused
        loops: Animation.Infinite

        ScaleAnimator {
            target: polygon
            from: 1
            to:   1.10
            duration: 500
        }

        ScaleAnimator {
            target: polygon
            from: 1.10
            to:   1
            duration: 500
        }
    }

    RotationAnimation on rotation {
        id: twist
        from: 0
        to:   360
        duration: 10000
        running: polygon.idleAnimationRunning
        paused: polygon.idleAnimationPaused
        loops: Animation.Infinite
    }
}
