import QtQuick 2.3
import GearBoy 1.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3

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

	ContentPeerModel {
		id: model
		contentType: ContentType.Documents
		handler: ContentHandler.Source
	}

	Connections {
		target: ContentHub
		onImportRequested: {
			root.importItems(transfer.items);
		}
	}

	GearBoyEmulator { 
		id: emu
		color: gb_white
	}

	function importItems(items)  {
		load(items[0].url);
	}

	function load(url) {
		var path = url.toString().replace("file://", "");
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
		var peer = null;
		for (var i = 0; i < model.peers.length; ++i) {
			var p = model.peers[i];
			var s = p.appId;
			if (s.indexOf("filemanager") != -1) {
				peer = p;
			}
		}
		if (peer == null) { 
			picker.visible = true; /* didn't find ubuntu's file manager, maybe they have another app */
		} else {
			root.activeTransfer = peer.request(); 
		}
	}

	Component.onCompleted: {
		btns.aPressed.connect(emu.aPressed);		
		btns.aReleased.connect(emu.aReleased);

		btns.bPressed.connect(emu.bPressed);
		btns.bReleased.connect(emu.bReleased);

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

	Item {
		id: lefthand
		width: units.gu(19)
		height: units.gu(35)

		anchors.left: parent.left
		anchors.bottom: parent.bottom

		DirectionalPad {
			id: dpad
			x: units.gu(1)
			y: 0
			width: units.gu(17)
			height: units.gu(17)
			color: gb_black
			wingSize: units.gu(6)
			centerColor: gb_black_accent
			innerColor: gb_white_accent
		}

		GBButton {
			id: select
			y: units.gu(28)

			anchors.right: parent.right
			anchors.rightMargin: units.gu(1)

			width: units.gu(11)
			height: units.gu(3)
			radius: height / 3
			border.width: thin_outline

			color: gb_gray_accent
			border.color: gb_gray_dark

			text: i18n.tr("SELECT")
			textColor: gb_gray 
			fontSize: "medium"
		}
	}

	Item {
		id: righthand
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: units.gu(19)
		height: units.gu(35)

		GBButton {
			id: start
			y: select.y

			text: i18n.tr("START")
			textColor: select.textColor
			fontSize: select.fontSize
			bold: select.bold

			anchors.left: parent.left
			anchors.leftMargin: units.gu(1)

			width: select.width
			height: select.height
			radius: select.radius
			border.width: select.border.width

			border.color: select.border.color
			color: select.color
		}

		ButtonPad {
			y: units.gu(2)
			width: parent.width
			height: units.gu(18)
			id: btns
		}
	}

	Rectangle {
		id: picker
		anchors.fill: parent
		visible: false

		ContentPeerPicker {
			id: peerPicker
			visible: parent.visible
			handler: ContentHandler.Source
			contentType: ContentType.Documents

			onPeerSelected: {
				peer.contentType = ContentType.Documents;
				peer.selectionType = ContentTransfer.Single;
				root.activeTransfer = peer.request();
				picker.visible = false;
			}

			onCancelPressed: {
				console.log("load cancelled");
				picker.visible = false;
				emu.play();
			}
		}
	}

	Connections {
		target: root.activeTransfer
		onStateChanged: {
			if (root.activeTransfer.state === ContentTransfer.Charged) {
				root.importItems(root.activeTransfer.items);
			} else if (root.activeTransfer.state == ContentTransfer.Aborted) {
				emu.play();
				picker.visible = false;
				console.log("aborted transfer");
			}
		}
	}
}
