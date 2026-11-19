# Done

Finished work, one row per commit, newest first. Open work is in [TODO.md](TODO.md). The detail of a finished item was deleted from its doc and is in git history: `git log -S "## CODE " -- docs/`.

| Date | Code | Area | Change | Why / how |
|---|---|---|---|---|
| 2026-11-19 | — | server | Repair registry.db and grant the pending ACL requests of cw_script, race_ghost, race_spawnchoice, runcode and sup | server.log showed the database had orphaned pages and two broken indexes, and five 123robot resources were running without the rights they ask for. Reindexed and vacuumed the database and granted the rights in acl.xml; verified with integrity_check and a clean server start. |
| 2026-11-19 | — | docs | Add CLAUDE.md, the docs/TODO.md index with its detail docs, this log and CHANGELOG.md | Open work was scattered across code comments, GitHub issues and a broken readme link. The comments moved into the detail docs; the changelog was backfilled from both release zips and the current map. |
