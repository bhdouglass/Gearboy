#include <QDebug>
#include <QFile>
#include <QDir>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTime>

#include "EmulationRunner.h"

QList<QThread *> EmulationRunner::threads;

EmulationRunner::EmulationRunner(QObject *parent) : QThread(parent)
{
    GB_Color llgreen(0x9F, 0xBF, 0x1B);
    GB_Color lgreen(0x82, 0x9B, 0x0D);
    GB_Color dgreen(0x30, 0x62, 0x30);
    GB_Color ddgreen(0x0F, 0x38, 0x0F);
    GB_Color white(0xFF, 0xFF, 0xFF);

	for (int i = 0; i < GAMEBOY_WIDTH * GAMEBOY_HEIGHT; ++i) { 
		m_buffer[i] = white;
	}
    readFrame(m_pixels, 256);
	threads.append(this);
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
                if (m_pixel_lock.tryLock(2)) {
                    readFrame(m_pixels, 256);
					m_pixel_lock.unlock();
				} 
			}
		}
        int elapsed = m_time.elapsed();
        int rest = 50 - elapsed;
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

void EmulationRunner::stop()
{
	m_isRunning = false;
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
    u16 *buff = reinterpret_cast<u16*>(pixels);
    u16 *src = reinterpret_cast<u16*>(m_buffer);
    for (int y = 0; y < GAMEBOY_HEIGHT; ++y) {
        std::copy(&src[y * GAMEBOY_WIDTH], &src[(y + 1) * GAMEBOY_WIDTH], &buff[y * width]);
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

