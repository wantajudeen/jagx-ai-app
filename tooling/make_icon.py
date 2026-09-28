"""Unique interlocking JX monogram — tech style, not a copy of any third-party logo."""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
bg = Image.new("RGBA", (s, s), (5, 8, 20, 255))
d0 = ImageDraw.Draw(bg)
d0.rounded_rectangle([40, 40, s - 40, s - 40], radius=220, fill=(8, 10, 24, 255))

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

# J stem + top bar (cyan-blue)
md.rounded_rectangle([320, 250, 430, 600], radius=36, fill=(40, 140, 255, 255))
md.rounded_rectangle([320, 240, 540, 340], radius=32, fill=(50, 170, 255, 255))
# J hook
md.arc([230, 500, 450, 780], start=5, end=175, fill=(60, 120, 255, 255), width=95)

# Interlocking X (violet) — unique proportions
thick_line(490, 270, 760, 710, 82, (150, 70, 255, 255))
thick_line(760, 270, 490, 710, 82, (190, 80, 255, 255))
thick_line(505, 285, 745, 690, 18, (220, 160, 255, 160))

# Unique single orbit (different path than common templates)
O = Image.new("RGBA", (s, s), (0, 0, 0, 0))
od = ImageDraw.Draw(O)
for i in range(48):
    t = i / 47
    ang = math.radians(-25 + t * 230)
    x = 512 + 330 * math.cos(ang)
    y = 500 + 250 * math.sin(ang)
    r = 7
    od.ellipse([x - r, y - r, x + r, y + r], fill=(50 + int(80 * t), 160, 255, 210))
od.ellipse([770, 290, 845, 365], fill=(80, 200, 255, 255))
O = O.filter(ImageFilter.GaussianBlur(0.6))

glow = L.filter(ImageFilter.GaussianBlur(16))
out = Image.alpha_composite(bg, glow)
out = Image.alpha_composite(out, O)
out = Image.alpha_composite(out, L)
out.save("assets/icons/app_icon.png")
print("jx monogram icon ok")
