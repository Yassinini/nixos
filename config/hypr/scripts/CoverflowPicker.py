#!/usr/bin/env python3
import os
import sys
import shutil
import subprocess
from PySide6.QtCore import Qt, QRectF, QPointF, QVariantAnimation, QEasingCurve
from PySide6.QtGui import QPixmap, QTransform, QKeySequence, QShortcut, QColor, QFont
from PySide6.QtWidgets import (
    QApplication, QGraphicsView, QGraphicsScene, QGraphicsPixmapItem,
    QGraphicsDropShadowEffect, QGraphicsTextItem
)

class CoverflowItem(QGraphicsPixmapItem):
    def __init__(self, path, index):
        super().__init__()
        self.path = path
        self.index = index
        self._pixmap_loaded = False
        
        # Drop shadow effect
        shadow = QGraphicsDropShadowEffect()
        shadow.setBlurRadius(20)
        shadow.setColor(QColor(0, 0, 0, 160))
        shadow.setOffset(0, 8)
        self.setGraphicsEffect(shadow)

    def load_pixmap(self):
        if not self._pixmap_loaded:
            pixmap = QPixmap(self.path).scaled(
                340, 210, 
                Qt.KeepAspectRatioByExpanding, 
                Qt.SmoothTransformation
            )
            self.setPixmap(pixmap)
            self.setTransformationMode(Qt.SmoothTransformation)
            self._pixmap_loaded = True

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            views = self.scene().views()
            if views:
                views[0].on_item_clicked(self.index)
        super().mousePressEvent(event)

class CoverflowView(QGraphicsView):
    def __init__(self, wall_dir):
        super().__init__()
        self.setWindowTitle("CoverflowPicker")
        
        self.scene = QGraphicsScene(self)
        self.setScene(self.scene)
        
        self.wall_dir = wall_dir
        self.items = []
        self.current_index = 0
        
        # Smooth animation property
        self.anim_progress = 0.0
        self.target_index = 0
        self.start_index = 0
        self.animation = QVariantAnimation(self)
        self.animation.setDuration(200)
        self.animation.setEasingCurve(QEasingCurve.OutCubic)
        self.animation.valueChanged.connect(self._on_anim_value_changed)
        
        # Window flags
        self.setWindowFlags(
            Qt.FramelessWindowHint |
            Qt.WindowStaysOnTopHint |
            Qt.Dialog
        )
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setStyleSheet("background: transparent;")
        self.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        
        screen = QApplication.primaryScreen().geometry()
        self.resize(screen.width(), 480)
        self.scene.setSceneRect(0, 0, screen.width(), 480)
        
        # Filename Label Item
        self.label_item = QGraphicsTextItem()
        self.label_item.setDefaultTextColor(QColor(255, 255, 255, 220))
        font = QFont("Sans-Serif", 13, QFont.Bold)
        self.label_item.setFont(font)
        self.scene.addItem(self.label_item)
        self.label_item.setZValue(200)
        
        self.load_wallpapers()
        self.update_positions(float(self.current_index))
        
        # Keybindings
        QShortcut(QKeySequence(Qt.Key_Left), self, self.prev_item)
        QShortcut(QKeySequence(Qt.Key_Right), self, self.next_item)
        QShortcut(QKeySequence(Qt.Key_Return), self, self.apply_wallpaper)
        QShortcut(QKeySequence(Qt.Key_Escape), self, QApplication.quit)

    def load_wallpapers(self):
        valid_exts = ('.png', '.jpg', '.jpeg', '.webp')
        if not os.path.exists(self.wall_dir):
            return
        files = [os.path.join(self.wall_dir, f) for f in os.listdir(self.wall_dir) if f.lower().endswith(valid_exts)]
        files.sort()
        
        for idx, path in enumerate(files):
            item = CoverflowItem(path, idx)
            self.scene.addItem(item)
            self.items.append(item)
            
        if self.items:
            self.current_index = len(self.items) // 2
            self.target_index = self.current_index
            self.start_index = self.current_index
            self.items[self.current_index].load_pixmap()

    def animate_to_index(self, index):
        index = max(0, min(len(self.items) - 1, index))
        if index == self.target_index and self.animation.state() == QVariantAnimation.Running:
            return
            
        self.start_index = self.anim_progress if self.animation.state() == QVariantAnimation.Running else float(self.current_index)
        self.target_index = index
        self.current_index = index
        
        self.animation.stop()
        self.animation.setStartValue(self.start_index)
        self.animation.setEndValue(float(index))
        self.animation.start()

    def _on_anim_value_changed(self, value):
        self.anim_progress = value
        self.update_positions(value)

    def update_positions(self, active_pos):
        center_x = self.width() / 2
        center_y = (self.height() / 2) - 20
        
        for item in self.items:
            offset = item.index - active_pos
            abs_offset = abs(offset)
            
            if abs_offset < 4:
                item.load_pixmap()

            transform = QTransform()
            spacing = 160
            
            if abs_offset < 1.0:
                scale = 1.2 - (abs_offset * 0.5)
                opacity = 1.0 - (abs_offset * 0.2)
                x_pos = center_x - 170 + (offset * (spacing + 80))
            else:
                direction = 1 if offset > 0 else -1
                scale = max(0.5, 0.7 - ((abs_offset - 1.0) * 0.1))
                opacity = max(0.1, 0.8 - ((abs_offset - 1.0) * 0.2))
                x_pos = center_x - 170 + (offset * spacing) + (direction * 80)
                
            transform.translate(x_pos, center_y - 105)
            transform.scale(scale, scale)
            
            item.setZValue(100 - abs_offset)
            item.setOpacity(opacity)
            item.setTransform(transform)

        if self.items and 0 <= self.current_index < len(self.items):
            filename = os.path.basename(self.items[self.current_index].path)
            self.label_item.setPlainText(filename)
            lbl_rect = self.label_item.boundingRect()
            self.label_item.setPos(center_x - (lbl_rect.width() / 2), self.height() - 50)

    def wheelEvent(self, event):
        angle_delta = event.angleDelta()
        delta = angle_delta.x() if angle_delta.x() != 0 else angle_delta.y()
        
        if delta < 0:
            self.next_item()
        elif delta > 0:
            self.prev_item()

    def on_item_clicked(self, index):
        if index == self.current_index:
            self.apply_wallpaper()
        else:
            self.animate_to_index(index)

    def prev_item(self):
        if self.current_index > 0:
            self.animate_to_index(self.current_index - 1)

    def next_item(self):
        if self.current_index < len(self.items) - 1:
            self.animate_to_index(self.current_index + 1)

    def apply_wallpaper(self):
        if not self.items:
            return
        
        selected = os.path.abspath(self.items[self.current_index].path)
        env = os.environ.copy()

        home = os.path.expanduser("~")
        user = os.getenv("USER", "suupatruupa")
        nix_paths = f"{home}/.nix-profile/bin:/run/current-system/sw/bin:/etc/profiles/per-user/{user}/bin"
        env["PATH"] = f"{nix_paths}:{env.get('PATH', '')}"

        matugen_bin = shutil.which("matugen", path=env["PATH"]) or "matugen"
        awww_bin = shutil.which("awww", path=env["PATH"]) or "awww"

        subprocess.run(["pkill", "-9", "mpvpaper"], stderr=subprocess.DEVNULL, env=env)
	# Set wallpaper via awww with transition flags
        subprocess.run([
            awww_bin, "img",
            "-o", "eDP-1",
            "--transition-type", "outer",
            "--transition-step", "90",
            "--transition-fps", "60",
            selected
        ], env=env)
        
        config_path = os.path.join(home, ".config/matugen/config.toml")
        
        # Bypass TTY checks by attaching pipes and DEVNULL for stdin
        res = subprocess.run(
    	[
        	matugen_bin,
        	"-c", config_path,
        	"image", selected,
        	"-m", "dark",
        	"-t", "scheme-tonal-spot",
        	"--prefer=darkness",  # <-- add this
    	],
    	env=env,
    	stdin=subprocess.DEVNULL,
    	stdout=subprocess.PIPE,
    	stderr=subprocess.PIPE,
    	text=True,
	)
 
        with open("/tmp/matugen.log", "w") as log:
            log.write(f"STDOUT:\n{res.stdout}\n")
            log.write(f"STDERR:\n{res.stderr}\n")
        
        QApplication.quit()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    wall_path = os.path.expanduser("~/Pictures/Wallpapers")
    view = CoverflowView(wall_path)
    view.show()
    sys.exit(app.exec())
