#!/usr/bin/env python3
"""Validate the plugin marketplace structure.

Checks:
- marketplace.json parses; every listed plugin's source dir + plugin.json exist
- plugin.json names match marketplace entries
- every skill dir has a SKILL.md with name + description frontmatter
- hooks.json / .mcp.json files parse
- cross-marketplace dependencies have their marketplace whitelisted
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        return {}
    fields = {}
    for line in match.group(1).splitlines():
        if ":" in line and not line.startswith((" ", "\t")):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()
    return fields


def main() -> int:
    mp_path = ROOT / ".claude-plugin" / "marketplace.json"
    try:
        marketplace = json.loads(mp_path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        print(f"FATAL: cannot parse {mp_path}: {exc}")
        return 1

    allowed_markets = set(marketplace.get("allowCrossMarketplaceDependenciesOn", []))

    for entry in marketplace.get("plugins", []):
        name = entry.get("name", "<unnamed>")
        source = entry.get("source")
        if not source:
            err(f"{name}: marketplace entry has no source")
            continue
        plugin_dir = (ROOT / ".claude-plugin" / source).resolve() if source.startswith("./") else ROOT / source
        plugin_dir = (ROOT / source).resolve()
        if not plugin_dir.is_dir():
            err(f"{name}: source dir {source} does not exist")
            continue

        manifest_path = plugin_dir / ".claude-plugin" / "plugin.json"
        if not manifest_path.is_file():
            err(f"{name}: missing {manifest_path.relative_to(ROOT)}")
            continue
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001
            err(f"{name}: plugin.json does not parse: {exc}")
            continue
        if manifest.get("name") != name:
            err(f"{name}: plugin.json name is '{manifest.get('name')}' (must match marketplace entry)")

        for dep in manifest.get("dependencies", []):
            if isinstance(dep, dict):
                market = dep.get("marketplace")
                if market and market not in allowed_markets:
                    err(f"{name}: dependency marketplace '{market}' not in allowCrossMarketplaceDependenciesOn")

        skills_dir = plugin_dir / "skills"
        if skills_dir.is_dir():
            for skill_dir in sorted(p for p in skills_dir.iterdir() if p.is_dir()):
                skill_md = skill_dir / "SKILL.md"
                if not skill_md.is_file():
                    err(f"{name}: skill '{skill_dir.name}' has no SKILL.md")
                    continue
                fm = frontmatter(skill_md)
                if not fm.get("name"):
                    err(f"{name}/{skill_dir.name}: SKILL.md frontmatter missing 'name'")
                if not fm.get("description"):
                    err(f"{name}/{skill_dir.name}: SKILL.md frontmatter missing 'description'")

        for json_file in ("hooks/hooks.json", ".mcp.json"):
            path = plugin_dir / json_file
            if path.is_file():
                try:
                    json.loads(path.read_text(encoding="utf-8"))
                except Exception as exc:  # noqa: BLE001
                    err(f"{name}: {json_file} does not parse: {exc}")

        hooks_dir = plugin_dir / "hooks"
        if hooks_dir.is_dir():
            for script in hooks_dir.glob("*.sh"):
                if not script.stat().st_mode & 0o111:
                    err(f"{name}: hook script {script.name} is not executable")

    if errors:
        print(f"FAIL — {len(errors)} problem(s):")
        for problem in errors:
            print(f"  - {problem}")
        return 1
    plugins = ", ".join(p["name"] for p in marketplace.get("plugins", []))
    print(f"OK — marketplace '{marketplace.get('name')}' valid. Plugins: {plugins}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
