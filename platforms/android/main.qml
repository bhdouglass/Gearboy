import QtQuick 2.3
import Qt.labs.settings 1.0

import GearBoy 1.0

Item {
    id: root
    height: unitsgu(80)
    width: unitsgu(45)

    //applicationName: "gearboy.rpattison"

    property color gb_black: "#2A2A2A"
    property color gb_black_accent: "#3B3B3B"

    property color gb_gray: "#ABABAB"
    property color gb_gray_accent: "#D0D0D7"

    property color gb_light_gray: "#D6D6D6"

    property color gb_white: "#E1E1E1"
    property color gb_white_accent: "#F7F7F7"

    property color gb_blue: "#45457e"
    property color gb_purple: "#B01561"
    property color gb_purple_accent: "#931946"

    property real thin_outline: unitsgu(0.25)

    property var activeTransfer: null

    property bool muted: false
    property bool haptics: true

    property bool bold: true

    onMutedChanged: {
        emu.mute(muted)
    }

    function unitsgu(n) {
	return n * 15;
    }

    function i18ntr(s) {
	return s;
    }

    function click() {
        if (root.haptics) {
        }
    }

    GearBoyEmulator {
        id: emu
        color: gb_white
    }

    function importItems(items) {
        load(items[0].url)
    }

    function load(url) {
        var path = url.toString().replace("file://", "")
        console.log(path)
        if (path) {
            if (emu.loadRom(path)) {
                help.visible = false
                emu.play()
            } else {
                help.text = i18ntr("ROM failed to load")
                help.visible = true
            }
        }
    }

    function requestROM() {
	emu.pause()
	if (emu.requestRom()) {
		help.visible = false
		emu.play()
	} else {
		help.text = i18ntr("ROM Failed to Load")
		help.visible = true
	}
    }

    Component.onCompleted: {
        btns.aPressed.connect(emu.aPressed)
        btns.aReleased.connect(emu.aReleased)

        btns.bPressed.connect(emu.bPressed)
        btns.bReleased.connect(emu.bReleased)

        select.pushed.connect(emu.selectPressed)
        select.unpushed.connect(emu.selectReleased)

        start.pushed.connect(emu.startPressed)
        start.unpushed.connect(emu.startReleased)

        dpad.upPressed.connect(emu.upPressed)
        dpad.upReleased.connect(emu.upReleased)

        dpad.downPressed.connect(emu.downPressed)
        dpad.downReleased.connect(emu.downReleased)

        dpad.leftPressed.connect(emu.leftPressed)
        dpad.leftReleased.connect(emu.leftReleased)

        dpad.rightPressed.connect(emu.rightPressed)
        dpad.rightReleased.connect(emu.rightReleased)
    }

    Component.onDestruction: {
        console.log("shutdown")
        emu.shutdown()
    }

    Text {
        id: help
        y: emu.rect.height / 2 - height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18ntr("OPEN ROM…")
        color: gb_blue
        font {
            bold: true
            italic: true
        }
    }

    MouseArea {
        id: loaderArea
        width: emu.rect.width * 0.8
        height: emu.rect.height * 0.9 // keep some padding away from buttons
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        onClicked: requestROM()
    }

    Item {
        id: lefthand
        width: unitsgu(18)
        height: unitsgu(35)

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        DirectionalPad {
            id: dpad
            x: 0
            y: 0
            width: parent.width
            height: width
            color: gb_black
            wingSize: unitsgu(5.5)
            centerColor: gb_black_accent
            innerColor: gb_white_accent

            onLeftPressed: click()
            onRightPressed: click()
            onUpPressed: click()
            onDownPressed: click()
        }

        GBButton {
            id: select
            y: unitsgu(22)

            anchors.right: parent.right
            anchors.rightMargin: unitsgu(1)

            buttonWidth: unitsgu(10.5)
            buttonHeight: unitsgu(3)
            touchPadding: unitsgu(1)

            radius: height / 2

            color: gb_white_accent
            border.color: gb_gray_accent

            text: i18ntr("SELECT")
            textColor: gb_gray

            font {
                bold: true
            }

            onPushed: click()
        }
    }

    Item {
        id: righthand
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: unitsgu(18)
        height: unitsgu(35)

        GBButton {
            id: start
            y: select.y

            text: i18ntr("START")
            textColor: select.textColor

            font: select.font

            anchors.left: parent.left
            anchors.leftMargin: unitsgu(1)

            buttonWidth: unitsgu(10)
            buttonHeight: unitsgu(3)
            touchPadding: unitsgu(1)

            radius: select.radius
            border.width: select.border.width

            color: gb_white_accent
            border.color: gb_gray_accent

            onPushed: click()
        }

        ButtonPad {
            y: 0
            x: unitsgu(0.5)
            width: parent.width
            height: unitsgu(18)
            id: btns

            onAPressed: click()
            onBPressed: click()

            font {
                bold: root.bold
            }
        }
    }

    property var startKey: Qt.Key_Return
    property var selectKey: Qt.Key_Backspace
    property var upKey: Qt.Key_Up
    property var downKey: Qt.Key_Down
    property var leftKey: Qt.Key_Left
    property var rightKey: Qt.Key_Right
    property var aKey: Qt.Key_A
    property var bKey: Qt.Key_B

    Keys.onPressed: {
        var key = event.key
        if (key == leftKey) {
            emu.leftPressed()
            event.accepted = true
        } else if (key == rightKey) {
            emu.rightPressed()
            event.accepted = true
        } else if (key == downKey) {
            emu.downPressed()
            event.accepted = true
        } else if (key == upKey) {
            emu.upPressed()
            event.accepted = true
        } else if (key == aKey) {
            emu.aPressed()
            event.accepted = true
        } else if (key == bKey) {
            emu.bPressed()
            event.accepted = true
        } else if (key == startKey) {
            emu.startPressed()
            event.accepted = true
        } else if (key == selectKey) {
            emu.selectPressed()
            event.accepted = true
        } else {

        }
    }

    Keys.onReleased: {
        var key = event.key
        if (key == leftKey) {
            emu.leftReleased()
            event.accepted = true
        } else if (key == rightKey) {
            emu.rightReleased()
            event.accepted = true
        } else if (key == downKey) {
            emu.downReleased()
            event.accepted = true
        } else if (key == upKey) {
            emu.upReleased()
            event.accepted = true
        } else if (key == aKey) {
            emu.aReleased()
            event.accepted = true
        } else if (key == bKey) {
            emu.bReleased()
            event.accepted = true
        } else if (key == startKey) {
            emu.startReleased()
            event.accepted = true
        } else if (key == selectKey) {
            emu.selectReleased()
            event.accepted = true
        }
    }

    Rectangle {
        id: shaded_corner
        width: unitsgu(16)
        height: unitsgu(28)
        color: gb_light_gray
        rotation: 50

        anchors {
            verticalCenter: parent.bottom
            horizontalCenter: parent.right
        }
    }

    Settings {
        id: gameSettings
        property bool vibrate: root.haptics
        property bool sound: !root.muted
        onSoundChanged: {
            root.muted = !sound
        }
        onVibrateChanged: {
            root.haptics = vibrate
        }
    }

    Text {
        text: gameSettings.sound ? "Mute" : "Sound"
        color: gb_gray
        width: unitsgu(5)
        height: unitsgu(5)
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: unitsgu(1)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                click();
                gameSettings.sound = !gameSettings.sound;
            }
        }
    }
}
