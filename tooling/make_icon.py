from PIL import Image, ImageDraw
from pathlib import Path
import math

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d = ImageDraw.Draw(i)

# subtle rounded tile
d.rounded_rectangle([48, 48, s - 48, s - 48], radius=220, fill=(18, 18, 18, 255))

cx, cy = s // 2, s // 2
r = 260
sw = 52
color = (230, 230, 230, 255)

# open ring
for a in range(-126, 138):
    rad = math.radians(a)
    x1 = cx + (r - sw / 2) * math.cos(rad)
    y1 = cy + (r - sw / 2) * math.sin(rad)
    x2 = cx + (r + sw / 2) * math.cos(rad)
    y2 = cy + (r + sw / 2) * math.sin(rad)
    d.line([(x1, y1), (x2, y2)], fill=color, width=3)

# thicker arc approximation
d.arc([cx - r, cy - r, cx + r, cy + r], start=-130, end=140, fill=color, width=sw)

# diagonal slash
def thick_line(x1, y1, x2, y2, w):
    dx, dy = x2 - x1, y2 - y1
    length = math.hypot(dx, dy) or 1
    px, py = -dy / length * w / 2, dx / length * w / 2
    d.polygon(
        [
            (x1 + px, y1 + py),
            (x1 - px, y1 - py),
            (x2 - px, y2 - py),
            (x2 + px, y2 + py),
        ],
        fill=color,
    )

thick_line(280, 760, 760, 280, 56)

i.save("assets/icons/app_icon.png")
print("icon ok")
