# PropHunt with 40 props (unfinished)

Saved from two git stashes in the `[123robot]` repo (robot-mta-server), made on 2025-03-15 on `master`. Both were made on top of commit `34fe7bb5` ("Merge branch 'The123robot-Final-120325' into 'master'").

What it changes compared with that commit:
- `[maps]/[MG]/PropHunt/ph_server.lua`: the prop list grows from 28 to 42 entries.
- `[gameplay]/achievements/achievements_list.lua`: adds the "Prop Predator" achievement ("Find all 40 unique Props"). The old 25-prop entry is commented out.
- `[gameplay]/achievements/meta.xml`: adds the two `prophuntProps40.png` icons.
- `[gameplay]/achievements/icons/` and `icons/gray/`: the new icon, `prophuntProps40.png`.

Upstream took a different path: its PropHunt has 28 props, and the achievement is "Find all 26 unique Props".

## Contents
- `files/`: the changed files in full, at the paths they have inside `[123robot]`.
- `prophunt-40-props.patch`: the code changes (ph_server.lua, achievements_list.lua and meta.xml).
- `prophunt-40-props-icons.patch`: the two icons, as a binary patch.

## Using it again
In a `[123robot]` checkout, either copy the files from `files/` into place, or run:

```
git checkout -b prophunt-40 34fe7bb5
git apply --binary <path>/prophunt-40-props.patch <path>/prophunt-40-props-icons.patch
```

On a newer commit, the patches may not apply cleanly, because PropHunt and the achievements list have changed since then.
