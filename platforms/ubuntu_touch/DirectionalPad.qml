import QtQuick 2.3
import Ubuntu.Components 1.3

Item {
	id: root
	property color innerColor: "white"
	property color color: "black"
	property color centerColor: "black"
	property int wingSize: width / 3
	property int centreSize: Math.min(width, height)  - 2 * wingSize
	property int dpad_line: units.gu(0.25)

	property var direction : null
	property int dead_zone : centreSize / 2

	signal rightPressed();
	signal leftPressed();
	signal upPressed();
	signal downPressed();

	signal rightReleased();
	signal leftReleased();
	signal upReleased();
	signal downReleased();
	
	Rectangle {
		id: xAxis
		x: 0
		y: wingSize
		width: wingSize * 2 + centreSize
		height: centreSize
		radius: dpad_line * 2
		color: root.innerColor
		border.color: root.color
		border.width: Math.min(width, height) / 2 - dpad_line
	}
	
	Rectangle {
		id: yAxis

		x: wingSize
		y: 0
		width: centreSize
		height: wingSize * 2 + centreSize
		radius: dpad_line * 2

		color: root.innerColor
		border.color: root.color
		border.width: Math.min(width, height) / 2 - dpad_line
	}

	Rectangle {
		id: mid
		x: wingSize - (Math.sqrt(2) - 1) * centreSize / 2
		y: x
		width: centreSize * Math.sqrt(2)
		height: width
		radius: centreSize / 2 * Math.sqrt(2)
		border.width: dpad_line * 6
		border.color: root.color
		color: centerColor
	}

	function release() {
		if (direction) {
			if (direction == "left") {
				leftReleased();
			} else if (direction == "right") {
				rightReleased();
			} else if (direction == "up") {
				upReleased();
			} else if (direction == "down") {
				downReleased();
			}
			direction = null;
		}
	}

	function press(dir) {
		if (dir != direction) {
			release();
			direction = dir;
			if (direction == "left") {
				leftPressed();
			} else if (direction == "right") {
				rightPressed();
			} else if (direction == "up") {
				upPressed();
			} else if (direction == "down") {
				downPressed();
			}
			Haptics.play();
		}
	}

	MultiPointTouchArea {
		anchors.fill: parent

		onReleased: {
			release();
		}

		onCanceled: {
			release();
		}

		onTouchUpdated: {
			for (var i = 0; i < touchPoints.length; ++i) {
				var p = touchPoints[i];
				var dx = p.x - (width / 2);
				var dy = p.y - (height / 2);
				var xmag = dx * dx;
				var ymag = dy * dy;
				var deadmag = dead_zone * dead_zone;

				if (xmag < deadmag && ymag < deadmag) {
					release();
					return;
				}
				
				if (xmag > ymag) {
					if (dx > 0) { 
						press("right");
					} else { 
						press("left");
					}
				} else {
					if (dy > 0) { 
						press("down");
					} else { 
						press("up");
					}
				}
			}
		}	
	}
}
