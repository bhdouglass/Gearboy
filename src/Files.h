#ifndef FILES_H
#define FILES_H

#include <QObject>

class Files: public QObject {
    Q_OBJECT

    Q_PROPERTY(QString romDir READ romDir CONSTANT)

public:
    Files(QObject* parent = 0);
    ~Files();

    static Files *instance(QObject* parent = 0) {
        if (!m_files) {
            m_files = new Files(parent);
        }
        return m_files;
    }

    QString romDir();
    Q_INVOKABLE QString moveRom(const QString path);
    Q_INVOKABLE void removeRom(const QString path);

private:
    static Files *m_files;
};

#endif
