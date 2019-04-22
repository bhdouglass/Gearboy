import QtQuick 2.3
import Ubuntu.Components 1.3

MouseArea {
    property color gb_white_accent: "#EDEDED"
    property color gb_purple: "#B01561"
    property color gb_purple_accent: Qt.darker("#CF2463", 1.4)
    property color gb_purple_pressed: Qt.darker(gb_purple, 1)
    property color gb_accent_pressed: Qt.darker(gb_purple_accent, 1)

    property real outline: width / 10 // units.gu(0.375)  // TODO calculate this based on width
    property alias text: label.text
    property alias iconName: icon.name

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: gb_purple_accent

        Rectangle {
            anchors {
                fill: parent
                margins: units.gu(0.2)
            }

            color: gb_purple
            border {
                color: gb_purple_accent
                width: outline
            }
            radius: width / 2

            Label {
                id: label

                visible: text
                anchors.centerIn: parent

                color: gb_white_accent
                fontSize: "x-large"
            }

            Icon {
                id: icon

                visible: iconName
                anchors.centerIn: parent

                color: gb_white_accent
                width: parent.width / 2
                height: width
            }
        }
    }
}
