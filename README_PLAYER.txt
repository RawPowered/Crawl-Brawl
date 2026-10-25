CRAWL BRAWL — BETA 0.1

START
-----
Run CrawlBrawl_Beta_0.1.exe. Godot does not need to be installed.

SAVE DATA
---------
Realm saves are stored in Godot's writable Crawl Brawl user-data directory,
not beside the game executable. On Windows this is normally:

  %APPDATA%\Crawl Brawl\saves

The save files use a stable game key, so the save folder can be backed up,
restored after reinstalling, synchronized, or copied to another computer.
Keep the entire saves folder together, including active_realm.txt.

LEGACY ALPHA SAVE MIGRATION
---------------------------
When the game first starts, it looks for the older installation-local saves
folder beside the project or executable. Valid saves are copied into the new
user-data location and re-encrypted with the portable format. The old files
are not deleted.

For automatic migration, launch this build once from the same Crawl Brawl
folder that contains the old saves directory. After the migration succeeds,
future builds can be installed or moved anywhere.

BETA FEEDBACK
-------------
When reporting a problem, include:
- What you were doing immediately before it happened.
- Whether the realm was newly created or migrated from an alpha build.
- The wave number and difficulty.
- A screenshot and the Godot log when available.
