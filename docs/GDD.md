# Tidewrack — Game Design Document

Concise and living. For story canon see [`narrative-bible.md`](narrative-bible.md);
for schedule see [`milestones.md`](milestones.md).

## Pillars

1. **The fog keeps its secrets.** Discovery is slow, earned, and atmospheric.
2. **Words over combat.** The game is exploration + reading + choices. No fail
   states, no timers, no death.
3. **A place you tend.** The lighthouse is a home and a job; verbs are keeper's
   verbs — light the lamp, log the night, work the radio.

## Core loop

Explore a location → find a document, recording, or object → read/hear it in a
branching conversation → make a choice that sets a flag → the world (and later,
who answers you) responds. Repeat across locations toward the water.

## Systems

| System | State | Notes |
|--------|-------|-------|
| Branching dialogue | ✅ vertical slice | JSON graphs, choices set flags. |
| Save / load        | Implemented + headless tested | Room-entry checkpoint, validated writes and recovery backup. |
| Menus + settings   | Implemented + headless tested | Modal ownership, persisted settings, timed display rollback. |
| Player movement    | Implemented + headless tested | CharacterBody2D and room/obstacle collision. |
| Journal            | Implemented + headless tested | Discoveries, reader UI, persistence and new-game reset. |
| Second location    | Implemented + headless tested | Lamp room, tending sequence, return route and closing beat; narrative review pending. |
| Controller + remap  | Partial | Explicit keyboard/pad bindings and text hints; physical-device acceptance and rebinding UI remain. |
| Localization        | ⏳ press build    | String extraction + translation tables. |
| Accessibility       | ⏳ press build    | Text scale, dyslexia-friendly font, no-flash. |
| Steam integration   | ⏳ launch         | Achievements, cloud saves. |

## Interaction design

Proximity-based: walk near an object, a prompt appears, press Enter. Dialogue
uses a typewriter reveal with press-to-skip; choices are keyboard-navigable and
focus the first option automatically. Movement is locked during conversation.

## Art & audio direction

Placeholder primitives today. Target: muted, desaturated palette (slate, kelp,
lamp-gold as the one warm accent — `#ffd466`); hand-painted 2D; a sound bed of
foghorn, surf, and radio static carrying most of the mood. Concept art and
final assets are produced per-milestone (see the tracker's `art` label).

## Out of scope (YAGNI)

No inventory economy, no crafting, no procedural generation, no multiplayer.
