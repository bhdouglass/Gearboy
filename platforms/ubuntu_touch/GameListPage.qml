import QtQuick 2.9
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

import GearBoy 1.0

Page {
    id: gameList
    anchors.fill: parent

    property var activeTransfer: null

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
                gameList.activeTransfer = peer.request()
                picker.visible = false
            }

            onCancelPressed: {
                picker.visible = false
                emu.play()
            }
        }
    }

    Connections {
        target: gameList.activeTransfer
        onStateChanged: {
            if (gameList.activeTransfer.state === ContentTransfer.Charged) {
                if (gameList.activeTransfer.items.length > 0) {
                    for (var i = 0; i < gameList.activeTransfer.items.length; i++) {
                        var path = gameList.activeTransfer.items[i].url.toString().replace("file://", "")
                        Files.moveRom(path);
                    }
                }
                else {
                    var path = gameList.activeTransfer.items[0].url.toString().replace("file://", "")
                    path = Files.moveRom(path);
                    gameListPage.visible = false;
                    root.load(path);
                }
            } else if (gameList.activeTransfer.state === ContentTransfer.Aborted) {
                picker.visible = false
            }
        }
    }

    ContentPeerModel {
        id: model
        contentType: ContentType.Documents
        handler: ContentHandler.Source
    }

    function requestROM() {
        var peer = null
        for (var i = 0; i < model.peers.length; ++i) {
            var p = model.peers[i]
            var s = p.appId
            if (s.indexOf("filemanager") != -1) {
                peer = p
            }
        }
        if (peer != null) {
            gameList.activeTransfer = peer.request()
        } else if (model.peers.length > 0) {
            picker.visible = true
            /* didn't find ubuntu's file manager, maybe they have another app */
        } else {
            if (emu.requestRom()) {
                emu.play();
                gameListPage.visible = false;
            }
        }
    }

    Rectangle {
        id: bkg
        anchors.fill: parent
        color: "white"
    }

    header: PageHeader {
        title: i18n.tr("ROMs")

        leadingActionBar.actions: [
            Action {
                iconName: 'back'
                text: i18n.tr("Back")
                onTriggered: gameList.visible = false
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: 'add'
                text: i18n.tr("Import ROM")
                onTriggered: requestROM()
            }
        ]

        flickable: flickable
    }

    FolderListModel {
        id: folderList
        showDotAndDotDot: false
        showHidden: false
        rootFolder: "file://" + Files.romDir
        folder: "file://" + Files.romDir
        showDirs: false
    }

    Flickable {
        id: flickable

        contentHeight: column.height
        anchors.fill: parent

        Column {
            id: column

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Label {
                visible: folderList.count === 0
                text: i18n.tr("No ROMs available.\nTap the plus to add your own!")
                width: parent.width
                height: units.gu(10)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Repeater {
                model: folderList

                delegate: ListItem {
                    height: layout.height + divider.height

                    leadingActions: ListItemActions {
                        actions: Action {
                            iconName: "delete"
                            text: i18n.tr("Delete")
                            onTriggered: {
                                var path = folderList.get(index, 'fileURL').toString().replace('file://', '')
                                Files.removeRom(path);
                            }
                        }
                    }


                    ListItemLayout {
                        id: layout
                        title.text: folderList.get(index, 'fileName')

                        ProgressionSlot {}
                    }

                    onClicked: {
                        gameListPage.visible = false;
                        root.load(folderList.get(index, 'fileURL'));
                    }
                }
            }
        }
    }
}
