import QtQuick 2.0

MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    property bool isDown: false

    signal pushed()
    signal unpushed()

    onEntered: {
	if (!isDown) {
		isDown = true;
		pushed();
	}
	}

    onPressed: {
	if (!isDown) {
		isDown = true;
	pushed();
}
    }

    onExited: {
	if (isDown) {
		isDown = false;
	unpushed();
}
    }
    onReleased: {
	if (isDown) {
		isDown = false;
	unpushed();
}
    }
    onCanceled: {
	if (isDown) {
	isDown = false;
	unpushed();
}
    }
}
