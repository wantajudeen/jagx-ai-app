#!/usr/bin/env python3
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont
except Exception as e:
    raise SystemExit(f"Pillow missing: {e}")

out = Path("assets/icons/app_icon.png")
out.parent.mkdir(parents=True, exist_ok=True)
size = 1024
img = Image.new("RGBA", (size, size), (5, 5, 5, 255))
d = ImageDraw.Draw(img)
d.ellipse([72, 72, size - 72, size - 72], outline=(139, 92, 246, 255), width=30)
try:
    font = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 520
    )
except Exception:
    font = ImageFont.load_default()
bbox = d.textbbox((0, 0), "J", font=font)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
d.text(
    ((size - tw) / 2 - bbox[0], (size - th) / 2 - bbox[1] - 20),
    "J",
    font=font,
    fill=(255, 255, 255, 255),
)
img.save(out)
print("wrote", out)
