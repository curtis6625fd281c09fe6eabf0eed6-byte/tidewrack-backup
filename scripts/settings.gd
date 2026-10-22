extends Control
signal closed
var _fullscreen: CheckButton
var _volume: HSlider
var _message: Label
var _confirm: ConfirmationDialog
var _remaining := 0.0
var _pending_fullscreen := false
var _closing := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var modal := UIHelpers.modal("Settings")
	add_child(modal)
	var column := UIHelpers.column(modal)
	column.add_child(UIHelpers.text("Master volume"))
	_volume = HSlider.new()
	_volume.min_value = 0.0
	_volume.max_value = 1.0
	_volume.step = 0.05
	_volume.value = Preferences.volume
	_volume.custom_minimum_size.y = 40
	_volume.value_changed.connect(Preferences.apply_volume)
	column.add_child(_volume)
	_fullscreen = CheckButton.new()
	_fullscreen.text = "Fullscreen"
	_fullscreen.button_pressed = Preferences.fullscreen
	_fullscreen.toggled.connect(_preview_fullscreen)
	column.add_child(_fullscreen)
	_message = UIHelpers.text("Display changes revert automatically unless confirmed.")
	column.add_child(_message)
	var back := UIHelpers.button("Back", _close)
	column.add_child(back)
	_volume.focus_neighbor_bottom = _volume.get_path_to(_fullscreen)
	_fullscreen.focus_neighbor_top = _fullscreen.get_path_to(_volume)
	_fullscreen.focus_neighbor_bottom = _fullscreen.get_path_to(back)
	back.focus_neighbor_top = back.get_path_to(_fullscreen)
	back.grab_focus()
	_confirm = ConfirmationDialog.new()
	_confirm.title = "Keep this display mode?"
	_confirm.ok_button_text = "Keep"
	_confirm.cancel_button_text = "Revert"
	_confirm.confirmed.connect(_keep_display)
	_confirm.canceled.connect(_revert_display)
	add_child(_confirm)

func _preview_fullscreen(value: bool) -> void:
	_pending_fullscreen = value
	Preferences.apply_fullscreen(value)
	_remaining = 10.0
	_confirm.dialog_text = "Keep this display mode? Reverting in 10 seconds."
	_confirm.popup_centered(Vector2i(500, 180))
	_confirm.get_cancel_button().grab_focus()

func _process(delta: float) -> void:
	if _remaining <= 0.0:
		return
	_remaining -= delta
	_confirm.dialog_text = "Reverting in %d seconds unless you choose Keep." % ceili(_remaining)
	if _remaining <= 0.0:
		_revert_display()

func _keep_display() -> void:
	_remaining = 0.0
	Preferences.fullscreen = _pending_fullscreen
	_persist()
	_fullscreen.grab_focus()

func _revert_display() -> void:
	_remaining = 0.0
	Preferences.apply_fullscreen(Preferences.fullscreen)
	_fullscreen.set_pressed_no_signal(Preferences.fullscreen)
	_confirm.hide()
	_fullscreen.grab_focus()

func _persist() -> bool:
	if Preferences.save() != OK:
		_message.text = "Settings work for this session, but could not be saved to disk."
		return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_echo() and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	if _closing:
		return
	if _remaining > 0.0:
		_revert_display()
	if not _persist():
		# A second Back press may still close the screen after showing the error.
		if not has_meta("save_error_shown"):
			set_meta("save_error_shown", true)
			return
	_closing = true
	closed.emit()
	queue_free()

func _exit_tree() -> void:
	if _remaining > 0.0:
		Preferences.apply_fullscreen(Preferences.fullscreen)
