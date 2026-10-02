#!/usr/bin/env python3
"""Export Hex projects into analyses/<collection>/<slug>/ as .hex.yaml files.

Usage:
    export HEX_API_TOKEN=...            # Hex > Settings > API keys
    python3 scripts/export_hex.py              # all projects in scripts/hex_projects.csv
    python3 scripts/export_hex.py <project_id> # just one

To add a project, add a row to scripts/hex_projects.csv and rerun.
Exports contain project logic only (cells, SQL, layout), never query results.
"""
import csv, json, os, sys, time, urllib.request, urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "scripts" / "hex_projects.csv"
API = "https://app.hex.tech/api/v1/projects/export"
ORG = "d289eb74-2a64-4475-9878-fa22bd2914d3"

README = """---
title: "{title}"
collection: {collection}
collections: []
author: {creator}
date: {created}
status: final
source: https://app.hex.tech/{org}/hex/{project_id}
tags: []
---

# {title}

Exported directly from Hex. The full project logic (SQL, Python, markdown, app layout) is in `{slug}.hex.yaml`; query results are not included.

<!-- Optional: add a short Question / Answer / Caveats summary here to make this easier to find. -->
"""


def export(project_id: str, token: str) -> str:
    body = json.dumps({"projectId": project_id, "version": "draft"}).encode()
    req = urllib.request.Request(API, data=body, method="POST", headers={
        "Authorization": f"Bearer {token}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        text = r.read().decode()
        if "json" in r.headers.get("Content-Type", ""):
            data = json.loads(text)
            text = next((v for v in data.values() if isinstance(v, str) and "\n" in v), text)
        return text


def main():
    token = os.environ.get("HEX_API_TOKEN")
    if not token:
        sys.exit("Set HEX_API_TOKEN first (Hex > Settings > API keys).")
    rows = list(csv.DictReader(MANIFEST.open()))
    only = set(sys.argv[1:])
    failed = []
    for row in rows:
        if only and row["project_id"] not in only:
            continue
        out_dir = ROOT / "analyses" / row["collection"] / row["slug"]
        out_dir.mkdir(parents=True, exist_ok=True)
        try:
            (out_dir / f"{row['slug']}.hex.yaml").write_text(export(row["project_id"], token))
        except urllib.error.HTTPError as e:
            failed.append(row["slug"])
            print(f"FAIL {row['slug']}: HTTP {e.code} {e.read().decode()[:200]}")
            continue
        readme = out_dir / "README.md"
        if not readme.exists():
            readme.write_text(README.format(org=ORG, **row))
        print(f"ok   {row['collection']}/{row['slug']}")
        time.sleep(2.5)  # API limit: 30 requests/minute
    if failed:
        sys.exit(f"{len(failed)} failed")


if __name__ == "__main__":
    main()
