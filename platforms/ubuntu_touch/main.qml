import QtQuick 2.3
import Qt.labs.settings 1.0

import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3

import GearBoy 1.0

MainView {
    id: root
    height: units.gu(80)
    width: units.gu(45)

    applicationName: "gearboy.bhdouglass"

    property color gb_black: "#2A2A2A"
    property color gb_black_accent: "#3B3B3B"

    property color gb_gray: Qt.darker("#ABABAB", 1.1)
    property color gb_gray_accent: "#D0D0D0"

    property color gb_light_gray: "#D6D6D6"

    property color gb_white: "#E1E1E1"
    property color gb_white_accent: "#F7F7F7"

    property color gb_blue: "#45457e"
    property color gb_purple: "#B01561"
    property color gb_purple_accent: "#931946"

    property real thin_outline: units.gu(0.25)

    property bool muted: false
    property bool haptics: true

    property bool bold: true

    onMutedChanged: {
        emu.mute(muted)
    }

    function click() {
        if (root.haptics) {
            Haptics.play()
        }
    }

    Connections {
        target: ContentHub
        onImportRequested: {
            var path = transfer.items[0].url.toString().replace("file://", "")
            path = Files.moveRom(path);
            root.load(path);
        }
    }

    GearBoyEmulator {
        id: emu
        color: gb_white

        onIsRunningChanged: {
            if (isRunning) {
                gameListPage.visible = false;
                settingsPage.visible = false;
            }
        }
    }

    Rectangle {
        id: emuCover

        // TODO this covers the emulator when it's not running, figure out how to hide the emulator without covering it
        x: emu.rect.x
        y: parent.height - emu.rect.y - emu.rect.height
        width: emu.rect.width
        height: emu.rect.height
        visible: !emu.isRunning

        color: 'white'
    }

    function load(url) {
        gameListPage.visible = false;
        settingsPage.visible = false;

        var path = url.toString().replace("file://", "")
        if (path) {
            if (emu.loadRom(path)) {
                emu.play()
            } else {
                help.text = i18n.tr("ROM failed to load")
            }
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
        emu.shutdown()
    }

    RoundButton {
        id: shutdownButton

        anchors {
            top: parent.top
            topMargin: units.gu(0.2)
            right: parent.right
            rightMargin: units.gu(0.2)
        }

        visible: gameSettings.showPower
        iconName: 'system-shutdown'
        width: units.gu(3)
        height: width

        onClicked: {
            emu.shutdown();
        }
    }

    RoundButton {
        id: restartButton
        anchors {
            top: shutdownButton.top
            right: shutdownButton.left
            rightMargin: units.gu(1)
        }

        visible: gameSettings.showPower
        iconName: 'system-restart'
        width: units.gu(3)
        height: width

        onClicked: {
            emu.restart();
        }
    }

    Label {
        id: help
        visible: !emu.isRunning

        y: emu.rect.height / 2 - height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("OPEN ROM…")
        fontSize: "x-large"
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

        onClicked: gameListPage.visible = true
    }

    Item {
        id: lefthand
        width: units.gu(18)
        height: units.gu(32)

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            bottom: parent.bottom
        }

        DirectionalPad {
            id: dpad
            x: 0
            y: 0
            width: parent.width
            height: width
            color: gb_black
            wingSize: units.gu(5.5)
            centerColor: gb_black_accent
            innerColor: gb_white_accent

            onLeftPressed: click()
            onRightPressed: click()
            onUpPressed: click()
            onDownPressed: click()
        }

        GBButton {
            id: select
            y: units.gu(22)

            anchors.right: parent.right
            anchors.rightMargin: units.gu(2)

            buttonWidth: units.gu(9.5)
            buttonHeight: units.gu(2.5)
            touchPadding: units.gu(1)

            radius: height / 2

            text: i18n.tr("SELECT")
            textColor: gb_white_accent
            fontSize: "small"

            font {
                bold: true
            }

            onPushed: click()
        }
    }

    Item {
        id: righthand
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
        }
        width: units.gu(18)
        height: units.gu(32)

        GBButton {
            id: start
            y: select.y

            text: i18n.tr("START")
            textColor: select.textColor

            font: select.font
            fontSize: select.fontSize

            anchors.left: parent.left
            anchors.leftMargin: units.gu(2)

            buttonWidth: units.gu(9.5)
            buttonHeight: units.gu(2.5)
            touchPadding: units.gu(1)

            radius: select.radius

            onPushed: click()
        }

        ButtonPad {
            y: 0
            x: units.gu(0.5)
            width: parent.width
            height: units.gu(18)
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
        width: units.gu(16)
        height: units.gu(28)
        color: Qt.darker(gb_white, 1.05)
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
        property bool showPower: true
        property string dmgPalette: 'original'

        onSoundChanged: root.muted = !sound
        onVibrateChanged: root.haptics = vibrate
        onDmgPaletteChanged: emu.dmgPalette = dmgPalette
    }

    Icon {
        name: 'properties'
        color: gb_gray
        width: units.gu(4)
        height: units.gu(4)
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: units.gu(1.5)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                click();

                settingsPage.visible = !settingsPage.visible;
            }
        }
    }

    SettingsPage {
        id: settingsPage
        visible: false

        onVisibleChanged: {
            if  (settingsPage.visible) {
                emu.pause();
            }
            else {
                emu.play();
            }
        }
    }

    GameListPage {
        id: gameListPage
        visible: false

        onVisibleChanged: {
            if  (gameListPage.visible) {
                emu.pause();
            }
            else {
                emu.play();
            }
        }
    }
}
