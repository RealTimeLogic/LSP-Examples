#!/usr/bin/env python3
"""Build .ai/main-ai-catalog.json from per-example ai-catalog.json files.

Run this script from the repository-level .ai directory:

    cd .ai
    python build-main-ai-catalog.py

The script intentionally writes only relative, forward-slash paths so the
generated catalog can be used across Windows, Linux, and embedded workflows.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


CATALOG_FILE_NAME = "ai-catalog.json"
OUTPUT_FILE_NAME = "main-ai-catalog.json"

REQUIRED_FIELDS = (
    "name",
    "path",
    "summary",
    "compatibility",
    "use_when",
    "avoid_when",
    "read_next",
)


class CatalogError(Exception):
    """Raised when a catalog file cannot be used."""


def relative_path(path: Path, repo_root: Path) -> str:
    return path.relative_to(repo_root).as_posix()


def require_run_from_ai_dir() -> tuple[Path, Path]:
    ai_dir = Path.cwd().resolve()
    if ai_dir.name != ".ai":
        raise CatalogError(
            "Run this script from the repository-level .ai directory, "
            "for example: cd .ai && python build-main-ai-catalog.py"
        )
    return ai_dir, ai_dir.parent


def find_catalog_files(repo_root: Path) -> list[Path]:
    catalog_files: list[Path] = []

    for catalog_file in repo_root.rglob(CATALOG_FILE_NAME):
        rel = catalog_file.relative_to(repo_root)
        if rel.parts and rel.parts[0] == ".ai":
            continue
        catalog_files.append(catalog_file)

    return sorted(catalog_files, key=lambda path: relative_path(path, repo_root).lower())


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise CatalogError(f"{path}: invalid JSON: {exc}") from exc


def normalize_string_list(value: Any, field_name: str, catalog_path: str) -> list[str]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise CatalogError(f"{catalog_path}: field '{field_name}' must be a list of strings")
    return value


def reject_absolute_paths(value: Any, field_name: str, catalog_path: str) -> None:
    values = value if isinstance(value, list) else [value]
    for item in values:
        if isinstance(item, str) and Path(item).is_absolute():
            raise CatalogError(f"{catalog_path}: field '{field_name}' must use relative paths")


def validate_entry(entry: dict[str, Any], catalog_path: str) -> dict[str, Any]:
    missing = [field for field in REQUIRED_FIELDS if field not in entry]
    if missing:
        raise CatalogError(f"{catalog_path}: missing required field(s): {', '.join(missing)}")

    for field in ("name", "path", "summary"):
        if not isinstance(entry[field], str) or not entry[field].strip():
            raise CatalogError(f"{catalog_path}: field '{field}' must be a non-empty string")

    for field in ("compatibility", "use_when", "avoid_when", "read_next"):
        normalize_string_list(entry[field], field, catalog_path)

    reject_absolute_paths(entry["path"], "path", catalog_path)
    reject_absolute_paths(entry["read_next"], "read_next", catalog_path)

    if "run" in entry:
        normalize_string_list(entry["run"], "run", catalog_path)

    for optional_list_field in ("topics", "protocols", "targets"):
        if optional_list_field in entry:
            normalize_string_list(entry[optional_list_field], optional_list_field, catalog_path)

    if "variants" in entry and not isinstance(entry["variants"], dict):
        raise CatalogError(f"{catalog_path}: field 'variants' must be an object")

    normalized = dict(entry)
    normalized["catalog_path"] = catalog_path
    return normalized


def load_catalog_entries(catalog_file: Path, repo_root: Path) -> list[dict[str, Any]]:
    catalog_path = relative_path(catalog_file, repo_root)
    data = load_json(catalog_file)

    if isinstance(data, dict):
        raw_entries = [data]
    elif isinstance(data, list):
        raw_entries = data
    else:
        raise CatalogError(f"{catalog_path}: root value must be an object or an array of objects")

    entries: list[dict[str, Any]] = []
    for index, raw_entry in enumerate(raw_entries):
        if not isinstance(raw_entry, dict):
            raise CatalogError(f"{catalog_path}: entry {index} must be an object")
        entries.append(validate_entry(raw_entry, catalog_path))
    return entries


def build_catalog(repo_root: Path) -> dict[str, Any]:
    entries: list[dict[str, Any]] = []
    seen_paths: dict[str, str] = {}

    for catalog_file in find_catalog_files(repo_root):
        for entry in load_catalog_entries(catalog_file, repo_root):
            example_path = entry["path"]
            if example_path in seen_paths:
                raise CatalogError(
                    f"duplicate example path '{example_path}' in "
                    f"{entry['catalog_path']} and {seen_paths[example_path]}"
                )
            seen_paths[example_path] = entry["catalog_path"]
            entries.append(entry)

    entries.sort(key=lambda entry: (entry["path"].lower(), entry["name"].lower()))

    return {
        "schema_version": 1,
        "generated_by": ".ai/build-main-ai-catalog.py",
        "catalog_count": len(entries),
        "entries": entries,
    }


def entry_label(count: int) -> str:
    return "entry" if count == 1 else "entries"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build .ai/main-ai-catalog.json from recursive ai-catalog.json files."
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="validate and report what would be written, but do not update the output file",
    )
    args = parser.parse_args()

    try:
        ai_dir, repo_root = require_run_from_ai_dir()
        catalog = build_catalog(repo_root)
        output_path = ai_dir / OUTPUT_FILE_NAME
        output_text = json.dumps(catalog, indent=2, ensure_ascii=False) + "\n"

        if args.check:
            print(f"OK: found {catalog['catalog_count']} catalog {entry_label(catalog['catalog_count'])}")
            print(f"Would write: {OUTPUT_FILE_NAME}")
            return 0

        output_path.write_text(output_text, encoding="utf-8")
        print(f"Wrote {OUTPUT_FILE_NAME} with {catalog['catalog_count']} catalog {entry_label(catalog['catalog_count'])}")
        return 0
    except CatalogError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
