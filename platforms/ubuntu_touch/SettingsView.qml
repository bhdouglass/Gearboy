import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0

Page {
    id: settings
    anchors.fill: parent

    Rectangle {
        id: bkg
        anchors.fill: parent
        color: "white"
    }

    header: PageHeader {
        title: i18n.tr("Settings")
        flickable: settingsPlugin
    }

    Flickable {
        id: settingsPlugin

        contentHeight: _settingsColumn.height
        anchors.fill: parent

        Column {
            id: _settingsColumn

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ListItem {
                height: soundLayout.height + divider.height
                ListItemLayout {
                    id: soundLayout
                    title.text: i18n.tr("Sound")

                    Switch {
                        id: soundSwitch
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: gameSettings.sound
                        onCheckedChanged: {
                            if (checked) {
                                gameSettings.sound = true
                            } else {
                                gameSettings.sound = false
                            }
                        }
                    }
                }

                onClicked: {
                    soundSwitch.checked = !soundSwitch.checked
                }
            }

            ListItem {
                height: vibrationLayout.height + divider.height
                ListItemLayout {
                    id: vibrationLayout
                    title.text: i18n.tr("Vibration")

                    Switch {
                        id: vibrateSwitch
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: gameSettings.vibrate
                        onCheckedChanged: {
                            if (checked) {
                                gameSettings.vibrate = true
                            } else {
                                gameSettings.vibrate = false
                            }
                        }
                    }
                }

                onClicked: {
                    vibrateSwitch.checked = !vibrateSwitch.checked
                }
            }
        }
    }
}
