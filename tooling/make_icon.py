"""Professional JagX app icon — abstract geometric mark, not a letter."""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d = ImageDraw.Draw(i)

# Soft rounded container
d.rounded_rectangle([36, 36, s - 36, s - 36], radius=230, fill=(12, 12, 12, 255))

cx, cy = s / 2, s / 2

def poly(pts, fill=None, outline=None, width=1):
    d.polygon(pts, fill=fill, outline=outline)

# Outer hex (professional geometric frame)
r_out = 310
hex_pts = []
for k in range(6):
    a = math.radians(30 + k * 60)
    hex_pts.append((cx + r_out * math.cos(a), cy + r_out * math.sin(a)))
d.line(hex_pts + [hex_pts[0]], fill=(55, 55, 55, 255), width=6)

# Inner glowing diamond / rhombus (core mark)
r_in = 150
diamond = [
    (cx, cy - r_in),
    (cx + r_in * 0.85, cy),
    (cx, cy + r_in),
    (cx - r_in * 0.85, cy),
]
poly(diamond, fill=(235, 235, 235, 255))

# Smaller inner cut (negative space diamond) for depth
r_cut = 55
cut = [
    (cx, cy - r_cut),
    (cx + r_cut * 0.85, cy),
    (cx, cy + r_cut),
    (cx - r_cut * 0.85, cy),
]
poly(cut, fill=(12, 12, 12, 255))

# Three soft nodes on a rising arc (suggests network / intelligence)
nodes = [
    (cx - 210, cy + 40),
    (cx - 40, cy - 200),
    (cx + 200, cy - 20),
]
for n in nodes:
    d.ellipse([n[0] - 18, n[1] - 18, n[0] + 18, n[1] + 18], fill=(200, 200, 200, 255))
# connect nodes lightly
d.line([nodes[0], nodes[1]], fill=(90, 90, 90, 255), width=4)
d.line([nodes[1], nodes[2]], fill=(90, 90, 90, 255), width=4)

i.save("assets/icons/app_icon.png")
print("icon ok")
