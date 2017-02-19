import QtQuick 2.3

MouseArea {
    id: button
    property alias text: label.text
    property alias textColor: label.color
    property alias font: label.font

    property var fontSize: ""

    property real colorChange: 1.02
    property real pressScale: 0.95

    property alias buttonWidth: rect.width
    property alias buttonHeight: rect.height
    property alias border: rect.border
    property alias radius: rect.radius
    property alias color: rect.color
    property int touchPadding: 0


    property real bwidth: 0

    width: buttonWidth + 2 * touchPadding
    height: buttonHeight + 2 * touchPadding
    hoverEnabled: true

    signal pushed
    signal unpushed

    Rectangle {
        width: buttonWidth * 1.1
        height: buttonHeight * 1.3
        radius: rect.radius
        anchors.centerIn: parent
        color: Qt.lighter(rect.border.color, 1.05)
    }

    Rectangle {
        id: rect
        anchors.centerIn: parent
    }

    Text {
        id: label
        anchors.centerIn: button
    }

    onPressed: {
        color = Qt.darker(color, colorChange);
        rect.scale = pressScale;
        pushed();
        bwidth = rect.border.width;
        rect.border.width = bwidth / 2;
    }

    onReleased: {
        color = Qt.lighter(color, colorChange);
        rect.scale = 1;
        unpushed();
        rect.border.width = bwidth;
    }
}
