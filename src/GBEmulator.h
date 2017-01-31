#ifndef GBEmulator_H
#define GBEmulator_H

#include <QtQuick/QQuickItem>
#include <QMutex>
#include <QTime>

#include "gearboy.h"
#include "PixelRenderer.h"
#include "EmulationRunner.h"

class GBEmulator : public QQuickItem
{
	Q_OBJECT

	Q_PROPERTY(QRect rect READ rect WRITE setRect NOTIFY rectChanged)
	Q_PROPERTY(QColor color READ color WRITE setColor)

public:
	GBEmulator();
	~GBEmulator();

	QRect rect() { return m_rect; }
	void setRect(QRect);
	void setColor(QColor);
	QColor color() { return m_color; }

signals:
	void rectChanged();

public slots:
    void timerEvent(QTimerEvent *);

    void redraw();
	void sync();
	void cleanup();

	bool loadRom(QString path);
	void save();
	void play();
	void pause();
    void shutdown();

	void upPressed();
	void leftPressed();
	void rightPressed();
	void downPressed();

	void startPressed();
	void selectPressed();

	void aPressed();
	void bPressed();

	void upReleased();
	void leftReleased();
	void rightReleased();
	void downReleased();

	void startReleased();
	void selectReleased();

	void aReleased();
	void bReleased();
	void mute(bool);
	bool requestRom();

private slots:
	void handleWindowChanged(QQuickWindow *win);

private:
	EmulationRunner *m_emu;
	PixelRenderer *m_renderer;
	QRect m_rect;
	QColor m_color;
};

#endif	/* GBEMULATOR_H */

