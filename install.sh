#!/bin/sh
# install.sh -- idempotent mch workspace installer. Companion to PROMPT.md
# route A. Read the policy below before changing it.
#
# Usage: sh install.sh [REPO_DIR] [WORKSPACE_DIR]
#   REPO_DIR       repo checkout (default: directory containing this script)
#   WORKSPACE_DIR  target workspace (default: $HOME/.openclaw/workspace)
#
# Policy (the deterministic stand-in for "merge, never clobber"):
#   managed   PROMPT.md HARNESS_VERSION skills/mch/*
#             -> mirrored on every run (repo-owned artifacts)
#   starter   BOOTSTRAP.md
#             -> seeded only into a harness-less workspace; never resurrected
#                after first run deletes it (AGENTS.md: archive it when done)
#   judgment  SOUL.md AGENTS.md USER.md IDENTITY.md MEMORY.md .learnings/*
#             -> written only when absent; a differing existing file is NEVER
#                overwritten, only reported as a conflict for a human/agent merge
#   memory/   -> seeds memory/<today YYYY-MM-DD>.md when absent; existing notes
#                are never touched
#
# Output ends in one machine-readable line:
#   INSTALL <OK|PARTIAL|FAIL> version=<v> written=<n> skipped=<n> conflicts=<n>
# Idempotent: run twice and the second run reports written=0 with the same
# conflicts. Exit: 0 = ok/partial (conflicts are informational), 1 = hard error
# (FAIL: unwritable target, empty version, or missing repo files).

set -u

ver="-"
written=0
skipped=0
conflicts=0
failed=0

fail_line() { # fail_line <message> -- always exits 1 with a summary line
    echo "error: $1" >&2
    printf 'INSTALL FAIL version=%s written=%s skipped=%s conflicts=%s\n' \
        "$ver" "$written" "$skipped" "$conflicts"
    exit 1
}

REPO="${1:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
if [ "${2:-}" != "" ]; then
    WS="$2"
elif [ "${HOME:-}" != "" ]; then
    WS="$HOME/.openclaw/workspace"
else
    fail_line "no workspace argument and HOME is unset"
fi

[ -f "$REPO/HARNESS_VERSION" ] \
    || fail_line "$REPO does not look like an mch repo checkout (no HARNESS_VERSION)"
mkdir -p "$WS" 2>/dev/null || fail_line "cannot create workspace $WS"

ver=$(sed -e 's/[[:space:]]//g' "$REPO/HARNESS_VERSION" | grep . | head -n 1)
[ -n "$ver" ] || fail_line "HARNESS_VERSION is empty; refusing to install"

same() { [ -f "$2" ] && cmp -s "$1" "$2"; }

try_cp() { # try_cp <src> <dest> -- counted write; failure is loud, not silent
    mkdir -p "$(dirname -- "$2")" 2>/dev/null
    if cp "$1" "$2" 2>/dev/null; then
        written=$((written + 1))
        return 0
    fi
    failed=$((failed + 1))
    echo "error: cannot write $2" >&2
    return 1
}

# mirror <src> <dest> -- managed artifact: always ends up matching the repo
mirror() {
    if same "$1" "$2"; then
        skipped=$((skipped + 1))
    else
        try_cp "$1" "$2"
    fi
}

# preserve <src> <dest> -- judgment file: fills gaps, never overwrites
preserve() {
    if [ ! -f "$2" ]; then
        try_cp "$1" "$2"
    elif same "$1" "$2"; then
        skipped=$((skipped + 1))
    else
        conflicts=$((conflicts + 1))
        echo "conflict: kept existing $2 (differs from repo; merge by hand)"
    fi
}

fresh=no
[ -f "$WS/HARNESS_VERSION" ] || fresh=yes

for f in SOUL.md AGENTS.md USER.md IDENTITY.md MEMORY.md; do
    preserve "$REPO/$f" "$WS/$f"
done
# BOOTSTRAP.md: first-run starter only (see policy above)
if [ "$fresh" = yes ]; then
    preserve "$REPO/BOOTSTRAP.md" "$WS/BOOTSTRAP.md"
elif [ -f "$WS/BOOTSTRAP.md" ]; then
    preserve "$REPO/BOOTSTRAP.md" "$WS/BOOTSTRAP.md"
else
    skipped=$((skipped + 1))
fi
for f in PROMPT.md HARNESS_VERSION; do
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

today=$(date +%F 2>/dev/null || true)
case "$today" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
        if [ -f "$REPO/memory/mch.md.example" ]; then
            if [ -f "$WS/memory/$today.md" ]; then
                skipped=$((skipped + 1))
            else
                try_cp "$REPO/memory/mch.md.example" "$WS/memory/$today.md"
            fi
        fi
        ;;
    *)
        echo "warn: date unavailable or unparsable; skipped seeding memory/<today>.md" >&2
        ;;
esac

if [ "$failed" -gt 0 ]; then
    status=FAIL
elif [ "$conflicts" -gt 0 ]; then
    status=PARTIAL
else
    status=OK
fi
printf 'INSTALL %s version=%s written=%s skipped=%s conflicts=%s\n' \
    "$status" "$ver" "$written" "$skipped" "$conflicts"
[ "$failed" -eq 0 ]
