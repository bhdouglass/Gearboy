import QtQuick 2.3
import Ubuntu.Components 1.3

MouseArea {
    property color labelColor: "#EDEDED"
    property color fillColor: Qt.darker("#ABABAB", 1.0)
    property color borderColor: Qt.darker("#E1E1E1", 1.075)

    property real outline: width / 10
    property alias text: label.text
    property alias iconName: icon.name

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: borderColor

        Rectangle {
            anchors {
                fill: parent
                margins: units.gu(0.2)
            }

            color: fillColor
            border {
                color: borderColor
                width: outline
            }
            radius: width / 2

            Label {
                id: label

                visible: text
                anchors.centerIn: parent

                color: labelColor
                fontSize: "x-large"
            }

            Icon {
                id: icon

                visible: iconName
                anchors.centerIn: parent

                color: labelColor
                width: parent.width / 2
                height: width
            }
        }
    }
}
