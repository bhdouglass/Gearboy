import QtQuick 2.3
import GearBoy 1.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3

Item {
	id: root

	property color gb_white: Qt.lighter("#CDCDCD", 1.1)
	property color gb_white_accent: "#EDEDED"
	property color gb_gray: Qt.lighter("#A3A3A3", 1.1)  //text
	property color gb_gray_dark: Qt.lighter("#999999", 1.3) //1.2) //border
	property color gb_gray_accent: Qt.lighter("#999999", 1.7) // fill
	property color gb_black: "#2A2A2A"
	property color gb_black_accent: "#343434" //, 2)
	property color gb_purple: "#B01561"
	property color gb_purple_accent: Qt.darker("#CF2463", 1.4)

	property color gb_grape: "#4B51A4"
	property color gb_dandelion: "#E1A929"
	property color gb_berry: "#C31E44"
	property color gb_kiwi: "#62AD33"
	property color gb_teal: "#009189"

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
		var path = items[0].url.toString().replace("file://", "");
		if (path) {
			if (emu.loadRom(path)) {
				help.visible = false;
				emu.play();
			} else {
				help.text = i18n.tr("ROM failed to load");
				help.visible = true;
				//PopupUtils.open(romfailed, root)	;
			}
		}
	}

	function requestROM() {
		var peer = null;
		for (var i = 0; i < model.peers.length; ++i) {
			var p = model.peers[i];
			var s = p.appId;
			if (s.indexOf("filemanager") != -1) {
				peer = p;
			}
		}
		if (peer == null) {
			PopupUtils.open(findfilemanager, root);
			picker.visible = true;
		} else {
			peer.request(); 
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
	}

	Label {
		id: help
		text: i18n.tr("Open ROM…")
		fontSize: "x-large"
		color: gb_blue //gb_white_accent
		anchors.centerIn: loaderArea
		font.bold: true
	}

	MouseArea {
		id: loaderArea
		width: emu.rect.width
		height: emu.rect.height
		anchors.horizontalCenter: root.horizontalCenter
		anchors.top: root.top
		onClicked: {
			emu.pause();
			requestROM();
		}	
	}

	Item {
		id: lefthand
		width: units.gu(19)
		height: units.gu(38)

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
			textColor: gb_gray //gb_blue //Qt.lighter(emu.color, 1.2)
			fontSize: "medium"
			//bold: true
		}

		Label {
			anchors.top: select.bottom
			anchors.topMargin: units.gu(1)
			anchors.horizontalCenter: select.horizontalCenter

			//text: i18n.tr("SELECT")
			color: gb_blue // Qt.lighter(emu.color, 1.2)
			fontSize: "medium"
			font.bold: select.bold
		}

	}

	Item {
		id: righthand
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: units.gu(19)
		height: units.gu(38)

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

		Label {
			anchors.top: start.bottom
			anchors.topMargin: units.gu(1)
			anchors.horizontalCenter: start.horizontalCenter

			//text: i18n.tr("START")
			//color: gb_blue //Qt.lighter(emu.color, 1.2)
			font.bold: select.bold
			fontSize: "medium"
		}

		GBButton {
			id: a
			x: units.gu(9)
			y: 0
			width: units.gu(9)
			height: units.gu(9)
			radius: units.gu(4.5)
			color: gb_purple
			border.color: gb_purple_accent
			border.width: outline
			text: "A"
			textColor: gb_white_accent
			fontSize: "x-large"
			bold: true
		}

		GBButton {
			id: b
			x: units.gu(1)
			y: units.gu(9)
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

	Rectangle {
		id: picker
		anchors.fill: parent
		visible: false

		ContentPeerPicker {
			id: peerPicker
			visible: parent.visible
			handler: ContentHandler.Source
			contentType: ContentType.All

			onPeerSelected: {
				peer.contentType = ContentType.All;
				peer.selectionType = ContentTransfer.Single;
				root.activeTransfer = peer.request();
				picker.visible = false;
				console.log(peer.appId);
			}

			onCancelPressed: {
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

	Component {
		id: findfilemanager
		GBDialog {
			text: i18n.tr("You need to install Ubuntu File Manager from the store.")
		}
	}

	/*
	Component {
		id: romfailed
		GBDialog {
			text: i18n.tr("ROM failed to load")
		}
	} */
}
