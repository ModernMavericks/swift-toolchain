# Build ingredients

Everything baked into what this repo publishes, and how a change to it reaches a release. An
*ingredient* is an input to the product; the *own upstream* is the thing this repo exists to port.

This repo is unusual in the family twice over: it publishes a **build environment** for
`ModernMavericks/swift-runtime` rather than an end-user `.pkg`, and it consumes **none** of
shared-cmake's CMake facilities — no updater, no `.pkg`, no 10.9 install floor, so nothing to stage or
sign. It still runs the family conventions gate, because conventions that only apply to the typical
repo are not conventions.

| Ingredient | Pinned in | Renovate | On a bump |
|---|---|---|---|
| Swift release (own upstream) | `SWIFT_VERSION` + `SWIFT_SHA` in `pins.env` | ✅ `github-tags` on `swiftlang/swift`, **patch automerged** | tag `<upstream>-mavericks.1` to publish |
| swiftlang/llvm-project commit | `LLVM_BRANCH` + `LLVM_SHA` in `pins.env` | ✅ `git-refs` | manual: `LLVM_BRANCH` is `swift/release/<minor>` and must follow a minor Swift bump |
| swift.org toolchain `.pkg` | `TOOLCHAIN_URL`, derived from `SWIFT_VERSION` | ✅ moves with the Swift pin | verified by **signer identity**, not a hash — see below |

Not ingredients: `VERSION` is this repo's own packaging revision, and the build scripts are its recipe.
A change there is a repackage you cut deliberately.

## Why version and commit are captured by one regex

`SWIFT_VERSION` and `SWIFT_SHA` are matched by a single `matchStrings` so Renovate moves them together.
`verify-relocatable.sh` asserts the clone of `SWIFT_TAG` is exactly `SWIFT_SHA`, so a version bumped
without its commit **fails closed** rather than silently building something else.

## Why the toolchain is verified by signature, not a pinned hash

A hash can only vouch for bytes someone has already seen, so every version bump needed a human to paste
a new one — the one thing keeping Swift updates off the automated path. The signing identity is stable
across releases, so `TOOLCHAIN_SIGNER` verifies a version that does not exist yet. Upstream publishes no
GPG signature for the macOS `.pkg`; it is an Apple-signed installer, so `pkgutil` is the check that
exists.

## No repackage-on-ingredient-bump caller here

The pins above are all *own upstream* (the Swift release and the LLVM commit coupled to it), which is
the `-mavericks.1` path, not a repackage. There is no foreign ingredient to watch — this repo consumes
no other ModernMavericks product. Add a caller the day one lands, with `own-upstream-paths: pins.env`.
