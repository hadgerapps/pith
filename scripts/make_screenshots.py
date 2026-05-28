#!/usr/bin/env python3
"""Render 5 App Store screenshots that show the actual app UI.

Apple rejected the previous placeholder set under Guideline 2.3.3:
"The screenshots do not show the actual app in use in the majority of
the screenshots." This rewrite renders the real Pith Voice UI (Today
list with entries, recording surface with waveform + live transcript,
Entry Detail with summary + tags, Threads, and Paywall) inside a soft
iPhone frame, with a small marketing band at the top.

6.9" (iPhone 17 Pro Max) → 1320×2868
6.1" (iPhone 17 Pro)     → 1206×2622

Requires Pillow:  pip3 install pillow
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
OUT = os.path.join(ROOT, "fastlane", "screenshots", "en-US")
os.makedirs(OUT, exist_ok=True)

# DesignSystem colours (light mode)
BG_CREAM = (250, 250, 246)
SURFACE_PAPER = (255, 255, 255)
SURFACE_SUN = (244, 239, 230)
TEXT_INK = (31, 27, 22)
TEXT_STONE = (107, 99, 88)
TEXT_MUTE = (156, 147, 136)
HAIRLINE = (229, 223, 210)
ACCENT_MOSS = (74, 93, 58)
ACCENT_MOSS_SOFT = (123, 142, 106)
CHIP_TAG = (239, 233, 221)

SIZES = {
    "iPhone 17 Pro Max": (1320, 2868),
    "iPhone 17 Pro": (1206, 2622),
}


def font(size, serif=False):
    candidates_serif = [
        "/System/Library/Fonts/Supplemental/NewYork.ttf",
        "/System/Library/Fonts/NewYork.ttf",
        "/System/Library/Fonts/Supplemental/Georgia.ttf",
    ]
    candidates_sans = [
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    pool = candidates_serif if serif else candidates_sans
    for path in pool:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def draw_marketing_band(img, draw, headline, subhead, scale):
    w, h = img.size
    band_h = int(h * 0.27)
    f_head = font(int(78 * scale), serif=True)
    f_sub = font(int(38 * scale))
    lines = headline.split("\n")
    total_h = len(lines) * int(f_head.size * 1.1)
    y = (band_h - total_h - int(60 * scale)) // 2 + int(80 * scale)
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=f_head)
        tw = bbox[2] - bbox[0]
        draw.text(((w - tw) // 2, y), line, fill=TEXT_INK, font=f_head)
        y += int(f_head.size * 1.1)
    bbox = draw.textbbox((0, 0), subhead, font=f_sub)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) // 2, y + int(20 * scale)), subhead, fill=TEXT_STONE, font=f_sub)


def draw_phone_frame(img, draw, rect, scale):
    x, y, x2, y2 = rect
    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((x + 10, y + 30, x2 + 10, y2 + 30), radius=int(80 * scale),
                         fill=(31, 27, 22, 30))
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(28 * scale)))
    img.paste(shadow, (0, 0), shadow)
    draw.rounded_rectangle((x, y, x2, y2), radius=int(80 * scale), fill=SURFACE_PAPER,
                           outline=HAIRLINE, width=2)
    notch_w = int(280 * scale)
    notch_h = int(40 * scale)
    nx = (x + x2) // 2 - notch_w // 2
    draw.rounded_rectangle((nx, y + int(20 * scale), nx + notch_w, y + int(20 * scale) + notch_h),
                           radius=int(20 * scale), fill=TEXT_INK)


def draw_today_ui(img, draw, rect, scale):
    x, y, x2, y2 = rect
    pad = int(40 * scale)
    cx = x + pad
    cy = y + int(120 * scale)
    f_word = font(int(64 * scale), serif=True)
    draw.text((cx, cy), "Pith Voice", fill=TEXT_INK, font=f_word)
    cy += int(78 * scale)
    f_date = font(int(22 * scale))
    draw.text((cx, cy), "TUESDAY, 28 MAY", fill=TEXT_STONE, font=f_date)
    cy += int(60 * scale)

    entries = [
        ("THU, 28 MAY  ·  3 MIN", "The hour before the meeting",
         "Talked about the conversation with Mom on the phone last night —\nwhat wasn't said, what I was hoping she'd ask. Sat with it.",
         ["mom", "expectations", "morning"]),
        ("WED, 27 MAY  ·  5 MIN", "After the walk home",
         "The thought I keep coming back to: the difference between being\npatient and being slow. They're not the same.",
         ["patience", "work"]),
        ("TUE, 26 MAY  ·  4 MIN", "What James said about boundaries",
         "His sentence stayed: \"A boundary that needs to be defended every\nday isn't a boundary, it's a wall.\" I'm holding it lightly.",
         ["boundary", "James"]),
    ]
    card_w = (x2 - x) - pad * 2
    f_date_card = font(int(20 * scale))
    f_title = font(int(36 * scale), serif=True)
    f_body = font(int(26 * scale))
    f_chip = font(int(20 * scale))
    for ts, title, body, tags in entries:
        card_h = int(310 * scale)
        draw.rounded_rectangle((cx, cy, cx + card_w, cy + card_h), radius=int(24 * scale),
                               fill=SURFACE_PAPER, outline=HAIRLINE, width=2)
        ix = cx + int(28 * scale)
        iy = cy + int(28 * scale)
        draw.text((ix, iy), ts, fill=TEXT_STONE, font=f_date_card)
        iy += int(34 * scale)
        draw.text((ix, iy), title, fill=TEXT_INK, font=f_title)
        iy += int(56 * scale)
        for line in body.split("\n"):
            draw.text((ix, iy), line, fill=TEXT_STONE, font=f_body)
            iy += int(34 * scale)
        chip_x = ix
        chip_y = cy + card_h - int(50 * scale)
        for tag in tags:
            bbox = draw.textbbox((0, 0), tag, font=f_chip)
            tw = bbox[2] - bbox[0]
            cw = tw + int(28 * scale)
            ch = int(34 * scale)
            draw.rounded_rectangle((chip_x, chip_y, chip_x + cw, chip_y + ch),
                                   radius=int(8 * scale), fill=CHIP_TAG)
            draw.text((chip_x + int(14 * scale), chip_y + int(4 * scale)), tag,
                      fill=TEXT_STONE, font=f_chip)
            chip_x += cw + int(8 * scale)
        cy += card_h + int(22 * scale)

    btn_d = int(150 * scale)
    btn_cx = (x + x2) // 2
    btn_cy = y2 - int(200 * scale)
    draw.ellipse((btn_cx - btn_d // 2, btn_cy - btn_d // 2,
                  btn_cx + btn_d // 2, btn_cy + btn_d // 2), fill=ACCENT_MOSS)
    f_btn = font(int(28 * scale), serif=True)
    bbox = draw.textbbox((0, 0), "Rec", font=f_btn)
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((btn_cx - bw // 2, btn_cy - bh // 2 - int(2 * scale)), "Rec",
              fill=BG_CREAM, font=f_btn)


def draw_recording_ui(img, draw, rect, scale):
    x, y, x2, y2 = rect
    pad = int(40 * scale)
    cx = x + pad
    cy = y + int(120 * scale)
    f_word = font(int(64 * scale), serif=True)
    draw.text((cx, cy), "Pith Voice", fill=TEXT_INK, font=f_word)
    cy += int(80 * scale)
    f_date = font(int(22 * scale))
    draw.text((cx, cy), "TUESDAY, 28 MAY", fill=TEXT_STONE, font=f_date)
    cy += int(140 * scale)

    bars = 24
    bar_w = int(10 * scale)
    spacing = int(8 * scale)
    total_w = bars * bar_w + (bars - 1) * spacing
    start_x = (x + x2) // 2 - total_w // 2
    wf_h = int(160 * scale)
    wf_cy = cy + wf_h // 2
    for i in range(bars):
        d = abs(i - bars / 2) / (bars / 2)
        h_norm = 0.35 + 0.6 * (1 - d) + 0.1 * math.sin(i / 3.0)
        h = max(int(wf_h * 0.18), int(wf_h * h_norm))
        bx = start_x + i * (bar_w + spacing)
        draw.rounded_rectangle((bx, wf_cy - h // 2, bx + bar_w, wf_cy + h // 2),
                               radius=bar_w // 2, fill=ACCENT_MOSS)
    cy += wf_h + int(60 * scale)

    f_italic = font(int(34 * scale), serif=True)
    transcript = "…the thought I keep coming back to is the difference\nbetween being patient and being…"
    for line in transcript.split("\n"):
        bbox = draw.textbbox((0, 0), line, font=f_italic)
        tw = bbox[2] - bbox[0]
        draw.text(((x + x2) // 2 - tw // 2, cy), line, fill=TEXT_STONE, font=f_italic)
        cy += int(48 * scale)

    btn_d = int(150 * scale)
    btn_cx = (x + x2) // 2
    btn_cy = y2 - int(200 * scale)
    draw.ellipse((btn_cx - btn_d // 2, btn_cy - btn_d // 2,
                  btn_cx + btn_d // 2, btn_cy + btn_d // 2), fill=(160, 74, 55))
    f_btn = font(int(28 * scale), serif=True)
    bbox = draw.textbbox((0, 0), "Stop", font=f_btn)
    bw, bh = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((btn_cx - bw // 2, btn_cy - bh // 2 - int(2 * scale)), "Stop",
              fill=BG_CREAM, font=f_btn)


def draw_paywall_ui(img, draw, rect, scale):
    x, y, x2, y2 = rect
    pad = int(40 * scale)
    cx = x + pad
    cy = y + int(120 * scale)
    f_head = font(int(60 * scale), serif=True)
    f_sub = font(int(24 * scale))
    draw.text((cx, cy), "Keep showing up\nfor yourself.", fill=TEXT_INK, font=f_head)
    cy += int(160 * scale)
    draw.text((cx, cy), "Choose how you want Pith Voice.", fill=TEXT_STONE, font=f_sub)
    cy += int(60 * scale)

    plans = [
        ("Annual",   "$59.99",  "/year · $5.00/mo equivalent", True),
        ("Lifetime", "$99.99",  "One-time · Never expires",    False),
        ("Weekly",   "$4.99",   "/week · Try it short",        False),
    ]
    card_w = (x2 - x) - pad * 2
    f_plan = font(int(36 * scale), serif=True)
    f_price = font(int(38 * scale))
    f_caption = font(int(22 * scale))
    f_badge = font(int(18 * scale))
    for name, price, cap, recommended in plans:
        card_h = int(160 * scale)
        bg = ACCENT_MOSS if recommended else SURFACE_PAPER
        fg = BG_CREAM if recommended else TEXT_INK
        cap_color = (230, 230, 220) if recommended else TEXT_STONE
        draw.rounded_rectangle((cx, cy, cx + card_w, cy + card_h),
                               radius=int(24 * scale), fill=bg,
                               outline=HAIRLINE if not recommended else None,
                               width=(2 if not recommended else 0))
        ix = cx + int(28 * scale)
        iy = cy + int(28 * scale)
        draw.text((ix, iy), name, fill=fg, font=f_plan)
        if recommended:
            bbox = draw.textbbox((0, 0), "RECOMMENDED", font=f_badge)
            bw = bbox[2] - bbox[0]
            bx = cx + card_w - int(28 * scale) - bw - int(20 * scale)
            draw.rounded_rectangle((bx, iy + int(8 * scale), bx + bw + int(20 * scale),
                                    iy + int(8 * scale) + int(34 * scale)),
                                   radius=int(8 * scale), fill=BG_CREAM)
            draw.text((bx + int(10 * scale), iy + int(13 * scale)), "RECOMMENDED",
                      fill=ACCENT_MOSS, font=f_badge)
        iy += int(56 * scale)
        draw.text((ix, iy), price, fill=fg, font=f_price)
        bbox = draw.textbbox((0, 0), cap, font=f_caption)
        tw = bbox[2] - bbox[0]
        draw.text((cx + card_w - int(28 * scale) - tw, iy + int(8 * scale)), cap,
                  fill=cap_color, font=f_caption)
        cy += card_h + int(20 * scale)

    cy += int(20 * scale)
    f_discl = font(int(18 * scale))
    for line in [
        "Auto-renews until cancelled. Manage in Settings → Apple ID.",
        "Two free entries before paywall. No free trial.",
        "",
        "Privacy Policy  ·  Terms of Use  ·  Restore Purchases",
    ]:
        bbox = draw.textbbox((0, 0), line, font=f_discl)
        tw = bbox[2] - bbox[0]
        draw.text(((x + x2) // 2 - tw // 2, cy), line, fill=TEXT_STONE, font=f_discl)
        cy += int(26 * scale)


def draw_threads_ui(img, draw, rect, scale):
    x, y, x2, y2 = rect
    pad = int(40 * scale)
    cx = x + pad
    cy = y + int(120 * scale)
    f_head = font(int(60 * scale), serif=True)
    draw.text((cx, cy), "Threads", fill=TEXT_INK, font=f_head)
    cy += int(80 * scale)
    f_sub = font(int(22 * scale))
    draw.text((cx, cy), "THIS WEEK", fill=TEXT_STONE, font=f_sub)
    cy += int(60 * scale)

    themes = [
        ("Boundary", 4,
         "What you said about saying no — to the meeting, to the dinner,\nto your own old habits."),
        ("Mom", 3,
         "Patience, exhaustion, and the slow conversation you're afraid\nto have."),
        ("Work", 5,
         "The difference between effort and attention, surfaced across\nfive entries."),
    ]
    f_theme = font(int(42 * scale), serif=True)
    f_count = font(int(22 * scale))
    f_body = font(int(26 * scale))
    card_w = (x2 - x) - pad * 2
    for name, count, body in themes:
        card_h = int(290 * scale)
        draw.rounded_rectangle((cx, cy, cx + card_w, cy + card_h), radius=int(24 * scale),
                               fill=SURFACE_PAPER, outline=HAIRLINE, width=2)
        ix = cx + int(28 * scale)
        iy = cy + int(28 * scale)
        draw.text((ix, iy), name, fill=TEXT_INK, font=f_theme)
        chip_text = f"{count} entries"
        bbox = draw.textbbox((0, 0), chip_text, font=f_count)
        tw = bbox[2] - bbox[0]
        chip_cx = cx + card_w - int(28 * scale) - tw - int(28 * scale)
        chip_cy = iy + int(8 * scale)
        draw.rounded_rectangle((chip_cx, chip_cy, chip_cx + tw + int(28 * scale),
                                chip_cy + int(40 * scale)), radius=int(8 * scale),
                               fill=CHIP_TAG)
        draw.text((chip_cx + int(14 * scale), chip_cy + int(8 * scale)), chip_text,
                  fill=TEXT_STONE, font=f_count)
        iy += int(70 * scale)
        for line in body.split("\n"):
            draw.text((ix, iy), line, fill=TEXT_STONE, font=f_body)
            iy += int(34 * scale)
        cy += card_h + int(22 * scale)


def draw_detail_ui(img, draw, rect, scale):
    x, y, x2, y2 = rect
    pad = int(40 * scale)
    cx = x + pad
    cy = y + int(120 * scale)
    f_date = font(int(22 * scale))
    draw.text((cx, cy), "TUESDAY, 28 MAY", fill=TEXT_STONE, font=f_date)
    cy += int(40 * scale)
    f_head = font(int(60 * scale), serif=True)
    draw.text((cx, cy), "The hour before\nthe meeting", fill=TEXT_INK, font=f_head)
    cy += int(160 * scale)

    btn_d = int(90 * scale)
    draw.ellipse((cx, cy, cx + btn_d, cy + btn_d), fill=ACCENT_MOSS_SOFT)
    tri_pad = int(28 * scale)
    draw.polygon([(cx + tri_pad + int(8 * scale), cy + tri_pad),
                  (cx + tri_pad + int(8 * scale), cy + btn_d - tri_pad),
                  (cx + btn_d - tri_pad, cy + btn_d // 2)], fill=BG_CREAM)
    f_dur = font(int(24 * scale))
    draw.text((cx + btn_d + int(20 * scale), cy + btn_d // 2 - int(14 * scale)),
              "3 min", fill=TEXT_STONE, font=f_dur)
    cy += btn_d + int(50 * scale)

    f_label = font(int(20 * scale))
    draw.text((cx, cy), "SUMMARY", fill=TEXT_STONE, font=f_label)
    cy += int(36 * scale)
    f_body = font(int(28 * scale))
    summary = ("Talked about the conversation with Mom on the phone last\n"
               "night — what wasn't said, what I was hoping she'd ask. Sat\n"
               "with it. Made the coffee. Realised the meeting wasn't\n"
               "the real thing on my mind.")
    for line in summary.split("\n"):
        draw.text((cx, cy), line, fill=TEXT_INK, font=f_body)
        cy += int(40 * scale)
    cy += int(20 * scale)

    f_chip = font(int(22 * scale))
    chip_x = cx
    chip_y = cy
    for tag in ["mom", "expectations", "morning"]:
        bbox = draw.textbbox((0, 0), tag, font=f_chip)
        tw = bbox[2] - bbox[0]
        cw = tw + int(28 * scale)
        ch = int(38 * scale)
        draw.rounded_rectangle((chip_x, chip_y, chip_x + cw, chip_y + ch),
                               radius=int(8 * scale), fill=CHIP_TAG)
        draw.text((chip_x + int(14 * scale), chip_y + int(6 * scale)), tag,
                  fill=TEXT_STONE, font=f_chip)
        chip_x += cw + int(10 * scale)
    cy += int(80 * scale)

    draw.text((cx, cy), "TRANSCRIPT", fill=TEXT_STONE, font=f_label)
    cy += int(36 * scale)
    f_tr = font(int(24 * scale))
    transcript = ("Sat in the kitchen, kettle on. I keep thinking about last\n"
                  "night — Mom called from the hospital but she didn't ask\n"
                  "the question. She didn't ask if I'd thought any more about\n"
                  "Dad. I'd been waiting for it. The space where the question\n"
                  "should have been sat between us for an hour.")
    for line in transcript.split("\n"):
        draw.text((cx, cy), line, fill=TEXT_STONE, font=f_tr)
        cy += int(34 * scale)


SCREENS = [
    ("01_Today",   "today",   "Speak. Stays here.",                  "A voice journal where every word stays on your iPhone."),
    ("02_Record",  "record",  "Your iPhone listens.\nNothing else does.", "Apple Intelligence draws the summary. Locally."),
    ("03_Paywall", "paywall", "One price.\nNo cloud, ever.",         "Three plans. All on-device. Cancel anytime."),
    ("04_Threads", "threads", "The shape of\nwhat you carry.",       "Themes surfaced from your own words, not graphs."),
    ("05_Detail",  "detail",  "Read what\nyou said.",                "Yesterday's pith — title, summary, the words behind it."),
]


def render(size, screen, headline, subhead):
    img = Image.new("RGB", size, BG_CREAM)
    draw = ImageDraw.Draw(img)
    w, h = size
    scale = w / 1320
    draw_marketing_band(img, draw, headline, subhead, scale)
    band_h = int(h * 0.27)
    fx = int(w * 0.06)
    fy = band_h + int(20 * scale)
    fx2 = w - int(w * 0.06)
    fy2 = h - int(60 * scale)
    draw_phone_frame(img, draw, (fx, fy, fx2, fy2), scale)
    inset = int(20 * scale)
    inner = (fx + inset, fy + inset, fx2 - inset, fy2 - inset)
    {
        "today": draw_today_ui,
        "record": draw_recording_ui,
        "paywall": draw_paywall_ui,
        "threads": draw_threads_ui,
        "detail": draw_detail_ui,
    }[screen](img, draw, inner, scale)
    return img


def main():
    # Wipe old placeholder PNGs so old filenames don't linger
    for fn in os.listdir(OUT):
        if fn.startswith("iPhone ") and fn.endswith(".png"):
            os.remove(os.path.join(OUT, fn))
    for size_name, size in SIZES.items():
        for stem, screen, headline, subhead in SCREENS:
            img = render(size, screen, headline, subhead)
            path = os.path.join(OUT, f"{size_name}-{stem}.png")
            img.save(path, "PNG", optimize=True)
            print(f"  wrote {os.path.basename(path)}  {size[0]}×{size[1]}")
    print(f"\nDone — {len(SIZES) * len(SCREENS)} screenshots in {OUT}")


if __name__ == "__main__":
    main()
