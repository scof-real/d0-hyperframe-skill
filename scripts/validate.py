#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


EXPECTED = {
    "d0-brand": ["SKILL.md"],
    "d0-hyperframe": [
        "SKILL.md",
        "agents/openai.yaml",
        "scripts/bootstrap_project.sh",
        "assets/brand/d0-logo.png",
        "assets/brand/d0-avatar.jpg",
        "assets/fonts/InstrumentSerif-Regular.woff2",
        "assets/fonts/InstrumentSerif-Italic.woff2",
        "assets/fonts/OpenSans-400-normal.woff2",
        "assets/fonts/OpenSans-600-normal.woff2",
        "assets/fonts/OpenSans-700-normal.woff2",
        "assets/fonts/OpenSans-800-normal.woff2",
        "assets/fonts/InstrumentSerif-OFL.txt",
        "assets/fonts/OpenSans-OFL.txt",
    ],
}


def validate_skill(root: Path, name: str, files: list[str]) -> list[str]:
    errors: list[str] = []
    skill_dir = root / name
    for relative in files:
        path = skill_dir / relative
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty: {path}")

    skill_md = skill_dir / "SKILL.md"
    if skill_md.is_file():
        text = skill_md.read_text(encoding="utf-8")
        if not re.search(rf"(?m)^name:\s*['\"]?{re.escape(name)}['\"]?\s*$", text):
            errors.append(f"invalid name frontmatter: {skill_md}")
        if not re.search(r"(?m)^description:\s*\S", text):
            errors.append(f"missing description frontmatter: {skill_md}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate the D0 HyperFrame skill bundle")
    parser.add_argument("--installed-root", type=Path)
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    skills_root = args.installed_root or repo_root / "skills"
    errors = [
        error
        for name, files in EXPECTED.items()
        for error in validate_skill(skills_root, name, files)
    ]
    if errors:
        print("Validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"Validated {len(EXPECTED)} skills in {skills_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
