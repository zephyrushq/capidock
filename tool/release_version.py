#!/usr/bin/env python3
"""Plan a release from Git tags and Conventional Commits (no external packages)."""

import argparse
import json
import os
import re
import subprocess
from pathlib import Path


VERSION = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
HEADER = re.compile(r"^[a-z]+(?:\([^\r\n()]+\))?(!)?: ")


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


def parse_version(value):
    match = VERSION.fullmatch(value)
    if not match:
        raise ValueError(f"Invalid stable version: {value}")
    return tuple(map(int, match.groups()))


def version_code(version):
    major, minor, patch = version
    if minor >= 1000 or patch >= 1000:
        raise ValueError("Minor and patch must be below 1000 for Android versionCode")
    code = major * 1_000_000 + minor * 1000 + patch
    if not 1 <= code <= 2_100_000_000:
        raise ValueError("Version is outside Android's versionCode range")
    return code


def bump(version, messages):
    major, minor, patch = version
    for message in messages:
        header = HEADER.match(message)
        if (header and header.group(1)) or re.search(
            r"^BREAKING[ -]CHANGE: ", message, re.MULTILINE
        ):
            return major + 1, 0, 0
    if any(re.match(r"^feat(?:\([^\r\n()]+\))?: ", m) for m in messages):
        return major, minor + 1, 0
    # Every other push (including docs/ci/chore) still produces a release.
    return major, minor, patch + 1


def plan_release():
    if git("rev-parse", "--is-shallow-repository") == "true":
        raise ValueError("A complete Git history is required (fetch-depth: 0)")
    sha = git("rev-parse", "HEAD")
    tags = [
        (parse_version(tag[1:]), tag)
        for tag in git("tag", "--list", "v*").splitlines()
        if VERSION.fullmatch(tag[1:])
    ]
    previous = max(tags, default=None)
    existing_version = None
    if previous:
        previous_version, previous_tag = previous
        ancestor = subprocess.run(
            ["git", "merge-base", "--is-ancestor", previous_tag, "HEAD"],
            check=False,
        )
        if ancestor.returncode != 0:
            raise ValueError("Latest release is not an ancestor of HEAD; do not rewrite release history")
        released_sha = git("rev-list", "-n", "1", previous_tag)
        if sha == released_sha:
            existing_version = previous_version
            previous = max((t for t in tags if t[0] < previous_version), default=None)
        revision = f"{previous[1]}..HEAD" if previous else "HEAD"
    else:
        revision = "HEAD"
    records = git("log", "--format=%H%x00%B%x00", revision).split("\0")
    commits = [
        {"sha": records[i].strip(), "message": records[i + 1].strip()}
        for i in range(0, len(records) - 1, 2)
        if records[i].strip()
    ]
    if existing_version:
        version = existing_version
    elif previous:
        version = bump(previous[0], [c["message"] for c in commits])
    else:
        version = (0, 0, 0)
    # An explicit development version is a floor for new releases, allowing
    # locally distributed Play builds to be reconciled without fake Git tags.
    if not existing_version:
        source = Path("pubspec.yaml").read_text()
        match = re.search(r"^version:\s*([0-9.]+)(?:\+\d+)?\s*$", source, re.MULTILINE)
        if not match:
            raise ValueError("pubspec.yaml must contain a stable initial version")
        version = max(version, parse_version(match.group(1)))
    name = ".".join(map(str, version))
    return {
        "version": name,
        "build_number": version_code(version),
        "tag": f"v{name}",
        "sha": sha,
        "tag_exists": existing_version is not None,
        "commits": commits,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--notes", type=Path, help="Write release notes to this file")
    args = parser.parse_args()
    plan = plan_release()
    if args.notes:
        lines = [
            f"Capidock {plan['version']} · Android · build {plan['build_number']}",
            "",
            "Local app: workspaces and credentials stay encrypted on your device. "
            "Connect directly using SSH or the Coolify API.",
            "",
            "Install the `.apk` file. Use `SHA256SUMS` to verify the download.",
            "Development builds use a different signature and cannot be updated directly "
            "with this APK. Preserve any important data before uninstalling an existing build.",
            "",
            "Code licensed under GPL-3.0-only. No warranty, to the extent permitted by law. "
            "See the attached `LICENSE`, `LICENSE-TRADEMARKS`, and `COPYRIGHT` files.",
            f"The `capidock-{plan['version']}-source.tar.gz` archive contains the source "
            "from the commit used for this build, lockfiles, and instructions in `README.md` "
            "and `docs/releases.md`. Dependencies are retrieved during the build.",
            "",
            "## Changes",
            "",
        ]
        lines.extend(
            f"- {commit['message'].splitlines()[0]} (`{commit['sha'][:7]}`)"
            for commit in plan["commits"]
        )
        lines.extend(["", f"Commit: `{plan['sha']}`", ""])
        args.notes.write_text("\n".join(lines))
    if output := os.environ.get("GITHUB_OUTPUT"):
        with open(output, "a") as stream:
            for key in ("version", "build_number", "tag", "sha", "tag_exists"):
                value = plan[key]
                if isinstance(value, bool):
                    value = str(value).lower()
                stream.write(f"{key}={value}\n")
    print(json.dumps(plan, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
