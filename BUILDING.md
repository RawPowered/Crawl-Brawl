# Build Crawl Brawl for Windows

The easiest way to play is to download the standalone Windows ZIP from [the latest release](https://github.com/RawPowered/Crawl-Brawl/releases/latest). It does not require Godot.

## Build from source

1. Install Godot 4.7.1 stable and its Windows Desktop export templates.
2. Set `GODOT_EXE` to the Godot executable, or add Godot to `PATH`.
3. Run `Build Windows Beta.bat`.

The script imports the project resources, exports the standalone executable, checks the package contents, and creates `dist/CrawlBrawl_Beta_0.1_Windows.zip`. The package contains the game, player instructions, third-party notices, and executable checksum. It does not include saved games. A fresh player profile is created the first time the game launches.

The project is pinned to Godot 4.7.1 stable. Exporting with another version is not supported by the release script.
