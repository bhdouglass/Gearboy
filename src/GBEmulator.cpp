#include <QDebug>
#include <QtQuick/qquickwindow.h>
#include <QFile>
#include <QDir>
#include <QThread>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>
#include <QIODevice>
#include <QTime>


#include "GBEmulator.h"

GBEmulator::GBEmulator() : m_renderer(0)
{
	GB_Color llgreen = {.red=0x9F, .green=0xBF, .blue=0x1B, .alpha=255};
	GB_Color lgreen  = {.red=0x82, .green=0x9B, .blue=0x0D, .alpha=255};
	GB_Color dgreen  = {.red=0x30, .green=0x62, .blue=0x30, .alpha=255};
	GB_Color ddgreen = {.red=0x0F, .green=0x38, .blue=0x0F, .alpha=255};

	GB_Color white = {.red=0xFF, .green=0xFF, .blue=0xFF, .alpha=255};
	for (int i = 0; i < GAMEBOY_WIDTH * GAMEBOY_HEIGHT; ++i) { 
		m_buffer[i] = white;
	}

	m_lock = new QMutex();
	m_core = new GearboyCore();
	m_core->Init();

	m_core->SetDMGPalette(llgreen, lgreen, dgreen, ddgreen);
	connect(this, &QQuickItem::windowChanged, this, &GBEmulator::handleWindowChanged);
	windowChanged(window());
	m_isPaused = true;
	startTimer(16, Qt::PreciseTimer);
}


void GBEmulator::timerEvent(QTimerEvent*)
{
    if (!m_isPaused && m_lock->tryLock(15)) {
        m_core->RunToVBlank(m_buffer);
        m_lock->unlock();
        window()->update();
    }
}


void GBEmulator::setColor(QColor c) 
{
	m_color = c;
	if (m_renderer) {
		m_renderer->setColor(c);
	} 
}


void GBEmulator::setRect(QRect r)
{
	if (r != m_rect) {
		m_rect = r;
		emit rectChanged();
	}
}


GBEmulator::~GBEmulator()
{
	SafeDelete(m_core);
}


void GBEmulator::handleWindowChanged(QQuickWindow *win)
{
	if (win) {
		connect(win, &QQuickWindow::beforeSynchronizing, this, &GBEmulator::sync, Qt::DirectConnection);
		connect(win, &QQuickWindow::sceneGraphInvalidated, this, &GBEmulator::cleanup, Qt::DirectConnection);
		win->setClearBeforeRendering(false);
	} 
}


void GBEmulator::cleanup()
{
	SafeDelete(m_renderer);
}


void GBEmulator::sync()
{
	if (!m_renderer) {
		m_renderer = new PixelRenderer(GAMEBOY_WIDTH, GAMEBOY_HEIGHT, m_buffer);
		connect(window(), &QQuickWindow::beforeRendering, m_renderer, &PixelRenderer::paint, Qt::DirectConnection);
		m_renderer->setBufferLock(m_lock);
		m_renderer->setColor(color());
	}

	QSize size = window()->size() * window()->devicePixelRatio();
	m_renderer->setWindow(window());
	m_renderer->setViewRect(QRect(QPoint(0, 0), size));
	setRect(m_renderer->viewRect());
	window()->update();
}


void GBEmulator::upPressed() { keyPressed(Up_Key); }
void GBEmulator::leftPressed() { keyPressed(Left_Key); }
void GBEmulator::rightPressed() { keyPressed(Right_Key); }
void GBEmulator::downPressed() { keyPressed(Down_Key); }
void GBEmulator::startPressed() { keyPressed(Start_Key); }
void GBEmulator::selectPressed() { keyPressed(Select_Key); }
void GBEmulator::aPressed() { keyPressed(A_Key); }
void GBEmulator::bPressed() { keyPressed(B_Key); }
void GBEmulator::upReleased() { keyReleased(Up_Key); }
void GBEmulator::leftReleased() { keyReleased(Left_Key); }
void GBEmulator::rightReleased() { keyReleased(Right_Key); }
void GBEmulator::downReleased() { keyReleased(Down_Key); }
void GBEmulator::startReleased() { keyReleased(Start_Key); }
void GBEmulator::selectReleased() { keyReleased(Select_Key); }
void GBEmulator::aReleased() { keyReleased(A_Key); }
void GBEmulator::bReleased() { keyReleased(B_Key); }


bool GBEmulator::loadRom(QString path)
{
	save();
	std::string cppstr = path.toStdString();
   	const char *local_path = cppstr.c_str(); 
	m_lock->lock();
	bool result = m_core->LoadROM(local_path, false);
	if (result) {
		QString save_path = defaultSavePath();
		if (QFileInfo::exists(save_path)) {
			m_core->LoadRam(save_path.toStdString().c_str());
			qDebug() << "Loaded Save File";
		} else {
			qDebug() << "No Save File Found. checked: " << save_path;
		}
	} else {
		qDebug() << "Failed to Load ROM";
	}
	m_lock->unlock();
	return result;
}


QString GBEmulator::defaultPath() const
{
	Cartridge *cartridge = m_core->GetCartridge();
	if (cartridge == NULL || !cartridge->IsLoadedROM()) {
		return QString();
	}
	QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
	QDir saveloc(path);
	if (!saveloc.exists()) {
        if (not saveloc.mkpath(".")) {
			qDebug() << "Failed to create save path: " << path;
		}
	}
	std::string name = cartridge->GetName();
	name.erase(remove_if(name.begin(), name.end(), ::isspace), name.end());
        path.append(QString(("/" + name).c_str()));
	return path;
}


QString GBEmulator::defaultSavePath() const
{
	QString path = defaultPath();
	if (path.isNull()) {
		return path;
	} else {
		path.append(".gearboy");
		return path;
	}
}


bool GBEmulator::importROM(const char *rom_path)
{
	QString path = defaultPath();
	if (path.isNull()) {
		return false;
	}
	path += ".rom";
	QFileInfo info(path);
	if (info.exists()) {
		return true;
	}
	qDebug() << "Copying ROM to " << path << "from" << rom_path;
	return QFile::copy(rom_path, path);
}


void GBEmulator::keyPressed(Gameboy_Keys key)
{
	m_lock->lock();
	m_core->KeyPressed(key);
	m_lock->unlock();
}


void GBEmulator::keyReleased(Gameboy_Keys key)
{
	m_lock->lock();
	m_core->KeyReleased(key);
	m_lock->unlock();
}


void GBEmulator::pause()
{
	if (!m_isPaused) {
		m_isPaused = true;
	}
}


void GBEmulator::play()
{
	if (m_isPaused) {
		m_isPaused = false;
	}
}


void GBEmulator::save()
{
	QString path = defaultSavePath();
   	if (!path.isNull()) {
		qDebug() << "Saving Game to: " << path;
		m_lock->lock();
		if (not m_core->SaveRam(path.toStdString().c_str())) {
			qDebug() << "Failed to save ram to: " << path;
		}
		m_lock->unlock();
	} else {
		qDebug() << "No Game Loaded to Save";
	}
}


void GBEmulator::requestROM()
{


}
