# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal collection of Multi Theft Auto: San Andreas (MTA:SA) maps and resources: the owner's own maps (finished and work in progress), fixes to other people's maps, a large archive of old server maps, and a working local MTA server to test them in. There is no build, lint or test step. Content is MTA resources: a `meta.xml`, `.map` files (XML placed by the map editor) and Lua scripts.

## Tracked work

Start at [docs/TODO.md](docs/TODO.md): every open item, by three-letter code, with detail in the docs it links to. Finished work is logged in [docs/DONE.md](docs/DONE.md). Changes players or server owners of Super FleischBerg Autos would notice go under Unreleased in [CHANGELOG.md](CHANGELOG.md). Map work state is also shown by folder prefix (`prefixes.txt`, below).

## Layout

- `server/` is a full MTA server install (`MTA Server64.exe`, config in `server/mods/deathmatch/mtaserver.conf`, `acl.xml`). Runtime folders (`resource-cache`, `logs`, `databases`, `backups`, `internal.db`, `dumps`) are gitignored. `registry.db` (the server's database: top times, ratings) and `settings.xml` change on every run but are tracked on purpose, committed now and then as a backup; on a merge conflict take `registry.db` from either side.
- `server/mods/deathmatch/resources/` holds the resources. Top-level folders with a prefix are the owner's active work; `prefixes.txt` there defines them (`awip` work in progress, `bfix` a fix still to do on the owner's map, `new` a new map, `other` someone else's race, `test`, and `xrace`/`yrace`/`z` for unsorted old server maps). `aveh-<id><name>` is a series of one map per vehicle model ID.
- `[maps]/[classics]` (thousands of `z(<n>)` resources) and `[maps]/[old server maps]` are the bulk archive of old maps.
- `[123robot]` is a **Windows junction** to `external/robot-mta-server/mta/resources`, a git submodule of the 123robot community server (GitLab, `develop` branch). It's gitignored here: changes under it belong to the submodule repo, not this one. `.gitmodules` sets `ignore = all`, so `git status` here doesn't show the submodule's pointer moving; record a new pointer on purpose with `git add external/robot-mta-server`. Work on 123robot resources is done in the submodule itself, on `S/<topic>` branches made from `develop`. Its `Readme.md` is the reference for that server's map rules (folder naming in PascalCase, `racetype` attribute in `<info>`, required settings such as `#ghostmode`/`#respawntime`/`#useLODs`, custom checkpoint attributes `blipsize`/`extracolshapesize`, includable resources, the `mapEditorScriptingExtension` variants). Its `[templates]` folder has reusable map scripts.
- Super FleischBerg Autos, the map with releases here, is developed in the submodule at `[123robot]/[maps]/[R]/SuperFleischbergAutos`; its source left this repo in 2024. `aaaawip-bigimportexportrace` is an older copy of it.
- `[123robot_DUPES]--` holds this repo's own older copies of resources that also exist in `[123robot]`, including the owner's released maps under `[maps]/[my maps new]`.
- `mta-annotations/` is a submodule of MTA definitions for the Lua Language Server (sumneko), for autocomplete and type checks in Lua scripts.
- `old/` holds superseded copies (old race gamemode, admin changes, old-format maps); `archive/` holds unfinished work saved from the 123robot repo as patches plus files, each with a README on how to re-apply it.

## MTA resource rules that matter here

- A folder named `[...]` is a group folder: MTA scans inside it, but all resources are one flat namespace. Never use `[...]` paths in scripts or config, and moving a resource between group folders is safe.
- **A resource that exists twice anywhere in the tree won't load.** A trailing `--` after the brackets (`[123robot_DUPES]--`, `[old server not maps]--`, `[random tests]--`, `[Hide]--`) makes MTA skip the folder, which is how duplicates and parked resources are kept without clashing. Keep this in mind when copying a resource: hide one copy or rename it.
- Map resources are race-gamemode maps: `<info gamemodes="race" type="map" ...>` in `meta.xml`, race settings as `#`-prefixed `<setting>` entries (the map editor writes values in array form, `value='[ &quot;true&quot; ]'`), and usually a `customMapEditorScriptingExtension_s.lua` script written by the editor.

## Running and testing

Start `server/MTA Server64.exe` and use its console: `start <resource>`, `restart <resource>`, `refresh` after adding files, and `check` / `upgrade` for meta.xml and deprecated-function warnings. Resource names are folder names, without any `[...]` path. Testing a map means joining that local server from the MTA client.
