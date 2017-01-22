import QtQuick 2.3

Rectangle {
	id: root

	property alias text: label.text
	property alias textColor: label.color
	property alias fontSize: label.font.pixelSize
	property alias bold: label.font.bold

	signal pressed()
	signal released()

	Text {
		id: label
		anchors.centerIn: parent
	}

	TouchSensor {
		onPushed: root.pressed();	
		onUnpushed: root.released();
	}
}
