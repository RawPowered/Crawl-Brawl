# Crawl Brawl Native Launcher V3.1

V3.1 addresses the DEV STATE export appearing to hang in V3.0.

## What was happening

V3.0 compressed every project file with ZIP DEFLATE. Crawl Brawl is dominated by
already-compressed PNG/JPG and binary game assets, so Windows could spend a long
time recompressing data for almost no archive-size benefit. V3.0 also provided no
progress events while that work ran.

## What changed

- Native Windows progress bar for development exports.
- Stage labels: PREPARE, SCAN, PACK, FINALIZE, VERIFY, PUBLISH, DONE.
- Live percent, files, MB processed and current file.
- CANCEL EXPORT button with clean `.partial` removal.
- PNG/JPG/EXE and other binary assets use ZIP Store mode.
- Source/text files use DEFLATE BestSpeed.
- SHA-256 hashing reports progress instead of looking frozen.
- Existing numbered DEV snapshots, `index.json`, and `CrawlBrawl_LATEST.zip` remain compatible.

## Validation

The exporter was benchmarked on the supplied BV5 development tree (1,143 files):

- V3.0 exporter: about 2.61 seconds in the Linux validation environment.
- V3.1 exporter: about 0.53 seconds in the same environment.
- V3.1 archive was about 1.6% larger in exchange for roughly 5x faster packing.

Windows timing will differ because disk, Defender/antivirus and filesystem behavior differ,
but the launcher now shows exactly where export time is being spent.
