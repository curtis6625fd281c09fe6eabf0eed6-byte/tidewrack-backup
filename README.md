# Tidewrack

A narrative adventure at Cape Marrow Light, built in **Godot 4.3+** (standard,
non-.NET). The owner identifies this repository as the demo source.

## Implementation update - 22 October 2026

The former journal, lamp-room and collision scaffolds are now connected into a
playable demo loop. The implementation adds safe checkpoint saves, consistent
pause/settings flow, explicit keyboard/gamepad input and persistent discoveries.
The original `v0.2-demo-rc` tag was not present and has not been fabricated or moved.
This is a new source revision, not a claim about the historical Steam upload.

**Verified:** Godot 4.3 headless import/startup, 60 runtime integration checks,
5 validator regression tests and both authored dialogue graphs.
**Still required:** desktop visual/audio review, physical controller testing,
platform exports and Steam build verification. Placeholder primitive art remains;
no final art/audio assets or Steam integration have been added. New lamp-room
text and puzzle beats are a playable draft for narrative review.

## Open and play

Import `project.godot` in Godot 4.3+ and press F6 on `scenes/main_menu.tscn`, or
press F5 to run the project. CLI: `godot --path .`.

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | Arrows / WASD | Left stick / D-pad |
| Interact | Enter / Space / E | Bottom face button |
| Reveal / advance dialogue | Enter / Space | Bottom face button |
| Journal | J | Top face button |
| Pause | Esc | Start / right face button |
| Back in menus | Esc | Right face button |
| Menu navigation | Arrows / Tab | Stick / D-pad |

Prompts switch between keyboard labels and generic controller button positions.
Controller-brand artwork and user-configurable rebinding are not included.

## Demo route

1. Read the logbook downstairs and make both choices. The discovery goes into
   the journal; choices are stored as story flags.
2. Enter the stair at the north side of the ground floor.
3. Read the service plate. Trim the wick and align the lens, then light the burner.
   Acting out of order offers a reminder rather than a fail state or timer.
4. Finish the relight conversation to see the demo closing beat. You may continue
   exploring, return downstairs and reread discoveries.
5. Pause and save. Restart and Continue to restore the room, story/puzzle flags
   and journal. Checkpoints resume at the room entrance, not mid-sentence or at
   an exact coordinate. Saving is unavailable during dialogue.

## Save and settings behavior

- `user://save.json`: current checkpoint; `.bak`: previous valid checkpoint.
- Writes are staged in `.tmp` and validated before rotating the previous save.
- Invalid primary saves fall back to a validated backup with a recovery notice.
- Version-1 saves migrate to version 2 with an empty journal and entrance spawn.
- New Game resets live progress but keeps the existing disk checkpoint until an
  explicit confirmed overwrite. It does not reset audio/display preferences.
- Settings use `user://settings.cfg`. Display changes revert after ten seconds
  unless confirmed. A save/settings error is shown to the player.

## Code map

- `scripts/game.gd`: shared room construction, static collision, interactables,
  HUD, pause/journal/confirmation UI and room transitions.
- `scripts/lamp_room.gd`: selects the lamp-room layout in the shared room shell.
- `scripts/player.gd`: CharacterBody2D movement and collision.
- `scripts/autoload/controls.gd`: explicit actions and last-input-device hints.
- `scripts/autoload/preferences.gd`: audio/display preferences.
- `scripts/autoload/game_state.gd`: flags, journal discovery state, validated saves.
- `scripts/journal.gd`: journal definitions and discovery service.
- `scripts/autoload/dialogue_manager.gd`: validated JSON dialogue playback.
- `scripts/dialogue_box.gd`: reveal animation, choices and focus.
- `scripts/ui_helpers.gd`, `settings.gd`, `main_menu.gd`: shared UI and menus.
- `data/dialogue/`: authored conversation graphs.

## Repeat the checks

Python 3 and a Godot 4.3+ executable are required; no pip dependencies:

```sh
python3 tests/run_checks.py --godot /absolute/path/to/godot
```

The runner imports the project, checks startup and exercises gameplay in a
headless engine. Runtime tests use separate test save/settings filenames and
Linux user data is additionally isolated in a temporary directory. Two warnings
about `res://missing.json` are intentional missing-resource tests.

For content-only checks:

```sh
python3 tests/validate_dialogue.py
python3 -m unittest discover -s tests -p 'test_*.py'
```

See [the implementation notes](docs/implementation-2026-10-22.md) for changes,
acceptance checks and remaining limitations. Historical planning records remain
under `docs/`; their pre-implementation findings are not current completion status.
