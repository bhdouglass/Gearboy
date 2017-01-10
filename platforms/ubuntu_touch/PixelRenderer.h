#ifndef PIXEL_RENDER_H
#define PIXEL_RENDER_H

#include <QOpenGLFunctions>
#include <QtGui/QOpenGLShaderProgram>
#include <QtGui/QOpenGLFunctions>
#include <QQuickWindow>
#include <QMutex>
#include <QDebug>

QT_FORWARD_DECLARE_CLASS(QOpenGLShaderProgram);
QT_FORWARD_DECLARE_CLASS(QOpenGLTexture);
QT_FORWARD_DECLARE_CLASS(QOpenGLBuffer);


class PixelRenderer : public QObject, protected QOpenGLFunctions
{
	Q_OBJECT
public:
	
	PixelRenderer();
	~PixelRenderer();

	void setPixelBuffer(void *buffer) { m_pixels = buffer; }
	void setWindow(QQuickWindow *window) { m_window = window; }
	void setBufferLock(QMutex *lock) { m_lock = lock; }
	void setBufferSize(int width, int height) { m_buffer_width = width; m_buffer_height = height; }
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

private:
	QOpenGLShaderProgram *m_program;
	QOpenGLTexture *m_texture;
	QOpenGLBuffer *m_vertices;
	QQuickWindow *m_window;
	QMutex *m_lock;
    	QRect m_viewRect;
	QColor m_color;
	void *m_pixels;
	int m_buffer_width, m_buffer_height;
	int m_width, m_height;
};

#endif 
