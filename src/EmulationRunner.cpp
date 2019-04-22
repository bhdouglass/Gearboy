#include <QDebug>
#include <QFile>
#include <QDir>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTime>

#include "EmulationRunner.h"

QList<EmulationRunner *> EmulationRunner::threads;

// Original
GB_Color very_light_green(0x9F, 0xBF, 0x1B);
GB_Color light_green(0x82, 0x9B, 0x0D);
GB_Color dark_green(0x30, 0x62, 0x30);
GB_Color very_dark_green(0x0F, 0x38, 0x0F);

// Colors from https://en.wikipedia.org/wiki/List_of_video_game_console_palettes

// Grayscale
GB_Color white(0xFF, 0xFF, 0xFF);
GB_Color light_gray(0xAA, 0xAA, 0xAA);
GB_Color dark_gray(0x55, 0x55, 0x55);
GB_Color black(0x00, 0x00, 0x00);

// Brown
GB_Color dark_brown(0x84, 0x42, 0x04);
GB_Color light_brown(0xEC, 0x9A, 0x54);

// Pastel Mix
GB_Color pastel_purple(0x9C, 0x92, 0xF4);
GB_Color pink(0xEC, 0x8A, 0x8C);
GB_Color pastel_yellow(0xFC, 0xFA, 0xAC);

// Blue
GB_Color dark_blue(0x04, 0x32, 0xFC);
GB_Color light_blue(0x7C, 0xAA, 0xFC);

// Green
GB_Color orange(0xFC, 0x32, 0x04);
GB_Color green(0x04, 0xFA, 0x04);

// Red
GB_Color red(0xAC, 0x26, 0x24);

// Orange
GB_Color yellow(0xF4, 0xFE, 0x04);

// Dark Blue
GB_Color dark_purple(0x44, 0x32, 0xA4);
GB_Color light_purple(0x9C, 0x92, 0xF4);

// Dark Brown
GB_Color dark_dark_brown(0x94, 0x7A, 0x4C);
GB_Color dark_light_brown(0xC4, 0xAE, 0x94);
GB_Color dark_very_light_brown(0xFC, 0xEA, 0xE4);

// Yellow
GB_Color brown(0x84, 0x42, 0x04);

// Inverted
GB_Color inverted_blue(0x04, 0xA2, 0xA4);

EmulationRunner::EmulationRunner(QObject *parent) : QThread(parent)
{
	for (int i = 0; i < GAMEBOY_WIDTH * GAMEBOY_HEIGHT; ++i) {
		m_buffer[i] = white;
	}

	readFrame(m_pixels, 256);
	threads.append(this);
	m_core.Init();

	m_core.SetDMGPalette(very_light_green, light_green, dark_green, very_dark_green);

	Q_EMIT isPausedChanged();
	Q_EMIT isRunningChanged();
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
                int elapsed = m_time.elapsed();
                int rest = ((i + 1) * 16 - elapsed);
                if (m_pixel_lock.tryLock(rest)) {
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


void EmulationRunner::mute(bool m)
{
    m_lock.lock();
    m_core.EnableSound(!m);
    m_lock.unlock();
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
	m_lock.unlock();
	if (result) {
		qDebug() << "Loaded ROM:" << QString(local_path);
		QString save_path = defaultSavePath();
		if (QFileInfo::exists(save_path)) {
			m_lock.lock();
			m_core.LoadRam(save_path.toStdString().c_str());
			    qDebug() << "Loaded RAM Save File:" << save_path;
			m_lock.unlock();
		} else {
		    qDebug() << "No Save File Found: " << save_path;
		}

        if (m_core.GetCartridge()->HasBattery()) {
            if (!save_path.isNull()) {
                qDebug() << "Setting RAM Save File: " << save_path;
                m_core.GetMemory()->GetCurrentRule()->SetFileStore(save_path.toStdString());
			}
		}

		m_isPaused = false;
		m_isRunning = true;
		start();

		Q_EMIT isPausedChanged();
		Q_EMIT isRunningChanged();
	}
	else {
        qDebug() << "Failed to Load ROM:" << QString(local_path);
	}
	return result;
}


void EmulationRunner::keyPressed(Gameboy_Keys key)
{
	m_core.KeyPressed(key);
}


void EmulationRunner::keyReleased(Gameboy_Keys key)
{
    m_core.KeyReleased(key);
}


void EmulationRunner::pause()
{
	m_isPaused = true;
	Q_EMIT isPausedChanged();
}


void EmulationRunner::play()
{
	m_isPaused = false;
	Q_EMIT isPausedChanged();
}

void EmulationRunner::stop()
{
	m_isRunning = false;
	Q_EMIT isRunningChanged();
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

bool EmulationRunner::isPaused() const {
	return m_isPaused;
}

bool EmulationRunner::isRunning() const {
	return m_isRunning;
}

void EmulationRunner::setDmgPalette(const QString palette) {
	m_dmgPalette = palette;
	if (palette == QStringLiteral("original")) {
		m_core.SetDMGPalette(very_light_green, light_green, dark_green, very_dark_green);
	}
	else if (palette == QStringLiteral("grayscale")) {
		m_core.SetDMGPalette(white, light_gray, dark_gray, black);
	}
	else if (palette == QStringLiteral("brown")) {
		m_core.SetDMGPalette(white, light_brown, dark_brown, black);
	}
	else if (palette == QStringLiteral("pastel_mix")) {
		m_core.SetDMGPalette(pastel_yellow, pink, pastel_purple, black);
	}
	else if (palette == QStringLiteral("blue")) {
		m_core.SetDMGPalette(white, light_blue, dark_blue, black);
	}
	else if (palette == QStringLiteral("green")) {
		m_core.SetDMGPalette(white, green, orange, black);
	}
	else if (palette == QStringLiteral("red")) {
		m_core.SetDMGPalette(white, pink, red, black);
	}
	else if (palette == QStringLiteral("orange")) {
		m_core.SetDMGPalette(white, yellow, orange, black);
	}
	else if (palette == QStringLiteral("dark_blue")) {
		m_core.SetDMGPalette(white, light_purple, dark_purple, black);
	}
	else if (palette == QStringLiteral("dark_green")) {
		m_core.SetDMGPalette(white, green, dark_blue, black);
	}
	else if (palette == QStringLiteral("dark_brown")) {
		m_core.SetDMGPalette(dark_very_light_brown, dark_light_brown, dark_dark_brown, black);
	}
	else if (palette == QStringLiteral("yellow")) {
		m_core.SetDMGPalette(white, yellow, brown, black);
	}
	else if (palette == QStringLiteral("inverted")) {
		m_core.SetDMGPalette(black, inverted_blue, yellow, white);
	}
}

QString EmulationRunner::dmgPalette() const {
	return m_dmgPalette;
}
