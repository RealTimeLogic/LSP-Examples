#!/usr/bin/env python3
"""
Scan LSP-Examples for drift in .ai/example-index.json.

The script intentionally reports deltas instead of regenerating the index.
Structure can be discovered mechanically, but fields such as goodFor, notFor,
runtime notes, and compact-context omissions need human engineering judgment.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


INDEX_PATH = Path(".ai/example-index.json")
ROOT_README = "README.md"
ROOT_AGENTS = "AGENTS.md"

MARKER_NAMES = {".preload", ".config", "index.lsp", "index.html"}
IMPORTANT_SUFFIXES = {".lsp", ".lua", ".xlua", ".html", ".js"}
SORTED_ARRAY_KEYS = {
    "tags",
    "goodFor",
    "notFor",
    "importantFiles",
    "omitFromCompactContext",
}

RUN_RE = re.compile(r"\bmako\s+(?:[^\n\r`]*?\s)?-l::([^\s`]+)")
CD_RE = re.compile(r"^\s*cd\s+(.+?)\s*$", re.MULTILINE)


@dataclass(frozen=True)
class CandidateRoot:
    example_path: str
    app_root_path: str
    run: str | None
    source: str
    readme: str | None


def posix(path: Path | str) -> str:
    return str(path).replace("\\", "/")


def repo_path(path: Path) -> str:
    return posix(path.relative_to(Path(".")))


def load_index() -> dict:
    if not INDEX_PATH.exists():
        raise SystemExit(f"Missing index: {INDEX_PATH}")
    return json.loads(INDEX_PATH.read_text(encoding="utf-8"))


def is_hidden_or_generated(path: Path) -> bool:
    parts = set(path.parts)
    return ".git" in parts or ".codex" in parts or "__pycache__" in parts


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="replace")


def top_level_or_nested_example(readme: Path) -> str:
    parent = repo_path(readme.parent)
    if parent == ".":
        return ROOT_README
    return parent


def normalize_cd_arg(arg: str) -> str:
    arg = arg.strip().strip("\"'")
    arg = arg.replace("\\", "/")
    if arg.startswith("./"):
        arg = arg[2:]
    return arg.rstrip("/")


def resolve_run_root(readme: Path, app_arg: str, cd_arg: str | None) -> str:
    app_arg = app_arg.strip().strip("\"'").replace("\\", "/").rstrip("/")
    readme_dir = readme.parent

    if cd_arg:
        cd_norm = normalize_cd_arg(cd_arg)
        cd_path = Path(cd_norm)
        if cd_norm.startswith("LSP-Examples/"):
            cd_path = Path(cd_norm.removeprefix("LSP-Examples/"))
        elif not (Path(".") / cd_path).exists():
            cd_path = readme_dir / cd_path
    else:
        cd_path = readme_dir

    if app_arg.endswith(".zip"):
        return repo_path(cd_path)

    if "/" in app_arg:
        app_path = Path(app_arg)
        if (Path(".") / app_path).exists():
            return posix(app_path)
        return repo_path(cd_path / app_path)

    cd_candidate = cd_path / app_arg
    if cd_candidate.exists():
        return repo_path(cd_candidate)

    sibling_candidate = readme_dir / app_arg
    if sibling_candidate.exists():
        return repo_path(sibling_candidate)

    root_candidate = Path(app_arg)
    if root_candidate.exists():
        return repo_path(root_candidate)

    return repo_path(cd_candidate)


def discover_run_roots() -> list[CandidateRoot]:
    roots: list[CandidateRoot] = []
    for readme in sorted(Path(".").rglob("README.md")):
        if is_hidden_or_generated(readme):
            continue
        text = read_text(readme)
        cd_matches = list(CD_RE.finditer(text))
        run_matches = list(RUN_RE.finditer(text))
        if not run_matches:
            continue

        for match in run_matches:
            app_arg = match.group(1)
            if is_placeholder_run_arg(app_arg):
                continue
            prior_cd = None
            for cd_match in cd_matches:
                if cd_match.start() < match.start():
                    prior_cd = cd_match.group(1)
            app_root = resolve_run_root(readme, app_arg, prior_cd)
            readme_path = repo_path(readme)
            example_path = top_level_or_nested_example(readme)
            roots.append(
                CandidateRoot(
                    example_path=example_path,
                    app_root_path=app_root,
                    run=f"mako -l::{app_arg}",
                    source="readme-run-command",
                    readme=readme_path,
                )
            )
    return roots


def is_placeholder_run_arg(app_arg: str) -> bool:
    normalized = app_arg.lower()
    return (
        "<" in app_arg
        or ">" in app_arg
        or "..." in app_arg
        or "dir-name" in normalized
        or "paste" in normalized
    )


def nearest_readme(path: Path) -> str | None:
    for parent in [path, *path.parents]:
        candidate = parent / "README.md"
        if candidate.exists() and not is_hidden_or_generated(candidate):
            return repo_path(candidate)
        if parent == Path("."):
            break
    return None


def marker_rank(path: Path) -> int:
    rank = 0
    for name in MARKER_NAMES:
        if (path / name).exists():
            rank += 1
    if (path / ".preload").exists():
        rank += 4
    if (path / ".config").exists():
        rank += 2
    return rank


def discover_marker_roots() -> list[CandidateRoot]:
    dirs: dict[Path, set[str]] = {}
    for path in Path(".").rglob("*"):
        if is_hidden_or_generated(path) or not path.is_file():
            continue
        if path.name in MARKER_NAMES or path.suffix in IMPORTANT_SUFFIXES:
            dirs.setdefault(path.parent, set()).add(path.name)

    roots: list[CandidateRoot] = []
    for directory in sorted(dirs):
        names = dirs[directory]
        if not (names & MARKER_NAMES):
            continue

        # Prefer the directory with the strongest app markers. Avoid also
        # treating every nested HTML asset directory as a separate app root
        # when a parent has .preload or .config.
        parent = directory.parent
        if parent != directory and marker_rank(parent) > marker_rank(directory):
            continue

        readme = nearest_readme(directory)
        if readme and readme != ROOT_README:
            example_path = posix(Path(readme).parent)
        else:
            example_path = repo_path(directory)
        roots.append(
            CandidateRoot(
                example_path=example_path,
                app_root_path=repo_path(directory),
                run=None,
                source="app-marker",
                readme=readme,
            )
        )
    return roots


def dedupe_roots(candidates: Iterable[CandidateRoot]) -> list[CandidateRoot]:
    by_path: dict[str, CandidateRoot] = {}
    for candidate in candidates:
        current = by_path.get(candidate.app_root_path)
        if current is None:
            by_path[candidate.app_root_path] = candidate
            continue
        if current.source != "readme-run-command" and candidate.source == "readme-run-command":
            by_path[candidate.app_root_path] = candidate
    return [by_path[k] for k in sorted(by_path)]


def indexed_app_roots(data: dict) -> set[str]:
    return {
        app["appRootPath"]
        for example in data["examples"]
        for app in example.get("appRoots", [])
    }


def indexed_examples(data: dict) -> set[str]:
    return {example["examplePath"] for example in data["examples"]}


def path_is_within(path: str, parent: str) -> bool:
    if path == parent:
        return True
    return path.startswith(parent.rstrip("/") + "/")


def covered_by_index(candidate_root: str, indexed_roots: set[str]) -> bool:
    return any(path_is_within(candidate_root, indexed_root) for indexed_root in indexed_roots)


def concrete_paths(data: dict) -> Iterable[tuple[str, str, str]]:
    for example in data["examples"]:
        readme = example.get("readme")
        if readme:
            yield ("readme", example["examplePath"], readme)
        for app in example.get("appRoots", []):
            yield ("appRootPath", example["examplePath"], app["appRootPath"])
            for key in ("importantFiles", "omitFromCompactContext"):
                for value in app.get(key, []):
                    if "*" not in value:
                        yield (key, example["examplePath"], value)


def sorted_copy(values: list[str]) -> list[str]:
    return sorted(values, key=lambda item: item.lower())


def check_sorted(data: dict) -> list[str]:
    issues: list[str] = []
    examples = data["examples"]
    example_paths = [example["examplePath"] for example in examples]
    if example_paths != sorted_copy(example_paths):
        issues.append("examples are not sorted by examplePath")

    for example in examples:
        roots = [app["appRootPath"] for app in example.get("appRoots", [])]
        if roots != sorted_copy(roots):
            issues.append(f"{example['examplePath']}: appRoots are not sorted by appRootPath")
        for key in SORTED_ARRAY_KEYS:
            if key in example and example[key] != sorted_copy(example[key]):
                issues.append(f"{example['examplePath']}: {key} is not sorted")
        for app in example.get("appRoots", []):
            for key in SORTED_ARRAY_KEYS:
                if key in app and app[key] != sorted_copy(app[key]):
                    issues.append(f"{example['examplePath']} / {app['appRootPath']}: {key} is not sorted")
    return issues


def check_duplicates(data: dict) -> list[str]:
    issues: list[str] = []
    seen_examples: set[str] = set()
    for example in data["examples"]:
        path = example["examplePath"]
        if path in seen_examples:
            issues.append(f"duplicate examplePath: {path}")
        seen_examples.add(path)

    seen_roots: dict[str, str] = {}
    for example in data["examples"]:
        for app in example.get("appRoots", []):
            root = app["appRootPath"]
            if root in seen_roots:
                issues.append(f"duplicate appRootPath: {root} in {seen_roots[root]} and {example['examplePath']}")
            seen_roots[root] = example["examplePath"]
    return issues


def check_paths(data: dict) -> list[str]:
    issues: list[str] = []
    for key, example_path, value in concrete_paths(data):
        if "\\" in value or re.match(r"^[A-Za-z]:", value) or value.startswith("/"):
            issues.append(f"{example_path}: {key} is not a relative forward-slash path: {value}")
        elif not Path(value).exists():
            issues.append(f"{example_path}: {key} does not exist: {value}")
    return issues


def candidate_stub(candidate: CandidateRoot) -> dict:
    root = Path(candidate.app_root_path)
    important = []
    for name in [".config", ".preload", "index.lsp", "index.html"]:
        p = root / name
        if p.exists():
            important.append(repo_path(p))
    for p in sorted(root.rglob("*")):
        if len(important) >= 8:
            break
        if p.is_file() and p.suffix in {".lua", ".lsp"}:
            rp = repo_path(p)
            if rp not in important:
                important.append(rp)

    readme = candidate.readme or ROOT_README
    return {
        "examplePath": candidate.example_path,
        "title": Path(candidate.example_path).name,
        "summary": "TODO: add concise factual summary.",
        "tags": [],
        "goodFor": [],
        "notFor": [],
        "runtime": {
            "mako": "unknown",
            "xedge": "unknown",
            "notes": [],
        },
        "appRoots": [
            {
                "appRootPath": candidate.app_root_path,
                "label": Path(candidate.app_root_path).name,
                "run": candidate.run or f"mako -l::{Path(candidate.app_root_path).name}",
                "summary": "TODO: describe runnable app root.",
                "importantFiles": sorted_copy(important),
                "omitFromCompactContext": [],
            }
        ],
        "readme": readme,
        "rawReadmeUrl": "https://raw.githubusercontent.com/RealTimeLogic/LSP-Examples/refs/heads/master/"
        + readme,
    }


def print_section(title: str, lines: list[str]) -> None:
    print(f"\n{title}")
    print("-" * len(title))
    if lines:
        for line in lines:
            print(line)
    else:
        print("none")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="exit nonzero when drift or validation issues are found")
    parser.add_argument("--stubs", action="store_true", help="print starter JSON stubs for missing app roots")
    args = parser.parse_args()

    data = load_index()
    run_roots = discover_run_roots()
    marker_roots = discover_marker_roots()
    candidates = dedupe_roots([*run_roots, *marker_roots])

    indexed_roots = indexed_app_roots(data)
    indexed_example_paths = indexed_examples(data)
    candidate_roots = {candidate.app_root_path for candidate in candidates}

    missing_roots = [
        candidate
        for candidate in candidates
        if candidate.app_root_path not in indexed_roots
        and not covered_by_index(candidate.app_root_path, indexed_roots)
    ]
    stale_roots = sorted([root for root in indexed_roots if not Path(root).exists()], key=str.lower)
    missing_examples = sorted(
        {
            candidate.example_path
            for candidate in missing_roots
            if candidate.example_path not in indexed_example_paths
        },
        key=str.lower,
    )

    path_issues = check_paths(data)
    duplicate_issues = check_duplicates(data)
    sort_issues = check_sorted(data)

    print("LSP Examples AI index scan")
    print(f"indexed examples: {len(data['examples'])}")
    print(f"indexed app roots: {len(indexed_roots)}")
    print(f"candidate app roots: {len(candidate_roots)}")

    print_section(
        "Missing candidate examples",
        [f"{example}" for example in missing_examples],
    )
    print_section(
        "Missing candidate app roots",
        [
            f"{candidate.app_root_path} ({candidate.source}, readme={candidate.readme or 'none'})"
            for candidate in missing_roots
        ],
    )
    print_section("Stale indexed app roots", stale_roots)
    print_section("Path issues", path_issues)
    print_section("Duplicate issues", duplicate_issues)
    print_section("Sorting issues", sort_issues)

    if args.stubs and missing_roots:
        print("\nStarter stubs")
        print("-------------")
        for candidate in missing_roots:
            print(json.dumps(candidate_stub(candidate), indent=2))

    issue_count = len(missing_roots) + len(stale_roots) + len(path_issues) + len(duplicate_issues) + len(sort_issues)
    if issue_count:
        print(f"\nscan completed with {issue_count} issue(s)")
    else:
        print("\nscan completed cleanly")

    return 1 if args.strict and issue_count else 0


if __name__ == "__main__":
    sys.exit(main())
