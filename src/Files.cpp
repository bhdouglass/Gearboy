#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>

#include "Files.h"

Files *Files::m_files = nullptr;

Files::Files(QObject* parent) : QObject(parent) {
    QDir().mkpath(romDir());
}

Files::~Files() {
    m_files = nullptr;
}

QString Files::romDir() {
    return QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/roms/";
}

QString Files::moveRom(const QString path) {
    QFileInfo fileInfo(path);
    QString newPath = romDir() + fileInfo.fileName();

    QFile f(path);
    bool ok = f.copy(newPath);
    qDebug() << "coping" << path << newPath << ok << f.error();

    if (ok) {
        removeRom(path);
        return newPath;
    }
    return path;
}

void Files::removeRom(const QString path) {
    QFile::remove(path);
}
