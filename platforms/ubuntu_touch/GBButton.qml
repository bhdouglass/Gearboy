import QtQuick 2.3
import Ubuntu.Components 1.3

Rectangle {
    id: root

    property alias text: label.text
    property alias textColor: label.color
    property alias fontSize: label.fontSize
    property alias bold: label.font.bold

    property real colorChange: 1.05

    signal pressed
    signal released

    Label {
        id: label
        anchors.centerIn: parent
    }

    onPressed: {
        root.color = Qt.darker(root.color, colorChange);
        root.border.color = Qt.lighter(root.border.color, colorChange);
    }

    onReleased: {
        root.color = Qt.lighter(root.color, colorChange);
        root.border.color = Qt.darker(root.border.color, colorChange);
    }

    TouchSensor {
        onPushed: root.pressed()
        onUnpushed: root.released()
    }
}
