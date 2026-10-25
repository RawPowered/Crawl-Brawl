CRAWL BRAWL GUI LAUNCHER v1
============================

INSTALL
1. Copy the contents of this package into the Crawl Brawl project root.
2. The project root must contain project.godot.
3. Double-click "Play Crawl Brawl.vbs" for a completely console-free launch.
   "Play Crawl Brawl.bat" is included as a familiar fallback entry point.

WHAT IT DOES
- Dark Windows GUI instead of a scrolling batch console.
- One-click Play Crawl Brawl.
- Optional automatic build validation before Play.
- Dedicated Validate Build button.
- Detects GDScript SCRIPT ERROR entries even when Godot returns exit code 0.
- Shows a concise list of compiler errors and res:// file locations.
- Opens import.log, runtime.log, and launcher.log directly.
- Opens the project in the Godot editor.
- Opens the project folder.
- Lets you select/change the Godot executable.
- Stores launcher settings in launcher/launcher_config.json.
- Keeps Crawl Brawl telemetry compatible with CRAWL_BRAWL_TELEMETRY and
  CRAWL_BRAWL_TELEMETRY_LOG.
- Watches the game process and reports clean exit, non-zero exit, or script
  errors found in runtime.log.

GODOT SEARCH ORDER
1. Saved launcher setting
2. CRAWL_BRAWL_GODOT environment variable
3. Godot 4.7.1 on PATH or at a project-local engine path
4. Project-local Godot_v4.7.1-stable_win64.exe
5. tools\godot\Godot_v4.7.1-stable_win64.exe
6. godot.exe / godot on PATH

CURRENT BUILD NOTE
The supplied import log from 2026-08-21 shows one remaining GDScript compiler
error in systems/run_components/run_world_presentation.gd at line 1190:
"best_biome" cannot infer its type. The launcher intentionally blocks Play
until validation passes.
