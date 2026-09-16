#!/usr/bin/env python3
"""JagX icon: sharp angular J + circuit traces/nodes (logo options 3+5)."""
from struct import pack
import zlib
import math
import sys
from pathlib import Path


def chunk(tag, data):
    return pack(">I", len(data)) + tag + data + pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def dist(x, y, cx, cy):
    return math.hypot(x - cx, y - cy)


def near_segment(x, y, x1, y1, x2, y2, thickness):
    dx, dy = x2 - x1, y2 - y1
    if dx == 0 and dy == 0:
        return dist(x, y, x1, y1) <= thickness
    t = max(0.0, min(1.0, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)))
    px, py = x1 + t * dx, y1 + t * dy
    return dist(x, y, px, py) <= thickness


def make_png(size: int) -> bytes:
    pixels = bytearray()
    for y in range(size):
        for x in range(size):
            sx = x * 512.0 / size
            sy = y * 512.0 / size
            on = False
            th = 28
            if near_segment(sx, sy, 200, 120, 340, 120, th):
                on = True
            if near_segment(sx, sy, 320, 120, 320, 340, th):
                on = True
            if near_segment(sx, sy, 180, 340, 320, 340, th):
                on = True
            if near_segment(sx, sy, 180, 280, 180, 340, th):
                on = True
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
            for cx, cy in [
                (280, 150),
                (280, 300),
                (360, 150),
                (360, 290),
                (200, 365),
                (300, 365),
                (300, 180),
            ]:
                if dist(sx, sy, cx, cy) <= 8:
                    on = True
            if on:
                pixels.extend([250, 250, 250])
            else:
                pixels.extend([0, 0, 0])
    raw = b"".join(b"\x00" + pixels[i : i + size * 3] for i in range(0, len(pixels), size * 3))
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("jagx_icon.png")
    size = int(sys.argv[2]) if len(sys.argv) > 2 else 512
    out.write_bytes(make_png(size))
    print(f"Wrote {out} ({size}x{size})")


if __name__ == "__main__":
    main()
