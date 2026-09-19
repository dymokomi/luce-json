#!/bin/sh
# The luce-json gate: the module's own encode/decode unit tests through both backends, and a
# consumer package that depends on luce-json and round-trips a value. Set LUCE_BASE to the
# compiler; it defaults to a sibling checkout, then to `luce-base` on the PATH.
set -eu
cd "$(dirname "$0")"
LUCE_BASE=${LUCE_BASE:-../luce-base/build/luce-base}
[ -x "$LUCE_BASE" ] || LUCE_BASE=luce-base
mkdir -p build
echo "== module unit tests (c backend)"
"$LUCE_BASE" test src/luce_json/json.lucb --backend=c
echo "== module unit tests (native backend)"
"$LUCE_BASE" test src/luce_json/json.lucb --native
expected='{"count":42,"name":"luce"}
count=42 name=luce'
for mode in --backend=c --native; do
    echo "== package consumer round-trip ($mode)"
    "$LUCE_BASE" build tests/roundtrip/main.lucb $mode -o build/roundtrip
    got=$(build/roundtrip)
    [ "$got" = "$expected" ] || { echo "FAIL: $mode produced:"; echo "$got"; exit 1; }
done
echo ok
