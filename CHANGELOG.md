# Changelog

Changes to the Super FleischBerg© Autos map that players and server owners will notice, per release. Downloads are on this repo's GitHub releases page.

## Unreleased

The map is now developed for the 123robot server, and the next download will be built from that version.

### Action required

- **The map's folder is now called `SuperFleischbergAutos`.** Remove the old `new-race-superfleischbergautos` folder when you install it, or the map shows up twice.

### Added

- More lengths in the vote at the start. Double It Up (2), Post SSA Instadeliveries (3) and Tetrad (4) are always offered. Sunshine Autos Normal (6), Portland Harbor Crane (7), Like It's 1984 (8), Liberty City Garage Style (16), A Per Decem (21) and III SSSA Mode (55) sometimes appear.
- Achievements, on servers that run the 123robot achievements resource: Life Fulfillment, 15 Shades of Fleisch, Berg to Berg, Expensive Exports and You Can Fire Me Now.
- Boats and aircraft take less damage near the crane delivery areas.
- On servers running 123robot's race gamemode, the checkpoint counter shows your deliveries out of the chosen length.
- Admin commands: `/ie_saveGame` saves everyone's progress, `/ie_skipCutscene` skips the intro, `/ie_poll <length>` adds a length to the next vote, and `/ie_enableCheats` turns on cheat commands for everyone (`/cheatnext`, `/cheatprev`, `/cheatflip`, `/cheattp`, `/cheattpop` and `/cheattpboat`).

### Changed

- One List (10), Classic (30) and Extended (100) now only sometimes appear in the vote. Full Experience (212) appears only when an admin adds it with `/ie_poll 212`.
- The weather is sunny instead of overcast.
- Progress saved by earlier versions isn't loaded.

## 1.0.1 (2023-12-15)

### Action required

- **The zip now holds a `new-race-superfleischbergautos` folder.** Extract it into your server's resources folder instead of putting the zip there, and remove the 1.0.0 `race-superfleischbergautos` zip or folder.

### Added

- The name of your current vehicle is shown on screen when you get in.
- Vehicle and Money columns in the scoreboard.
- A Basic Race (1) and Extended (100) in the length vote. If the vote can't start, the race is 1 vehicle long instead of 20.
- Messages in the console (F8) when a vehicle is delivered, to help track down bugs.

### Changed

- Big planes are slightly easier to deliver, and the cranes lower them gently.
- The weather is overcast instead of sunny.
- The tutorial text is coloured.
- `/resetprogress` is now `/ie_resetprogress`.

### Removed

- The `/showtimes` command and the separate times window. The scoreboard columns replace them.

## 1.0.0 (2023-09-15)

### Added

- Super FleischBerg© Autos: a race where every vehicle in the game has a fixed spawn point and must be driven to the delivery point at the FleischBerg© brewery. Everyone delivers the same vehicles, in a random order each. A vote at the start sets the length: Bite Sized Chunk (5), One List (10), Classic (30) or the Full Experience (212). Cranes help with boats, trains, planes and trailers, and progress is saved if you leave and come back.
