#!/bin/sh
# test.sh -- dev-time checks for the mch harness. Run from the repo checkout
# before shipping a change. Not installed into workspaces (boot runs doctor.sh).
#
# Usage: sh test.sh
#   WORKDIR=<dir>  override scratch dir (default: mktemp -d)
#
# Covers the PROMPT.md hard rules that prose alone cannot enforce:
#   1. install is idempotent (second run writes nothing, files byte-identical)
#   2. judgment files are never clobbered (user content survives)
#   3. conflicts are reported, not decided silently
#   4. version lockstep holds and the installed tree passes doctor.sh
#   5. hard errors surface as INSTALL FAIL + exit 1 (never a fake OK)
#   6. BOOTSTRAP.md is a first-run starter, not a resurrection
#   7. doctor warns on stale BOOTSTRAP.md, hidden characters, stray root SKILL.md
#
# Output ends in: TEST <OK|FAIL> checks=<n> failures=<n>

set -u

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WORKDIR="${WORKDIR:-$(mktemp -d 2>/dev/null || echo /tmp/mch-test-$$)}"
checks=0
failures=0

check() { # check <label> <command...>
    checks=$((checks + 1))
    label=$1
    shift
    if "$@" >/dev/null 2>&1; then
        echo "ok: $label"
    else
        echo "fail: $label"
        failures=$((failures + 1))
    fi
}

ws="$WORKDIR/ws"
mkdir -p "$ws"

# --- 1. clean install -------------------------------------------------------
out1=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "clean install reports INSTALL OK" sh -c "printf '%s' '$out1' | grep -q '^INSTALL OK '"
check "clean install passes doctor" sh "$REPO/doctor.sh" "$ws"

# --- 2. idempotency: second run writes nothing, tree is byte-identical -------
hashes() { find "$ws" -type f -exec cksum {} + 2>/dev/null | sort; }
before=$(hashes)
out2=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "second install writes nothing" sh -c "printf '%s' '$out2' | grep -q 'written=0'"
after=$(hashes)
check "second install leaves tree byte-identical" test "$before" = "$after"
check "hashes() is not vacuous (cksums every file)" test \
    "$(printf '%s\n' "$after" | grep -c .)" -eq "$(find "$ws" -type f | wc -l)"

# --- 3. judgment files survive ---------------------------------------------
echo "USER-OWNED-CONTENT" > "$ws/MEMORY.md"
echo "HAND-EDITED-SOUL" > "$ws/SOUL.md"
out3=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "user content in MEMORY.md survives reinstall" grep -q "USER-OWNED-CONTENT" "$ws/MEMORY.md"
check "hand-edited SOUL.md survives reinstall" grep -q "HAND-EDITED-SOUL" "$ws/SOUL.md"
check "conflicts are reported" sh -c "printf '%s' '$out3' | grep -q 'conflicts=2'"
check "reinstall with conflicts reports PARTIAL" sh -c "printf '%s' '$out3' | grep -q '^INSTALL PARTIAL '"

# --- 4. version lockstep ----------------------------------------------------
fv=$(sed -e 's/[[:space:]]//g' "$REPO/HARNESS_VERSION" | grep . | head -n 1)
sv=$(sed -n -e 's/^[[:space:]]*harness-version:[[:space:]]*//p' "$REPO/SKILL.md" | head -n 1 | sed -e 's/[\"'"'"']//g' -e 's/[[:space:]]//g')
check "HARNESS_VERSION matches SKILL.md harness-version" test "$fv" = "$sv"
check "install report carries the same version" sh -c "printf '%s' '$out1' | grep -q 'version=$fv'"

# --- 5. hard errors are loud, never a fake OK -------------------------------
ws_block="$WORKDIR/ws-blocked"
mkdir -p "$ws_block"
: > "$ws_block/skills"   # a file where a directory must go
out4=$(sh "$REPO/install.sh" "$REPO" "$ws_block" 2>&1)
rc4=$?
check "unwritable managed path exits non-zero" test "$rc4" -ne 0
check "unwritable managed path reports INSTALL FAIL" sh -c "printf '%s' '$out4' | grep -q '^INSTALL FAIL '"

repo_empty="$WORKDIR/repo-empty-ver"
mkdir -p "$repo_empty"
printf '   \n\n' > "$repo_empty/HARNESS_VERSION"
out5=$(sh "$REPO/install.sh" "$repo_empty" "$WORKDIR/ws-empty" 2>&1)
rc5=$?
check "empty HARNESS_VERSION exits non-zero" test "$rc5" -ne 0
check "empty HARNESS_VERSION reports INSTALL FAIL" sh -c "printf '%s' '$out5' | grep -q '^INSTALL FAIL '"
check "HOME-less install without arg fails cleanly" sh -c \
    "env -u HOME sh '$REPO/install.sh' '$REPO' 2>&1 | grep -q '^INSTALL FAIL '"

# --- 6. BOOTSTRAP.md is a starter, not a resurrection -----------------------
rm -f "$ws/BOOTSTRAP.md"
out6=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "deleted BOOTSTRAP.md is not resurrected" test ! -f "$ws/BOOTSTRAP.md"
check "non-resurrecting reinstall stays written=0" sh -c "printf '%s' '$out6' | grep -q 'written=0'"

# --- 7. doctor warnings -----------------------------------------------------
cp "$ws/skills/mch/SKILL.md" "$ws/SKILL.md" 2>/dev/null
cp "$REPO/BOOTSTRAP.md" "$ws/BOOTSTRAP.md"
check "doctor warns on stale BOOTSTRAP.md" sh -c \
    "sh '$REPO/doctor.sh' '$ws' | grep -Eiq '^warn: .*bootstrap'"
check "doctor warns on stray root SKILL.md" sh -c \
    "sh '$REPO/doctor.sh' '$ws' | grep -Eiq '^warn: .*root SKILL.md'"
rm -f "$ws/SKILL.md"
printf 'hello\342\200\213hidden' > "$ws/memory/evil.md"
check "doctor warns on hidden characters" sh -c \
    "sh '$REPO/doctor.sh' '$ws' | grep -Eiq '^warn: .*hidden'"
rm -f "$ws/memory/evil.md"

if [ "$failures" -gt 0 ]; then
    status=FAIL
else
    status=OK
fi
printf 'TEST %s checks=%s failures=%s\n' "$status" "$checks" "$failures"
[ "$failures" -eq 0 ]
