#include <QOpenGLFunctions>
#include <QOpenGLContext>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>
#include <QOpenGLBuffer>

#include "PixelRenderer.h"


PixelRenderer::PixelRenderer(int width, int height, EmulationRunner *e)
	: emu(e)
	, m_program(0)
	, m_texture(0)
	, m_vertices(0)
{
	setBufferSize(width, height);
}


PixelRenderer::~PixelRenderer()
{
	if (m_program) delete m_program;
	if (m_texture) delete m_texture;
	if (m_vertices) delete m_vertices;
}


static int ceilpow2(int v)
{
	int c = 1;
	while (c < v) {
		c <<= 1;
	}
	return c;
}


void PixelRenderer::setBufferSize(int width, int height)
{
    // opengl es 2 needs powers of 2 dimensions
	m_tex_width = ceilpow2(width);
	m_tex_height = ceilpow2(height);
	m_image_width = width;
	m_image_height = height;
}

void PixelRenderer::readFrame()
{
    unsigned char *pixels = emu->openPixels();
    std::copy(pixels, &pixels[256 * 256 * 2], buffer);
    emu->closePixels();
}


bool PixelRenderer::initializeTexture(QOpenGLTexture::TextureFormat format, bool cleanup)
{
        GLenum err = 0;
    m_texture = new QOpenGLTexture(QOpenGLTexture::Target2D);

	if ((err = glGetError())) {
		if (err == GL_INVALID_ENUM) {
			qDebug() << "Ignoring GL_INVALID_ENUM error for texture::new";
		}
		else {
			qDebug() << "Error texture::new: " << err;

			if (cleanup) {
				delete m_texture;
				return false;
			}
		}
	}

    m_texture->setFormat(format);
    if ((err = glGetError())) {
        qDebug() << "Error texture::setFormat: " << err;
	if (cleanup) {
		delete m_texture;
		return false;
	}
    }

    m_texture->setSize(m_tex_width, m_tex_height);
    if ((err = glGetError())) {
        qDebug() << "Error texture::setSize: " << err;
	if (cleanup) {
		delete m_texture;
		return false;
	}
    }


    m_texture->setMinMagFilters(QOpenGLTexture::Nearest, QOpenGLTexture::Nearest);
    if ((err = glGetError())) {
        qDebug() << "Error texture::setMinMag: " << err;
	if (cleanup) {
		delete m_texture;
		return false;
	}
    }

    m_texture->setWrapMode(QOpenGLTexture::Repeat);
    if ((err = glGetError())) {
        qDebug() << "Error texture::setWrap: " << err;
	if (cleanup) {
		delete m_texture;
		return false;
	}
    }

    m_texture->allocateStorage();
    if ((err = glGetError())) {
        qDebug() << "Error texture::allocate: " << err;
    if (cleanup) {
        delete m_texture;
        return false;
    }
    }

    m_texture->bind();
    m_texture->setData(QOpenGLTexture::RGBA, QOpenGLTexture::UInt16_RGB5A1, buffer);
    m_texture->release();

    if ((err = glGetError())) {
        qDebug() << "Error texture::setData: " << err;
	if (cleanup) {
		m_texture->release();
		delete m_texture;
	}
        return false;
    }
    return true;
}


void PixelRenderer::initializeGL()
{
	initializeOpenGLFunctions();

	if (not initializeTexture(QOpenGLTexture::RGBAFormat, true)) {
		qDebug() << "Initializing Texture Unit Failed for RGBAFormat";

		if (not initializeTexture(QOpenGLTexture::RGB5A1, false)) {
			qDebug() << "Initializing Texture Unit Failed for RGB5A1";
		}
	}

	GLfloat w = m_image_width / (double)m_tex_width;
	GLfloat h = m_image_height / (double)m_tex_height;

	QVector<GLfloat> vertData {
	-1.0f, -1.0f, 0.0f, 	0.0f, h,
	 1.0f, -1.0f, 0.0f, 	   w, h,
	-1.0f, 1.0f, 0.0f, 	0.0f, 0.0f,
	 1.0f, 1.0f, 0.0f, 	   w, 0.0f
	};
	m_vertices = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
	m_vertices->setUsagePattern(QOpenGLBuffer::StaticDraw);

	m_vertices->create();
	m_vertices->bind();
	m_vertices->allocate(vertData.constData(), vertData.count() * sizeof (GLfloat));
	m_vertices->release();

	const char *vshader_src =
	"attribute vec4 a_position;\n"
	"attribute vec2 a_texCoord;\n"
	"varying vec2 v_texCoord;\n"
	"void main()\n"
	"{\n"
	"    gl_Position = a_position;\n"
	"    v_texCoord = a_texCoord;\n"
	"}\n";

	const char *fshader_src =
	"varying mediump vec2 v_texCoord;\n"
	"uniform sampler2D s_texture;\n"
	"void main()\n"
	"{\n"
	"   gl_FragColor =  texture2D(s_texture, v_texCoord.st);\n"
	"}\n";

	m_program = new QOpenGLShaderProgram;
	m_program->addShaderFromSourceCode(QOpenGLShader::Vertex, vshader_src);
	m_program->addShaderFromSourceCode(QOpenGLShader::Fragment, fshader_src);
	m_program->link();

	m_vertexAttr = m_program->attributeLocation("a_position");
	m_texCoordAttr = m_program->attributeLocation("a_texCoord");

}


void PixelRenderer::paintGL()
{
	glClearColor(m_color.redF(), m_color.greenF(), m_color.blueF(), m_color.alphaF());
	glViewport(0, 0, m_width, m_height);
	glClear(GL_COLOR_BUFFER_BIT);

	glDisable(GL_DEPTH_TEST);
	setViewport();

	m_program->bind();
	paintScreen();
	m_program->release();

	glEnable(GL_DEPTH_TEST);
    m_window->update();
}


void PixelRenderer::paintScreen()
{
    readFrame();

	m_texture->bind();
    m_texture->setData(QOpenGLTexture::RGBA, QOpenGLTexture::UInt16_RGB5A1, buffer);

	m_program->setUniformValue("s_texture", 0);

	m_vertices->bind();
	m_program->enableAttributeArray(m_vertexAttr);
	m_program->enableAttributeArray(m_texCoordAttr);
	m_program->setAttributeBuffer(m_vertexAttr, GL_FLOAT, 0, 3, 5 * sizeof (GLfloat));
	m_program->setAttributeBuffer(m_texCoordAttr, GL_FLOAT, 3 * sizeof (GLfloat), 2, 5 * sizeof (GLfloat));
	m_vertices->release();

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	m_program->disableAttributeArray(m_vertexAttr);
	m_program->disableAttributeArray(m_texCoordAttr);
}


void PixelRenderer::resizeGL(int width, int height)
{
	m_width = width;
	m_height = height;
	// image is scaled by integer multiples
	int xscale = width / m_image_width;
	int yscale = height / m_image_height;
	int scale = qMin(xscale, yscale);
	int w = m_image_width * scale;
	int h = m_image_height * scale;
	int x_remaining = width - w;
	int y_remaining = height - h;
	// centred horizontally
	int x = x_remaining / 2;
	// anchored to the top with a "small" margin
    int small_margin = qMin(x_remaining, y_remaining) / 2;
    if (small_margin > 4) small_margin /= 4;
    int y = y_remaining - small_margin;
    m_viewRect = QRect(x, y, w, h);
}


void PixelRenderer::setViewport()
{
	glViewport(m_viewRect.x(), m_viewRect.y(), m_viewRect.width(), m_viewRect.height());
}


void PixelRenderer::paint()
{
	if (!m_program) {
		initializeGL();
	}
	paintGL();
    	//m_window->resetOpenGLState();
}
