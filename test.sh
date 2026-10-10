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

# 1. clean install
out1=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "clean install reports INSTALL OK" sh -c "printf '%s' '$out1' | grep -q '^INSTALL OK '"
check "clean install passes doctor" sh "$REPO/doctor.sh" "$ws"

# 2. idempotency: second run writes nothing, tree is byte-identical
hashes() { find "$ws" -type f | sort | xargs cksum 2>/dev/null; }
before=$(hashes)
out2=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "second install writes nothing" sh -c "printf '%s' '$out2' | grep -q 'written=0'"
after=$(hashes)
check "second install leaves tree byte-identical" test "$before" = "$after"

# 3. judgment files survive
mkdir -p "$ws/memory"
echo "USER-OWNED-CONTENT" > "$ws/MEMORY.md"
echo "HAND-EDITED-SOUL" > "$ws/SOUL.md"
out3=$(sh "$REPO/install.sh" "$REPO" "$ws")
check "user content in MEMORY.md survives reinstall" grep -q "USER-OWNED-CONTENT" "$ws/MEMORY.md"
check "hand-edited SOUL.md survives reinstall" grep -q "HAND-EDITED-SOUL" "$ws/SOUL.md"
check "conflicts are reported" sh -c "printf '%s' '$out3' | grep -q 'conflicts=2'"
check "reinstall with conflicts reports PARTIAL" sh -c "printf '%s' '$out3' | grep -q '^INSTALL PARTIAL '"

# 4. version lockstep
fv=$(sed -e 's/[[:space:]]//g' "$REPO/HARNESS_VERSION" | grep . | head -n 1)
sv=$(sed -n -e 's/^[[:space:]]*harness-version:[[:space:]]*//p' "$REPO/SKILL.md" | head -n 1 | sed -e 's/[\"'"'"']//g' -e 's/[[:space:]]//g')
check "HARNESS_VERSION matches SKILL.md harness-version" test "$fv" = "$sv"
check "install report carries the same version" sh -c "printf '%s' '$out1' | grep -q 'version=$fv'"

if [ "$failures" -gt 0 ]; then
    status=FAIL
else
    status=OK
fi
printf 'TEST %s checks=%s failures=%s\n' "$status" "$checks" "$failures"
[ "$failures" -eq 0 ]
