# Crawl Brawl Launcher v3.2 - Source Handoff Hotfix

Extract this package over the Crawl Brawl project root and replace `Play Crawl Brawl.exe`.

The export button is now `SAVE CODE HANDOFF ZIP`.

V3.2 no longer packages the whole game. Numbered handoffs contain editable source/configuration/context only. Binary runtime assets remain on the local development machine and are represented only by path/size entries in `ASSET_INDEX.txt`.

Expected output name:

`exports/CrawlBrawl_BV5_DEV###_SOURCE_YYYYMMDD_HHMM.zip`

Stable upload alias:

`exports/CrawlBrawl_LATEST.zip`

The source handoff is intentionally not runnable by itself. It is intended to be uploaded to ChatGPT/browser/Codex, edited, then applied back to the full local project.

V3.2 does not automatically delete old completed V3/V3.1 full-project exports. You may delete those old oversized ZIPs manually after confirming you do not need them. Abandoned `.partial` exports are still removed automatically before a new export.
