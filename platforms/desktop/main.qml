import QtQuick 2.3
import GearBoy 1.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.Dialogs 1.2

MainView {
	id: root
	height: units.gu(80)
	width: units.gu(45)
	
	applicationName: "gearboy.rpattison" 

	property color gb_white: Qt.lighter("#CDCDCD", 1.1)
	property color gb_white_accent: "#EDEDED"
	property color gb_gray: Qt.lighter("#A3A3A3", 1.1)  
	property color gb_gray_dark: Qt.lighter("#999999", 1.3)
	property color gb_gray_accent: Qt.lighter("#999999", 1.7)
	property color gb_black: "#2A2A2A"
	property color gb_black_accent: "#343434"
	property color gb_purple: "#B01561"
	property color gb_purple_accent: Qt.darker("#CF2463", 1.4)

	property color gb_blue: "#45457e"

	property real outline: units.gu(0.375)
	property real thin_outline: units.gu(0.25)

	property var activeTransfer: null

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
		title: i18n.tr("Open ROM…")
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
				help.text = i18n.tr("ROM failed to load");
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

	Label {
		id: help
		text: i18n.tr("Open ROM…")
		fontSize: "x-large"
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
