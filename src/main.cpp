#include <QApplication>
#include <QQuickView>

#include "GBEmulator.h"


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	qmlRegisterType<GBEmulator>("GearBoy", 1, 0, "GearBoyEmulator");

	QQuickView view;
	view.setResizeMode(QQuickView::SizeRootObjectToView);
	view.setSource(QUrl("qrc:///main.qml"));
	view.show();

	return app.exec();
}
