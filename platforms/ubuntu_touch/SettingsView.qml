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

        leadingActionBar.actions: [
            Action {
                iconName: 'back'
                text: i18n.tr('Back')
                onTriggered: settings.visible = false
            }
        ]

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

            ListItem {
                height: powerLayout.height + divider.height
                ListItemLayout {
                    id: powerLayout
                    title.text: i18n.tr('Show power and restart buttons')

                    Switch {
                        id: powerSwitch
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: gameSettings.showPower
                        onCheckedChanged: gameSettings.showPower = checked
                    }
                }

                onClicked: {
                    powerSwitch.checked = !powerSwitch.checked
                }
            }

            ExpandableListItem {
                id: paletteSetting

                listViewHeight: model.length * units.gu(6)
                model: [
                    { text: i18n.tr('Original'), value: 'original' },
                    { text: i18n.tr('Grayscale'), value: 'grayscale' },
                    { text: i18n.tr('Brown'), value: 'brown' },
                    { text: i18n.tr('Pastel Mix'), value: 'pastel_mix' },
                    { text: i18n.tr('Blue'), value: 'blue' },
                    { text: i18n.tr('Green'), value: 'green' },
                    { text: i18n.tr('Red'), value: 'red' },
                    { text: i18n.tr('Orange'), value: 'orange' },
                    { text: i18n.tr('Dark Blue'), value: 'dark_blue' },
                    { text: i18n.tr('Dark Green'), value: 'dark_green' },
                    { text: i18n.tr('Dark Brown'), value: 'dark_brown' },
                    { text: i18n.tr('Yellow'), value: 'yellow' },
                    { text: i18n.tr('Inverted'), value: 'inverted' },
                ]
                title.text: i18n.tr('GB Palette')
                subText.text: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value == gameSettings.dmgPalette) {
                            return model[i].text;
                            break;
                        }
                    }

                    return 'Original';
                }

                delegate: ListItem {
                    height: units.gu(6)

                    ListItemLayout {
                        id: listitemlayout

                        title.text: modelData.text

                        Icon {
                            height: units.gu(2)
                            width: height
                            visible: paletteSetting.subText.text === modelData.text
                            name: 'ok'
                            SlotsLayout.position: SlotsLayout.Last
                        }
                    }

                    onClicked: {
                        gameSettings.dmgPalette = modelData.value;
                        paletteSetting.toggleExpansion();
                    }
                }
            }
        }
    }
}
