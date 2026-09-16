#!/usr/bin/env python3
"""JagX icon: sharp angular J + circuit traces/nodes (logo options 3+5)."""
from struct import pack
import zlib
import math
import sys
from pathlib import Path


def chunk(tag, data):
    return pack(">I", len(data)) + tag + data + pack(">I", zlib.crc32(tag + data) & 0xffffffff)


def dist(x, y, cx, cy):
    return math.hypot(x - cx, y - cy)


def near_segment(x, y, x1, y1, x2, y2, thickness):
    dx, dy = x2 - x1, y2 - y1
    if dx == 0 and dy == 0:
        return dist(x, y, x1, y1) <= thickness
    t = max(0.0, min(1.0, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)))
    px, py = x1 + t * dx, y1 + t * dy
    return dist(x, y, px, py) <= thickness


def pixel(x, y, size):
    sx = x * 512.0 / size
    sy = y * 512.0 / size
    fg = (250, 250, 250)
    bg = (0, 0, 0)
    th = 28
    on = False
    # Angular J
    if near_segment(sx, sy, 200, 120, 340, 120, th):
        on = True
    if near_segment(sx, sy, 320, 120, 320, 340, th):
        on = True
    if near_segment(sx, sy, 180, 340, 320, 340, th):
        on = True
    if near_segment(sx, sy, 180, 280, 180, 340, th):
        on = True
    # Circuit traces
    th2 = 3.5
    for seg in [
        (280, 150, 280, 300),
        (360, 150, 360, 290),
        (200, 300, 200, 365),
        (240, 365, 300, 365),
        (300, 160, 300, 200),
    ]:
        if near_segment(sx, sy, *seg, th2):
            on = True
    nodes = [
        (200, 120), (280, 120), (340, 120), (320, 180),
        (320, 250), (320, 340), (250, 340), (180, 340),
        (180, 300), (360, 200), (280, 220), (360, 150),
    ]
    for nx, ny in nodes:
        if dist(sx, sy, nx, ny) <= 9:
            on = True
    return fg if on else bg


def make_png(w, h):
    rows = []
    for y in range(h):
        row = b"\x00"
        for x in range(w):
            row += bytes(pixel(x, y, w))
        rows.append(row)
    raw = b"".join(rows)
    ihdr = pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("assets/icons/app_icon.png")
    size = int(sys.argv[2]) if len(sys.argv) > 2 else 512
    out.parent.mkdir(parents=True, exist_ok=True)
    data = make_png(size, size)
    out.write_bytes(data)
    print(f"wrote {out} ({len(data)} bytes, {size}x{size})")


if __name__ == "__main__":
    main()
