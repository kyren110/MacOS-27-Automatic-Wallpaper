Tahoe Dynamic Wallpapers

A small macOS utility that enables the hidden Automatic / dynamic variants for the Tahoe and Golden Gate aerial wallpapers on supported macOS 27 Developer Beta releases.

⚠️ Experimental: This modifies how macOS’s Wallpaper system loads its local aerial wallpaper catalog. Apple can change or remove this functionality in future macOS updates.

✨ What it does

This script creates a local copy of Apple’s wallpaper catalog and modifies it to expose additional wallpaper variants.

It:

* Enables combined wallpaper variants for Tahoe
* Enables combined wallpaper variants for Golden Gate
* Adds solar-position metadata for the different variants
* Uses a local entries.json rather than modifying Apple’s system files
* Configures WallpaperAgent to use the modified catalog
* Restarts the relevant wallpaper services automatically
* Provides an easy way to undo the changes

The result is that supported wallpapers can expose an Automatic option that transitions between their different variants.

🖥️ Requirements

* Apple Silicon Mac recommended
* macOS 27 Developer Beta
* A build containing the required WallpaperAerialsExtension
* Terminal
* Administrator access may be requested by macOS depending on the system configuration

This project was originally tested against:

macOS 27 Developer Beta 6 — 26A5416b

Newer or older builds may use different wallpaper identifiers or catalog structures.

🚀 Installation

1. Download the script

Clone the repository:

git clone https://github.com/YOUR-USERNAME/tahoe-dynamic-wallpapers.git
cd tahoe-dynamic-wallpapers

2. Run the installer

chmod +x install.sh
./install.sh

The installer will:

1. Create the custom wallpaper directory.
2. Copy Apple’s entries.json.
3. Add the required variant metadata.
4. Enable combined variants.
5. Configure WallpaperAgent to use the local catalog.
6. Restart the wallpaper services.

3. Choose the wallpaper

Open:

System Settings → Wallpaper

Select Tahoe or Golden Gate.

If your macOS build supports the modification, the wallpaper should expose its available variants, including Automatic.

🧹 Uninstall

To completely revert the modification:

chmod +x uninstall.sh
./uninstall.sh

The uninstall script removes the local catalog and restores macOS’s normal wallpaper manifest behavior.

You can also run:

defaults delete com.apple.wallpaper.aerial AerialManifestLocalPathOverride 2>/dev/null || true
defaults delete com.apple.wallpaper.aerial AerialManifestForceLocal 2>/dev/null || true
rm -rf -- "$HOME/Library/Application Support/com.apple.wallpaper/aerials/custom"
killall WallpaperAgent WallpaperAerialsExtension 2>/dev/null || true

🔍 How it works

macOS stores metadata for its aerial wallpapers inside the WallpaperAerialsExtension.

This project does not modify Apple’s system entries.json directly.

Instead, it:

Apple wallpaper catalog
        │
        ▼
Copy entries.json
        │
        ▼
Modify local catalog
        │
        ├── Enable combined variants
        ├── Add solar positions
        └── Preserve original system files
        │
        ▼
WallpaperAgent local manifest override
        │
        ▼
macOS Wallpaper system

The local catalog is stored at:

~/Library/Application Support/com.apple.wallpaper/aerials/custom/entries.json

⚠️ Compatibility

This relies on internal macOS wallpaper behavior and is therefore not guaranteed to work across macOS releases.

Apple may:

* Change wallpaper identifiers
* Change the structure of entries.json
* Move the WallpaperAerials extension
* Remove the local manifest override
* Change how WallpaperAgent loads wallpaper metadata

If an update breaks the script, don’t assume your Mac is damaged. The wallpaper implementation may simply have changed.

Run the uninstall script and check whether a newer version of this project supports your build.

🛟 Troubleshooting

The wallpapers don’t appear

Restart System Settings and WallpaperAgent:

killall WallpaperAgent WallpaperAerialsExtension 2>/dev/null || true

Then reopen:

System Settings → Wallpaper

The installer reports that an ID cannot be found

Your macOS build probably has different wallpaper metadata.

Check your build with:

sw_vers

and open an issue with:

* macOS version
* macOS build number
* The exact error message

I updated macOS and it stopped working

That’s expected for an experimental modification like this.

First run:

./uninstall.sh

Then check whether the current macOS build is supported.

📚 Credits

This project is based on research and implementation work by pdfux.

Original reference:

pdfux’s original gist

The repository version packages the procedure into an easier-to-run utility and may include additional installation, validation, compatibility, and rollback functionality.

Please refer to the original work for the underlying discovery and technique.

📄 License

Unless otherwise stated, the original implementation and methodology remain subject to the terms and attribution requirements of the original author.

If this repository contains substantial modifications, see the repository’s LICENSE file for the license applying to those modifications.

⸻

⭐ Disclaimer

This is an unofficial community project.

It is not affiliated with or endorsed by Apple Inc.

Use at your own risk, especially on developer/beta versions of macOS.
