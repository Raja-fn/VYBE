"""Draws the VYBE logo: the wordmark "VYBE" (white, the E in coral) on the
dark brand background.

    python -E -P tool/icon/make_icon.py
    dart run flutter_launcher_icons
    dart run flutter_native_splash:create

Writes to assets/icon/:
- icon.png: the full app icon (1024 px), used for iOS and older Androids;
- foreground.png: the adaptive-icon foreground, inside Android's safe zone;
- splash.png: the native start screen. It matches the first frame of the
  animated splash (lib/core/splash/splash_gate.dart) exactly: 46 dp
  ExtraBold, 3 dp letter spacing, centred, drawn at 4 px per dp on a
  1152 px (288 dp) canvas, the size Android 12 splash icons use.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets' / 'icon'
FONT = ROOT / 'assets' / 'fonts' / 'PlusJakartaSans-ExtraBold.ttf'

CORAL = (255, 107, 74, 255)
INK = (14, 14, 18, 255)
WHITE = (244, 243, 246, 255)
LETTERS = 'VYBE'


def wordmark(canvas: int, font_px: float, spacing_px: float, background) -> Image.Image:
    """The wordmark centred on a square canvas the way Flutter centres a line of
    text with `height: 1`: the line box is `font_px` tall and the baseline sits
    at font_px * ascent / (ascent + descent)."""
    scale = 4  # draw large, then shrink for smooth edges
    big = canvas * scale
    image = Image.new('RGBA', (big, big), background)
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype(str(FONT), round(font_px * scale))
    ascent, descent = font.getmetrics()
    size = font_px * scale
    advances = [font.getlength(ch) + spacing_px * scale for ch in LETTERS]
    width = sum(advances) - spacing_px * scale
    x = big / 2 - width / 2
    baseline = big / 2 - size / 2 + size * ascent / (ascent + descent)
    for ch, advance in zip(LETTERS, advances):
        draw.text((x, baseline), ch, font=font, fill=CORAL if ch == 'E' else WHITE, anchor='ls')
        x += advance
    return image.resize((canvas, canvas), Image.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    # App icon: the word fills about 62% of the width.
    wordmark(1024, 230, 14, INK).save(OUT / 'icon.png')
    # Adaptive foreground: Android may crop to the central 66%; keep the word well inside.
    wordmark(1024, 168, 10, (0, 0, 0, 0)).save(OUT / 'foreground.png')
    # Native splash: 46 dp text, 3 dp spacing, at 4 px per dp.
    wordmark(1152, 46 * 4, 3 * 4, (0, 0, 0, 0)).save(OUT / 'splash.png')
    print(f'Wrote icon.png, foreground.png and splash.png to {OUT}')


if __name__ == '__main__':
    main()
