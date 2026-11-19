# Work-in-progress maps

Indexed in [TODO.md](TODO.md). These are maps under construction in `server/mods/deathmatch/resources` that have written notes. The notes were moved here from comments in their scripts. Other WIP maps are marked only by their folder prefix.

## BIE — Big Import/Export Race

`aaaawip-bigimportexportrace` ("[R] Big Import/Export Race", description "Big") is a copy of Super FleischBerg Autos at about version 1.0.1. Its map file is still `new-race-superfleischbergautos.map` and its scripts are the 1.0.1 set, plus a vote script and a vehicle scoreboard. `abigimportwip` next to it holds only a map. What this map is meant to become, besides Super FleischBerg Autos, isn't written down.

Its notes, inherited from Super FleischBerg Autos:

- Runway indicators on the map.
- Hide the boat icon when the player isn't in a boat.
- Move the transparency code client side.
- Add pedestrians as spectators, as an endurance reward, with no collision. Maybe other decorations too.
- Drop the LEFT PLAYERS table and index by player serial everywhere.
- Crane one often makes 350-degree turns. Only visual: deliveries still work.
- Options to leave out planes, boats and so on.
- The client could be told `required_cp_count` and run `collectCP` before it talks to the server.
- Nice to have: output to text.
- Test the Tropic's behaviour at the bridge.
- Test heli blade collisions, your own and others'.
- Flying a plane kamikaze into the marker can count as a delivery. It shouldn't.
- Cranes: spawn a LowLOD version so they're visible from afar. Which model to use is unknown.
- Cranes: the approaching-boat detector (`craneDetectApproachingBoat`) should also ignore boats in the spawn area.

Most of these are also in `todo.txt` of the live map in the 123robot repo (`[maps]/[R]/SuperFleischbergAutos`). The spectator pedestrians and the Tropic test are only here.

**Evidence:** read 2026-11-19.

**Plan:** decide what this map is for. If it's only an old copy of Super FleischBerg Autos, delete it and leave these notes to that map's `todo.txt`. If not, rename its map file, write its description, and work through the notes that apply.

**Verify:** start it on the local server and play it through.

**Docs when done:** `CHANGELOG.md` only if it ships as a release here.

## TWK — Teamwork stadium map

`aawip-newteamwork` is a teamwork map set in a stadium, driven by `Teamwork.lua`. `aawip-newteamworkscripts/Teamwork.lua` is a copy of that script with course notes added and `MAIN_COURSE_CHECKPOINTS` set to 20 instead of 24. The script is also the base of the released teamwork maps Driving School and Verona Pier (in the 123robot repo under `[maps]/[TW]`).

Script notes:

- A team's compensation message for having had an advantage could use a colour.
- Make announcements more visible, including players quitting or idling.
- Revamp the checkpoint handling.
- The first gate opens only when the packer changes back to a Caddy, or someone picks up a race pickup. It should open as soon as players finish.
- Teams: synchronise the helper count, not the rider count.
- Changing teams sometimes breaks things.
- Collisions are odd when two teammates hit each other while ghosted against a non-teammate.
- `teamCheckStageOne` doesn't check properly.
- `updateHudInfo` also checks requirements, which belongs elsewhere.
- `promptTeamMenu` only prints a `/changeteam` message. Give it a GUI.

Course notes (from the scripts copy):

- Packer 1 is placed oddly.
- People wait for the big drop.
- People go into the Dumper's cargo hold instead of waiting.
- The Dumper gets stuck on exit with its cargo door up.
- The diagonal bus gets stuck. Make the entry straighter.
- Players can get stuck in the hole between the Dumper and the Beagle.
- The drop into the Packer area flips you badly.
- Add a repair on the DFT drop.
- Add a shortcut from the start into the baseball area, to the DFT area.
- The Yankee can hit the right Caddy spawn on its way to its parking spot. Move them further apart.
- Make the helper ramp faster to climb.
- Redesign the start area. See whether the helper up-ramp can go on the right instead of the left, then add a shortcut to the DFT.
- Maybe swap the Caddy for a Quad. Only a small speed bump should be needed.
- A billboard blocks a quick route from the DFT exit to the helper catch-up gate. Perhaps allow that shortcut.

**Evidence:** read 2026-11-19.

**Plan:** settle on one `Teamwork.lua` (the scripts copy has the newer notes) and delete the other (see [EMP](tasks.md#emp--resource-folders-with-no-metaxml)). Fix the team-change and gate bugs first, since they break play. Then work through the course notes in the map editor.

**Verify:** a local test with at least two players per team: change teams mid-race, finish the main course, and check that the first gate opens.

**Docs when done:** none.

## STR — Strategizer race

`aaawip-strategizer` is a race of 10 tracks. During a 5-minute setup phase, each player assigns the same 10 vehicles to the 10 tracks (from `help.xml`).

Notes:

- `strategizer.lua`: both failsafe timers (one for the `fadeout` state, one for `finishing`) break if a player quits after finishing.
- `strategizer.lua`: the `race.collideworld` handler should do the freezing, in case a player dies during a transition.
- `strategizer.lua`: `enableNextCheckpoint` gets checkpoint data from the server and sends it to the client, which already has it. Let the client look it up, and drop the call in `onPlayerReachCheckpoint`, which was meant to be temporary.
- `strategizer_client.lua`: `dumpSpeed` saves the vehicle's rotation without converting it to face the right way.
- `strategizer.lua`: the "Misc" section might belong in its own file.

**Evidence:** read 2026-11-19.

**Plan:** fix the timers first (check the player still exists before using them), then move the freezing, then the checkpoint lookup.

**Verify:** a local test with two players, one quitting right after finishing, with no script errors in the server console.

**Docs when done:** `help.xml` if the rules change.
