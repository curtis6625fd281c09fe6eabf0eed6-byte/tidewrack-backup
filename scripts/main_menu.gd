extends Control
var _continue_button: Button
var _settings: Control
var _panel: Control
var _message: Label
var _confirm: ConfirmationDialog
var _settings_button: Button

func _ready() -> void:
	_panel = UIHelpers.modal("TIDEWRACK - Cape Marrow Light")
	add_child(_panel)
	var column := UIHelpers.column(_panel)
	column.add_child(UIHelpers.text("A quiet place to tend. A disappearance to read."))
	var new_button := UIHelpers.button("New Game", _request_new)
	column.add_child(new_button)
	_continue_button = UIHelpers.button("Continue checkpoint", _continue_game)
	_continue_button.disabled = not GameState.has_save()
	column.add_child(_continue_button)
	_settings_button = UIHelpers.button("Settings", _open_settings)
	column.add_child(_settings_button)
	column.add_child(UIHelpers.button("Quit", func(): get_tree().quit()))
	_message = UIHelpers.text("Keyboard: arrows/WASD, Enter/E to interact, J for journal, Esc to pause.\nGamepad: stick/D-pad, bottom button to interact, top button for journal.")
	column.add_child(_message)
	_confirm = ConfirmationDialog.new()
	_confirm.title = "Start a new game?"
	_confirm.dialog_text = "Your existing checkpoint stays on disk until you explicitly save over it. Unsaved progress will be discarded."
	_confirm.confirmed.connect(_new_game)
	add_child(_confirm)
	new_button.grab_focus()

func _request_new() -> void:
	if GameState.has_save():
		_confirm.popup_centered(Vector2i(560, 200))
		_confirm.get_cancel_button().grab_focus()
	else:
		_new_game()

func _new_game() -> void:
	GameState.new_game()
	if get_tree().change_scene_to_file(GameState.current_scene) != OK:
		_message.text = "The starting room could not be loaded."

func _continue_game() -> void:
	if not GameState.load_game():
		_message.text = GameState.last_error
		return
	if get_tree().change_scene_to_file(GameState.current_scene) != OK:
		_message.text = "The saved room could not be loaded."

func _open_settings() -> void:
	if _settings != null:
		return
	_panel.hide()
	_settings = preload("res://scenes/ui/settings.tscn").instantiate()
	add_child(_settings)
	_settings.closed.connect(func():
		_settings = null
		_panel.show()
		_settings_button.grab_focus())
