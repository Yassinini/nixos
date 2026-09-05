#include <QGraphicsSceneMouseEvent>
#include <QApplication>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QGraphicsPixmapItem>
#include <QGraphicsDropShadowEffect>
#include <QGraphicsTextItem>
#include <QVariantAnimation>
#include <QEasingCurve>
#include <QScreen>
#include <QDir>
#include <QFileInfo>
#include <QShortcut>
#include <QKeySequence>
#include <QWheelEvent>
#include <QProcess>
#include <QTransform>
#include <QFont>
#include <QColor>
#include <QStandardPaths>

#include <vector>
#include <algorithm>
#include <cmath>

class CoverflowView;

class CoverflowItem : public QGraphicsPixmapItem {
public:
    QString path;
    int index;
    bool pixmapLoaded = false;
    CoverflowView* parentView;

    CoverflowItem(const QString& p, int idx, CoverflowView* view)
        : QGraphicsPixmapItem(), path(p), index(idx), parentView(view) 
    {
        auto shadow = new QGraphicsDropShadowEffect();
        shadow->setBlurRadius(20);
        shadow->setColor(QColor(0, 0, 0, 160));
        shadow->setOffset(0, 8);
        setGraphicsEffect(shadow);
    }

    void loadPixmap() {
        if (!pixmapLoaded) {
            QPixmap pix(path);
            if (!pix.isNull()) {
                setPixmap(pix.scaled(340, 210, Qt::KeepAspectRatioByExpanding, Qt::SmoothTransformation));
                setTransformationMode(Qt::SmoothTransformation);
            }
            pixmapLoaded = true;
        }
    }

protected:
    void mousePressEvent(QGraphicsSceneMouseEvent* event) override;
};

class CoverflowView : public QGraphicsView {
    Q_OBJECT

public:
    QGraphicsScene* scene;
    QString wallDir;
    std::vector<CoverflowItem*> items;
    int currentIndex = 0;
    int targetIndex = 0;
    float startIndex = 0.0f;
    float animProgress = 0.0f;
    QVariantAnimation* animation;
    QGraphicsTextItem* labelItem;

    CoverflowView(const QString& dir) : wallDir(dir) {
        setWindowTitle("CoverflowPicker");
        scene = new QGraphicsScene(this);
        setScene(scene);

        animation = new QVariantAnimation(this);
        animation->setDuration(200);
        animation->setEasingCurve(QEasingCurve::OutCubic);
        connect(animation, &QVariantAnimation::valueChanged, this, &CoverflowView::onAnimValueChanged);

        setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Dialog);
        setAttribute(Qt::WA_TranslucentBackground);
        setStyleSheet("background: transparent;");
        setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

        QScreen* screen = QApplication::primaryScreen();
        QRect screenGeo = screen->geometry();
        resize(screenGeo.width(), 480);
        scene->setSceneRect(0, 0, screenGeo.width(), 480);

        labelItem = new QGraphicsTextItem();
        labelItem->setDefaultTextColor(QColor(255, 255, 255, 220));
        labelItem->setFont(QFont("Sans-Serif", 13, QFont::Bold));
        scene->addItem(labelItem);
        labelItem->setZValue(200);

        loadWallpapers();
        updatePositions(static_cast<float>(currentIndex));

        new QShortcut(QKeySequence(Qt::Key_Left), this, SLOT(prevItem()));
        new QShortcut(QKeySequence(Qt::Key_Right), this, SLOT(nextItem()));
        new QShortcut(QKeySequence(Qt::Key_Return), this, SLOT(applyWallpaper()));
        new QShortcut(QKeySequence(Qt::Key_Escape), this, []() { qApp->quit(); });
    }

    void loadWallpapers() {
        QDir dir(wallDir);
        if (!dir.exists()) return;

        QStringList filters = {"*.png", "*.jpg", "*.jpeg", "*.webp"};
        QStringList fileList = dir.entryList(filters, QDir::Files, QDir::Name);

        for (int i = 0; i < fileList.size(); ++i) {
            QString fullPath = dir.absoluteFilePath(fileList[i]);
            auto item = new CoverflowItem(fullPath, i, this);
            scene->addItem(item);
            items.push_back(item);
        }

        if (!items.empty()) {
            currentIndex = items.size() / 2;
            targetIndex = currentIndex;
            startIndex = currentIndex;
            items[currentIndex]->loadPixmap();
        }
    }

    void animateToIndex(int index) {
        index = std::max(0, std::min(static_cast<int>(items.size()) - 1, index));
        if (index == targetIndex && animation->state() == QAbstractAnimation::Running) return;

        startIndex = (animation->state() == QAbstractAnimation::Running) ? animProgress : static_cast<float>(currentIndex);
        targetIndex = index;
        currentIndex = index;

        animation->stop();
        animation->setStartValue(startIndex);
        animation->setEndValue(static_cast<float>(index));
        animation->start();
    }

    void updatePositions(float activePos) {
        float centerX = width() / 2.0f;
        float centerY = (height() / 2.0f) - 20.0f;

        for (auto item : items) {
            float offset = item->index - activePos;
            float absOffset = std::abs(offset);

            if (absOffset < 4.0f) {
                item->loadPixmap();
            }

            QTransform transform;
            float spacing = 160.0f;
            float scale, opacity, xPos;

            if (absOffset < 1.0f) {
                scale = 1.2f - (absOffset * 0.5f);
                opacity = 1.0f - (absOffset * 0.2f);
                xPos = centerX - 170.0f + (offset * (spacing + 80.0f));
            } else {
                float direction = (offset > 0.0f) ? 1.0f : -1.0f;
                scale = std::max(0.5f, 0.7f - ((absOffset - 1.0f) * 0.1f));
                opacity = std::max(0.1f, 0.8f - ((absOffset - 1.0f) * 0.2f));
                xPos = centerX - 170.0f + (offset * spacing) + (direction * 80.0f);
            }

            transform.translate(xPos, centerY - 105.0f);
            transform.scale(scale, scale);

            item->setZValue(100.0f - absOffset);
            item->setOpacity(opacity);
            item->setTransform(transform);
        }

        if (!items.empty() && currentIndex >= 0 && currentIndex < static_cast<int>(items.size())) {
            QFileInfo fi(items[currentIndex]->path);
            labelItem->setPlainText(fi.fileName());
            QRectF lblRect = labelItem->boundingRect();
            labelItem->setPos(centerX - (lblRect.width() / 2.0f), height() - 50.0f);
        }
    }

public slots:
    void onAnimValueChanged(const QVariant& value) {
        animProgress = value.toFloat();
        updatePositions(animProgress);
    }

    void onItemClicked(int index) {
        if (index == currentIndex) {
            applyWallpaper();
        } else {
            animateToIndex(index);
        }
    }

    void prevItem() {
        if (currentIndex > 0) animateToIndex(currentIndex - 1);
    }

    void nextItem() {
        if (currentIndex < static_cast<int>(items.size()) - 1) animateToIndex(currentIndex + 1);
    }

    void applyWallpaper() {
        if (items.empty()) return;

        QString selected = items[currentIndex]->path;
        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

        QString home = QDir::homePath();
        QString user = env.value("USER", "suupatruupa");
        QString nixPaths = QString("%1/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/%2/bin").arg(home, user);
        env.insert("PATH", nixPaths + ":" + env.value("PATH"));

        QProcess::execute("pkill", {"-9", "mpvpaper"});

        QProcess awww;
        awww.setProcessEnvironment(env);
        awww.start("awww", {
            "img", "-o", "eDP-1",
            "--transition-type", "outer",
            "--transition-step", "90",
            "--transition-fps", "60",
            selected
        });
        awww.waitForFinished();

        QString configPath = home + "/.config/matugen/config.toml";

        QProcess matugen;
        matugen.setProcessEnvironment(env);
        matugen.setStandardInputFile(QProcess::nullDevice());
        matugen.start("matugen", {
            "-c", configPath,
            "image", selected,
            "-m", "dark",
            "-t", "scheme-tonal-spot",
            "--prefer=darkness"
        });
        matugen.waitForFinished();

        QByteArray stdoutBuf = matugen.readAllStandardOutput();
        QByteArray stderrBuf = matugen.readAllStandardError();

        QFile logFile("/tmp/matugen.log");
        if (logFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&logFile);
            out << "STDOUT:\n" << stdoutBuf << "\n";
            out << "STDERR:\n" << stderrBuf << "\n";
            logFile.close();
        }

        qApp->quit();
    }

protected:
    void wheelEvent(QWheelEvent* event) override {
        int delta = event->angleDelta().x() != 0 ? event->angleDelta().x() : event->angleDelta().y();
        if (delta < 0) nextItem();
        else if (delta > 0) prevItem();
    }
};

void CoverflowItem::mousePressEvent(QGraphicsSceneMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        parentView->onItemClicked(index);
    }
    QGraphicsPixmapItem::mousePressEvent(event);
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QString wallPath = QDir::homePath() + "/Pictures/Wallpapers";
    CoverflowView view(wallPath);
    view.show();
    return app.exec();
}

#include "main.moc"
