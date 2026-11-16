"""Draws the FindX app icon: a dark map pin with a coral-and-white core on coral.

    python tool/icon/make_icon.py

Writes assets/icon/icon.png (full icon, 1024px) and
assets/icon/foreground.png (adaptive-icon foreground with safe-zone padding).
flutter_launcher_icons then builds every Android size from them.
"""
from pathlib import Path

from PIL import Image, ImageDraw

CORAL = (255, 107, 74, 255)
INK = (14, 14, 18, 255)
WHITE = (255, 255, 255, 255)
SIZE = 1024
OUT = Path(__file__).resolve().parents[2] / 'assets' / 'icon'


def pin(draw: ImageDraw.ImageDraw, cx: float, cy: float, r: float) -> None:
    """A map pin: circle head with a pointed tail, a white ring and a coral core."""
    # Tail sides meet the head exactly where they touch the circle (no notch).
    apex = 1.75
    ty = 1 / apex
    tx = (1 - ty * ty) ** 0.5
    draw.polygon([(cx - r * tx, cy + r * ty), (cx + r * tx, cy + r * ty), (cx, cy + r * apex)], fill=INK)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=INK)
    ring = r * 0.52
    draw.ellipse([cx - ring, cy - ring, cx + ring, cy + ring], fill=WHITE)
    core = r * 0.3
    draw.ellipse([cx - core, cy - core, cx + core, cy + core], fill=CORAL)


def render(scale: float, background: bool) -> Image.Image:
    big = SIZE * 4  # draw large, then shrink for smooth edges
    image = Image.new('RGBA', (big, big), CORAL if background else (0, 0, 0, 0))
    r = big * 0.2 * scale
    pin(ImageDraw.Draw(image), big / 2, big / 2 - r * 0.45, r)
    return image.resize((SIZE, SIZE), Image.LANCZOS)


OUT.mkdir(parents=True, exist_ok=True)
render(1.0, background=True).save(OUT / 'icon.png')
# Adaptive icons crop to a circle or squircle: keep the pin inside the middle 66%.
render(0.72, background=False).save(OUT / 'foreground.png')
print(f'Wrote {OUT / "icon.png"} and {OUT / "foreground.png"}')
