# Tidewrack — Milestones

## Evidence reconciliation - 2026-10-22

The connected repository is `curtis6625fd281c09fe6eabf0eed6-byte/tidewrack-backup`. Its inspected main tree is `8c9b1e407afe178a6287c6646705185d2e356e3c`. No tags were returned, and `v0.2-demo-rc` could not be resolved. This backup has not been matched to the Steam demo. Code observations below apply only to this snapshot; no engine or packaged-build testing was performed.

- **Journal:** `scripts/journal.gd` is explicitly a scaffold, with no reader UI and a TODO for persistence; it is not registered as an autoload in `project.godot`.
- **Lamp room:** `scripts/lamp_room.gd` is an empty-room/placeholder-lamp scaffold with player interaction and puzzle work still TODO.
- **Controllers:** gamepad events exist in `project.godot`; complete navigation, keyboard coexistence, glyphs and runtime behavior remain unverified.
- **Collision:** `scripts/player.gd` labels wall collision as unwired; movement is bounded to a rectangle.
- **Playtest fixes:** the Drive log records fixed statuses, but contains no fix commit, exact fixed build or retest evidence establishing inclusion in the released demo.

The 2026-06-29 scope report excludes controllers and targets `v0.2`. The repo scope and 2026-08-14 changelog include controllers and name `v0.2-demo-rc`. These document a scope discrepancy; the change date/approval and shipped implementation are not verified. Do not describe controller complaints as automatically out of scope.

**To close verification:** locate the actual demo source/tag, record its commit and corresponding Steam build ID, then record dated acceptance results for journal discovery/save-load, lamp-room completion, supported input navigation and the historical major/blocker fixes. Until then, completion and release-inclusion claims are historical assertions, not verified release status.


A nine-month schedule from kickoff to Steam launch. Dates are targets; the
GitHub Milestones mirror these and the issue tracker is grouped under them.

| # | Milestone       | Target date  | Definition of done |
|---|-----------------|--------------|--------------------|
| 0 | Kickoff         | 2026-03-02   | Repo, engine, dialogue system spike, GDD v0. |
| 1 | **Vertical slice** | 2026-05-15 | One explorable scene, working branching dialogue, save/load, menus. *(historical milestone target)* |
| 2 | **Public demo**    | 2026-08-15 | Second scene (the lamp room), journal, wall collision, controller support. Ships for Steam Next Fest. |
| 3 | **Press build**    | 2026-10-15 | Full act one, localization-ready strings, accessibility pass, review keys out. |
| 4 | **Full launch**    | 2026-11-20 | Complete game, Steam achievements, store page live, launch trailer. |

## Historical planning statement (2026-07; not verified release status)

The original plan described the vertical slice as complete and in players' hands. Its next target was the **Public
Demo** for Next Fest: the lamp-room scene, a journal to track discovered logs,
and the collision/controller gaps left open in the slice.

## Notes on scope

- **One location per milestone.** Each milestone adds exactly one new explorable
  space to keep the solo workload honest.
- **Narrative is the long pole.** Writing and iterating dialogue is the critical
  path; systems work is scheduled around leaving writing time.
- **Marketing beats are milestones too.** Store page, trailer, and Next Fest
  are tracked as first-class deliverables, not afterthoughts.

## Recorded intended demo scope (Steam Next Fest)

The working scope lists the vertical slice **plus**:

- **Lamp-room chapter** — the stair from the ground floor opens into the lamp
  room; relighting the lamp is the demo's closing beat.
- **Journal** — discovered logs collect into a readable in-game journal.
- **Controller support** — gamepad input map layered on the built-in actions.
- **Playtest fixes** — the round of fixes from the vertical-slice playtests.

Everything past this list (chapters 2+, full soundtrack, cover art integration)
is **out of demo scope** and deferred to the press/launch milestones. No crunch,
but the Next Fest date is firm.
