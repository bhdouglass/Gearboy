import QtQuick 2.3
import Ubuntu.Components 1.3

Rectangle {
	id: root

	property alias text: label.text
	property alias textColor: label.color
	property alias fontSize: label.fontSize
	property alias bold: label.font.bold

	signal pressed()
	signal released()

	Label {
		id: label
		anchors.centerIn: parent
	}

	TouchSensor {
		onPushed: root.pressed();	
		onUnpushed: root.released();
	}
}
