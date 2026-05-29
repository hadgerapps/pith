#!/usr/bin/env python3
"""Re-upload IAP review screenshots with a correct 3-step flow.

Fixes quirk #42: the prior uploads left `uploaded == null` because the
PUT to S3 did not replay the reservation's requestHeaders, so ASC's
checksum validation failed and never flipped `uploaded` to true.

This script:
  1. DELETEs the existing (broken) review screenshot on each product.
  2. POSTs a fresh reservation.
  3. PUTs the bytes to S3 replaying EVERY requestHeader from uploadOperations.
  4. PATCHes {uploaded:true, sourceFileChecksum:md5}.
  5. Verifies uploaded == true.

Token via env ASC_TOKEN. PNG path is fixed below.
"""
import hashlib
import json
import os
import subprocess
import sys
import time

TOKEN = os.environ["ASC_TOKEN"]
PNG = "/tmp/pith_iap_review.png"
BASE = "https://api.appstoreconnect.apple.com"

# (label, variant, relationship_name, relationship_type, parent_id, get_url)
TARGETS = [
    ("Weekly", "subscriptionAppStoreReviewScreenshots", "subscription", "subscriptions",
     "6770545728", f"{BASE}/v1/subscriptions/6770545728/appStoreReviewScreenshot"),
    ("Annual", "subscriptionAppStoreReviewScreenshots", "subscription", "subscriptions",
     "6770545519", f"{BASE}/v1/subscriptions/6770545519/appStoreReviewScreenshot"),
    ("Lifetime", "inAppPurchaseAppStoreReviewScreenshots", "inAppPurchaseV2", "inAppPurchases",
     "6770546034", f"{BASE}/v2/inAppPurchases/6770546034/appStoreReviewScreenshot"),
]

HJSON = ["-H", f"Authorization: Bearer {TOKEN}", "-H", "Content-Type: application/json"]
HBEAR = ["-H", f"Authorization: Bearer {TOKEN}"]


def curl_json(method, url, body=None):
    cmd = ["curl", "-sS", "-X", method, *HJSON, url]
    if body is not None:
        cmd += ["-d", json.dumps(body)]
    out = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return json.loads(out.stdout) if out.stdout.strip() else {}


def main():
    with open(PNG, "rb") as f:
        data = f.read()
    size = len(data)
    md5 = hashlib.md5(data).hexdigest()
    print(f"PNG {size} bytes, md5 {md5}\n")

    for label, variant, rel_name, rel_type, parent_id, get_url in TARGETS:
        print(f"=== {label} ===")

        # 1. delete existing
        cur = curl_json("GET", get_url)
        sid = cur.get("data", {}).get("id")
        if sid:
            code = subprocess.run(
                ["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}", "-X", "DELETE", *HBEAR,
                 f"{BASE}/v1/{variant}/{sid}"],
                capture_output=True, text=True, check=False).stdout.strip()
            print(f"  deleted old {sid}: HTTP {code}")
            time.sleep(1)

        # 2. reservation
        reserve = curl_json("POST", f"{BASE}/v1/{variant}", {
            "data": {
                "type": variant,
                "attributes": {"fileName": "pith_paywall.png", "fileSize": size},
                "relationships": {rel_name: {"data": {"type": rel_type, "id": parent_id}}},
            }
        })
        if "errors" in reserve:
            print(f"  RESERVE ERROR: {reserve['errors']}")
            sys.exit(1)
        new_id = reserve["data"]["id"]
        op = reserve["data"]["attributes"]["uploadOperations"][0]
        print(f"  reserved {new_id}")

        # 3. PUT replaying ALL requestHeaders
        headers = []
        for h in op["requestHeaders"]:
            headers += ["-H", f"{h['name']}: {h['value']}"]
        code = subprocess.run(
            ["curl", "-sS", "-o", "/dev/null", "-w", "%{http_code}", "-X", op["method"],
             *headers, "--data-binary", f"@{PNG}", op["url"]],
            capture_output=True, text=True, check=False).stdout.strip()
        print(f"  PUT {op['method']}: HTTP {code}")
        if code not in ("200", "201", "204"):
            print("  PUT FAILED")
            sys.exit(1)

        # 4. commit
        patch = curl_json("PATCH", f"{BASE}/v1/{variant}/{new_id}", {
            "data": {
                "type": variant,
                "id": new_id,
                "attributes": {"uploaded": True, "sourceFileChecksum": md5},
            }
        })
        if "errors" in patch:
            print(f"  COMMIT ERROR: {patch['errors']}")
            sys.exit(1)
        up = patch["data"]["attributes"].get("uploaded")
        print(f"  committed: uploaded={up}")
        time.sleep(2)

        # 5. verify
        check = curl_json("GET", get_url)
        a = check.get("data", {}).get("attributes", {})
        print(f"  VERIFY: uploaded={a.get('uploaded')} "
              f"assetState={a.get('assetDeliveryState', {}).get('state')}\n")

    print("=== DONE ===")


if __name__ == "__main__":
    main()
