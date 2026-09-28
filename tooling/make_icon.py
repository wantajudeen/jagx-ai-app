"""Dark interlocking JX monogram — subtle gray on black (not bright neon)."""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
bg = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d0 = ImageDraw.Draw(bg)
d0.rounded_rectangle([48, 48, s - 48, s - 48], radius=220, fill=(10, 10, 10, 255))

L = Image.new("RGBA", (s, s), (0, 0, 0, 0))
md = ImageDraw.Draw(L)

def thick_line(x1, y1, x2, y2, w, color):
    dx, dy = x2 - x1, y2 - y1
    length = math.hypot(dx, dy) or 1
    px, py = -dy / length * w / 2, dx / length * w / 2
    md.polygon(
        [(x1 + px, y1 + py), (x1 - px, y1 - py), (x2 - px, y2 - py), (x2 + px, y2 + py)],
        fill=color,
    )

# Dark gray J
gray = (110, 110, 110, 255)
gray2 = (95, 95, 95, 255)
md.rounded_rectangle([320, 250, 430, 600], radius=36, fill=gray)
md.rounded_rectangle([320, 240, 540, 340], radius=32, fill=gray)
md.arc([230, 500, 450, 780], start=5, end=175, fill=gray2, width=95)

# Darker X
thick_line(490, 270, 760, 710, 82, (100, 100, 100, 255))
thick_line(760, 270, 490, 710, 82, (90, 90, 90, 255))

# Subtle orbit in dim gray
O = Image.new("RGBA", (s, s), (0, 0, 0, 0))
od = ImageDraw.Draw(O)
for i in range(48):
    t = i / 47
    ang = math.radians(-25 + t * 230)
    x = 512 + 330 * math.cos(ang)
    y = 500 + 250 * math.sin(ang)
    r = 6
    od.ellipse([x - r, y - r, x + r, y + r], fill=(70, 70, 70, 180))
od.ellipse([780, 300, 840, 360], fill=(90, 90, 90, 220))

out = Image.alpha_composite(bg, O)
out = Image.alpha_composite(out, L)
out.save("assets/icons/app_icon.png")
print("dark jx icon ok")
