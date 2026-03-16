#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "locales" / "readme"

if not SRC_DIR.exists():
    raise SystemExit(f"Missing source dir: {SRC_DIR}")

for src in sorted(SRC_DIR.glob("*.md")):
    lang = src.stem
    target = ROOT / ("README.md" if lang == "en" else f"README.{lang}.md")
    target.write_text(src.read_text(encoding="utf-8"), encoding="utf-8")
    print(f"synced {src.relative_to(ROOT)} -> {target.name}")
