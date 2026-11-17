"""Draws the illustrations used as photos for the sample profiles.

    python -E -P tool/samples/make_sample_photos.py

Writes site/samples/<id>-<1..3>.jpg (4:5, like feed photos). They are flat
geometric posters, one palette per person, never pictures of real people.
Publish with the website (see README, "Website").
"""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parents[2] / 'site' / 'samples'
W, H = 800, 1000

# Keep in sync with server/src/domain/sampleProfiles.ts.
PALETTES = {
    'ananya': ['#F2E6D8', '#E07A5F', '#3D405B', '#81B29A', '#F2CC8F'],
    'rohan': ['#1B263B', '#E0A458', '#F4EBD9', '#C1666B', '#48A9A6'],
    'meera': ['#FCE4D8', '#D1495B', '#00798C', '#EDAE49', '#30638E'],
    'kabir': ['#E8EDDF', '#2F3E46', '#84A98C', '#CAD2C5', '#F28F3B'],
    'sara': ['#FFF3E2', '#7B2CBF', '#FF7B54', '#FFB26B', '#2B2D42'],
    'arjun': ['#2D2A32', '#DDD92A', '#EEEFA8', '#FAFDF6', '#E4572E'],
    'ishita': ['#F7D1CD', '#5E548E', '#E8C2CA', '#9F86C0', '#231942'],
    'dev': ['#E3F2FD', '#1D3557', '#E63946', '#A8DADC', '#F1FAEE'],
}


def hex_rgb(h: str):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def grain(image: Image.Image, rnd: random.Random, amount: int = 10) -> Image.Image:
    """A little paper grain, so the flat shapes feel printed."""
    noise = Image.effect_noise((W, H), 40).convert('L').point(lambda v: 128 + (v - 128) * amount // 40)
    noise = noise.filter(ImageFilter.GaussianBlur(0.6))
    return Image.blend(image, Image.merge('RGB', (noise, noise, noise)), 0.06)


def sun_and_hills(draw, c, rnd):
    draw.rectangle([0, 0, W, H], fill=c[0])
    r = rnd.randint(170, 230)
    cx, cy = rnd.randint(250, 550), rnd.randint(260, 380)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=c[1])
    for i, color in enumerate([c[3], c[2]]):
        top = 560 + i * 120
        phase = rnd.random() * 6
        points = [(0, H)]
        for x in range(0, W + 1, 10):
            points.append((x, top + 60 * math.sin(x / (140 + i * 60) + phase)))
        points.append((W, H))
        draw.polygon(points, fill=color)


def arches(draw, c, rnd):
    draw.rectangle([0, 0, W, H], fill=c[2])
    colors = [c[1], c[0], c[4], c[3]]
    for i in range(4):
        r = 360 - i * 80
        draw.pieslice([W / 2 - r, H - 120 - r, W / 2 + r, H - 120 + r], 180, 360, fill=colors[i])
        draw.rectangle([W / 2 - r, H - 120, W / 2 + r, H], fill=colors[i])
    d = rnd.randint(50, 80)
    x, y = rnd.randint(120, 260), rnd.randint(120, 260)
    draw.ellipse([x, y, x + d, y + d], fill=c[0])


def grid_shapes(draw, c, rnd):
    draw.rectangle([0, 0, W, H], fill=c[0])
    cell = 200
    for gx in range(0, W, cell):
        for gy in range(0, H, cell):
            color = rnd.choice(c[1:])
            kind = rnd.randint(0, 3)
            box = [gx + 14, gy + 14, gx + cell - 14, gy + cell - 14]
            if kind == 0:
                draw.ellipse(box, fill=color)
            elif kind == 1:
                draw.pieslice([gx + 14, gy + 14, gx + 2 * cell - 42, gy + 2 * cell - 42], 180, 270, fill=color)
            elif kind == 2:
                draw.rectangle([gx + 14, gy + cell / 2, gx + cell - 14, gy + cell - 14], fill=color)
            else:
                draw.polygon([(gx + 14, gy + cell - 14), (gx + cell / 2, gy + 14), (gx + cell - 14, gy + cell - 14)],
                             fill=color)


LAYOUTS = [sun_and_hills, arches, grid_shapes]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for pid, palette in PALETTES.items():
        colors = [hex_rgb(h) for h in palette]
        for n, layout in enumerate(LAYOUTS, start=1):
            rnd = random.Random(f'{pid}-{n}')
            image = Image.new('RGB', (W, H))
            layout(ImageDraw.Draw(image), colors, rnd)
            grain(image, rnd).save(OUT / f'{pid}-{n}.jpg', quality=82, optimize=True, progressive=True)
    print(f'Wrote {len(PALETTES) * len(LAYOUTS)} images to {OUT}')


if __name__ == '__main__':
    main()
