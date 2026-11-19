# Feature requests

Indexed in [TODO.md](TODO.md). Both come from GitHub issues opened in 2022. Footrace support now lives in the 123robot repo's race gamemode, so the work may belong there.

## STA — Limited stamina maps

GitHub issue #4: MTA doesn't support sprint stamina the way single-player GTA SA does, so a map can't limit how long players sprint.

**Evidence:** the issue only (read 2026-11-19).

**Plan:** write a script that tracks sprint time and stops sprinting when stamina runs out. Make it something a map can include, the way the 123robot server's `breathbar` resource is included.

**Verify:** a test map where sprinting stops after a set time and stamina recovers while walking.

**Docs when done:** none here. The 123robot readme lists includable resources if it goes there.

## SHF — Shooting footrace maps

GitHub issue #3, "Support for shooty footrace maps", has no description.

**Evidence:** the issue only (read 2026-11-19).

**Plan:** write down what the issue was meant to cover: which weapons, whether players can damage each other, and how deaths and respawns work in a footrace. Then decide where it goes.

**Verify:** to be set once the feature is defined.

**Docs when done:** none.
