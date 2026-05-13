# skill-docs-search

Strategy guide and tooling for searching local documentation collections using SQLite FTS5 full-text search with BM25 ranking.

This skill ships `docs-index`, a lightweight CLI that indexes documentation files into SQLite and provides ranked search. It is a dependency for other documentation skills (ask-s3df, ask-olcf, ask-epics).

Part of the [deploy-opencode](https://github.com/carbonscott/deploy-opencode) meta-deploy.

## Layout

```
claude/skills/docs-search/
opencode/skills/docs-search/
    SKILL.md         skill instructions
    env.sh           per-skill activation (adds bin/ to PATH, sets UV_CACHE_DIR)
    facility-env.sh  site detection (S3DF vs OLCF) for DOCS_SEARCH_BIN
    bin/             ambient-uv wrapper (uses `uv` from PATH)
    scripts/         co-located-uv wrapper (uses `uv` next to the script)
```

Both `claude/skills/docs-search/` and `opencode/skills/docs-search/` contain identical content. They live in separate trees so each runtime (Claude Code / OpenCode) can be deployed independently.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) on PATH (or co-located with the wrapper for `scripts/docs-index`)
- Python 3.9+ (managed automatically by uv)

## Install

Centrally deployed at S3DF under `/sdf/group/lcls/ds/dm/apps/dev/opencode/skills/docs-search/`. End users do not clone this repo directly; deploy-opencode's `deploy.sh` rsyncs `opencode/skills/docs-search/` into the shared deploy location. To pick it up, employees set `OPENCODE_CONFIG_DIR=/sdf/group/lcls/ds/dm/apps/dev/opencode`.

For ad-hoc / non-S3DF use:

```bash
# Claude Code
git clone https://github.com/carbonscott/skill-docs-search.git ~/.claude/skills/docs-search-tmp
ln -s ~/.claude/skills/docs-search-tmp/claude/skills/docs-search ~/.claude/skills/docs-search
source ~/.claude/skills/docs-search/env.sh

# OpenCode
git clone https://github.com/carbonscott/skill-docs-search.git /tmp/skill-docs-search
ln -s /tmp/skill-docs-search/opencode/skills/docs-search "$OPENCODE_CONFIG_DIR/skills/docs-search"
```

## env.sh vs facility-env.sh

Two activation scripts cover two deploy patterns:

- `env.sh` — adds the skill's local `bin/` to PATH and configures `UV_CACHE_DIR`. Source this when the skill ships its own `docs-index` wrapper.
- `facility-env.sh` — detects S3DF (`/sdf`) or OLCF (`/lustre/orion`) and adds a facility-wide `bin/` containing `docs-index` (and a co-deployed `uv`) to PATH. Source this on shared S3DF deploys where `docs-index` lives at `/sdf/group/lcls/ds/dm/apps/dev/bin/`.

Override `DOCS_SEARCH_BIN` to point at any custom location before sourcing `facility-env.sh`.

## bin/ vs scripts/

Both directories contain `docs-index` (shell wrapper) + `docs-index.py` (uv inline-script).

- `bin/docs-index` uses ambient `uv` (`exec uv run --script ...`)
- `scripts/docs-index` expects `uv` co-located next to the script (`exec "$SCRIPT_DIR/uv" run --script ...`) — used by the centralized S3DF deploy where `uv` is shipped under `/sdf/group/lcls/ds/dm/apps/dev/bin/uv`

## Usage (standalone)

```bash
source <skill-dir>/env.sh   # or facility-env.sh

docs-index index /path/to/docs --incremental --ext md rst
docs-index search /path/to/docs "your query" --limit 5
docs-index info /path/to/docs
```

## How it works

- `docs-index index` walks the docs root, reads files matching the given extensions, and inserts them into a SQLite FTS5 virtual table with Porter stemming
- `docs-index search` runs an FTS5 MATCH query with BM25 ranking and returns highlighted snippets
- The database is stored as `search.db` inside the docs root
- Incremental mode only re-indexes files with changed modification times

## License

Apache-2.0
