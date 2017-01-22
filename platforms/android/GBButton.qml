import QtQuick 2.3

Rectangle {
	id: root
	signal pressed()
	signal released()

	TouchSensor {
		onPushed: root.pressed();	
		onUnpushed: root.released();
	}
}
