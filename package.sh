#!/bin/sh
# package.sh — tar the LLVM build-support tree and emit dist/SHA256SUMS.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/pins.env"
DIST="$HERE/dist"; mkdir -p "$DIST"
[ -d "$HERE/out/llvm" ] || { echo "FAIL: run ./build-llvm.sh first"; exit 1; }

SHORT="$(printf %s "$LLVM_SHA" | cut -c1-12)"
TARBALL="$DIST/llvm-buildsupport-$SHORT-macos-$HOST_ARCH.tar.gz"

echo "==> packaging $TARBALL"
rm -f "$TARBALL"
# Archive the `llvm` directory itself so the consumer extracts to <root>/llvm.
tar -C "$HERE/out" -czf "$TARBALL" llvm

echo "==> SHA256SUMS"
( cd "$DIST" && shasum -a 256 \
    "llvm-buildsupport-$SHORT-macos-$HOST_ARCH.tar.gz" \
    "swift-$SWIFT_VERSION-RELEASE-osx.pkg" > SHA256SUMS )
cat "$DIST/SHA256SUMS"
echo "OK: assets staged in $DIST"
