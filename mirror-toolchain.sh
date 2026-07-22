#!/bin/sh
# mirror-toolchain.sh — download the official swift.org toolchain and stage it VERBATIM.
# No repacking: the mirrored file is byte-identical to upstream, so its SHA256 is the
# upstream SHA256 and provenance stays checkable against download.swift.org.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/pins.env"
DIST="$HERE/dist"; mkdir -p "$DIST"
PKG="$DIST/swift-$SWIFT_VERSION-RELEASE-osx.pkg"

if [ ! -f "$PKG" ]; then
  echo "==> downloading $TOOLCHAIN_URL (~1.5 GB)"
  curl -fSL --retry 3 --retry-delay 5 -o "$PKG.tmp" "$TOOLCHAIN_URL"
  mv "$PKG.tmp" "$PKG"
fi

echo "${TOOLCHAIN_SHA256}  $PKG" | shasum -a 256 -c - || {
  echo "FAIL: toolchain SHA256 mismatch — refusing to publish"; rm -f "$PKG"; exit 1; }
echo "OK: verbatim toolchain mirror at $PKG"
