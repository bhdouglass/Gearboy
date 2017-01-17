#ifndef GBEmulator_H
#define GBEmulator_H

#include <QtQuick/QQuickItem>
#include <QMutex>
#include <QTime>

#include "gearboy.h"
#include "PixelRenderer.h"


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

	QString defaultPath() const;
	QString defaultSavePath() const;

	bool importROM(const char *rom_path);

signals:
	void rectChanged();

public slots:
	void sync();
	void cleanup();

	bool loadRom(QString path);
	void save();
	void play();
	void pause();

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

	void requestROM();

private slots:
	void handleWindowChanged(QQuickWindow *win);
protected:
	void timerEvent(QTimerEvent *event) Q_DECL_OVERRIDE;

private:
	void keyPressed(Gameboy_Keys key);
	void keyReleased(Gameboy_Keys key);

	GB_Color m_buffer[GAMEBOY_WIDTH * GAMEBOY_HEIGHT];
	PixelRenderer *m_renderer;
	QMutex* m_lock;
	bool m_isPaused;
	GearboyCore* m_core;
	QRect m_rect;
	QColor m_color;
};

#endif	/* GBEMULATOR_H */

