import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import PolygonListModel 1.0

Window {
    id: window
    minimumWidth:  800
    minimumHeight: 600

    visible: true

    PolygonListModel {
        id: polygonListModel
        minimumWindowWidth:  window.minimumWidth
        minimumWindowHeight: window.minimumHeight

        onTimerTriggered: {
            repeater.itemAt(index).removeThis();
        }

        onRestart: {
            appearAnimation.running = true;
        }
    }

    Repeater {
        id: repeater
        model: polygonListModel

        property bool idleAnimationRunning: false
        property bool idleAnimationPaused: false

        Polygon {
            id: polygon
            width:  boundingRect.width  * polygon.widthScale  + polygon.borderIndent
            height: boundingRect.height * polygon.heightScale + polygon.borderIndent
            x: boundingRect.x * polygon.widthScale
            y: boundingRect.y * polygon.heightScale

            points: polygonListModel.data(polygonListModel.index(index, 0), PolygonListModel.PointsRole)

            idleAnimationRunning: repeater.idleAnimationRunning
            idleAnimationPaused: repeater.idleAnimationPaused

            widthScale:  window.width  / window.minimumWidth
            heightScale: window.height / window.minimumHeight

            property rect boundingRect: {
                if (index >= 0)
                    return polygonListModel.data(polygonListModel.index(index, 0), PolygonListModel.BoundingRectRole);
                else
                    return Qt.rect(0, 0, 0, 0);
            }

            onClicked: {
                let mousePosition = Qt.point(mouseArea.mouseX / polygon.widthScale, mouseArea.mouseY / polygon.heightScale);
                if(polygonListModel.containsPoint(polygonListModel.index(index, 0), mousePosition))
                {
                    polygonListModel.timerStop(index);
                    polygon.isClicked = true;
                    polygon.removeThis();
                }
            }

            onDisappearAnimationStarted: {

            }

            onDisappearAnimationFinished: {
                if (polygon.isClicked)
                    polygonListModel.insertRows(polygonListModel.rowCount(), polygon.points.length);

                polygonListModel.removeRows(index);
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        enabled: false
        propagateComposedEvents: true

        onClicked: {
            mouse.accepted = false;
        }
    }

    RowLayout {
        id: rowLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.bottom
        anchors.verticalCenterOffset: -30

        enabled: true
        opacity: 1
        spacing: 10

        LineEdit {
            id: lineEditQuantity
            labelText: "quantity:"
            text: "10"
        }

        LineEdit {
            id: lineEditMinSizeRange
            labelText: "minSizeRange:"
            minValue: 3
            text: "3"
        }

        LineEdit {
            id: lineEditMaxSizeRange
            labelText: "maxSizeRange:"
            minValue: lineEditMinSizeRange.text
            text: "8"
        }

        LineEdit {
            id: lineEditLifespan
            labelText: "lifespan:"
            maxValue: 99999
            text: "7000"
        }

        Button {
            id: buttonApply
            text: "Apply"

            onClicked: {
                if (lineEditQuantity.acceptableInput &
                        lineEditMinSizeRange.acceptableInput &
                        lineEditMaxSizeRange.acceptableInput &
                        lineEditLifespan.acceptableInput)
                {
                    disappearAnimation.running = true;

                    polygonListModel.quantity     = lineEditQuantity.text;
                    polygonListModel.minSizeRange = lineEditMinSizeRange.text;
                    polygonListModel.maxSizeRange = lineEditMaxSizeRange.text;
                    polygonListModel.lifespan     = lineEditLifespan.text;

                    polygonListModel.insertRows(polygonListModel.rowCount(), lineEditQuantity.text);
                }
            }
        }

        NumberAnimation {
            id: appearAnimation
            target: rowLayout
            property: "opacity"
            duration: 400
            from: 0
            to:   1
            running: false

            onStarted: {
                mouseArea.enabled = false;
            }

            onFinished: {
                rowLayout.enabled = true;
            }
        }

        NumberAnimation {
            id: disappearAnimation
            target: rowLayout
            property: "opacity"
            duration: 400
            from: 1
            to:   0
            running: false

            onStarted: {
                rowLayout.enabled = false;
            }

            onFinished: {
                mouseArea.enabled = true;
            }
        }
    }

    Shortcut {
        id: shortcutAltP
        sequence: "Alt+P"
        onActivated: {
            if (repeater.idleAnimationRunning)
            {
                if (repeater.idleAnimationPaused)
                    repeater.idleAnimationPaused = false;
                else
                    repeater.idleAnimationPaused = true;
            }
        }
    }

    Shortcut {
        id: shortcutAltR
        sequence: "Alt+R"
        onActivated: {
            if (repeater.idleAnimationRunning)
                repeater.idleAnimationRunning = false;
            else
                repeater.idleAnimationRunning = true;
        }
    }
}
