from PIL import Image, ImageDraw
from pathlib import Path

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (10, 10, 10, 255))
d = ImageDraw.Draw(i)

# rounded square with blue→violet gradient approximation (layered rects)
rad = 240
for k in range(40):
    t = k / 39
    r = int(59 + (139 - 59) * t)
    g = int(130 + (92 - 130) * t)
    b = int(246 + (246 - 246) * t)
    inset = 90 + k * 2
    d.rounded_rectangle(
        [inset, inset, s - inset, s - inset],
        radius=max(40, rad - k * 4),
        outline=(r, g, b, 255),
        width=6,
    )

# solid fill center
d.rounded_rectangle([120, 120, s - 120, s - 120], radius=200, fill=(59, 130, 246, 255))
# top-left lighter, bottom-right violet overlay via arcs
d.rounded_rectangle([120, 120, s - 120, s // 2 + 40], radius=200, fill=(96, 165, 250, 90))

# X glyph
sw = 88
p = dict(fill=(255, 255, 255, 255))
# thick X using polygons
def thick_line(x1, y1, x2, y2, w):
    # approximate with polygon
    import math
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
        fill=(255, 255, 255, 255),
    )

thick_line(300, 300, 724, 724, sw)
thick_line(724, 300, 300, 724, sw)

i.save("assets/icons/app_icon.png")
print("icon ok")
