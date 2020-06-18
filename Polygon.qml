import QtQuick 2.14

Rectangle {
    id: polygon
    border.color: "blue"
    color: "transparent"

    property var points: []
    property bool isClicked: false

    property bool idleAnimationRunning: true
    property bool idleAnimationPaused: false

    property int borderIndent: 2
    property real widthScale:  1
    property real heightScale: 1

    signal removeThis()
    signal disappearAnimationStarted()
    signal disappearAnimationFinished()
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

            property color color: Qt.rgba(0, 0, 0)

            onPaint: {
                let brush = getContext("2d");

                brush.lineWidth = 2;
                brush.strokeStyle = canvas.color;

                brush.globalAlpha = 0.2;

                brush.beginPath();
                brush.moveTo(polygon.points[0].x * polygon.widthScale  - polygon.x + polygon.borderIndent,
                             polygon.points[0].y * polygon.heightScale - polygon.y + polygon.borderIndent);

                for (let i = 1; i < polygon.points.length; ++i)
                    brush.lineTo(polygon.points[i].x * polygon.widthScale  - polygon.x + polygon.borderIndent,
                                 polygon.points[i].y * polygon.heightScale - polygon.y + polygon.borderIndent);

                brush.closePath();
                brush.stroke();
            }

            onColorChanged: {
                canvas.requestPaint();
            }

        }

        onClicked: {
            mouse.accepted = false;
            polygon.clicked();
        }

        SequentialAnimation {
            id: gradient
            running: true
            loops: Animation.Infinite

            ColorAnimation {
                target: canvas
                properties: "color"
                from: Qt.rgba(1, 0, 0)
                to:   Qt.rgba(0, 1, 0)
                duration: 2000
            }

            ColorAnimation {
                target: canvas
                properties: "color"
                from: Qt.rgba(0, 1, 0)
                to:   Qt.rgba(0, 0, 1)
                duration: 2000
            }

            ColorAnimation {
                target: canvas
                properties: "color"
                from: Qt.rgba(0, 0, 1)
                to:   Qt.rgba(1, 0, 0)
                duration: 2000
            }
        }

        SequentialAnimation {
            id: disappear
            running: false

            ScaleAnimator {
                target: canvas
                from: 1
                to:   1.4
                duration: 350
            }

            ScaleAnimator {
                target: canvas
                from: 1.4
                to:   0
                duration: 700
            }

            onStarted: {
                polygon.disappearAnimationStarted();
            }

            onFinished: {
                polygon.disappearAnimationFinished();
            }
        }
    }

    onRemoveThis: {
        mouseArea.enabled = false;
        pulsation.running = false;
        disappear.running = true;
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
