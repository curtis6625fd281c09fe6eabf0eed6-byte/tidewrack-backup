# Tidewrack — Milestones

> **Implementation update:** the code gaps below were audited before the 22 October implementation. Journal, lamp-room flow, collision, menu handling and save protection have since been implemented and passed headless checks. See [current implementation notes](implementation-2026-10-22.md); the historical audit below is retained as context. Physical-device, visual and export acceptance remain outstanding.

## Reconciled demo source and priorities - 2026-10-22

**Owner-confirmed source:** the owner confirmed that `curtis6625fd281c09fe6eabf0eed6-byte/tidewrack-backup` is the source that would have gone out as the demo. This supersedes the earlier interpretation that it might be an unrelated backup. Treat its implementation gaps as demo-source gaps. The original code-review baseline was tree `8c9b1e407afe178a6287c6646705185d2e356e3c`; subsequent changes in this reconciliation are documentation only.

**Evidence limits:** source identification is resolved by owner confirmation. The missing `v0.2-demo-rc` tag, exact exported commit/Steam build ID and runtime behavior are separate unresolved matters. No engine or packaged-build tests were performed. Do not state that a particular player encountered a bug without report or reproduction evidence.

### Scope resolution
Use the working demo scope: ground floor, lamp room, journal, controller support and playtest fixes; wall collision is also a public-demo milestone deliverable. The June report's controller deferral is superseded as the working baseline by the repo scope and August changelog. The historical change date remains unknown. The June report's claims that journal and lamp-room work were complete and tested are contradicted by this confirmed demo source. Completion claims must be withdrawn, not merely treated as an unrelated-backup mismatch. Chapters beyond the demo remain excluded; this review does not expand scope.

### Prioritized work and acceptance checks
| Priority | Problem and evidence | Required result |
|---|---|---|
| P0 - functional baseline | Input actions in `project.godot` list gamepad events without explicit keyboard events, while prompts advertise Enter. Keyboard coexistence is a concrete test risk, not a reproduced failure. | Explicitly support intended keyboard and gamepad inputs; test movement, interaction, dialogue, pause and settings with each device. Correct glyphs/hints for the active device. |
| P0 - pause flow | In `scripts/game.gd`, Esc toggles `_paused` off without removing PauseLayer. Only Resume removes that layer; repeated toggles can create additional layers. | One pause overlay; Esc and Resume both remove it and restore movement/focus. Test repeated cycles and settings opened from pause. |
| P0 - progress protection | `GameState.save_game()` writes directly to the sole save file; pause Save calls it without overwrite confirmation. No temporary-file/backup recovery path is present. This confirms missing safeguards, not a reproduced corruption event. | Confirm overwrite where required, use recoverable save writes, and test interrupted writes, malformed saves, restart and both narrative branches. |
| P1 - promised content | `scripts/lamp_room.gd` is a placeholder. Ground-floor stair invokes dialogue; its JSON ends with “next chapter” text rather than changing scene. | Wire entry/return, player interaction, puzzle/relight flags and a reachable demo ending. Test a fresh run and saved progress. |
| P1 - promised content | `scripts/journal.gd` only stores entries in memory. No reader UI, autoload registration or save/load integration is present. | Discover, read and persist entries; clear them on new game; support keyboard and controller navigation. |
| P1 - movement | `scripts/player.gd` clamps to room bounds. `_resolve_walls()` is a TODO and is not called from movement. | Implement and wire collision against room geometry; test stairs, doors and corners for clipping/sticking. |
| P1 - verification | UI size/contrast, input timing, save behavior and controller navigation lack runtime acceptance evidence. | Run targeted checks at 1080p and intended display modes; attach dated results to the tested commit/build. |
| P2 - polish | Historical duplicates cover spacing, glow clipping and ambience balance; present impact has not been reproduced. | Defer cosmetic items unless testing shows they obscure essential information or block play. |

### Implemented fixes that still need runtime verification
- `dialogue_box.gd`: linear-line input reveals the current text before advancing; choice buttons stay disabled until text completes, then receive focus.
- `settings.gd`: slider reads the current master volume and Back receives focus.
- `game.gd`: interaction prompt hides while dialogue is active.
- `keeper_intro.json`: the quiet branch explicitly sets `trusted_edith: false`; DialogueManager applies choice flags and GameState serializes flags.
These code paths support specific historical fix claims. They do not establish all fixes, safe interrupted writes, correct sizing or a tested release.

### Release and feedback records
Record the exact exported commit, build identifier and test results. Do not create a historical tag on today's head merely to make the record look complete. The feedback log is historical evidence (39 rows, PR1-PR9, 21 distinct summaries), with conflicting duplicate statuses. Keep its source rows; attach fest reports to complaint families and one current disposition per family. Fest new-versus-recurring counts still require the actual fest reports.


Historical schedule from kickoff to Steam launch. Dates are targets; the
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
is **out of demo scope** and deferred to the press/launch milestones. These are historical scope boundaries, not a current completion sign-off.
