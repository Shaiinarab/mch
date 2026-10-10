#!/bin/sh
# doctor.sh -- mch harness verification. Read-only, idempotent, no dependencies
# beyond POSIX sh + grep/sed/awk.
#
# Usage:
#   sh doctor.sh                # auto-detect target (see below)
#   sh doctor.sh <WORKSPACE_DIR>  # check an explicit directory
#
# Target auto-detection:
#   - if this script lives at <root>/skills/mch/doctor.sh -> check <root>
#   - otherwise -> check the directory containing this script (repo layout)
#
# Checks:
#   1. required root files present
#   2. boot SKILL.md present (installed layout skills/mch/ or repo layout root)
#   3. SKILL.md YAML frontmatter has name + description
#   4. HARNESS_VERSION matches the harness-version embedded in SKILL.md
#   5. memory template present (repo layout only)
#   6. no secret-looking strings in scanned markdown (root, skills/mch, docs,
#      memory) — warn only
#   7. no hidden/bidi/control characters in scanned markdown — warn only
#   8. no stale BOOTSTRAP.md or stray root SKILL.md in installed workspaces —
#      warn only
#
# Output: one "ok:/warn:/gap:" line per check, then a single machine-readable
# summary line: DOCTOR <OK|PARTIAL|FAIL> version=<v> files=<n> gaps=<n> warns=<n>
# Exit: 0 = no gaps, 1 = gaps found.

set -u

gaps=0
warns=0
ok()   { printf 'ok: %s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*"; warns=$((warns + 1)); }
gap()  { printf 'gap: %s\n' "$*"; gaps=$((gaps + 1)); }

# --- resolve target root -----------------------------------------------------
if [ "${1:-}" != "" ]; then
    ROOT=$(CDPATH= cd -- "$1" 2>/dev/null && pwd) || {
        echo "gap: target directory not found: $1"
        echo "DOCTOR FAIL version=- files=0 gaps=1 warns=0"
        exit 1
    }
else
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    case "$script_dir" in
        */skills/mch) ROOT=$(dirname -- "$(dirname -- "$script_dir")") ;;
        *)            ROOT="$script_dir" ;;
    esac
fi

echo "mch doctor -- target: $ROOT"

# --- 1. required root files --------------------------------------------------
missing=0
present=0
for f in SOUL.md AGENTS.md USER.md IDENTITY.md MEMORY.md PROMPT.md HARNESS_VERSION; do
    if [ -f "$ROOT/$f" ]; then
        ok "root file $f"
        present=$((present + 1))
    else
        gap "root file missing: $f"
        missing=$((missing + 1))
    fi
done

# BOOTSTRAP.md lifecycle: required in repo layout; in installed workspaces its
# ABSENCE is the healthy state (first-run starter consumed per AGENTS.md).
if [ -f "$ROOT/skills/mch/SKILL.md" ]; then
    if [ -f "$ROOT/BOOTSTRAP.md" ]; then
        warn "BOOTSTRAP.md still present in installed workspace (first run not completed?)"
    else
        ok "first-run starter consumed (BOOTSTRAP.md absent)"
    fi
    present=$((present + 1))
elif [ -f "$ROOT/BOOTSTRAP.md" ]; then
    ok "root file BOOTSTRAP.md"
    present=$((present + 1))
else
    gap "root file missing: BOOTSTRAP.md"
    missing=$((missing + 1))
fi

# --- 2. boot skill location --------------------------------------------------
SKILL=""
if [ -f "$ROOT/skills/mch/SKILL.md" ]; then
    SKILL="$ROOT/skills/mch/SKILL.md"
    ok "boot skill at skills/mch/SKILL.md (installed layout)"
    if [ -f "$ROOT/SKILL.md" ]; then
        warn "stray root SKILL.md (repo-layout leftover); skills/mch/SKILL.md is authoritative"
    fi
elif [ -f "$ROOT/SKILL.md" ]; then
    SKILL="$ROOT/SKILL.md"
    ok "boot skill at SKILL.md (repo layout)"
else
    gap "boot skill missing: neither skills/mch/SKILL.md nor SKILL.md found"
fi

# --- 3. frontmatter ----------------------------------------------------------
if [ -n "$SKILL" ]; then
    fm=$(awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} NR>1 {print}' "$SKILL")
    printf '%s\n' "$fm" | grep -q '^name:[[:space:]]*' \
        && ok "frontmatter has name" \
        || gap "frontmatter missing name in $SKILL"
    printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*' \
        && ok "frontmatter has description" \
        || gap "frontmatter missing description in $SKILL"
fi

# --- 4. version match --------------------------------------------------------
file_ver=""
if [ -f "$ROOT/HARNESS_VERSION" ]; then
    file_ver=$(sed -e 's/[[:space:]]//g' "$ROOT/HARNESS_VERSION" | grep . | head -n 1)
fi
skill_ver=""
if [ -n "$SKILL" ]; then
    skill_ver=$(sed -n -e 's/^[[:space:]]*harness-version:[[:space:]]*//p' "$SKILL" | head -n 1 | sed -e 's/[\"'"'"']//g' -e 's/[[:space:]]//g')
fi

if [ -z "$file_ver" ]; then
    gap "HARNESS_VERSION is missing or empty"
elif [ -z "$skill_ver" ]; then
    gap "SKILL.md has no harness-version in frontmatter (cannot verify install)"
elif [ "$file_ver" != "$skill_ver" ]; then
    gap "version mismatch: HARNESS_VERSION=$file_ver SKILL.md=$skill_ver"
else
    ok "version consistent: $file_ver"
fi

# --- 5. memory template (repo layout only) -----------------------------------
if [ -f "$ROOT/memory/mch.md.example" ]; then
    ok "memory template memory/mch.md.example"
elif [ -f "$ROOT/skills/mch/SKILL.md" ]; then
    : # installed layout: template is intentionally not required
else
    warn "memory template memory/mch.md.example not found"
fi

# --- 6. content scans (warn only) ---------------------------------------------
scan_md() {
    for d in "$ROOT" "$ROOT/skills/mch" "$ROOT/docs" "$ROOT/memory"; do
        [ -d "$d" ] || continue
        for f in "$d"/*.md; do
            [ -f "$f" ] && printf '%s\n' "$f"
        done
    done
}

if command -v grep >/dev/null 2>&1; then
    hits=$(scan_md | while IFS= read -r f; do
        grep -l -E 'BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|((api|access|auth)[_-]?key|secret|token|password)[[:space:]]*[:=][[:space:]]*[^[:space:]]' "$f" 2>/dev/null
    done | tr '\n' ' ')
    if [ -n "$hits" ]; then
        warn "secret-looking strings in: $hits"
    else
        ok "no secret-looking strings in scanned markdown"
    fi

    # invisible characters: zero-width, bidi controls, BOM, soft hyphen, C0s
    inv=$(printf '[\001\002\003\004\005\006\007\010\013\014\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177]|\342\200\213|\342\200\214|\342\200\215|\342\200\216|\342\200\217|\342\200\252|\342\200\253|\342\200\254|\342\200\255|\342\200\256|\342\201\246|\342\201\247|\342\201\250|\342\201\251|\357\273\277|\302\255')
    bad=$(scan_md | while IFS= read -r f; do
        LC_ALL=C grep -l -E "$inv" "$f" 2>/dev/null
    done | tr '\n' ' ')
    if [ -n "$bad" ]; then
        warn "hidden/bidi/control characters in: $bad"
    else
        ok "no hidden characters in scanned markdown"
    fi
fi

# --- summary -----------------------------------------------------------------
files=$((present))
if [ "$gaps" -gt 0 ]; then
    status=FAIL
    [ "$missing" -lt 8 ] && [ -n "$SKILL" ] && status=PARTIAL
else
    status=OK
fi
printf 'DOCTOR %s version=%s files=%s gaps=%s warns=%s\n' \
    "$status" "${file_ver:--}" "$files" "$gaps" "$warns"
[ "$gaps" -eq 0 ]
