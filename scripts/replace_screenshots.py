#!/usr/bin/env python3
"""Replace App Store screenshots via ASC API.

For each set: DELETE existing screenshots, then upload new PNGs via the
3-step flow (POST reserve → PUT to S3 → PATCH uploaded=true with MD5).

Run with the JWT token in env var ASC_TOKEN.
"""
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from PIL import Image

TOKEN = os.environ["ASC_TOKEN"]
ROOT = Path("/Users/vassiliyshmigirivov/Apple_apps/1_Pith")
SCREENSHOTS_DIR = ROOT / "fastlane/screenshots/en-US"

# (set_id, screenshot_display_type, [filenames])
SETS = [
    (
        "91a4162b-af78-4217-8dba-664e88a175e7",
        "APP_IPHONE_67",
        [
            "iPhone 17 Pro Max-01_Today.png",
            "iPhone 17 Pro Max-02_Record.png",
            "iPhone 17 Pro Max-03_Paywall.png",
            "iPhone 17 Pro Max-04_Threads.png",
            "iPhone 17 Pro Max-05_Detail.png",
        ],
    ),
    (
        "3639c790-64be-4091-8fa0-5afba4dd6a25",
        "APP_IPHONE_61",
        [
            "iPhone 17 Pro-01_Today.png",
            "iPhone 17 Pro-02_Record.png",
            "iPhone 17 Pro-03_Paywall.png",
            "iPhone 17 Pro-04_Threads.png",
            "iPhone 17 Pro-05_Detail.png",
        ],
    ),
    (
        "21fbdf4e-3878-47df-a023-9a519ae0a2d2",
        "APP_IPAD_PRO_3GEN_129",
        ["iPad Pro 12.9-paywall.png"],
    ),
]

BASE = "https://api.appstoreconnect.apple.com"
HEAD_JSON = ["-H", f"Authorization: Bearer {TOKEN}", "-H", "Content-Type: application/json"]
HEAD_BEARER = ["-H", f"Authorization: Bearer {TOKEN}"]


def curl_json(method, url, body=None):
    cmd = ["curl", "-sS", "-X", method, *HEAD_JSON, url]
    if body is not None:
        cmd += ["-d", json.dumps(body)]
    out = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if not out.stdout.strip():
        return {}
    return json.loads(out.stdout)


def curl_status(method, url):
    cmd = ["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}", "-X", method, *HEAD_BEARER, url]
    out = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return out.stdout.strip()


def get_existing(set_id):
    r = curl_json("GET", f"{BASE}/v1/appScreenshotSets/{set_id}/appScreenshots")
    return [s["id"] for s in r.get("data", [])]


def delete_screenshot(sid):
    code = curl_status("DELETE", f"{BASE}/v1/appScreenshots/{sid}")
    return code in ("204", "200")


def png_bytes_rgb(path):
    """Load PNG; if RGBA, flatten to RGB on white. Return bytes + md5."""
    im = Image.open(path)
    if im.mode != "RGB":
        bg = Image.new("RGB", im.size, (255, 255, 255))
        bg.paste(im, mask=im.split()[-1] if im.mode in ("RGBA", "LA") else None)
        im = bg
    import io
    buf = io.BytesIO()
    im.save(buf, "PNG", optimize=True)
    data = buf.getvalue()
    md5 = hashlib.md5(data).hexdigest()
    return data, md5


def upload_screenshot(set_id, path):
    name = path.name
    data, md5 = png_bytes_rgb(path)
    size = len(data)

    print(f"  reserve POST: {name} ({size} bytes)")
    reserve = curl_json("POST", f"{BASE}/v1/appScreenshots", {
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": name, "fileSize": size},
            "relationships": {
                "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
            },
        }
    })
    if "errors" in reserve:
        print(f"    ERROR reserving: {reserve['errors']}")
        return False
    sid = reserve["data"]["id"]
    ops = reserve["data"]["attributes"]["uploadOperations"]
    if len(ops) != 1:
        print(f"    Unexpected uploadOperations count: {len(ops)}")
    op = ops[0]

    headers = []
    for h in op["requestHeaders"]:
        headers += ["-H", f"{h['name']}: {h['value']}"]

    import tempfile
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tf:
        tf.write(data)
        tf_path = tf.name

    print(f"  PUT {op['method']} {op['url'][:80]}...")
    code = subprocess.run(
        ["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}",
         "-X", op["method"], *headers, "--data-binary", f"@{tf_path}", op["url"]],
        capture_output=True, text=True, check=False
    )
    os.unlink(tf_path)
    if code.stdout.strip() not in ("200", "201", "204"):
        print(f"    PUT failed: HTTP {code.stdout.strip()}")
        return False

    print(f"  PATCH uploaded=true md5={md5}")
    patch = curl_json("PATCH", f"{BASE}/v1/appScreenshots/{sid}", {
        "data": {
            "type": "appScreenshots",
            "id": sid,
            "attributes": {"uploaded": True, "sourceFileChecksum": md5},
        }
    })
    if "errors" in patch:
        print(f"    PATCH errors: {patch['errors']}")
        return False
    print(f"  OK: {sid}")
    return True


def main():
    for set_id, display_type, filenames in SETS:
        print(f"\n=== Set {display_type} ({set_id}) ===")
        existing = get_existing(set_id)
        print(f"  existing: {len(existing)} screenshots")
        for sid in existing:
            ok = delete_screenshot(sid)
            print(f"  delete {sid}: {'ok' if ok else 'FAIL'}")
        for fn in filenames:
            path = SCREENSHOTS_DIR / fn
            if not path.exists():
                print(f"  MISSING: {path}")
                continue
            if not upload_screenshot(set_id, path):
                print(f"  FAILED: {fn}")
                sys.exit(1)
            time.sleep(0.5)

    print("\n=== ALL DONE ===")


if __name__ == "__main__":
    main()
