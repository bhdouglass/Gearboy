import QtQuick 2.3
import GearBoy 1.0

Item {
	id: root
	
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

	property real outline: 15 * 0.375
	property real thin_outline: 15 * 0.25

	GearBoyEmulator { 
		id: emu
		color: gb_white
	}

	function requestROM() {
        if (emu.requestRom()) {
            emu.play();
            help.visible = false;
        }
	}

	Component.onCompleted: {
		a.pressed.connect(emu.aPressed);		
		a.released.connect(emu.aReleased);

		b.pressed.connect(emu.bPressed);
		b.released.connect(emu.bReleased);

		select.pressed.connect(emu.selectPressed);
		select.released.connect(emu.selectReleased);

		start.pressed.connect(emu.startPressed);
		start.released.connect(emu.startReleased);

		dpad.upPressed.connect(emu.upPressed);
		dpad.upReleased.connect(emu.upReleased);

		dpad.downPressed.connect(emu.downPressed);
		dpad.downReleased.connect(emu.downReleased);

		dpad.leftPressed.connect(emu.leftPressed);
		dpad.leftReleased.connect(emu.leftReleased);

		dpad.rightPressed.connect(emu.rightPressed);
		dpad.rightReleased.connect(emu.rightReleased);
	}

	Component.onDestruction: {
		emu.pause();
		emu.save();
		emu.stop();
	}

	Text {
		id: help
		text: "Open ROM…"
		font.pixelSize: 48
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

	Item {
		id: lefthand
		width: 15 * 19
		height: 15 * 38

		anchors.left: parent.left
		anchors.bottom: parent.bottom

		DirectionalPad {
			id: dpad
			x: 15
			y: 0
			width: 15 * 17
			height: width
			color: gb_black
			wingSize: 15 * 6
			centerColor: gb_black_accent
			innerColor: gb_white_accent
		}

		GBButton {
			id: select
			y: 28 * 15

			anchors.right: parent.right
			anchors.rightMargin: 15

			width: 15 * 11
			height: 15 * 3
			radius: height / 3
			border.width: thin_outline

			color: gb_gray_accent
			border.color: gb_gray_dark

			text: "SELECT"
			textColor: gb_gray 
			fontSize: 14
		}
	}

	Item {
		id: righthand
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: 15 * 19
		height: 15 * 38

		GBButton {
			id: start
			y: select.y

			text: "START"
			textColor: select.textColor
			fontSize: select.fontSize
			bold: select.bold

			anchors.left: parent.left
			anchors.leftMargin: 15 * 1

			width: select.width
			height: select.height
			radius: select.radius
			border.width: select.border.width

			border.color: select.border.color
			color: select.color
		}

		GBButton {
			id: a
			x: 15 * 9
			y: 0
			width: 15 * 9
			height: width
			radius: width / 2
			color: gb_purple
			border.color: gb_purple_accent
			border.width: outline
			text: "A"
			textColor: gb_white_accent
			fontSize: 24
			bold: true
		}

		GBButton {
			id: b
			x: 15 
			y: 15 * 9
			text: "B"

			width: a.width
			height: a.height
			radius: a.radius
			color: a.color 
			border.color: a.border.color
			border.width: a.border.width
			textColor: a.textColor
			fontSize: a.fontSize
			bold: a.bold
		}
	}
}
