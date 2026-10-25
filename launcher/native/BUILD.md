# Build Crawl Brawl Launcher v3.2

Source is Go and uses only the standard library.

## Windows x64 build

```bat
set GOOS=windows
set GOARCH=amd64
go vet ./...
go build -trimpath -ldflags "-H=windowsgui -s -w" -o "Play Crawl Brawl.exe" .
```

## Exporter tests

The exporter is platform-neutral and can be tested separately:

```bash
go test exporter.go exporter_test.go
```

## Release checks used for v3.2

- `go test exporter.go exporter_test.go`
- `GOOS=windows GOARCH=amd64 go vet ./...`
- Windows x64 GUI cross-build
- PE32+ executable inspection
- source-only export against the supplied BV5 project tree
- ZIP integrity and payload inspection (no `assets/` binary entries)
