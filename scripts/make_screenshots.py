#!/usr/bin/env python3
"""Render 5 hero screenshots for App Store Connect.

6.9" (iPhone 17 Pro Max) → 1320×2868
6.1" (iPhone 17 / 16 / 15 Pro) → 1206×2622

Outputs into fastlane/screenshots/en-US/iPhone N.NN-NN_Name.png, matching
the structure `fastlane deliver` expects.

Phase 8 ships placeholder hero screenshots that match the SPEC creative
brief (cream background, serif headline, quiet caption). True product
screenshots from the running app land via `fastlane snapshot` in the next
session before Phase 9.

Requires Pillow:  pip3 install pillow
"""

import os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
OUT = os.path.join(ROOT, "fastlane", "screenshots", "en-US")
os.makedirs(OUT, exist_ok=True)

BG = (250, 250, 246)
INK = (31, 27, 22)
STONE = (107, 99, 88)
ACCENT = (74, 93, 58)

SIZES = {
    "iPhone 17 Pro Max": (1320, 2868),
    "iPhone 17 Pro": (1206, 2622),
}

CARDS = [
    ("01_Hook",      "Speak. Stays here.",
     "A voice journal where every word stays on your iPhone."),
    ("02_Value",     "Your iPhone listens.\nNothing else does.",
     "Apple Intelligence draws the summary. Locally."),
    ("03_Trust",     "One price.\nNo cloud, ever.",
     "Annual $59.99 · Lifetime $99.99 · Weekly $4.99."),
    ("04_Threads",   "The shape of what\nyou've been carrying.",
     "Quiet weekly themes. No streaks, no graphs."),
    ("05_ReadMeBack","Some days you don't want\nto make anything new.",
     "Read me back replays yesterday in your own voice."),
]

def _font(size: int, weight: str = "regular") -> ImageFont.ImageFont:
    # macOS New York for serif, SF Pro for sans. Fallback to default.
    candidates = []
    if weight == "serif":
        candidates = ["/System/Library/Fonts/NewYork.ttf",
                      "/System/Library/Fonts/NewYorkItalic.ttf",
                      "/Library/Fonts/Georgia.ttf"]
    elif weight == "bold":
        candidates = ["/System/Library/Fonts/SFPro.ttf",
                      "/System/Library/Fonts/Helvetica.ttc"]
    else:
        candidates = ["/System/Library/Fonts/SFPro.ttf",
                      "/System/Library/Fonts/Helvetica.ttc"]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()

def _draw(name: str, headline: str, caption: str, size: tuple) -> Image.Image:
    image = Image.new("RGB", size, BG)
    draw = ImageDraw.Draw(image)
    w, h = size

    # Top-right corner indicator
    indicator = "Apple Intelligence · On device"
    indicator_font = _font(28, "regular")
    draw.text((w - 40, 64), indicator, font=indicator_font, fill=STONE, anchor="rt")

    # Headline (serif, centred horizontally, top third)
    headline_size = 96
    head_font = _font(headline_size, "serif")
    head_y = int(h * 0.30)
    for idx, line in enumerate(headline.split("\n")):
        line_y = head_y + idx * int(headline_size * 1.15)
        draw.text((w // 2, line_y), line, font=head_font, fill=INK, anchor="ma")

    # Caption (sans, centred horizontally, lower third)
    cap_font = _font(40, "regular")
    cap_y = int(h * 0.62)
    for idx, line in enumerate(caption.split("\n")):
        line_y = cap_y + idx * 60
        draw.text((w // 2, line_y), line, font=cap_font, fill=STONE, anchor="ma")

    # Accent bar
    bar_y = int(h * 0.78)
    draw.rectangle([w // 2 - 60, bar_y, w // 2 + 60, bar_y + 6], fill=ACCENT)

    # Bottom-left attribution
    attr_font = _font(28, "regular")
    draw.text((48, h - 72), "Pith Voice", font=attr_font, fill=INK)
    return image

def main() -> None:
    for device, size in SIZES.items():
        for name, headline, caption in CARDS:
            image = _draw(name, headline, caption, size)
            path = os.path.join(OUT, f"{device}-{name}.png")
            image.save(path, "PNG", optimize=True)
            print(f"  wrote {path}  {size[0]}x{size[1]}")

if __name__ == "__main__":
    main()
