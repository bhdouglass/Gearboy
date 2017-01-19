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
	connect(this, &QQuickItem::windowChanged, this, &GBEmulator::handleWindowChanged);
	windowChanged(window());
	m_emu = new EmulationRunner(this);
	m_emu->start(QThread::TimeCriticalPriority);
}

void GBEmulator::redraw()
{
	window()->update();
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


GBEmulator::~GBEmulator() { }


void GBEmulator::handleWindowChanged(QQuickWindow *win)
{
	if (win) {
		connect(win, &QQuickWindow::beforeSynchronizing, this, &GBEmulator::sync, Qt::DirectConnection);
		connect(win, &QQuickWindow::sceneGraphInvalidated, this, &GBEmulator::cleanup, Qt::DirectConnection);
        connect(win, &QQuickWindow::frameSwapped, this, &GBEmulator::redraw, Qt::DirectConnection);
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
		m_renderer = new PixelRenderer(GAMEBOY_WIDTH, GAMEBOY_HEIGHT, m_emu);
		connect(window(), &QQuickWindow::beforeRendering, m_renderer, &PixelRenderer::paint, Qt::DirectConnection);
		m_renderer->setColor(m_color);
	}

	QSize size = window()->size() * window()->devicePixelRatio();
	m_renderer->setWindow(window());
	m_renderer->setViewRect(QRect(QPoint(0, 0), size));
	setRect(m_renderer->viewRect());
	window()->update();
}


void GBEmulator::upPressed()      { m_emu->keyPressed(Up_Key); }
void GBEmulator::leftPressed()    { m_emu->keyPressed(Left_Key); }
void GBEmulator::rightPressed()   { m_emu->keyPressed(Right_Key); }
void GBEmulator::downPressed()    { m_emu->keyPressed(Down_Key); }
void GBEmulator::startPressed()   { m_emu->keyPressed(Start_Key); }
void GBEmulator::selectPressed()  { m_emu->keyPressed(Select_Key); }
void GBEmulator::aPressed()       { m_emu->keyPressed(A_Key); }
void GBEmulator::bPressed()       { m_emu->keyPressed(B_Key); }
void GBEmulator::upReleased()     { m_emu->keyReleased(Up_Key); }
void GBEmulator::leftReleased()   { m_emu->keyReleased(Left_Key); }
void GBEmulator::rightReleased()  { m_emu->keyReleased(Right_Key); }
void GBEmulator::downReleased()   { m_emu->keyReleased(Down_Key); }
void GBEmulator::startReleased()  { m_emu->keyReleased(Start_Key); }
void GBEmulator::selectReleased() { m_emu->keyReleased(Select_Key); }
void GBEmulator::aReleased()      { m_emu->keyReleased(A_Key); }
void GBEmulator::bReleased()      { m_emu->keyReleased(B_Key); }


bool GBEmulator::loadRom(QString path)
{
	save();
	return m_emu->loadRom(path);
}

void GBEmulator::pause() { m_emu->pause(); }
void GBEmulator::play() { m_emu->play(); }


void GBEmulator::save()
{
	m_emu->save();
}
