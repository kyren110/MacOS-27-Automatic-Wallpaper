#!/bin/bash

set -e

Tahoe Dynamic Wallpapers

Uninstaller

Based on the work by pdfux:

https://gist.github.com/pdfux/5659724021e584313c00b843312e909d

echo “🧹 Tahoe Dynamic Wallpapers — Uninstaller”
echo “==========================================”
echo “”

CUSTOM_DIR=”$HOME/Library/Application Support/com.apple.wallpaper/aerials/custom”

echo “🔄 Removing WallpaperAgent overrides…”

defaults delete com.apple.wallpaper.aerial 
AerialManifestLocalPathOverride 2>/dev/null || true

defaults delete com.apple.wallpaper.aerial 
AerialManifestForceLocal 2>/dev/null || true

echo “🗑️  Removing custom wallpaper catalog…”

if [[ -d “$CUSTOM_DIR” ]]; then
rm -rf – “$CUSTOM_DIR”
echo “   Removed:”
echo “   $CUSTOM_DIR”
else
echo “   Custom catalog was already removed.”
fi

echo “🔄 Restarting wallpaper services…”

killall WallpaperAgent WallpaperAerialsExtension 2>/dev/null || true

echo “”
echo “✅ Uninstallation complete!”
echo “”
echo “macOS’s normal wallpaper manifest should now be active.”
echo “”
echo “If System Settings still shows the old wallpaper options,”
echo “close and reopen System Settings.”
echo “”
