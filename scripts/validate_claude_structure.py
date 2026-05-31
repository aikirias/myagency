#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
CLAUDE_DIR = ROOT / ".claude"


def fail(message: str) -> None:
    print(f"[FAIL] {message}")
    raise SystemExit(1)


def parse_frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        fail(f"{path.relative_to(ROOT)} is missing YAML frontmatter")

    end = text.find("\n---\n", 4)
    if end == -1:
        fail(f"{path.relative_to(ROOT)} has unclosed YAML frontmatter")

    raw = text[4:end].strip().splitlines()
    data: dict[str, str] = {}
    for line in raw:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip('"').strip("'")
    return data


def require_fields(path: Path, fields: list[str]) -> None:
    frontmatter = parse_frontmatter(path)
    missing = [field for field in fields if not frontmatter.get(field)]
    if missing:
        fail(f"{path.relative_to(ROOT)} is missing required frontmatter keys: {', '.join(missing)}")


def validate_agents() -> None:
    agent_files = sorted((CLAUDE_DIR / "agents").glob("*.md"))
    if not agent_files:
        fail(".claude/agents/ is empty")
    for path in agent_files:
        require_fields(path, ["name", "description"])


def validate_skills() -> None:
    skill_files = sorted((CLAUDE_DIR / "skills").glob("*/SKILL.md"))
    if not skill_files:
        fail(".claude/skills/ has no SKILL.md files")
    for path in skill_files:
        require_fields(path, ["name", "description"])


def validate_commands() -> None:
    command_files = sorted((CLAUDE_DIR / "commands").glob("*.md"))
    if not command_files:
        fail(".claude/commands/ is empty")

    required_sections = [
        "## What Claude should do",
        "## Expected input",
    ]

    for path in command_files:
        text = path.read_text(encoding="utf-8")
        if not text.startswith("# Command: /project:"):
            fail(f"{path.relative_to(ROOT)} must start with '# Command: /project:...'")
        for section in required_sections:
            if section not in text:
                fail(f"{path.relative_to(ROOT)} is missing section: {section}")


def validate_rules() -> None:
    rule_files = sorted((CLAUDE_DIR / "rules").glob("*.md"))
    if not rule_files:
        fail(".claude/rules/ is empty")
    for path in rule_files:
        text = path.read_text(encoding="utf-8").strip()
        if not text.startswith("# "):
            fail(f"{path.relative_to(ROOT)} must start with a level-1 heading")


def validate_references() -> None:
    claude_md = (ROOT / "CLAUDE.md").read_text(encoding="utf-8")
    referenced = re.findall(r"- `([^`]+)`", claude_md)
    for rel in referenced:
        if rel.startswith(".claude/") or rel.endswith(".md") or rel.endswith(".json"):
            path = ROOT / rel
            if not path.exists():
                fail(f"CLAUDE.md references a missing file: {rel}")


def main() -> int:
    validate_agents()
    validate_skills()
    validate_commands()
    validate_rules()
    validate_references()
    print("[OK] .claude surface validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
