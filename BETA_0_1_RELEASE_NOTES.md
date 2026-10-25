# Crawl Brawl Beta 0.1 — Save Portability & Distribution Hardening

## Storage changes

- Realm saves now use `user://saves` instead of writing beside the project or executable. The project uses the branded custom user directory `%APPDATA%\Crawl Brawl` on Windows.
- New saves use a stable game-level encryption password rather than a machine ID and installation path.
- Save folders can be moved between game installations and computers.
- The first launch scans the former installation-local `saves` directory and migrates valid primary saves, backups, recovery journals, and the active-realm pointer.
- Legacy source files remain untouched until the developer or player chooses to remove them.
- A missing, stale, ended, or corrupt active pointer is repaired by selecting the newest valid resumable realm.
- Adds a focused legacy-save migration test that covers primary, backup, recovery, portable re-encryption, and source preservation.
- Primary save writes, backup rotation, temporary-file verification, recovery journals, schema limits, and realm-ID validation remain active.

## Distribution changes

- Windows export metadata is now Beta 0.1 rather than the stale Patch 4.7 description.
- The release executable has a Crawl Brawl application icon and no debug console wrapper.
- The PCK remains embedded in the executable.
- Export filters remove development saves, archives, tests, captures, old builds, Godot cache data, launch logs, documentation, and unused production-source/keyed PNGs.
- `Build Windows Beta.bat` verifies Godot 4.7.1, exports, stages, validates, hashes, and compresses the standalone release.
- The tester ZIP includes `README_PLAYER.txt`, `LICENSES.md`, and `SHA256SUMS.txt`. Windows code signing remains disabled until a publisher certificate is supplied.

## Developer runtime test order

1. Back up the current alpha project folder and its `saves` directory.
2. Apply this candidate to the same project folder and launch it once.
3. Confirm **Continue Expedition** appears and the existing realm loads.
4. Save, exit, relaunch, and Continue again.
5. Confirm a new realm directory exists under `%APPDATA%\Crawl Brawl\saves`.
6. Confirm the original project-local `saves` folder still exists and was not modified or deleted by migration.
7. Move the project or exported executable to another folder and confirm Continue still works.
8. Copy the user-data `saves` folder to a second Windows account or machine and confirm the realm remains readable.
9. Run `Build Windows Beta.bat` and test the generated ZIP on a machine without Godot installed.
10. Verify no saves, test scripts, captures, caches, old versions, or development launchers are present in the tester ZIP.

Runtime validation is intentionally left to the developer machine because the current environment does not include the project's frozen Godot 4.7.1 runtime or Windows export templates.
