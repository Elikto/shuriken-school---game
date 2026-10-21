#!/usr/bin/env python3
"""Prepare a PUBLIC, read-only history of proven Godot screenshots.

Runs in GitHub Actions with permissions {contents:read, actions:read}.
Never copies logs, tokens or arbitrary artifact files to GitHub Pages.
"""
import json
import os
from pathlib import Path
import struct
import subprocess
import sys

DEST = Path("dashboard/live")
IMAGES = DEST / "captures"
MAX_FILE_BYTES = 5_000_000
MAX_CAPTURES = 5


def gh_api(path):
    output = subprocess.check_output(
        ["gh", "api", "--header", "Accept: application/vnd.github+json", path],
        text=True, timeout=30,
    )
    return json.loads(output)


def valid_png(file):
    try:
        data = file.read_bytes()
        if len(data) < 512 or len(data) > MAX_FILE_BYTES:
            return False
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            return False
        length = struct.unpack_from(">I", data, 8)[0]
        if data[12:16] != b"IHDR" or length != 13:
            return False
        width, height = struct.unpack_from(">II", data, 16)
        return 320 <= width <= 3840 and 240 <= height <= 2160
    except (OSError, ValueError, struct.error):
        return False


def main():
    repository = os.environ.get("GITHUB_REPOSITORY", "").strip()
    if repository != "Elikto/shuriken-school---game":
        raise RuntimeError("Unexpected repository: not publishing images")
    DEST.mkdir(parents=True, exist_ok=True)
    IMAGES.mkdir(parents=True, exist_ok=True)
    entries = []
    try:
        response = gh_api("repos/" + repository + "/actions/runs?per_page=60")
        runs = [r for r in response.get("workflow_runs", [])
                if r.get("name") == "Vérification Godot 3D"
                and r.get("head_branch") == "main"
                and r.get("conclusion") == "success"]
    except (subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print("IMAGE_HISTORY_WARNING", type(error).__name__)
        runs = []
    for run in runs:
        if len(entries) >= MAX_CAPTURES:
            break
        runid = run.get("id")
        if not isinstance(runid, int):
            continue
        try:
            artifacts = gh_api(f"repos/{repository}/actions/runs/{runid}/artifacts")
            preview = next((a for a in artifacts.get("artifacts", [])
                            if a.get("name") == "ShurikenSchool3D-Apercu"
                            and not a.get("expired", True)), None)
            if not preview:
                continue
            temp = Path("/tmp/shuriken-preview-" + str(runid))
            temp.mkdir(parents=True, exist_ok=True)
            subprocess.run(
                ["gh", "run", "download", str(runid), "--repo", repository,
                 "--name", "ShurikenSchool3D-Apercu", "--dir", str(temp)],
                check=True, timeout=90,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            image = temp / "preview.png"
            if not valid_png(image):
                print("IMAGE_HISTORY_IGNORED invalid PNG in run", runid)
                continue
            destination = IMAGES / f"{runid}.png"
            destination.write_bytes(image.read_bytes())
            entries.append({
                "run_id": runid,
                "image": f"live/captures/{runid}.png",
                "sha": str(run.get("head_sha", ""))[:40],
                "captured_at": preview.get("created_at") or run.get("updated_at"),
                "run_url": f"https://github.com/{repository}/actions/runs/{runid}",
                "source": "Godot renderer CI / ShurikenSchool3D-Apercu",
            })
            print("IMAGE_HISTORY_OK", runid, destination.stat().st_size)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired,
                StopIteration, OSError, ValueError) as error:
            print("IMAGE_HISTORY_WARNING", runid, type(error).__name__)
    manifest = {
        "version": 1,
        "source": "verified GitHub Actions artifact ShurikenSchool3D-Apercu",
        "scope": "Real Godot screenshots. Not a live video or AI concept illustration.",
        "captures": entries,
    }
    (DEST / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print("IMAGE_HISTORY_COUNT", len(entries))
    # Missing prior screenshots is not an excuse to fake visuals; publish empty state.
    return 0


if __name__ == "__main__":
    sys.exit(main())
