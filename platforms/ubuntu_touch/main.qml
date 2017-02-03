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

    property bool muted: false
    property bool haptics: true

    onMutedChanged: {
        emu.mute(muted)
    }

    function click() {
        if (root.haptics) {
            Haptics.play()
        }
    }

    ContentPeerModel {
        id: model
        contentType: ContentType.Documents
        handler: ContentHandler.Source
    }

    Connections {
        target: ContentHub
        onImportRequested: {
            root.importItems(transfer.items)
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
                help.text = i18n.tr("ROM failed to load")
                help.visible = true
            }
        }
    }

    function requestROM() {
        emu.pause()
        var peer = null
        for (var i = 0; i < model.peers.length; ++i) {
            var p = model.peers[i]
            var s = p.appId
            if (s.indexOf("filemanager") != -1) {
                peer = p
            }
        }
        if (peer != null) {
            root.activeTransfer = peer.request()
        } else if (model.peers.length > 0) {
            picker.visible
                    = true /* didn't find ubuntu's file manager, maybe they have another app */
        } else {
            if (emu.requestRom()) {
                help.visible = false
                emu.play()
            } else {
                help.text = i18n.tr("ROM Failed to Load")
                help.visible = true
            }
        }
    }

    Component.onCompleted: {
        btns.aPressed.connect(emu.aPressed)
        btns.aReleased.connect(emu.aReleased)

        btns.bPressed.connect(emu.bPressed)
        btns.bReleased.connect(emu.bReleased)

        select.pressed.connect(emu.selectPressed)
        select.released.connect(emu.selectReleased)

        start.pressed.connect(emu.startPressed)
        start.released.connect(emu.startReleased)

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

    Label {
        id: help
        text: i18n.tr("OPEN ROM…")
        fontSize: "x-large"
        color: gb_blue
        font.bold: true
        font.italic: true
        y: emu.rect.height / 2 - height / 2
        anchors.horizontalCenter: parent.horizontalCenter
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
        width: units.gu(18)
        height: units.gu(35)

        anchors.left: parent.left
        anchors.bottom: parent.bottom

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
            y: units.gu(25)

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
            bold: true

            onPressed: click()
        }
    }

    Item {
        id: righthand
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: units.gu(18)
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

            color: gb_gray_accent
            border.color: gb_gray_dark

            onPressed: click()
        }

        ButtonPad {
            y: 0
            width: parent.width
            height: units.gu(18)
            id: btns

            onAPressed: click()
            onBPressed: click()
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
                peer.contentType = ContentType.Documents
                peer.selectionType = ContentTransfer.Single
                root.activeTransfer = peer.request()
                picker.visible = false
            }

            onCancelPressed: {
                console.log("load cancelled")
                picker.visible = false
                emu.play()
            }
        }
    }

    Connections {
        target: root.activeTransfer
        onStateChanged: {
            if (root.activeTransfer.state === ContentTransfer.Charged) {
                root.importItems(root.activeTransfer.items)
            } else if (root.activeTransfer.state == ContentTransfer.Aborted) {
                emu.play()
                picker.visible = false
                console.log("aborted transfer")
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
        width: units.gu(16)
        height: units.gu(28)
        color: Qt.darker(gb_white, 1.05)
        rotation: 50
        border.width: units.gu(0.25)
        border.color: Qt.darker(gb_white, 1.07)
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

    SettingsView {
        id: settingsView
        visible: false
    }

    Icon {
        name: "properties"
        color: Qt.darker(gb_white, 1.3)
        width: units.gu(5)
        height: units.gu(5)
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: units.gu(1)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                settingsView.visible = !settingsView.visible
                if (settingsView.visible) {
                    emu.pause()
                } else {
                    emu.play()
                }
            }
        }
    }
}
