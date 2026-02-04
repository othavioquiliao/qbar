#!/usr/bin/env python3
"""Check OpenAI Codex CLI rate limit status (local logs + optional ping)."""

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path


def find_latest_session_file():
    sessions_dir = Path.home() / ".codex" / "sessions"
    now = datetime.now()

    for day_offset in range(2):
        date = datetime(now.year, now.month, now.day)
        date = datetime.fromordinal(date.toordinal() - day_offset)
        day_dir = sessions_dir / f"{date.year:04d}" / f"{date.month:02d}" / f"{date.day:02d}"

        if not day_dir.exists():
            continue

        jsonl_files = list(day_dir.glob("*.jsonl"))
        if jsonl_files:
            return max(jsonl_files, key=lambda f: f.stat().st_mtime)

    return None


def extract_rate_limits(file_path: Path):
    with open(file_path, "r") as f:
        for line in reversed(f.readlines()):
            if not line.strip():
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            payload = event.get("payload", {})
            if payload.get("type") == "token_count" and payload.get("rate_limits"):
                return payload["rate_limits"]
    return None


def unix_to_iso(timestamp: int):
    return datetime.fromtimestamp(timestamp, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def ping_codex(want_json=False):
    import subprocess

    codex_bin = os.environ.get("CODEX_BIN", "codex")
    if want_json:
        print("Pinging Codex for fresh rate limit data...", file=sys.stderr)
    else:
        print("Pinging Codex for fresh rate limit data...")

    try:
        subprocess.run(
            [codex_bin, "exec", "--skip-git-repo-check", "reply OK"],
            cwd=Path.home(),
            capture_output=True,
            timeout=60,
        )
    except Exception as e:
        if want_json:
            print(f"Ping failed: {e}", file=sys.stderr)
        else:
            print(f"Ping failed: {e}")

    return find_latest_session_file()


def main():
    args = set(sys.argv[1:])
    want_fresh = "--fresh" in args or "-f" in args
    want_json = "--json" in args or "-j" in args

    if want_fresh:
        session_file = ping_codex(want_json=want_json)
    else:
        session_file = find_latest_session_file()

    if not session_file:
        if want_json:
            print('{"error": "No session files found"}')
        else:
            print("No session files found")
        sys.exit(1)

    limits = extract_rate_limits(session_file)
    if not limits:
        if want_json:
            print('{"error": "Could not extract rate limits"}')
        else:
            print("Could not extract rate limits")
        sys.exit(1)

    output = {
        "primary": {
            "used_percent": limits["primary"]["used_percent"],
            "window_minutes": limits["primary"]["window_minutes"],
            "resets_at": unix_to_iso(limits["primary"]["resets_at"]),
        },
        "secondary": {
            "used_percent": limits["secondary"]["used_percent"],
            "window_minutes": limits["secondary"]["window_minutes"],
            "resets_at": unix_to_iso(limits["secondary"]["resets_at"]),
        },
        "updated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }

    if want_json:
        print(json.dumps(output, indent=2))
    else:
        print(json.dumps(output))


if __name__ == "__main__":
    main()
