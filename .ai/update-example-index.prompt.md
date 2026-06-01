# Resume Prompt: Update `.ai/example-index.json`

You are Codex working in the local `LSP-Examples` repository.

Read and follow:

- `AGENTS.md`
- `.ai/example-index.json`
- `.ai/scan-example-index.py`
- `.ai/example-index.schema.json`

Goal: update `.ai/example-index.json` after examples, README files, or runnable app roots have changed.

## Fast Workflow

1. Run:

   ```powershell
   python .ai/scan-example-index.py
   ```

2. Review the report for:

   - new candidate examples
   - new candidate app roots
   - stale indexed paths
   - duplicate app roots
   - sorting issues
   - concrete file paths that no longer exist

3. Edit only the affected entries in `.ai/example-index.json`.

4. Preserve the existing style:

   - two-space indentation
   - forward slashes in paths
   - no absolute local paths
   - sorted examples by `examplePath`
   - sorted app roots by `appRootPath`
   - sorted arrays such as `tags`, `goodFor`, `notFor`, `importantFiles`, and `omitFromCompactContext`
   - compact factual summaries
   - no timestamps

5. Validate:

   ```powershell
   python -m json.tool .ai/example-index.json
   python .ai/scan-example-index.py --strict
   ```

## Metadata Judgment

The scanner can discover structure, but it cannot reliably write all semantic fields. Curate these fields manually:

- `summary`
- `tags`
- `goodFor`
- `notFor`
- `runtime.notes`
- `omitFromCompactContext`

Use repository files as the source of truth. Do not invent BAS, Mako, Xedge, Lua, LSP, SMQ, MQTT, or authentication APIs. If an API detail is unclear, consult the official documentation listed in `AGENTS.md`.

## New Example Checklist

For a new example, add:

- `examplePath`
- `title`
- `summary`
- `tags`
- `goodFor`
- `notFor`
- `runtime`
- `appRoots`
- `readme`
- `rawReadmeUrl`

For each app root, add:

- `appRootPath`
- `label`
- `run`
- `summary`
- `importantFiles`
- `omitFromCompactContext`

Keep `examplePath` and `appRootPath` separate. `examplePath` is the documentation or package directory. `appRootPath` is the runnable BAS/Mako/Xedge app root that can be copied or loaded.

