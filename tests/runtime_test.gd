extends Node
## Integration tests run inside Godot. Uses a test-only save path.
var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _ready() -> void:
	# Remain as a root sibling while real application scenes change.
	get_tree().current_scene = null
	call_deferred("run")

func settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func finish_dialogue() -> void:
	var limit := 0
	while DialogueManager.is_active and limit < 30:
		var node: Dictionary = DialogueManager._graph.get(DialogueManager._current_id, {})
		if node.has("choices"):
			DialogueManager.choose(0)
		else:
			DialogueManager.advance()
		limit += 1
		await get_tree().process_frame
	check(not DialogueManager.is_active, "dialogue terminates")

func run() -> void:
	Preferences.config_path = "user://test_settings.cfg"
	GameState.save_path = "user://test_checkpoint.json"
	GameState.delete_save()
	GameState.new_game()
	for action in ["interact", "pause", "journal", "move_left", "ui_accept", "ui_cancel"]:
		var keyboard := false
		var pad := false
		for event in InputMap.action_get_events(action):
			keyboard = keyboard or event is InputEventKey
			pad = pad or event is InputEventJoypadButton or event is InputEventJoypadMotion
		check(keyboard and pad, action + " has keyboard and gamepad events")
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	await settle()
	var room = get_tree().current_scene
	check(room != null and room._player.can_move, "ground floor starts playable")
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await settle()
	check(room._modal_kind == "pause", "keyboard Esc opens pause through input pipeline")
	escape = InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = false
	Input.parse_input_event(escape)
	await settle()
	escape = InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await settle()
	check(room._modal == null and room._player.can_move, "keyboard Esc closes pause through input pipeline")
	escape.pressed = false
	Input.parse_input_event(escape)
	for i in range(3):
		room._open_pause()
		check(not room._player.can_move, "pause locks movement")
		room._close_modal()
		await settle()
		check(room._ui.get_child_count() == 0 and room._player.can_move, "pause overlay removed")
	room._open_pause()
	room._open_settings()
	await settle()
	var prior_display: bool = Preferences.fullscreen
	room._settings._preview_fullscreen(not prior_display)
	room._settings._remaining = 0.001
	room._settings._process(0.01)
	check(Preferences.fullscreen == prior_display and room._settings._remaining <= 0.0, "unconfirmed display mode reverts")
	room._settings._close()
	await settle()
	check(room._settings == null and room._modal.visible, "settings returns to pause")
	room._close_modal()
	await settle()
	# Physics collision: press left toward outer wall.
	room._player.position = Vector2(125, 400)
	Input.action_press("move_left")
	for i in range(20):
		await get_tree().physics_frame
	Input.action_release("move_left")
	check(room._player.position.x >= 111.0, "wall blocks movement")
	check(room._activate("logbook"), "logbook starts")
	check(not room._player.can_move and Journal.has("edith_log"), "dialogue locks movement and discovers log")
	# Exercise input reveal before advancing.
	var box = room.get_node_or_null("DialogueBox")
	if box == null:
		for child in room.get_children():
			if child.get_script() == load("res://scripts/dialogue_box.gd"):
				box = child
	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	var before: String = DialogueManager._current_id
	box._unhandled_input(accept)
	check(not box._typing and DialogueManager._current_id == before, "first press reveals, does not advance")
	DialogueManager._goto("logbook_choice2")
	box._unhandled_input(accept)
	check(not box._typing and not box._choice_box.get_child(0).disabled, "choice-line reveal unlocks choices")
	DialogueManager.choose(1)
	check(GameState.flags.has("trusted_edith") and GameState.flags.trusted_edith == false, "quiet branch stores false explicitly")
	await finish_dialogue()
	check(room._player.can_move, "dialogue restores movement")
	check(not DialogueManager._valid_graph({"start": 3}), "malformed runtime graph rejected")
	check(not DialogueManager._valid_graph({"start": {"text":"bad", "next":"missing"}}), "invalid runtime target rejected")
	check(not DialogueManager.start("res://missing.json"), "missing dialogue rejected")
	check(not DialogueManager.start("res://data/dialogue/keeper_intro.json", "absent"), "missing entry rejected")
	var once := Interactable.new()
	once.once = true
	once.persistent_id = "test"
	once.dialogue_path = "res://missing.json"
	check(not once.interact() and once.can_interact(), "failed interaction not consumed")
	once.action = func(): return true
	check(once.interact() and not once.can_interact(), "successful one-shot consumed")
	var restored := Interactable.new()
	restored.once = true
	restored.persistent_id = "test"
	check(not restored.can_interact(), "one-shot state survives scene object recreation")
	restored.free()
	once.free()
	check(room._activate("stairs"), "stair transition succeeds")
	await settle()
	room = get_tree().current_scene
	check(room.room_kind == "lamp", "lamp room loaded")
	room._activate("ignite")
	check(not GameState.get_flag("lamp_relit", false), "prerequisites block premature relight")
	await finish_dialogue()
	room._activate("notes")
	await finish_dialogue()
	room._activate("wick")
	await finish_dialogue()
	room._activate("wick")
	await finish_dialogue()
	check(GameState.get_flag("wick_trimmed", false), "repeated tending is idempotent")
	room._activate("lens")
	await finish_dialogue()
	room._activate("ignite")
	await finish_dialogue()
	check(GameState.get_flag("demo_complete", false) and Journal.has("answer"), "demo ending and answer entry recorded")
	check(room._modal != null, "ending screen shown")
	Journal.discover("answer")
	check(Journal.entries().count("answer") == 1, "journal discoveries deduplicate")
	room._close_modal()
	room._save()
	check(GameState.has_save(), "checkpoint saved")
	room._close_modal()
	room._request_save()
	check(room._modal_kind == "confirm", "existing save requires confirmation")
	room._close_modal()
	check(GameState.save_game(), "second save creates backup")
	GameState.new_game()
	check(Journal.entries().is_empty(), "new game resets journal")
	check(GameState.load_game(), "checkpoint restores")
	check(Journal.entries().size() == 3 and GameState.get_flag("lamp_relit", false), "journal and puzzle persisted")
	get_tree().change_scene_to_file(GameState.current_scene)
	await settle()
	room = get_tree().current_scene
	check(room.room_kind == "lamp" and room._lamp_visual.color == Color("#ffd466"), "restored room renders lit lamp")
	room._open_journal()
	await settle()
	check(room._modal != null and not room._player.can_move, "journal opens modally")
	room._close_modal()
	check(room._activate("return"), "return stairs succeeds")
	await settle()
	room = get_tree().current_scene
	check(room.room_kind == "ground" and room._player.position == Vector2(640, 230), "return uses stair spawn")
	# Corrupt primary and recover previous valid backup.
	var file := FileAccess.open(GameState.save_path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(GameState.load_game() and GameState.recovered_backup, "corrupt primary recovers backup")
	GameState.delete_save()
	GameState.set_flag("sentinel", true)
	check(not GameState.load_game() and GameState.get_flag("sentinel", false), "failed load leaves live progress intact")
	file = FileAccess.open(GameState.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version":1, "scene":"res://scenes/game.tscn", "flags":{"trusted_edith":false}}))
	file.close()
	check(GameState.load_game() and GameState.flags.has("trusted_edith"), "v1 save migration")
	check(GameState._normalize({"version":99,"scene":"res://scenes/game.tscn","flags":{}}).is_empty(), "future save version rejected")
	check(GameState._normalize({"version":2,"scene":"res://unexpected.tscn","flags":{}}).is_empty(), "unknown scene rejected")
	GameState.delete_save()
	if FileAccess.file_exists(Preferences.config_path):
		DirAccess.remove_absolute(Preferences.config_path)
	print("RUNTIME TESTS: %d checks; %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
