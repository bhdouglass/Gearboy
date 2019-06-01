#include <QApplication>
#include <QQuickView>

#include "GBEmulator.h"
#include "Files.h"

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	app.setOrganizationName("gearboy.bhdouglass");
    app.setApplicationName("gearboy.bhdouglass");

	qmlRegisterType<GBEmulator>("GearBoy", 1, 0, "GearBoyEmulator");
	qmlRegisterSingletonType<Files>("GearBoy", 1, 0, "Files", [](QQmlEngine*, QJSEngine*) -> QObject* { return Files::instance(); });

	QQuickView view;
	view.setResizeMode(QQuickView::SizeRootObjectToView);
	view.setSource(QUrl("qrc:///main.qml"));
	view.show();

	int result = app.exec();
	EmulationRunner::waitAll();
	return result;
}
