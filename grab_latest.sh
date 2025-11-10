#!/usr/bin/env bash
set -euo pipefail

MANIFEST_FILE="computer.helium.Helium.yml"
REPO_URL="https://github.com/imputnet/helium-linux/releases/download"

# --- Fetch latest Helium release tag ---
LATEST_VERSION=$(curl -s https://api.github.com/repos/imputnet/helium-linux/releases/latest \
  | grep -Po '"tag_name": *"\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=")')

if [[ -z "$LATEST_VERSION" ]]; then
  echo "   Failed to fetch latest version tag from GitHub."
  exit 1
fi

echo "   Latest Helium version: $LATEST_VERSION"

# --- Detect OS for sed compatibility ---
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

# --- Extract current version from manifest ---
CURRENT_VERSION=$(grep -Po 'helium-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' "$MANIFEST_FILE" \
  | head -n1 \
  | grep -Po '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?')

# --- Create temp file with version number ---
touch version.txt
echo "version: "$CURRENT_VERSION"" > version.txt

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "   Manifest already up to date ($CURRENT_VERSION). Checking SHA256..."
else
  echo "   Updating manifest from $CURRENT_VERSION → $LATEST_VERSION"
  # --- Replace version strings ---
  $SED_INPLACE -E "s|(helium-linux/releases/download/)$CURRENT_VERSION|\1$LATEST_VERSION|g" "$MANIFEST_FILE"
  $SED_INPLACE -E "s|(helium-$CURRENT_VERSION-x86_64_linux)|helium-$LATEST_VERSION-x86_64_linux|g" "$MANIFEST_FILE"
  $SED_INPLACE -E "s|(helium-$CURRENT_VERSION)|helium-$LATEST_VERSION|g" "$MANIFEST_FILE"
fi

# --- Compute new SHA256 ---
DOWNLOAD_URL="$REPO_URL/$LATEST_VERSION/helium-$LATEST_VERSION-x86_64_linux.tar.xz"
echo "   Downloading $DOWNLOAD_URL to compute sha256..."
TMP_FILE=$(mktemp)
curl -L -s -o "$TMP_FILE" "$DOWNLOAD_URL"

NEW_SHA256=$(sha256sum "$TMP_FILE" | awk '{print $1}')
rm -f "$TMP_FILE"

if [[ -z "$NEW_SHA256" ]]; then
  echo "   Failed to compute SHA256 checksum."
  exit 1
fi

echo "   New SHA256: $NEW_SHA256"

# --- Replace sha256 field in manifest ---
$SED_INPLACE -E "s/sha256: [a-f0-9]+/sha256: $NEW_SHA256/" "$MANIFEST_FILE"

# --- Commit and push if changed ---
if git diff --quiet -- "$MANIFEST_FILE"; then
  echo "   No effective change detected, skipping commit."
  exit 0
fi

git add "$MANIFEST_FILE"
git commit -m "update: helium ${LATEST_VERSION}"
git push origin main

echo "🚀 Changes committed and pushed: update: helium ${LATEST_VERSION}"
