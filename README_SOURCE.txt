CRAWL BRAWL — BETA 0.1 CLEAN SOURCE

RUN THE SOURCE PROJECT
----------------------
Double-click "Play Crawl Brawl.bat". On every launch it first runs Godot's
resource importer, then starts the game. A fresh extraction will create a local
.godot cache; that cache is generated data and was intentionally not stored in
this clean source ZIP.

The launcher expects Godot 4.7.1 at:
  Set GODOT_EXE to your local Godot 4.7.1 executable or add Godot to PATH.

If Godot is installed elsewhere, add it to PATH or edit GODOT_EXE in the batch
file. Import details are written to import.log. Launch details are written to
launcher.log.

BUILD A STANDALONE WINDOWS RELEASE
----------------------------------
Run "Build Windows Beta.bat".

The first build on a machine downloads the official Godot 4.7.1 export
templates once (~1.2 GB cached in tools/cache/), imports project resources,
then exports the embedded-PCK Windows executable to dist/.

SAVE DATA
---------
Realm saves are stored in Godot's writable Crawl Brawl user-data directory:
  %APPDATA%\Crawl Brawl\saves

The stable save key allows the save folder to be backed up, restored, or copied
to another computer. Keep the entire saves folder together.

FIX INCLUDED IN THIS PACKAGE
----------------------------
The custom mouse cursor is no longer preloaded while GDScript is being parsed.
If its imported texture is not ready yet, the game temporarily uses the normal
system cursor instead of failing compilation.
