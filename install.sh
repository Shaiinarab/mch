#!/bin/sh
# install.sh -- idempotent mch workspace installer. Companion to PROMPT.md
# route A. Read the policy below before changing it.
#
# Usage: sh install.sh [REPO_DIR] [WORKSPACE_DIR]
#   REPO_DIR       repo checkout (default: directory containing this script)
#   WORKSPACE_DIR  target workspace (default: $HOME/.openclaw/workspace)
#
# Policy (the deterministic stand-in for "merge, never clobber"):
#   managed   PROMPT.md BOOTSTRAP.md HARNESS_VERSION skills/mch/*
#             -> mirrored on every run (repo-owned artifacts)
#   judgment  SOUL.md AGENTS.md USER.md IDENTITY.md MEMORY.md .learnings/*
#             -> written only when absent; a differing existing file is NEVER
#                overwritten, only reported as a conflict for a human/agent merge
#   memory/   -> seeds memory/<today YYYY-MM-DD>.md when absent; existing notes
#                are never touched
#
# Output ends in one machine-readable line:
#   INSTALL <OK|PARTIAL> version=<v> written=<n> skipped=<n> conflicts=<n>
# Idempotent: run twice and the second run reports written=0 with the same
# conflicts. Exit: 0 = ok/partial (conflicts are informational), 1 = hard error.

set -u

written=0
skipped=0
conflicts=0

REPO="${1:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
WS="${2:-$HOME/.openclaw/workspace}"

if [ ! -f "$REPO/HARNESS_VERSION" ]; then
    echo "error: $REPO does not look like an mch repo checkout (no HARNESS_VERSION)"
    echo "INSTALL FAIL version=- written=0 skipped=0 conflicts=0"
    exit 1
fi
mkdir -p "$WS" || {
    echo "error: cannot create workspace $WS"
    echo "INSTALL FAIL version=- written=0 skipped=0 conflicts=0"
    exit 1
}

ver=$(sed -e 's/[[:space:]]//g' "$REPO/HARNESS_VERSION" | grep . | head -n 1)

same() { [ -f "$2" ] && cmp -s "$1" "$2"; }

# mirror <src> <dest> -- managed artifact: always ends up matching the repo
mirror() {
    if same "$1" "$2"; then
        skipped=$((skipped + 1))
    else
        mkdir -p "$(dirname -- "$2")"
        cp "$1" "$2" && written=$((written + 1))
    fi
}

# preserve <src> <dest> -- judgment file: repo fills gaps, never overwrites
preserve() {
    if [ ! -f "$2" ]; then
        mkdir -p "$(dirname -- "$2")"
        cp "$1" "$2" && written=$((written + 1))
    elif same "$1" "$2"; then
        skipped=$((skipped + 1))
    else
        conflicts=$((conflicts + 1))
        echo "conflict: kept existing $2 (differs from repo; merge by hand)"
    fi
}

for f in SOUL.md AGENTS.md USER.md IDENTITY.md MEMORY.md; do
    preserve "$REPO/$f" "$WS/$f"
done
for f in PROMPT.md BOOTSTRAP.md HARNESS_VERSION; do
    mirror "$REPO/$f" "$WS/$f"
done
for f in SKILL.md doctor.sh install.sh; do
    mirror "$REPO/$f" "$WS/skills/mch/$f"
done
if [ -d "$REPO/.learnings" ]; then
    for f in "$REPO"/.learnings/*.md; do
        [ -f "$f" ] && preserve "$f" "$WS/.learnings/$(basename -- "$f")"
    done
fi

today=$(date +%F 2>/dev/null || echo unknown)
if [ -f "$REPO/memory/mch.md.example" ] && [ ! -f "$WS/memory/$today.md" ]; then
    mkdir -p "$WS/memory"
    cp "$REPO/memory/mch.md.example" "$WS/memory/$today.md"
    written=$((written + 1))
else
    skipped=$((skipped + 1))
fi

status=OK
[ "$conflicts" -gt 0 ] && status=PARTIAL
printf 'INSTALL %s version=%s written=%s skipped=%s conflicts=%s\n' \
    "$status" "$ver" "$written" "$skipped" "$conflicts"
exit 0
