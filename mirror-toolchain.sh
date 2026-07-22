#!/bin/sh
# mirror-toolchain.sh — download the official swift.org toolchain and stage it VERBATIM.
# No repacking: the mirrored file is byte-identical to upstream, so its SHA256 is the
# upstream SHA256 and provenance stays checkable against download.swift.org.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/pins.env"
DIST="$HERE/dist"; mkdir -p "$DIST"
PKG="$DIST/$TOOLCHAIN_ASSET"

if [ ! -f "$PKG" ]; then
  echo "==> downloading $TOOLCHAIN_URL (~1.5 GB)"
  curl -fSL --retry 3 --retry-delay 5 -o "$PKG.tmp" "$TOOLCHAIN_URL"
  mv "$PKG.tmp" "$PKG"
fi

echo "${TOOLCHAIN_SHA256}  $PKG" | shasum -a 256 -c - || {
  # Print what it actually is BEFORE deleting it. A Renovate bump of SWIFT_VERSION lands here by
  # design -- Renovate cannot know the hash of a 1.5 GB binary it never downloads -- and making a
  # human re-download it just to read the number back is an hour spent for nothing.
  echo "FAIL: toolchain SHA256 mismatch — refusing to publish" >&2
  echo "  expected (pins.env): ${TOOLCHAIN_SHA256}" >&2
  echo "  actual   (upstream): $(shasum -a 256 "$PKG" | awk '{print $1}')" >&2
  echo "  After a deliberate SWIFT_VERSION bump, set TOOLCHAIN_SHA256 to the actual value." >&2
  rm -f "$PKG"; exit 1; }
echo "OK: verbatim toolchain mirror at $PKG"
