import QtQuick 2.3
import Ubuntu.Components 1.3

MultiPointTouchArea {
    id: button
    property alias text: label.text
    property alias textColor: label.color
    property alias fontSize: label.fontSize
    property alias font: label.font

    property alias buttonWidth: rect.width
    property alias buttonHeight: rect.height
    property alias radius: rect.radius
    property int touchPadding: 0
    property real outline: 2 * units.gu(0.33)

    property color fillColor: Qt.darker("#ABABAB", 1.0)
    property color pressedColor: Qt.darker(fillColor, 1.15)

    property color borderColor: Qt.darker("#E1E1E1", 1.075)
    property color pressedBorderColor: Qt.darker(borderColor, 1)

    width: buttonWidth + 2 * touchPadding
    height: buttonHeight + 2 * touchPadding

    signal pushed
    signal unpushed

    Rectangle {
        id: inset
        width: buttonWidth + 2.5 * outline
        height: buttonHeight + 2.5 * outline
        radius: rect.radius
        anchors.centerIn: parent
        border.color: borderColor
        color: Qt.darker(borderColor, 1.4)
        border.width: outline

        Rectangle {
            id: rect
            anchors.centerIn: parent
            border.width: units.gu(0)
            border.color: Qt.darker(fillColor, 1.15)
            color: fillColor
        }
    }

    Label {
        id: label
        anchors.centerIn: button
    }

    onPressed: {
        rect.color = pressedColor
        pushed()
    }

    onReleased: {
        rect.color = fillColor
        unpushed()
    }
}
