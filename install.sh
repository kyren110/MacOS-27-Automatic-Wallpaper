#!/bin/bash

set -e

Tahoe Dynamic Wallpapers

Based on the work by pdfux:

https://gist.github.com/pdfux/5659724021e584313c00b843312e909d

echo “🌅 Tahoe Dynamic Wallpapers”
echo “===========================”
echo “”

Check macOS

if [[ “$(uname)” != “Darwin” ]]; then
echo “❌ This script only works on macOS.”
exit 1
fi

VERSION=”$(sw_vers -productVersion)”
BUILD=”$(sw_vers -buildVersion)”

echo “Detected macOS $VERSION ($BUILD)”

The original implementation targets Beta 6.

if [[ “$BUILD” != “26A5416b” ]]; then
echo “”
echo “⚠️  WARNING”
echo “This script was tested against macOS 27 Developer Beta 6 (26A5416b).”
echo “Your build is $BUILD.”
echo “”
read -r -p “Continue anyway? [y/N] “ answer

if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

fi

WALLPAPER_CUSTOM=”$HOME/Library/Application Support/com.apple.wallpaper/aerials/custom”
WALLPAPER_RESOURCES=”/System/Library/ExtensionKit/Extensions/WallpaperAerialsExtension.appex/Contents/Resources”
CATALOG=”$WALLPAPER_CUSTOM/entries.json”

TAHOE_ID=‘0DC99DD8-3386-4D1E-8878-C43E97EB710A’
GOLDEN_GATE_ID=‘67512508-D33E-4CBC-8A9E-BE55CEE35C4C’

Make sure Apple’s catalog exists.

if [[ ! -f “$WALLPAPER_RESOURCES/entries.json” ]]; then
echo “”
echo “❌ Apple’s wallpaper catalog could not be found:”
echo “$WALLPAPER_RESOURCES/entries.json”
exit 1
fi

echo “”
echo “📁 Creating local wallpaper catalog…”
mkdir -p “$WALLPAPER_CUSTOM”

echo “📋 Copying Apple’s catalog…”
cp “$WALLPAPER_RESOURCES/entries.json” “$CATALOG”

find_id_index() {
local array_path=”$1”
local wanted_id=”$2”
local catalog=”$3”
local i=0
local current_id

while plutil -extract "$array_path.$i" json -o /dev/null "$catalog" 2>/dev/null; do
    current_id=$(plutil -extract "$array_path.$i.id" raw -o - "$catalog" 2>/dev/null || true)
    if [[ "$current_id" == "$wanted_id" ]]; then
        printf '%s\n' "$i"
        return 0
    fi
    (( i++ ))
done
return 1

}

find_asset_index() {
local shot_id=”$1”
local catalog=”$2”
local i=0
local value

while plutil -extract "assets.$i" json -o /dev/null "$catalog" 2>/dev/null; do
    value=$(plutil -extract "assets.$i.shotID" raw -o - "$catalog" 2>/dev/null || true)
    if [[ "$value" == "$shot_id" ]]; then
        printf '%s\n' "$i"
        return 0
    fi
    (( i++ ))
done
return 1

}

enable_combining() {
local subcategory_id=”$1”
local category_count=0
local category_index
local subcategory_index
local key_path

while plutil -extract "categories.$category_count" json -o /dev/null "$CATALOG" 2>/dev/null; do
    (( category_count++ ))
done
for (( category_index=0; category_index<category_count; category_index++ )); do
    if subcategory_index=$(find_id_index "categories.$category_index.subcategories" "$subcategory_id" "$CATALOG"); then
        key_path="categories.$category_index.subcategories.$subcategory_index.combineVariants"
        if plutil -extract "$key_path" raw -o /dev/null "$CATALOG" 2>/dev/null; then
            plutil -replace "$key_path" -bool true "$CATALOG"
        else
            plutil -insert "$key_path" -bool true "$CATALOG"
        fi
        return 0
    fi
done
echo "❌ Could not find subcategory: $subcategory_id" >&2
return 1

}

set_solar_variant() {
local shot_id=”$1”
local altitude=”$2”
local azimuth=”$3”
local asset_index
local key_path
local value

asset_index=$(find_asset_index "$shot_id" "$CATALOG") || {
    echo "❌ Could not find asset: $shot_id" >&2
    return 1
}
key_path="assets.$asset_index.variant"
value="{\"solar\":{\"altitude\":$altitude,\"azimuth\":$azimuth}"
if plutil -extract "$key_path" json -o /dev/null "$CATALOG" 2>/dev/null; then
    plutil -replace "$key_path" -json "$value" "$CATALOG"
else
    plutil -insert "$key_path" -json "$value" "$CATALOG"
fi

}

echo “🌄 Enabling Tahoe variants…”
enable_combining “$TAHOE_ID”

echo “🌉 Enabling Golden Gate variants…”
enable_combining “$GOLDEN_GATE_ID”

echo “☀️  Adding Tahoe solar coordinates…”
set_solar_variant TA_L_001 5 160
set_solar_variant TA_L_002 35 180
set_solar_variant TA_D_001 5 180
set_solar_variant TA_D_002 -35 140

echo “🌇 Adding Golden Gate solar coordinates…”
set_solar_variant GG_A_SUNSET 5 160
set_solar_variant GG_A_DAY 35 180
set_solar_variant GG_A_EVENING 5 180
set_solar_variant GG_A_NIGHT -35 140

echo “🔍 Validating catalog…”

if ! plutil -convert json -o /dev/null “$CATALOG”; then
echo “❌ The generated wallpaper catalog is invalid.”
exit 1
fi

echo “⚙️  Configuring WallpaperAgent…”

defaults write com.apple.wallpaper.aerial 
AerialManifestLocalPathOverride 
-string “$CATALOG”

defaults write com.apple.wallpaper.aerial 
AerialManifestForceLocal 
-bool true

echo “🔄 Restarting wallpaper services…”

killall WallpaperAgent WallpaperAerialsExtension 2>/dev/null || true

echo “”
echo “✅ Installation complete!”
echo “”
echo “Go to:”
echo “  System Settings → Wallpaper”
echo “”
echo “Tahoe and Golden Gate should now appear as single”
echo “landscape wallpaper entries with an Automatic option.”
echo “”
echo “To undo the changes, run:”
echo “  ./uninstall.sh”
echo “”
echo “Enjoy the dynamic wallpapers! 🌅”
