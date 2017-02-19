import QtQuick 2.3

MultiPointTouchArea {
	id: root
	property int bsize: width / 2

	property color gb_white_accent: "#EDEDED"
	property color gb_purple: "#B01561"
	property color gb_purple_accent: Qt.darker("#CF2463", 1.4)
    property color gb_purple_pressed: Qt.darker(gb_purple, 1.03)
	property real outline: unitsgu(0.375)
    property real pressScale: 0.95
    property real bwidth: 0
    property alias font: alabel.font

    function unitsgu(n) {
	return n * 15;
    }
	
	Rectangle {
		id: a

		x: bsize - unitsgu(1)
        y: unitsgu(0.5)
		width: bsize
		height: bsize 
		radius: bsize / 2

		color: gb_purple
		border.color: gb_purple_accent
		border.width: outline

		Text {
			id: alabel
			anchors.centerIn: parent
			color: gb_white_accent
			text: "A"
			//fontSize: "x-large"
		}
	}

	Rectangle {
		id: b
		x: 0
        y: bsize / 2 + unitsgu(3.5)
		width: bsize
		height: bsize
		radius: bsize / 2
        color: gb_purple
        border.color: gb_purple_accent
        border.width: a.border.width
	
		Text {
			id: blabel
			anchors.centerIn: parent
			text: "B"
			color: gb_white_accent
			//fontSize: "x-large"
            font: alabel.font
		}
	}

	property bool aIsDown: false
	property bool bIsDown: false

	signal aPressed()
	signal bPressed()
	signal aReleased()
	signal bReleased()

    onAPressed: {
        a.color = gb_purple_pressed;
        a.scale = pressScale;
        bwidth = a.border.width;
        a.border.width = bwidth / 2;
    }

    onAReleased: {
        a.color = gb_purple;
        a.scale = 1;
        a.border.width = bwidth;
    }

    onBPressed: {
        b.color = gb_purple_pressed;
        b.scale = pressScale;
        bwidth = b.border.width;
        b.border.width = bwidth / 2;

    }

    onBReleased: {
        b.color = gb_purple;
        b.scale = 1;
        b.border.width = bwidth;
    }

	onTouchUpdated: {
        var r = a.radius + unitsgu(1.5); // some extra space for edge presses
		var ax = a.x + r;
		var bx = b.x + r;
		var by = b.y + r;
		var ay = a.y + r;
		var r2 = r * r;

		var aDown = false;
		var bDown = false;

		for (var i in touchPoints) {
			var pt = touchPoints[i];
			if (pt.pressed) {
				var dax = ax - pt.x;
				var day = ay - pt.y;
				var dbx = bx - pt.x;
				var dby = by - pt.y;

				if (dax * dax + day * day <= r2) {
					aDown = true;
				} 

				if (dbx * dbx + dby * dby <= r2) {
					bDown = true;
				}
			}
		}

		if (aDown != aIsDown) {
			if (!aDown) {
				aReleased();
			} else if (!aIsDown) {
				aPressed();
			}
			aIsDown = aDown;
		}

        if (bDown != bIsDown) {
			if (!bDown) {
				bReleased();
			} else if (!bIsDown) {
				bPressed();
			}
			bIsDown = bDown;
		}
	}
}
