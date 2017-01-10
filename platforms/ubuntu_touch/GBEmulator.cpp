#include <QDebug>
#include <QtQuick/qquickwindow.h>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>
#include <QIODevice>


#include "GBEmulator.h"


GBEmulator::GBEmulator() : m_renderer(0)
{
	GB_Color white = {.red=255, .green=255, .blue=255, .alpha=255};
	for (int i = 0; i < GAMEBOY_HEIGHT * GAMEBOY_WIDTH; ++i) {
		m_buffer[i] = white;
	}

	m_lock = new QMutex();
	m_core = new GearboyCore();
	m_timer = new QTimer(this);
	m_core->Init();

	connect(this, &QQuickItem::windowChanged, this, &GBEmulator::handleWindowChanged);
	connect(m_timer, SIGNAL(timeout()), this, SLOT(tick()));
	windowChanged(window());
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


void GBEmulator::stateChanged(Qt::ApplicationState state) 
{
	if (state == Qt::ApplicationActive) {
		play();
	} else {
		pause();
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
		m_renderer = new PixelRenderer();
		connect(window(), &QQuickWindow::beforeRendering, m_renderer, &PixelRenderer::paint, Qt::DirectConnection);
		m_renderer->setPixelBuffer(m_buffer);
		m_renderer->setBufferSize(GAMEBOY_WIDTH, GAMEBOY_HEIGHT);
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
	std::string cppstr = path.toStdString();
   	const char *local_path = cppstr.c_str(); 
	save();
	m_lock->lock();
	bool result = m_core->LoadROM(local_path, false);
	if (result) {
		QString save_path = defaultSavePath();
		if (!save_path.isNull()) {
			m_core->LoadRam(save_path.toStdString().c_str());
		}
	}
	m_lock->unlock();
	return result;
}


void GBEmulator::tick()
{
	if (!m_isPaused && m_lock->tryLock(m_timer->interval() / 2)) { /* drop after half an update cycle */
		m_core->RunToVBlank(m_buffer);
		m_lock->unlock();
		window()->update();
	}
}


QString GBEmulator::defaultPath() const
{
	Cartridge *cartridge = m_core->GetCartridge();
	if (cartridge == NULL) {
		return QString();
	}
	QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
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
	qDebug() << "copy rom to " << path << "from" << rom_path;
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
    m_timer->stop();
    m_lock->lock();
    m_core->Pause(true);
    m_lock->unlock();
    m_isPaused = true;
}


void GBEmulator::play()
{
    m_lock->lock();
    m_core->Pause(false);
    m_lock->unlock();
    m_isPaused = false;
    m_timer->start(16);  // 16ms ~ 60 FPS
}


void GBEmulator::save()
{
	QString path = defaultSavePath();
    if (!path.isNull()) {
	    m_lock->lock();
	    m_core->SaveRam(path.toStdString().c_str());
	    m_lock->unlock();
	}
}
