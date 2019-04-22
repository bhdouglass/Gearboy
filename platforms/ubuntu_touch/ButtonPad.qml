import QtQuick 2.3
import Ubuntu.Components 1.3

MultiPointTouchArea {
    id: root
    property int bsize: width / 2

    property color gb_white_accent: "#EDEDED"
    property color gb_purple: "#B01561"
    property color gb_purple_accent: Qt.darker("#CF2463", 1.4)
    property color gb_purple_pressed: Qt.darker(gb_purple, 1)
    property color gb_accent_pressed: Qt.darker(gb_purple_accent, 1)
    property real outline: units.gu(0.375)
    property real pressScale: 0.95
    property alias font: alabel.font

    Rectangle {
        id: a

        x: bsize - units.gu(1)
        y: units.gu(0.5)
        width: bsize
        height: bsize
        radius: bsize / 2
        color: Qt.darker(gb_purple_accent, 1.4)

        Rectangle {
            id: abutton
            anchors.fill: parent
            anchors.margins: units.gu(0.2)
            color: gb_purple
            border.color: gb_purple_accent
            border.width: outline
            radius: width / 2

            Label {
                id: alabel
                anchors.centerIn: parent
                color: gb_white_accent
                text: "A"
                fontSize: "x-large"
            }
        }
    }

    Rectangle {
        id: b
        x: 0
        y: bsize / 2 + units.gu(3.5)
        width: bsize
        height: bsize
        radius: bsize / 2
        color: Qt.darker(gb_purple_accent, 1.4)

        Rectangle {
            id: bbutton
            anchors.fill: parent
            anchors.margins: units.gu(0.2)
            color: gb_purple
            border.color: gb_purple_accent
            border.width: abutton.border.width
            radius: width / 2

            Label {
                id: blabel
                anchors.centerIn: parent
                text: "B"
                color: gb_white_accent
                fontSize: "x-large"
                font: alabel.font
            }
        }
    }

    property bool aIsDown: false
    property bool bIsDown: false

    signal aPressed
    signal bPressed
    signal aReleased
    signal bReleased

    onAPressed: {
        abutton.color = gb_purple_pressed
        abutton.scale = pressScale
        abutton.border.color = gb_accent_pressed
    }

    onAReleased: {
        abutton.color = gb_purple
        abutton.scale = 1
        abutton.border.color = gb_purple_accent
    }

    onBPressed: {
        bbutton.color = gb_purple_pressed
        bbutton.scale = pressScale
        bbutton.border.color = gb_accent_pressed
    }

    onBReleased: {
        bbutton.color = gb_purple
        bbutton.scale = 1
        bbutton.border.color = gb_purple_accent
    }

    onTouchUpdated: {
        var r = bsize / 2 + units.gu(1.5) // some extra space for edge presses
        var ax = a.x + r
        var bx = b.x + r
        var by = b.y + r
        var ay = a.y + r
        var r2 = r * r

        var aDown = false
        var bDown = false

        for (var i in touchPoints) {
            var pt = touchPoints[i]
            if (pt.pressed) {
                var dax = ax - pt.x
                var day = ay - pt.y
                var dbx = bx - pt.x
                var dby = by - pt.y

                if (dax * dax + day * day <= r2) {
                    aDown = true
                }

                if (dbx * dbx + dby * dby <= r2) {
                    bDown = true
                }
            }
        }

        if (aDown != aIsDown) {
            if (!aDown) {
                aReleased()
            } else if (!aIsDown) {
                aPressed()
            }
            aIsDown = aDown
        }

        if (bDown != bIsDown) {
            if (!bDown) {
                bReleased()
            } else if (!bIsDown) {
                bPressed()
            }
            bIsDown = bDown
        }
    }
}
