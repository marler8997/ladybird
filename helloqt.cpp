#include <QApplication>
#include <QWidget>
#include <QPushButton>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QWidget window;
    window.resize(320, 240);
    window.setWindowTitle("Hello, World!");

    QPushButton button("Hello, World!", &window);
    button.setGeometry(100, 100, 100, 30);

    window.show();
    return app.exec();
}
