extends Node2D
## Shared room shell: input, collision, HUD, modal ownership and checkpoints.
const ROOM := Rect2(100, 110, 1080, 480)
const INTRO := "res://data/dialogue/keeper_intro.json"
const LAMP := "res://data/dialogue/lamp_room.json"
var room_kind := "ground"
var _player: Player
var _interactables: Array[Interactable] = []
var _prompt: Label
var _status: Label
var _lamp_visual: ColorRect
var _modal: Control
var _modal_kind := ""
var _settings: Control
var _ui: CanvasLayer
var _ending_pending := false
var _changing := false

func _ready() -> void:
	_build_room()
	_build_player()
	_build_interactables()
	_build_hud()
	add_child(preload("res://scenes/ui/dialogue_box.tscn").instantiate())
	DialogueManager.dialogue_started.connect(_sync_movement)
	DialogueManager.dialogue_finished.connect(_dialogue_finished)
	GameState.state_changed.connect(_refresh_world)
	_refresh_world()
	if GameState.recovered_backup:
		GameState.recovered_backup = false
		_message("Save recovered", "The primary save was unavailable. Your previous backup was loaded.")

func _build_room() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#0b141c")
	bg.size = Vector2(1280, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var floor_rect := ColorRect.new()
	floor_rect.color = Color("#1d3038") if room_kind == "ground" else Color("#24313e")
	floor_rect.position = ROOM.position
	floor_rect.size = ROOM.size
	floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_rect)
	_wall(Rect2(80, 90, 1120, 20))
	_wall(Rect2(80, 590, 1120, 20))
	_wall(Rect2(80, 110, 20, 480))
	_wall(Rect2(1180, 110, 20, 480))
	if room_kind == "ground":
		_wall(Rect2(245, 195, 150, 55))
		_wall(Rect2(920, 195, 150, 55))
	else:
		_wall(Rect2(555, 265, 170, 100))
		_lamp_visual = ColorRect.new()
		_lamp_visual.position = Vector2(590, 270)
		_lamp_visual.size = Vector2(100, 85)
		_lamp_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_lamp_visual)

func _wall(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	var visual := ColorRect.new()
	visual.position = rect.position
	visual.size = rect.size
	visual.color = Color("#3e5158")
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)

func _build_player() -> void:
	_player = Player.new()
	_player.position = Vector2(640, 520)
	if room_kind == "ground" and GameState.spawn_id == "stairs":
		_player.position = Vector2(640, 230)
	add_child(_player)

func _build_interactables() -> void:
	if room_kind == "ground":
		_item("Logbook", "Read Edith's log", "logbook", Vector2(320, 285))
		_item("Radio", "Call the mainland", "radio", Vector2(1000, 285))
		_item("Stair", "Enter the lamp room", "stairs", Vector2(640, 160))
	else:
		_item("Service plate", "Read the keeper's instructions", "notes", Vector2(260, 260))
		_item("Wick", "Trim the wick", "wick", Vector2(460, 350))
		_item("Lens", "Align the lens", "lens", Vector2(820, 350))
		_item("Burner", "Light the lamp", "ignite", Vector2(640, 405))
		_item("Stair", "Return downstairs", "return", Vector2(1040, 500))

func _item(title: String, prompt: String, id: String, pos: Vector2) -> void:
	var item := Interactable.new()
	item.label = title
	item.prompt_text = prompt
	item.persistent_id = id
	item.position = pos
	item.action = _activate.bind(id)
	add_child(item)
	item.setup()
	_interactables.append(item)

func _activate(id: String) -> bool:
	match id:
		"logbook":
			if DialogueManager.start(INTRO, "logbook"):
				Journal.discover("edith_log")
				return true
			return false
		"radio": return DialogueManager.start(INTRO, "radio")
		"stairs": return _travel("res://scenes/lamp_room.tscn", "entrance")
		"return": return _travel("res://scenes/game.tscn", "stairs")
		"notes":
			if not DialogueManager.start(LAMP, "start"):
				return false
			Journal.discover("lamp_notes")
			return true
		"wick":
			if not DialogueManager.start(LAMP, "wick"):
				return false
			GameState.set_flag("wick_trimmed", true)
			return true
		"lens":
			if not DialogueManager.start(LAMP, "lens"):
				return false
			GameState.set_flag("lens_aligned", true)
			return true
		"ignite":
			if GameState.get_flag("lamp_relit", false):
				return DialogueManager.start(LAMP, "already_lit")
			if not GameState.get_flag("wick_trimmed", false) or not GameState.get_flag("lens_aligned", false):
				return DialogueManager.start(LAMP, "not_ready")
			if not DialogueManager.start(LAMP, "relight"):
				return false
			GameState.set_flag("lamp_relit", true)
			GameState.set_flag("demo_complete", true)
			Journal.discover("answer")
			_ending_pending = true
			return true
	return false

func _travel(scene: String, spawn: String) -> bool:
	if _changing:
		return false
	var previous_scene := GameState.current_scene
	var previous_spawn := GameState.spawn_id
	GameState.current_scene = scene
	GameState.spawn_id = spawn
	_changing = true
	if get_tree().change_scene_to_file(scene) != OK:
		GameState.current_scene = previous_scene
		GameState.spawn_id = previous_spawn
		_changing = false
		_message("Travel unavailable", "The room could not be loaded.")
		return false
	return true

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 5
	add_child(hud)
	_status = Label.new()
	_status.position = Vector2(100, 30)
	_status.add_theme_font_size_override("font_size", 20)
	hud.add_child(_status)
	var panel := PanelContainer.new()
	panel.position = Vector2(100, 625)
	panel.size = Vector2(1080, 65)
	hud.add_child(panel)
	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 20)
	panel.add_child(_prompt)
	_ui = CanvasLayer.new()
	_ui.layer = 20
	add_child(_ui)

func _refresh_world() -> void:
	if _lamp_visual != null:
		_lamp_visual.color = Color("#ffd466") if GameState.get_flag("lamp_relit", false) else Color("#535c64")
	if _status != null:
		_status.text = "Cape Marrow Light - " + ("ground floor" if room_kind == "ground" else "lamp room")
		if room_kind == "lamp":
			_status.text += "\nWick: %s   Lens: %s   Light: %s" % ["trimmed" if GameState.get_flag("wick_trimmed", false) else "untended", "aligned" if GameState.get_flag("lens_aligned", false) else "unaligned", "lit" if GameState.get_flag("lamp_relit", false) else "dark"]

func _nearest() -> Interactable:
	var best: Interactable = null
	var distance := 95.0
	for item in _interactables:
		var d := _player.position.distance_to(item.position)
		if item.can_interact() and d < distance:
			best = item
			distance = d
	return best

func _process(_delta: float) -> void:
	if DialogueManager.is_active or _modal != null:
		_prompt.text = ""
		return
	var item := _nearest()
	_prompt.text = "[%s] Journal    [%s] Pause" % [Controls.hint("journal"), Controls.hint("pause")]
	if item != null:
		_prompt.text = "[%s] %s    |    [%s] Journal" % [Controls.hint("interact"), item.prompt_text, Controls.hint("journal")]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or _settings != null:
		return
	if _modal != null:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			_close_modal()
			get_viewport().set_input_as_handled()
		return
	# Safe checkpoints: no pausing/saving halfway through a conversation.
	if DialogueManager.is_active:
		return
	if event.is_action_pressed("pause"):
		_open_pause()
	elif event.is_action_pressed("journal"):
		_open_journal()
	elif event.is_action_pressed("interact"):
		var item := _nearest()
		if item != null:
			item.interact()
	else:
		return
	get_viewport().set_input_as_handled()

func _sync_movement() -> void:
	if _player != null:
		_player.can_move = _modal == null and not DialogueManager.is_active and not _changing

func _dialogue_finished() -> void:
	_sync_movement()
	if _ending_pending:
		_ending_pending = false
		_message("The light answers", "Three flashes beyond the north rocks.\n\nEnd of the demo. You can keep exploring, reread the journal, or save from the pause menu.")

func _new_modal(title: String, kind: String, width: float = 600.0) -> VBoxContainer:
	_close_modal()
	_modal = UIHelpers.modal(title, width)
	_modal_kind = kind
	_ui.add_child(_modal)
	_sync_movement()
	return UIHelpers.column(_modal)

func _close_modal() -> void:
	if _settings != null:
		return
	if _modal != null:
		_modal.queue_free()
		_modal = null
	_modal_kind = ""
	_sync_movement()

func _open_pause() -> void:
	var column := _new_modal("Paused", "pause")
	var resume := UIHelpers.button("Resume", _close_modal)
	column.add_child(resume)
	column.add_child(UIHelpers.button("Save checkpoint", _request_save))
	column.add_child(UIHelpers.button("Journal", _open_journal))
	var settings_button := UIHelpers.button("Settings", func(): _open_settings())
	column.add_child(settings_button)
	column.add_child(UIHelpers.button("Main menu", func(): _confirm("Leave for the main menu?", "Unsaved progress will be lost.", func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))))
	column.add_child(UIHelpers.text("[%s] Back / Resume" % Controls.hint("ui_cancel")))
	resume.grab_focus()

func _open_settings() -> void:
	if _settings != null:
		return
	_modal.hide()
	_settings = preload("res://scenes/ui/settings.tscn").instantiate()
	_ui.add_child(_settings)
	_settings.closed.connect(func():
		_settings = null
		_modal.show()
		var column := UIHelpers.column(_modal)
		(column.get_child(4) as Button).grab_focus())

func _confirm(title: String, body: String, accepted: Callable) -> void:
	var column := _new_modal(title, "confirm")
	column.add_child(UIHelpers.text(body))
	column.add_child(UIHelpers.button("Confirm", accepted))
	var cancel := UIHelpers.button("Cancel", _open_pause)
	column.add_child(cancel)
	cancel.grab_focus()

func _request_save() -> void:
	if GameState.has_save():
		_confirm("Replace the current checkpoint?", "The previous valid save is retained as a recovery backup.", _save)
	else:
		_save()

func _save() -> void:
	GameState.current_scene = scene_file_path
	GameState.spawn_id = "entrance"
	var ok := GameState.save_game()
	_message("Checkpoint saved" if ok else "Save failed", "You will resume at this room's entrance with choices, puzzle progress and journal entries preserved." if ok else GameState.last_error)

func _message(title: String, body: String) -> void:
	var column := _new_modal(title, "message")
	column.add_child(UIHelpers.text(body))
	var close := UIHelpers.button("Continue", _close_modal)
	column.add_child(close)
	close.grab_focus()

func _open_journal() -> void:
	var column := _new_modal("Journal", "journal", 850)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	column.add_child(row)
	var list := ItemList.new()
	list.custom_minimum_size = Vector2(300, 300)
	row.add_child(list)
	var reader := RichTextLabel.new()
	reader.custom_minimum_size = Vector2(520, 300)
	reader.add_theme_font_size_override("normal_font_size", 22)
	row.add_child(reader)
	var entries := Journal.entries()
	for id in entries:
		list.add_item(Journal.ENTRIES[id].title)
	list.item_selected.connect(func(index: int): reader.text = Journal.ENTRIES[entries[index]].text)
	if entries.is_empty():
		reader.text = "No entries yet. Read the keeper's log and inspect the service plate upstairs."
	else:
		list.select(0)
		reader.text = Journal.ENTRIES[entries[0]].text
	var close := UIHelpers.button("Close journal", _close_modal)
	column.add_child(close)
	if entries.is_empty():
		close.grab_focus()
	else:
		list.grab_focus()
	list.focus_neighbor_bottom = list.get_path_to(close)
	close.focus_neighbor_top = close.get_path_to(list)
