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
            delegate.itemAt(index).removeThis();
        }

        onRestart: {
            appearAnimation.running = true;
        }
    }

    Repeater {
        id: delegate
        model: polygonListModel

        property bool idleAnimationRunning: false
        property bool idleAnimationPaused: false

        Polygon {
            id: polygon
            width:  polygon.boundingRect.width
            height: polygon.boundingRect.height
            x: polygon.offset.x
            y: polygon.offset.y

            points: polygonListModel.data(polygonListModel.index(index, 0), PolygonListModel.PointsRole)

            idleAnimationRunning: delegate.idleAnimationRunning
            idleAnimationPaused: delegate.idleAnimationPaused

            property rect boundingRect: polygonListModel.data(polygonListModel.index(index, 0), PolygonListModel.BoundingRectRole)
            property point offset: polygonListModel.data(polygonListModel.index(index, 0), PolygonListModel.OffsetRole)

            onClicked: {
                let mousePosition = Qt.point(mouseArea.mouseX - polygon.x + polygon.calibration.x,
                                             mouseArea.mouseY - polygon.y + polygon.calibration.y);

                if(polygonListModel.containsPoint(polygonListModel.index(index, 0), mousePosition))
                {
                    polygon.removeThis();

                    polygonListModel.timerStop(index);
                    polygonListModel.polygonSeed = polygon.points;
                    polygonListModel.insertRows(polygonListModel.rowCount(), polygon.points.length);

                    repeater.polygonIndex  = index;
                    repeater.polygonOffset = polygon.offset;
                    repeater.polygonBoundingRect = polygon.boundingRect;
                    repeater.model = polygon.points.length;

                    mouseArea.enabled = false;
                }
            }

            onAppearAnimationFinished: {
                repeater.model = 0;

                mouseArea.enabled = true;
            }
        }
    }

    Repeater {
        id: repeater
        model: 0

        property int polygonIndex: -1
        property point polygonOffset: Qt.point(0, 0)
        property rect polygonBoundingRect: Qt.rect(0, 0, 0, 0)

        property int movingAnimationFinishedCounter: 0

        Line {
            id: line
            x: repeater.polygonOffset.x
            y: repeater.polygonOffset.y
            width:  delegate.itemAt(polygonListModel.rowCount() - repeater.model + index).boundingRect.width
            height: delegate.itemAt(polygonListModel.rowCount() - repeater.model + index).boundingRect.height

            points: [polygonListModel.polygonSeed[index], polygonListModel.polygonSeed[index + 1 === repeater.model ? 0 : index + 1]];
            destination: polygonListModel.data(polygonListModel.index(polygonListModel.rowCount() - repeater.model + index, 0), PolygonListModel.OffsetRole);
            calibration: delegate.itemAt(polygonListModel.rowCount() - repeater.model + index).calibration

            lineColor: delegate.itemAt(repeater.polygonIndex).lineColor

            onMovingAnimationFinished: {
                if (++repeater.movingAnimationFinishedCounter === repeater.model)
                {
                    for (let i = 0; i < repeater.model; ++i)
                        delegate.itemAt(polygonListModel.rowCount() - repeater.model + i).paintThis();
                    polygonListModel.removeRows(repeater.polygonIndex);
                    repeater.movingAnimationFinishedCounter = 0;
                }
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
            text: "3"
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
            text: "5"
        }

        LineEdit {
            id: lineEditLifespan
            labelText: "lifespan:"
            maxValue: 99999
            text: "70000"
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
                for (let i = 0; i < polygonListModel.rowCount(); ++i)
                    delegate.itemAt(i).paintThis();
            }
        }
    }

    Shortcut {
        id: shortcutAltP
        sequence: "Alt+P"
        onActivated: {
            if (delegate.idleAnimationRunning)
            {
                if (delegate.idleAnimationPaused)
                    delegate.idleAnimationPaused = false;
                else
                    delegate.idleAnimationPaused = true;
            }
        }
    }

    Shortcut {
        id: shortcutAltR
        sequence: "Alt+R"
        onActivated: {
            if (delegate.idleAnimationRunning)
                delegate.idleAnimationRunning = false;
            else
                delegate.idleAnimationRunning = true;
        }
    }
}
