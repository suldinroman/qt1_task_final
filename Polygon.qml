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

        Repeater {
            id: repeater
            model: polygon.points.length

            Canvas {
                id: canvas
                width:  polygon.width
                height: polygon.height

                property color color: Qt.rgba(0, 0, 0)

                onPaint: {
                    if (index >= 0)
                    {
                        let brush = getContext("2d");
                        brush.lineWidth = 2;
                        brush.strokeStyle = canvas.color;

                        brush.clearRect(0, 0, canvas.width, canvas.height);
                        brush.globalAlpha = 0.2;

                        brush.beginPath();

                        let i = index;
                        let j = (index + 1 === repeater.model ? 0 : index + 1);

                        let Xi = polygon.points[i].x * polygon.widthScale - polygon.x;
                        let Yi = polygon.points[i].y * polygon.heightScale - polygon.y;

                        let Xj = polygon.points[j].x * polygon.widthScale - polygon.x;
                        let Yj = polygon.points[j].y * polygon.heightScale - polygon.y;

                        brush.moveTo(Xi, Yi);
                        brush.lineTo(Xj, Yj);

                        brush.stroke();
                    }
                }

                onColorChanged: {
                    canvas.requestPaint();
                }
            }
        }

        onClicked: {
            console.log(mouseX, mouseY);
            mouse.accepted = false;
            polygon.clicked();
        }

/*        SequentialAnimation {
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
*/
        SequentialAnimation {
            id: disappear
            running: false

            ScaleAnimator {
                target: polygon
                from: 1
                to:   1.4
                duration: 350
            }

            ScaleAnimator {
                target: polygon
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
