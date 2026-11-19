# Defects and tasks

Indexed in [TODO.md](TODO.md).

## RDM — Readme source link is broken

The "Folder Download / Source Code" link in `readme.md` points at `server/mods/deathmatch/resources/[maps]/[my maps new]/new-race-superfleischbergautos` on master. That folder left this repo in commit `7c753f10` (2024-10-22, "Map sturtue"). The map now lives in the 123robot repo, at `mta/resources/[maps]/[R]/SuperFleischbergAutos` (the `external/robot-mta-server` submodule here). The "Zip Download (1.0.1)" link still works.

**Evidence:** reproduced 2026-11-19: GitHub returns 404 for the link. The GitLab folder `https://gitlab.com/The123robot/robot-mta-server/-/tree/develop/mta/resources/%5Bmaps%5D/%5BR%5D/SuperFleischbergAutos` returns 200, and the old folder exists in this repo's tree at tag `FTqVpI9kdSYfqJ6vO-5FXg` (the 1.0.1 release).

**Plan:** decide which source to send people to: the current map in the 123robot repo, or this repo's tree at the 1.0.1 tag, which matches the zip. Then update the link. If it points at the current map, say that it's newer than the zip and is built for 123robot's server (see Unreleased in `CHANGELOG.md`).

**Verify:** the link opens the map's folder.

**Docs when done:** none beyond `readme.md`.

## KEY — Server identity key and registry are tracked in git

`server/mods/deathmatch/server-id.keys` has been committed since `ad98651c` (2020-03-20). The server generates this file to identify itself, and it's in a public repo. `server/mods/deathmatch/registry.db` (37 MB) is also tracked. The server rewrites it as it runs, so every run can dirty the tree, and commit `3ad6d9f6` grew it from 18 MB to 37 MB.

**Evidence:** read 2026-11-19 (`git ls-files server/mods/deathmatch/`).

**Plan:** add both files to `server/.gitignore` and `git rm --cached` them. Delete `server-id.keys` so the server makes a new one, if this server is ever reachable by others. Whether to scrub them from history is the owner's call.

**Verify:** start the server and stop it again, then check that `git status` is clean and that the server made a new `server-id.keys`.

**Docs when done:** the runtime-folders line in `CLAUDE.md`.

## PRS — Pull request 6 is superseded

GitHub PR #6 ("Upgrade to 64-bit MTA server with modernized config", by SpeedyFolf, opened 2026-07-24) is still open. Commit `3ad6d9f6` (2026-11-18) made the same move to `MTA Server64.exe` and `server/x64/`, and `f5a67437` updated the config. The PR also changes `mtaserver.conf`, `local.conf`, `editor.conf` and `vehiclecolors.conf`. Master has since deleted `local.conf` and kept old copies in `server/old-config/`.

**Evidence:** read 2026-11-19 (the PR's file list against those commits). The config contents weren't compared.

**Plan:** diff the PR's four config files against master and take any settings master lacks. Then close the PR with a note pointing at the commits.

**Verify:** the server starts with the merged config, and the PR is closed.

**Docs when done:** none.

## EMP — Resource folders with no meta.xml

These folders in `server/mods/deathmatch/resources` have no `meta.xml`: `af-bikeorwalk`, `af-johnbull`, `atrash`, `aveh-426enforcer` and `RADADAnDADADomiser` are empty, and git doesn't track them. `aawip-newteamworkscripts` holds only a `Teamwork.lua` (see [TWK](wip.md#twk--teamwork-stadium-map)). `[maps]/[classics]/overlays` and `[maps]/[classics]/tools` are empty too. MTA treats every folder outside a `[...]` group as a resource, so each one should show up as a failed load when the server starts.

**Evidence:** read 2026-11-19. A script that walks the folders the way MTA does found these, and found no duplicate resource names. The server wasn't started to see its messages.

**Plan:** delete the empty folders. Move `aawip-newteamworkscripts/Teamwork.lua` into `aawip-newteamwork` under another name, or delete it once TWK has its notes.

**Verify:** start the server and check that it reports no failed loads for these names.

**Docs when done:** none.

## CPK — ColorPicker123 GUI rebuild is dead code

In `[scripts by me]/ColorPicker123/gui.lua`, the `onClientResourceStop` handler that should rebuild the settings GUI when the `gamecenter` resource stops has its `recreateGui()` call commented out. `recreateGui()` itself is never called, and a comment says it doesn't work. The GUI code is credited to driver2.

**Evidence:** read 2026-11-19.

**Plan:** find out whether the GUI breaks when `gamecenter` stops. If it does, fix `recreateGui`. If not, delete the handler and the function.

**Verify:** start ColorPicker123 and `gamecenter`, stop `gamecenter`, and check that the colour picker's GUI still works.

**Docs when done:** none.
