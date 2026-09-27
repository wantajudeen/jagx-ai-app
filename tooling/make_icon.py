from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d = ImageDraw.Draw(i)
# purple rounded square like the in-app mark
rad = 220
d.rounded_rectangle([80, 80, s - 80, s - 80], radius=rad, fill=(124, 58, 237, 255))
d.rounded_rectangle(
    [80, 80, s - 80, s - 80],
    radius=rad,
    outline=(196, 181, 253, 255),
    width=10,
)
try:
    f = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 520
    )
except Exception:
    f = ImageFont.load_default()
b = d.textbbox((0, 0), "J", font=f)
x = (s - (b[2] - b[0])) / 2 - b[0]
y = (s - (b[3] - b[1])) / 2 - b[1] - 24
d.text((x, y), "J", font=f, fill=(255, 255, 255, 255))
i.save("assets/icons/app_icon.png")
print("icon ok")
