import QtQuick 2.3
import Ubuntu.Components 1.3

MouseArea {
    id: button
    property alias text: label.text
    property alias textColor: label.color
    property alias fontSize: label.fontSize
    property alias font: label.font

    property real colorChange: 1.05

    property alias buttonWidth: rect.width
    property alias buttonHeight: rect.height
    property alias border: rect.border
    property alias radius: rect.radius
    property alias color: rect.color
    property int touchPadding: 0

    width: buttonWidth + 2 * touchPadding
    height: buttonHeight + 2 * touchPadding
    hoverEnabled: true

    signal pushed
    signal unpushed

    Rectangle {
        id: rect
        anchors.centerIn: parent
    }

    Label {
        id: label
        anchors.centerIn: button
    }

    onPressed: {
        color = Qt.darker(color, colorChange)
        pushed();
    }

    onReleased: {
        color = Qt.lighter(color, colorChange)
        unpushed();
    }
}
