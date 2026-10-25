# Crawl Brawl Native Launcher v3.2

## Source-only development handoffs

V3.2 changes the numbered export workflow from a full-project archive into a compact source handoff intended for ChatGPT/Codex/browser development.

`SAVE CODE HANDOFF ZIP` includes editable project context such as:

- `scripts/**/*.gd` and `*.uid`
- `systems/**/*.gd` and `*.uid`
- Godot scenes/resources (`*.tscn`, `*.tres`)
- `project.godot` and source/config/map formats such as XML, JSON, CFG and INI
- tests/tools/source files when present
- `launcher/native` Go source
- `SOURCE_HANDOFF.txt`
- `DEVSTATE.json`
- `ASSET_INDEX.txt` containing asset paths and sizes only

It intentionally excludes heavyweight or machine-local content:

- `assets/` binary payloads (PNG/JPG/audio/fonts/etc.)
- `.godot/` import/cache data
- game/launcher EXEs and build output
- logs, telemetry and recordings
- previous exports
- Git/editor metadata
- recovery folders, backup ZIPs and launcher machine config

The source handoff is not a runnable game copy. Apply edited source back over the full local Crawl Brawl project.

## Naming

Numbered source handoffs use:

`CrawlBrawl_<VERSION>_DEV###_SOURCE_<YYYYMMDD_HHMM>.zip`

The stable alias remains:

`exports/CrawlBrawl_LATEST.zip`

The exporter continues sequence numbering across older V3 full-project snapshots so a completed older DEV number is not reused.

## Safety

- Exports are written through a `.partial` file and published only after completion.
- Cancelled exports remove the partial archive and do not consume a DEV sequence.
- SHA-256 files are written for completed snapshots.
- Individual source-like files above 16 MB are omitted to prevent accidental generated-data bloat.
