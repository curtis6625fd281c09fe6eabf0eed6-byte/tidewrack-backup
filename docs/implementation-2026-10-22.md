# Demo implementation - 22 October 2026

## What changed

This update starts from commit `ef5ad6ea7769f86f0da53cfdb6bfaa0945f5e513`.
It is a new implementation revision; it does not recreate the missing historical
`v0.2-demo-rc` tag or certify the build already uploaded to Steam.

- Explicit keyboard and gamepad mappings, separate world/UI actions, a consistent
  0.2 stick deadzone, and device-aware text hints.
- One modal owner per room. Esc/Resume share cleanup, settings returns focus to
  its parent, journal locks movement, and repeated pause cycles do not stack UI.
- Validated versioned checkpoints: staged writes, a previous-good backup,
  recovery feedback, strict scene/flag/journal validation and v1 migration.
- Save-overwrite and main-menu confirmations. New Game preserves the prior disk
  save until an explicit overwrite. Resume is at a safe room entrance.
- Independent settings persistence and a ten-second display-mode rollback.
- CharacterBody2D player, foot collision shape and StaticBody2D room geometry.
- Ground-floor/lamp-room travel with explicit entrance/stair spawns.
- Playable lamp sequence: service plate, wick, lens, burner, answering-light beat
  and ending panel. No inventory system, fail state or time-pressure mechanic.
- A keyboard/controller journal reader. Discoveries have stable IDs, persist
  through save/load, deduplicate, and reset on New Game. GameState owns the state.
- Dialogue first-press reveal also works on choice lines. Choice buttons unlock
  only once the text is revealed. Full text is assigned once and revealed via
  visible_characters, with a scrollable text area and wrapped choice labels.
- Failed dialogue interactions no longer consume one-shot objects. One-shot
  state survives object recreation. Runtime graph validation checks schemas.
- Replay of the skeptic/believer choice explicitly clears the opposite flag.
- The Python validator rejects disconnected endings, dead-end branches, invalid
  flags/targets and malformed structures without crashing.

## Verification performed

On Godot `4.3.stable.official.77dcf97d8`, Linux headless:

- Project import and main-menu startup: passed without script errors.
- Both production dialogue graphs: passed.
- Five Python validator regression tests: passed.
- Sixty Godot runtime assertions: passed. Coverage includes explicit device
  bindings, keyboard Esc input dispatch, pause cleanup, settings return and mode
  rollback logic, physics collision, dialogue reveal/choice timing, false story
  flags, interaction failure, one-shot persistence, both room transitions,
  puzzle prerequisites and repetition, ending, journal dedup/reset/restore,
  overwrite confirmation, v1 migration, corrupt-primary backup recovery, and
  failed-load preservation of live state.

The tests manipulate some actions directly. They do not replace a physical
controller/desktop playthrough or test all OS-specific filesystem failures.
No claim of pixel-perfect display, actual monitor switching, audio mix, platform
export or Steam readiness is made from the headless run.

## Hands-on acceptance pass

1. Open main menu at 1280x720 and 1920x1080. Read every line and both choices;
   inspect text wrapping, scroll access, prompts and focus.
2. Play keyboard-only and controller-only; unplug/reconnect a controller and
   switch devices while a prompt is visible. Check journal list and Back controls.
3. Open/close pause repeatedly. Open settings from pause; cancel or time out a
   display change. Confirm the previous display mode and parent focus return.
4. Read the log, make each branch choice in separate runs, finish the lamp room,
   return downstairs and save. Restart and verify journal/flags/room restoration.
5. Walk against walls and furniture and through intended entrance routes.
6. Review the newly authored lamp-room dialogue and puzzle beats against intended
   pacing. They are implementation draft content, not a claim to recover lost text.
7. Review/export on each target platform, then record the actual exported commit
   and Steam build ID. Do not label this as the old demo tag without provenance.

## Remaining scope

Primitive visuals remain. Final art, environmental audio, controller-brand glyph
assets, rebinding UI, localization, broader accessibility options, achievements,
Steam Cloud and the full post-demo game are not implemented by this patch.
The feedback log is unchanged. Audio/polish reports still need reproduction
against a build that includes the relevant assets.
