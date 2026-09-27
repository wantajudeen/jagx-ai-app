from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

Path("assets/icons").mkdir(parents=True, exist_ok=True)
s = 1024
i = Image.new("RGBA", (s, s), (0, 0, 0, 255))
d = ImageDraw.Draw(i)
d.ellipse([90, 90, s - 90, s - 90], outline=(255, 255, 255, 255), width=20)
try:
    f = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 480
    )
except Exception:
    f = ImageFont.load_default()
b = d.textbbox((0, 0), "J", font=f)
d.text(
    ((s - (b[2] - b[0])) / 2 - b[0], (s - (b[3] - b[1])) / 2 - b[1] - 20),
    "J",
    font=f,
    fill=(255, 255, 255, 255),
)
i.save("assets/icons/app_icon.png")
print("icon ok")
