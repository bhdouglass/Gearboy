#include <QOpenGLFunctions>
#include <QOpenGLContext>
#include <QOpenGLShaderProgram>
#include <QOpenGLTexture>
#include <QOpenGLBuffer>

#include "PixelRenderer.h"


PixelRenderer::PixelRenderer()
{
        m_program = 0;
}


PixelRenderer::~PixelRenderer()
{
	// todo setcontent check null  shaders, texture, vertices ? 
	delete m_program;
}


void PixelRenderer::initializeGL()
{
    initializeOpenGLFunctions();
    #define PROGRAM_VERTEX_ATTRIBUTE 0
    #define PROGRAM_TEXCOORD_ATTRIBUTE 1

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

    QOpenGLShader *vshader = new QOpenGLShader(QOpenGLShader::Vertex, this);
    QOpenGLShader *fshader = new QOpenGLShader(QOpenGLShader::Fragment, this);
    vshader->compileSourceCode(vshader_src);
    fshader->compileSourceCode(fshader_src);

    m_program = new QOpenGLShaderProgram;
    m_program->addShader(vshader);
    m_program->addShader(fshader);
    m_program->bindAttributeLocation("a_position", PROGRAM_VERTEX_ATTRIBUTE);
    m_program->bindAttributeLocation("a_texCoord", PROGRAM_TEXCOORD_ATTRIBUTE);
    m_program->link();

    m_texture = new QOpenGLTexture(QOpenGLTexture::Target2D);
    m_texture->setMinMagFilters(QOpenGLTexture::Nearest, QOpenGLTexture::Nearest);
    m_texture->setSize(m_buffer_width, m_buffer_height);
    m_texture->setFormat(QOpenGLTexture::RGBA8_UNorm);
    m_texture->setWrapMode(QOpenGLTexture::Repeat);
    m_texture->allocateStorage();

    QVector<GLfloat> vertData {
        -1.0f, -1.0f, 0.0f, 	0.0f, 1.0f,
        1.0f, -1.0f, 0.0f, 	1.0f, 1.0f,
        -1.0f, 1.0f, 0.0f, 	0.0f, 0.0f,
        1.0f, 1.0f, 0.0f, 	1.0f, 0.0f
    };
    m_vertices = new QOpenGLBuffer(QOpenGLBuffer::VertexBuffer);
    m_vertices->create();
    m_vertices->bind();
    m_vertices->allocate(vertData.constData(), vertData.count() * sizeof (GLfloat));
}


void PixelRenderer::paintGL()
{
    m_program->bind();

    m_lock->lock();
    m_texture->setData(QOpenGLTexture::RGBA, QOpenGLTexture::UInt8,  m_pixels);
    m_lock->unlock();
    m_vertices->bind();
    m_program->enableAttributeArray(PROGRAM_VERTEX_ATTRIBUTE);
    m_program->setAttributeBuffer(PROGRAM_VERTEX_ATTRIBUTE, GL_FLOAT, 0, 3, 5 * sizeof (GLfloat));

    m_program->enableAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE);
    m_program->setAttributeBuffer(PROGRAM_TEXCOORD_ATTRIBUTE, GL_FLOAT, 3 * sizeof (GLfloat),
                                  2, 5 * sizeof (GLfloat));

    m_texture->bind(0, QOpenGLTexture::ResetTextureUnit);
    m_program->setUniformValue("s_texture", 0);

    glClearColor(m_color.redF(), m_color.greenF(), m_color.blueF(), m_color.alphaF());
    glViewport(0, 0, m_width, m_height);
    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT);

    setViewport();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    m_program->disableAttributeArray(PROGRAM_TEXCOORD_ATTRIBUTE);
    m_program->disableAttributeArray(PROGRAM_VERTEX_ATTRIBUTE);

    m_vertices->release();
    m_texture->release(0, QOpenGLTexture::ResetTextureUnit);
    m_program->release();

   glFinish();
}


void PixelRenderer::resizeGL(int width, int height)
{
    m_width = width;
    m_height = height;
    int xscale = width / m_buffer_width;
    int yscale = height / m_buffer_height;
    int scale = qMin(xscale, yscale);
    int w = m_buffer_width * scale;
    int h = m_buffer_height * scale;
    int x_remaining = width - w;
    int y_remaining = height - h;
    int x = x_remaining / 2;
    int y = y_remaining - qMin(x_remaining, y_remaining) / 8;
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
    m_window->resetOpenGLState();
}
