#!/usr/bin/env python3
"""Python 3.9-compatible variant of apple-app-team/scripts/create_intro_offers.py.

Drops the `dict | None` annotation that requires Python 3.10+. Same behaviour.
"""

import argparse
import json
import subprocess
import sys
from typing import Optional

ASC = "https://api.appstoreconnect.apple.com"


def curl(method, url, token, body=None):
    cmd = [
        "curl", "-sX", method,
        "-H", "Authorization: Bearer " + token,
        "-H", "Content-Type: application/json",
        url,
    ]
    if body is not None:
        cmd += ["-d", json.dumps(body)]
    out = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if out.returncode != 0 or not out.stdout.strip():
        return {"_curl_failed": True, "stderr": out.stderr}
    try:
        return json.loads(out.stdout)
    except json.JSONDecodeError as exc:
        return {"_json_error": str(exc), "raw": out.stdout[:500]}


def list_territories(token):
    data = curl("GET", ASC + "/v1/territories?limit=200", token)
    if "errors" in data:
        sys.exit("Failed to list territories: " + str(data["errors"]))
    return [t["id"] for t in data["data"]]


def existing_territories(token, sub_id):
    data = curl(
        "GET",
        ASC + "/v1/subscriptions/" + sub_id + "/introductoryOffers?include=territory&limit=200",
        token,
    )
    if "errors" in data:
        return set()
    territories = set()
    # Walk included territories and relationship pointers.
    for inc in data.get("included", []):
        if inc.get("type") == "territories":
            territories.add(inc["id"])
    for off in data.get("data", []):
        tref = off.get("relationships", {}).get("territory", {}).get("data")
        if tref:
            territories.add(tref["id"])
    return territories


def create_offer(token, sub_id, territory_id, duration, offer_mode):
    body = {
        "data": {
            "type": "subscriptionIntroductoryOffers",
            "attributes": {
                "duration": duration,
                "offerMode": offer_mode,
                "numberOfPeriods": 1,
            },
            "relationships": {
                "subscription": {"data": {"type": "subscriptions", "id": sub_id}},
                "territory": {"data": {"type": "territories", "id": territory_id}},
            },
        }
    }
    return curl("POST", ASC + "/v1/subscriptionIntroductoryOffers", token, body)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("token")
    parser.add_argument("subscription_id")
    parser.add_argument("--duration", default="ONE_WEEK")
    parser.add_argument("--offer-mode", default="FREE_TRIAL")
    args = parser.parse_args()

    territories = list_territories(args.token)
    already = existing_territories(args.token, args.subscription_id)
    todo = [t for t in territories if t not in already]
    print("Total territories: %d  ·  Already have offer: %d  ·  To create: %d"
          % (len(territories), len(already), len(todo)))

    ok = 0
    skipped = 0
    errors = 0
    for tid in todo:
        resp = create_offer(args.token, args.subscription_id, tid,
                            args.duration, args.offer_mode)
        if resp.get("errors"):
            err_detail = resp["errors"][0].get("detail", "?")
            if "already exists" in err_detail.lower() or "duplicate" in err_detail.lower():
                skipped += 1
            else:
                errors += 1
                if errors <= 3:
                    print("  [%s] %s" % (tid, err_detail))
        else:
            ok += 1
    print("Result: created %d, skipped (already) %d, errors %d"
          % (ok, skipped, errors))


if __name__ == "__main__":
    main()
