# skill-docs-search

Strategy guide and tooling for searching local documentation collections using SQLite FTS5 full-text search with BM25 ranking.

This skill ships `docs-index`, a lightweight CLI that indexes documentation files into SQLite and provides ranked search. It is a dependency for other documentation skills (ask-s3df, ask-olcf, ask-epics).

## Prerequisites

- [uv](https://docs.astral.sh/uv/) on your PATH
- Python 3.9+ (managed automatically by uv)

## Install

**Claude Code:**
```bash
git clone https://github.com/carbonscott/skill-docs-search.git ~/.claude/skills/docs-search
```

**OpenCode:**
```bash
git clone https://github.com/carbonscott/skill-docs-search.git "$OPENCODE_CONFIG_DIR/skills/docs-search"
```

## Verify

```bash
source ~/.claude/skills/docs-search/env.sh
docs-index --help
```

## Usage (standalone)

Index any documentation folder:

```bash
source ~/.claude/skills/docs-search/env.sh

# Index markdown files
docs-index index /path/to/docs --incremental --ext md rst

# Search
docs-index search /path/to/docs "your query" --limit 5

# Stats
docs-index info /path/to/docs
```

## How it works

- `docs-index index` walks the docs root, reads files matching the given extensions, and inserts them into a SQLite FTS5 virtual table with Porter stemming
- `docs-index search` runs an FTS5 MATCH query with BM25 ranking and returns highlighted snippets
- The database is stored as `search.db` inside the docs root
- Incremental mode only re-indexes files with changed modification times

## License

Apache-2.0
