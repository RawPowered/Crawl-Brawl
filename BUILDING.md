# Crawl Brawl Beta 0.1 — Windows release build

## One-command build

Double-click **`Build Windows Beta.bat`**. Set `GODOT_EXE` to your Godot 4.7.1 executable or add Godot to `PATH` first.

On the first build on a machine, the script also:

1. Downloads and installs the official Godot 4.7.1 Windows export templates if they are missing (~1.2 GB one-time cache under `tools/cache/`).
2. Runs Godot `--import` so the clean source tree has imported resources before export.
3. Exports, validates, hashes, and zips the standalone release.

After adding new ChatGPT combat or branding sheets, run the Python importer first:

```powershell
python tools/import_combat_textures.py
```

Godot may report import/export exit code `-1` on Windows even when the run succeeds. The build script treats that as non-fatal when the executable is created.

If the build fails with a locked `dist\CrawlBrawl_Beta_0.1_Windows\CrawlBrawl_Beta_0.1.exe`, close any running Crawl Brawl instance (or Explorer preview on that folder) and run the build again.

A successful build creates:

```text
dist/CrawlBrawl_Beta_0.1_Windows.zip
```

The ZIP contains only the embedded-PCK executable, player instructions, licenses, and a SHA-256 checksum. It does not package development saves, tests, captures, old versions, import caches, launch logs, or source-production artwork.

## Manual export

```powershell
& $GodotExe --headless --path $ProjectRoot --export-release "Windows Desktop" "$ProjectRoot\builds\windows\CrawlBrawl_Beta_0.1.exe"
```

Export templates for the frozen Godot version must be installed. The build script rejects other engine versions. The export preset disables the console wrapper, embeds the PCK, applies the Crawl Brawl icon, and writes Beta 0.1 Windows metadata. The Windows `.ico` must include all six sizes Godot expects: 16, 32, 48, 64, 128, and 256. `tools/import_combat_textures.py` generates that set from `crawl_brawl_icon.png`. Code signing remains disabled until a real publisher identity and signing certificate are available; enable it before an unrestricted public release.

## Save migration test

Run the focused migration test before packaging:

```powershell
& $GodotExe --headless --path $ProjectRoot --script res://tests/legacy_save_migration_test.gd
```

It creates a temporary save using the former machine-and-path-bound password, initializes the new storage layer, verifies portable primary/backup/recovery copies, confirms the legacy files were not deleted, and cleans up its test realm.

## Release validation

Test the generated ZIP, not the editor project:

1. Extract it to a clean folder on another Windows account or computer without Godot installed.
2. Create a new realm, save, quit, continue, save again, and confirm `world.backup.cbr` is created.
3. Move the extracted game folder and confirm Continue still works.
4. Copy the user-data `saves` folder to another test machine and confirm the realm loads there.
5. For legacy migration, place the new executable in the former alpha folder containing `saves`, launch once, and confirm the realm appears in Continue.
6. Confirm the release ZIP contains no `saves`, `tests`, `artifacts`, `.godot`, `save_archive`, or `~.OLD.VERSIONS` directories.

Do not delete the old installation-local save folder until the migrated realm has been loaded and saved successfully in the Beta build.
