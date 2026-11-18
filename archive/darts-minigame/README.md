# Darts minigame (unfinished)

Saved from the `[123robot]` repo (robot-mta-server), from the local branch `S/Archery`, which was never pushed to any remote. It's commit `88a34a8c` (2024-11-22, by S): "Copied Darts, calculated Theta, and did research into dartboard ratios". Its parent is `63513439`. The branch's two later commits were merges of `master` and the `2024/1211` tag, and they didn't touch this folder.

It adds a new map resource, `[maps]/[MG]/Archery` ("Darts!", racetype MG, author "=FoX=Wuzi & mr.dogshit"):
- `MG-Darts.map`, `meta.xml`
- `server.lua` and `client.lua` (the game logic), and `custom.lua`
- `files/`: the dart model (`dart.dff`, `.txd`, `.col`) and two images
- the two map editor scripting extension files

## Contents
- `files/[maps]/[MG]/Archery/`: the resource in full, as it was in that commit.
- `darts-minigame.patch`: the commit as a binary patch.

## Using it again
Copy `files/[maps]/[MG]/Archery` into a `[123robot]` checkout. Alternatively, apply the patch there with `git am darts-minigame.patch`, which keeps the commit message and author. The patch applies cleanly to `63513439`.
