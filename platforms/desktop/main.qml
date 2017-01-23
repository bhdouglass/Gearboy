import QtQuick 2.3
import QtQuick.Dialogs 1.2
import Ubuntu.Components 1.3

import GearBoy 1.0


MainView {
	id: root
	height: 144 * 3
	width: 160 * 3
	
	applicationName: "gearboy.rpattison" 

	property color gb_white: Qt.lighter("#CDCDCD", 1.1)
	property color gb_blue: "#45457e"

	property var startKey: Qt.Key_Return
	property var selectKey: Qt.Key_Backspace
	property var upKey: Qt.Key_Up
	property var downKey: Qt.Key_Down
	property var leftKey: Qt.Key_Left
	property var rightKey: Qt.Key_Right
	property var aKey: Qt.Key_A
	property var bKey: Qt.Key_B

	Keys.onPressed: {
			var key = event.key;
			if (key == leftKey) {
				emu.leftPressed();
				event.accepted = true;
			} else if (key == rightKey) {
				emu.rightPressed();
				event.accepted = true;
			} else if (key == downKey) {
				emu.downPressed();
				event.accepted = true;
			} else if (key == upKey) {
				emu.upPressed();
				event.accepted = true;
			} else if (key == aKey) {
				emu.aPressed();
				event.accepted = true;
			} else if (key == bKey) {
				emu.bPressed();
				event.accepted = true;
			} else if (key == startKey) {
				emu.startPressed();
				event.accepted = true;
			} else if (key == selectKey) {
				emu.selectPressed();
				event.accepted = true;
			}
		}

	Keys.onReleased: {
			var key = event.key;
			if (key == leftKey) {
				emu.leftReleased();
				event.accepted = true;
			} else if (key == rightKey) {
				emu.rightReleased();
				event.accepted = true;
			} else if (key == downKey) {
				emu.downReleased();
				event.accepted = true;
			} else if (key == upKey) {
				emu.upReleased();
				event.accepted = true;
			} else if (key == aKey) {
				emu.aReleased();
				event.accepted = true;
			} else if (key == bKey) {
				emu.bReleased();
				event.accepted = true;
			} else if (key == startKey) {
				emu.startReleased();
				event.accepted = true;
			} else if (key == selectKey) {
				emu.selectReleased();
				event.accepted = true;
			}
	}

	FileDialog {
		id: fileDialog
		title: "Open ROM…"
		onAccepted: {
			load(fileDialog.fileUrl);	
		}
		onRejected: {
			emu.play();
		}
		visible: false
		selectMultiple: false
	}

	GearBoyEmulator { 
		id: emu
		color: gb_white
	} 

	function load(url) {
		var path = url.toString().replace("file://", "");
		console.log("importing...");
		console.log(path);
		if (path) {
			if (emu.loadRom(path)) {
				help.visible = false;
				emu.play();
			} else {
				help.text = "ROM failed to load";
				help.visible = true;
			}
		}
	}

	function requestROM() {
		emu.pause();
		fileDialog.visible = true;
	}

	Component.onDestruction: {
		emu.pause();
		emu.save();
	}

	Text {
		id: help
		text: "Open ROM…"
		font.pixelSize: 30
		color: gb_blue 
		anchors.centerIn: loaderArea
		font.bold: true
	}

	MouseArea {
		id: loaderArea
		width: emu.rect.width
		height: emu.rect.height
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		onClicked: requestROM();
	}
}
