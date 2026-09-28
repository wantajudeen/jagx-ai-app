from PIL import Image, ImageDraw
from pathlib import Path

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d = ImageDraw.Draw(i)

d.rounded_rectangle([40, 40, s - 40, s - 40], radius=220, fill=(16, 16, 16, 255))

# Unique stylized J + dot (not Grok ring)
color = (220, 220, 220, 255)
sw = 70
# stem
d.line([(640, 200), (640, 600)], fill=color, width=sw)
# hook
d.arc([280, 520, 700, 860], start=0, end=180, fill=color, width=sw)
# accent dot
d.ellipse([260, 240, 360, 340], fill=color)

i.save("assets/icons/app_icon.png")
print("icon ok")
