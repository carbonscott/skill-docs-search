#!/bin/bash
# Environment for docs-search skill.
# Adds docs-index to PATH and configures uv cache.
# Override any variable via env.local or by exporting before sourcing.

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Facility detection: sets DOCS_SEARCH_BIN to the directory holding the shared
# uv and puts it on PATH, so docs-index resolves uv without a personal
# ~/.local/bin/uv. Off-site it sets nothing and PATH's own uv is used.
if [ -f "$SKILL_DIR/facility-env.sh" ]; then
    source "$SKILL_DIR/facility-env.sh"
fi

# Add docs-index to PATH
export PATH="$SKILL_DIR/bin:$PATH"

# uv cache per user (avoids permission issues in shared deploys)
export UV_CACHE_DIR="${UV_CACHE_DIR:-/tmp/uv-cache-$USER}"

# User overrides last
if [ -f "$SKILL_DIR/env.local" ]; then
    source "$SKILL_DIR/env.local"
fi
