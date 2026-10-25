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

## Gameplay in motion

These captures use the August 13, 2026 gameplay build. They show the underground map, the expanded loadout, a brood-carrier warning, and a weapon response in the tunnels.

<table>
  <tr>
    <td width="50%" valign="top">
      <p><strong>01 / TRACK THE BROOD CARRIER</strong></p>
      <img src="assets/showcase/dig-build-survive.gif" width="100%" alt="Latest Crawl Brawl gameplay build showing the Security Core room, a brood-carrier warning, expanded equipment bar, and tracked facility map." />
      <p><em>Read the facility map and act on an incoming brood-carrier warning.</em></p>
    </td>
    <td width="50%" valign="top">
      <p><strong>02 / HOLD THE TUNNELS</strong></p>
      <img src="assets/showcase/breach-response.gif" width="100%" alt="Latest Crawl Brawl gameplay build showing the player using a fire weapon in the tunnels, with loadout, resources, and facility map visible." />
      <p><em>Switch weapons and meet the threat inside the underground network.</em></p>
    </td>
  </tr>
</table>

<p align="center"><strong>LATEST GAMEPLAY CAPTURE / AUGUST 13, 2026</strong><br />Footage from an active development build. Systems and presentation may change.</p>

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

The repository includes the Godot project, gameplay source, runtime assets, build instructions, and focused development tests. Generated caches, local saves, video-editing material, and previous builds are excluded.

## Project notes

- Single-player, offline-first design.
- Underground quarantine facility and hive setting.
- Tunneling, resource gathering, fortress construction, personal combat, and persistent realm progression.
- Current milestone: Beta 0.1 Windows distribution candidate.

The full campaign is not represented by this build. Crawl Brawl remains an underground game; the above-ground continuation belongs to Civilian 66.

## Credits and permissions

Crawl Brawl's game code, characters, and original artwork are project materials. This repository does not grant a separate license to reuse those materials. Third-party software and font notices are in [LICENSES.md](LICENSES.md); the Share Tech Mono font license is also included at [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
