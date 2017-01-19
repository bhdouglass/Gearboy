#include <QDebug>
#include <QFile>
#include <QDir>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTime>

#include "EmulationRunner.h"

EmulationRunner::EmulationRunner(QObject *parent) : QThread(parent)
{
	GB_Color llgreen = {.red=0x9F, .green=0xBF, .blue=0x1B, .alpha=255};
	GB_Color lgreen  = {.red=0x82, .green=0x9B, .blue=0x0D, .alpha=255};
	GB_Color dgreen  = {.red=0x30, .green=0x62, .blue=0x30, .alpha=255};
	GB_Color ddgreen = {.red=0x0F, .green=0x38, .blue=0x0F, .alpha=255};
	GB_Color white   = {.red=0xFF, .green=0xFF, .blue=0xFF, .alpha=255};

	for (int i = 0; i < GAMEBOY_WIDTH * GAMEBOY_HEIGHT; ++i) { 
		m_buffer[i] = white;
	}

	m_core.Init();
	m_core.SetDMGPalette(llgreen, lgreen, dgreen, ddgreen);
	m_isPaused = true;
	m_isRunning = true;
}


void EmulationRunner::run()
{
	while (m_isRunning) {
		m_time.start();
		for (int i = 0; i < 3; ++i) { // run 3 frames, at 60 fps, 50ms for 3.
			if (!m_isPaused) {
				m_lock.lock();
				m_core.RunToVBlank(m_buffer);
				m_lock.unlock();
				/*
				if (m_pixel_lock.tryLock(i)) { 
					readFrame(m_pixels, 256);
					m_pixel_lock.unlock();
				} */
			}
		}
		int rest = 50 - m_time.elapsed();
		if (rest > 0) msleep(rest);
	}
}


unsigned char *EmulationRunner::openPixels()
{
    m_pixel_lock.lock();
	return m_pixels;
}


void EmulationRunner::closePixels()
{
    m_pixel_lock.unlock();
}


EmulationRunner::~EmulationRunner() { }


bool EmulationRunner::loadRom(QString path)
{
	std::string cppstr = path.toStdString();
   	const char *local_path = cppstr.c_str(); 
	m_lock.lock();
	bool result = m_core.LoadROM(local_path, false);
	if (result) {
		qDebug() << "successful load ROM";
		QString save_path = defaultSavePath();
		if (QFileInfo::exists(save_path)) {
			qDebug() << "Loading ram save file";
			m_core.LoadRam(save_path.toStdString().c_str());
			qDebug() << "Loaded Save File";
		} else {
			qDebug() << "No Save File Found. checked: " << save_path;
		}
	} else {
		qDebug() << "Failed to Load ROM";
	}
	m_lock.unlock();
	return result;
}


void EmulationRunner::keyPressed(Gameboy_Keys key)
{
	m_lock.lock();
	m_core.KeyPressed(key);
	m_lock.unlock();
}


void EmulationRunner::keyReleased(Gameboy_Keys key)
{
	m_lock.lock();
	m_core.KeyReleased(key);
	m_lock.unlock();
}


void EmulationRunner::pause()
{
	m_isPaused = true;
}


void EmulationRunner::play()
{
	m_isPaused = false;
}


void EmulationRunner::save()
{
	m_lock.lock();
	QString path = defaultSavePath();
   	if (!path.isNull()) {
		qDebug() << "Saving Game to: " << path;
		if (not m_core.SaveRam(path.toStdString().c_str())) {
			qDebug() << "Failed to save ram to: " << path;
		}
	} else {
		qDebug() << "No Game Loaded to Save";
	}
	m_lock.unlock();
}


void EmulationRunner::readFrame(unsigned char *pixels, int width)
{
	for (int y = 0; y < GAMEBOY_HEIGHT; ++y) {
		for (int x = 0; x < GAMEBOY_WIDTH; ++x) {
			int src = (GAMEBOY_WIDTH * y + x); 
			int dest = (y * width + x) * 2;
			GB_Color color = m_buffer[src];
			unsigned char r = color.red;
			unsigned char g = color.green;
			unsigned char b = color.blue;
			//unsigned char a = m_pixels[src + 3];
			//((a >> 4) ? 1 : 0); force alpha on, not meaningful
			// bits   channel
			// 11--15  Red
			//  6--10  Green
			//  1--5   Blue
			//  0      Alpha  
			pixels[dest + 0] = ((g << 3) & 0xC0) | (b >> 2) | 1;
			pixels[dest + 1] = (r & 0xF8) | (g >> 5);
		}
	}
}


QString EmulationRunner::defaultPath()
{
	std::string rom_name;
	Cartridge *cartridge = m_core.GetCartridge();
   	if (cartridge && cartridge->IsLoadedROM()) {
		rom_name = cartridge->GetName();
	}

	if (rom_name.empty()) return QString();

	QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
	QDir saveloc(path);
	if (!saveloc.exists()) {
		if (not saveloc.mkpath(".")) {
			qDebug() << "Failed to create save path: " << path;
		}
	}
	rom_name.erase(remove_if(rom_name.begin(), rom_name.end(), ::isspace), rom_name.end());
        path.append(QString(("/" + rom_name).c_str()));
	return path;
}


QString EmulationRunner::defaultSavePath()
{
	QString path = defaultPath();
	if (path.isNull()) {
		return path;
	} else {
		path.append(".gearboy");
		return path;
	}
}

