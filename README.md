# Tidewrack

A narrative adventure set on a fog-bound island off the Washington coast. You
are the new keeper of **Cape Marrow Light**. The keeper before you, Edith Vane,
rowed out into the fog eleven days ago and did not come back.

Built solo by **Fogline Games** (Seattle) in **Godot 4**, shipping to Steam.

> **Status (owner-confirmed, reconciled 2026-10-22):** This repository is the source the owner identifies as the demo source. Journal, lamp-room and collision work remain incomplete. The `v0.2-demo-rc` tag is missing; exact export/build provenance and runtime acceptance remain outstanding. See [`docs/milestones.md`](docs/milestones.md) for prioritized work.

## Controls

| Action        | Key                     |
|---------------|-------------------------|
| Move          | Arrow keys              |
| Interact      | Enter / Space           |
| Advance / skip line | Enter / Space     |
| Pause / back  | Esc                     |

The table describes the documented keyboard controls. The snapshot overrides the built-in input actions with gamepad events in `project.godot`; keyboard coexistence and runtime input behavior have not been verified.

## Running it

Requires **Godot 4.3+** (standard, non-.NET build).

```bash
# Open in the editor
godot -e --path .

# Or run directly
godot --path .
```

The main scene is `scenes/main_menu.tscn`. Saves are written to Godot's
`user://save.json` (per-OS user data dir).

## Project layout

```
tidewrack/
├── project.godot            # engine config; registers the two autoloads
├── scenes/                  # thin .tscn wrappers (root node + script)
│   ├── main_menu.tscn
│   ├── game.tscn            # the vertical-slice level
│   └── ui/{dialogue_box,settings}.tscn
├── scripts/
│   ├── autoload/
│   │   ├── game_state.gd     # story flags + save/load  (autoload: GameState)
│   │   └── dialogue_manager.gd  # branching graph player (autoload: DialogueManager)
│   ├── main_menu.gd, settings.gd
│   ├── game.gd               # builds the level + HUD + pause menu
│   ├── player.gd             # top-down movement (Player)
│   ├── interactable.gd       # examinable world object (Interactable)
│   └── dialogue_box.gd       # dialogue UI, listens to DialogueManager
├── data/dialogue/
│   └── keeper_intro.json     # the keeper's-log conversation
├── assets/{sprites,audio,fonts}/   # placeholder art for now
├── tests/validate_dialogue.py      # engine-free dialogue-graph checker
└── docs/                     # GDD, narrative bible, milestones, credits
```

**Design note:** UI and levels are constructed in GDScript rather than authored
as large scene files. This keeps `.tscn` files small and reviewable in diffs and
avoids merge pain — a deliberate choice for a one-person studio.

## The dialogue system

Conversations are plain JSON graphs in `data/dialogue/`. Each node is either a
linear line (`"next": "<id>"`, or `null` to end) or a choice node (`"choices"`).
Any node can set story flags via `"set_flag"`, which `GameState` persists.

```json
{
  "start": { "speaker": "Edith", "text": "…", "next": "choice1" },
  "choice1": {
    "text": "…",
    "choices": [
      { "text": "Trust her", "next": "end", "set_flag": { "trusted_edith": true } }
    ]
  },
  "end": { "speaker": "", "text": "…", "next": null }
}
```

## Verifying changes

```bash
# Validate every dialogue graph (targets resolve, has an ending, no orphans)
python3 tests/validate_dialogue.py

# In-engine checks (requires Godot on PATH)
godot --headless --path . --check-only   # parse all scripts
```

> The GDScript in this build was authored without a local Godot install, so it
> has been checked statically and via the dialogue validator, **not** yet run in
> the engine. First engine open may surface minor fixups — tracked in the issue
> list.

## Steam Next Fest demo

The documented intended demo scope adds the lamp room, discovered-logs journal, controller support and playtest fixes. The owner has confirmed this repository is the demo source. Its journal and lamp-room scaffolds are therefore genuine implementation gaps against the intended demo scope. Gamepad mappings exist, but complete input support still needs verification. The historical feature-freeze/tag claim is unverified: no `v0.2-demo-rc` tag is present here. See [`docs/milestones.md`](docs/milestones.md) for the scope conflict and verification requirements.
