# CRAWL BRAWL

<p align="center"><img src="assets/branding/crawl_brawl_logo.png" width="900" alt="Crawl Brawl logo with the tagline Dig. Build. Survive." /></p>

<p align="center"><strong>TOP-DOWN PIXEL-ACTION FORTRESS SHOOTER</strong><br />
Dig through the quarantine. Shape the swarm's route. Keep the Security Core alive.</p>

<p align="center">
  <a href="https://github.com/RawPowered/Crawl-Brawl/releases/latest">DOWNLOAD THE WINDOWS BETA</a> &nbsp;·&nbsp;
  <a href="GAME_PLAN.md">GAME AND PRODUCTION PLAN</a> &nbsp;·&nbsp;
  <a href="CHANGELOG.md">DEVELOPMENT HISTORY</a>
</p>

---

## The game

Crawl Brawl is a top-down pixel-action fortress game set entirely underground. Play as a maintenance engineer in a quarantined complex, dig through tunnels, gather materials, build defenses, and fight the mutant spider swarms and infected humans pressing toward the Security Core.

Digging changes the battlefield. Open a direct route for resources and you may also give the hive a way into the base. Build choke points, support your defenses, and step into the fight yourself when a tunnel breaks.

**Dig. Build. Survive.**

## Latest gameplay, full frame

This 10-second, 1080p gameplay reel comes from the August 13, 2026 development build. It moves from a defended Security Core through connected tunnel materials and into a fire-weapon encounter. The resource counter, pack, equipment bar, facility map, and defensive layout stay visible as play shifts between scenes.

<p align="center"><img src="assets/showcase/latest-gameplay-1080p.gif" width="100%" alt="1080p Crawl Brawl gameplay reel showing the defended Security Core, live resource and inventory UI, connected underground materials, facility map, and a fire-weapon encounter." /></p>

<p align="center"><strong>UIX / MATERIALS / BASE BUILDING / COMBAT</strong><br />Latest captured gameplay. Systems and presentation may change during development.</p>

<table>
  <tr>
    <td width="33%" valign="top"><img src="assets/showcase/core-room.jpg" width="100%" alt="Security Core room, defensive layout, current loadout, and facility map from the August 13 gameplay build." /><p align="center"><strong>COMMAND POST</strong><br />The core and its defenders under threat.</p></td>
    <td width="33%" valign="top"><img src="assets/showcase/tunnel-network.jpg" width="100%" alt="Branching underground passage with tracked map, equipment bar, and brood-carrier warning." /><p align="center"><strong>UNDERGROUND ROUTES</strong><br />Navigate the connected tunnel network.</p></td>
    <td width="33%" valign="top"><img src="assets/showcase/combat-response.jpg" width="100%" alt="Fire weapon effect in an underground tunnel, with the player loadout and facility map visible." /><p align="center"><strong>WEAPON RESPONSE</strong><br />Use the loadout to meet a tunnel threat.</p></td>
  </tr>
</table>

## Playable Windows package

The latest release contains a standalone Windows build. Godot does not need to be installed to play.

1. Download the Windows ZIP from [Releases](https://github.com/RawPowered/Crawl-Brawl/releases/latest).
2. Extract the ZIP to a writable folder.
3. Run `CrawlBrawl_Beta_0.1.exe`.

Beta 0.1 includes portable realm saves, recovery backups, and the latest included underground combat, excavation, fortress, economy, and brood ecology work. It is a development build for evaluation. Final release validation remains open.

See [README_PLAYER.txt](README_PLAYER.txt) for save locations and migration information. Saves are stored under `%APPDATA%\Crawl Brawl\saves` on Windows.

## From the underground to Civilian 66

Crawl Brawl was the first game in this creative direction. Its playable story stays underground. When I had found the setting and understood the direction I wanted to take, I stopped expanding the story here and carried that work into Civilian 66. Civilian 66 develops the journey beyond the underground, including how the player reaches the surface and what the above-ground story becomes.

The two projects show different stages of the same design journey. Crawl Brawl is the underground fortress game. Civilian 66 takes the story farther into exploration, first contact, and a changed world.

<p align="center"><a href="https://github.com/RawPowered/Civilian66-Public"><strong>EXPLORE THE CIVILIAN 66 SHOWCASE →</strong></a></p>

## Build from source

- Engine: Godot 4.7.1 stable
- Language: GDScript
- Main scene: `scenes/main.tscn`
- Windows build: run `Build Windows Beta.bat` with Godot 4.7.1 available. The script prepares export templates when needed, imports project resources, builds the standalone game, and packages player instructions and third-party notices.

The repository includes the Godot project, gameplay source, runtime assets, and Windows build instructions. The standalone beta is available from Releases. No saved games are included in the repository or release package.

## Project notes

- Single-player, offline-first design.
- Underground quarantine facility and hive setting.
- Tunneling, resource gathering, fortress construction, personal combat, and persistent realm progression.
- Current milestone: Beta 0.1 Windows distribution candidate.

The full campaign is not represented by this build. Crawl Brawl remains an underground game; the above-ground continuation belongs to Civilian 66.

## Credits and permissions

Crawl Brawl's game code, characters, and original artwork are project materials. This repository does not grant a separate license to reuse those materials. Third-party software and font notices are in [LICENSES.md](LICENSES.md); the Share Tech Mono font license is also included at [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
