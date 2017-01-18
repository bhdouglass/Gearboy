#ifndef PIXEL_RENDER_H
#define PIXEL_RENDER_H

#include <QOpenGLFunctions>
#include <QtGui/QOpenGLShaderProgram>
#include <QtGui/QOpenGLFunctions>
#include <QQuickWindow>
#include <QMutex>
#include <QDebug>

#include "EmulationRunner.h"

QT_FORWARD_DECLARE_CLASS(QOpenGLShaderProgram);
QT_FORWARD_DECLARE_CLASS(QOpenGLTexture);
QT_FORWARD_DECLARE_CLASS(QOpenGLBuffer);


class PixelRenderer : public QObject, protected QOpenGLFunctions
{
	Q_OBJECT
public:
	
	PixelRenderer(int width, int height, EmulationRunner *emu);
	~PixelRenderer();

	void setWindow(QQuickWindow *window) { m_window = window; }
	void setColor(QColor c) { m_color = c; }
	void setViewRect(QRect rect) { resizeGL(rect.width(), rect.height()); }
	QRect viewRect() { return m_viewRect; }
	QColor color() { return m_color; }

public slots:
	void paint();

protected:
	void initializeGL();
	void paintGL();
	void resizeGL(int width, int height);
	void setViewport();
	void setBufferSize(int width, int height);

private:
	QOpenGLShaderProgram *m_program;
	QOpenGLTexture *m_texture;
	QOpenGLBuffer *m_vertices;
	QQuickWindow *m_window;
    	QRect m_viewRect;
	QColor m_color;
	int m_buffer_width, m_buffer_height;
	int m_width, m_height;
	int m_p2width, m_p2height;
	EmulationRunner *emu;
};

#endif 
