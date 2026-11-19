# Open work

Every open item in this repo, by code. Detail is in the doc each heading names. Finished work goes to [DONE.md](DONE.md).

The state of individual maps is also tracked by folder prefix in `server/mods/deathmatch/resources` (`awip`, `bfix`, …; see `prefixes.txt` there). Only the maps that have written notes have items here.

## Defects and tasks

Detail in [tasks.md](tasks.md).

| Code | Area | Summary | Severity |
|---|---|---|---|
| [RDM](tasks.md#rdm--readme-source-link-is-broken) | readme | The readme's Super FleischBerg Autos "Folder Download / Source Code" link returns 404; the map's folder left this repo on 2024-10-22 and now lives in the 123robot repo | Medium |
| [KEY](tasks.md#key--server-identity-key-and-registry-are-tracked-in-git) | server | `server-id.keys` (the server's identity key) and the 37 MB `registry.db` the server rewrites are committed to the public repo | Medium |
| [PRS](tasks.md#prs--pull-request-6-is-superseded) | server | GitHub PR #6 (64-bit server upgrade) is still open, though commits on master made the same upgrade; take any config it has that master lacks, then close it | Low |
| [EMP](tasks.md#emp--resource-folders-with-no-metaxml) | resources | Five empty folders and `aawip-newteamworkscripts` (a lone `Teamwork.lua`) sit among the resources with no `meta.xml`, so the server tries to load them and fails | Low |
| [CPK](tasks.md#cpk--colorpicker123-gui-rebuild-is-dead-code) | ColorPicker123 | ColorPicker123's handler for rebuilding its GUI when `gamecenter` stops is commented out, and `recreateGui` is unused and noted as not working | Low |

## Work-in-progress maps

Detail in [wip.md](wip.md).

| Code | Area | Summary | Severity |
|---|---|---|---|
| [BIE](wip.md#bie--big-importexport-race) | aaaawip-bigimportexportrace | Big Import/Export Race, a copy of Super FleischBerg Autos at about 1.0.1: decide what it becomes, and work through the notes it inherited (runway indicators, boat icon, crane turns, vehicle-type options, plane kamikaze deliveries, …) | Low |
| [TWK](wip.md#twk--teamwork-stadium-map) | aawip-newteamwork | Teamwork stadium map: script fixes (team changes break it, the first gate opens late, the stage-one check is wrong, no team menu GUI) and course layout notes | Low |
| [STR](wip.md#str--strategizer-race) | aaawip-strategizer | Strategizer race: failsafe timers break when a player quits after finishing, no freeze handling if a player dies mid-transition, checkpoint data sent from the server needlessly, saved rotation not adjusted | Low |

## Feature requests

Detail in [features.md](features.md).

| Code | Area | Summary | Severity |
|---|---|---|---|
| [STA](features.md#sta--limited-stamina-maps) | maps | Support maps with limited sprint stamina like single-player GTA SA, which MTA doesn't do natively (GitHub issue #4) | Low |
| [SHF](features.md#shf--shooting-footrace-maps) | maps | Support footrace maps where players shoot (GitHub issue #3, which has no description) | Low |
