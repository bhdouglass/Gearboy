#ifndef Emulation_Runner_H 
#define Emulation_Runner_H

#include <QMutex>
#include <QObject>
#include <QString>
#include <QThread>
#include <QTime>
#include <QThread>

#include "GearboyCore.h"
#include "gearboy.h"


class EmulationRunner : public QThread
{
	Q_OBJECT
public:
	EmulationRunner(QObject *parent);
	~EmulationRunner();

	static void waitAll() {
		foreach (QThread *t, threads) {
			t->wait();
		}
	}

	/* blocks and reads the frame into pixels in RGB5A1 format, pixel's width must be at least GAMEBOY_WIDTH */
	unsigned char *openPixels();
	void closePixels();

	bool loadRom(QString path);

	void save();
	void play();
	void pause();
	void stop();

	void keyPressed(Gameboy_Keys key);
	void keyReleased(Gameboy_Keys key);

protected:
	virtual void run();
	QString defaultPath();
	QString defaultSavePath();
	void readFrame(unsigned char *pixels, int width);

private:
	unsigned char m_pixels[256 * 256 * 2];
	GB_Color m_buffer[GAMEBOY_WIDTH * GAMEBOY_HEIGHT];
	GearboyCore m_core;
	QMutex m_lock;
	QMutex m_pixel_lock;
	bool m_isPaused;
	bool m_isRunning;
	QTime m_time;
    QTime m_fps_time;

	static QList<QThread *> threads;
};

#endif 
