extends Node
## Explicit bindings; UI navigation and world actions have separate names.
signal device_changed
var gamepad := false

func _ready() -> void:
	_bind("ui_accept", [KEY_ENTER, KEY_SPACE], [JOY_BUTTON_A])
	_bind("ui_cancel", [KEY_ESCAPE], [JOY_BUTTON_B])
	_bind("ui_left", [KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_bind("ui_right", [KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_bind("ui_up", [KEY_UP], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_bind("ui_down", [KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_bind("move_left", [KEY_LEFT, KEY_A], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_bind("move_right", [KEY_RIGHT, KEY_D], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_bind("move_up", [KEY_UP, KEY_W], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_bind("move_down", [KEY_DOWN, KEY_S], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_bind("interact", [KEY_ENTER, KEY_SPACE, KEY_E], [JOY_BUTTON_A])
	_bind("pause", [KEY_ESCAPE], [JOY_BUTTON_START, JOY_BUTTON_B])
	_bind("journal", [KEY_J], [JOY_BUTTON_Y])

func _bind(action: String, keys: Array, buttons: Array, axis: int = -1, value: float = 0.0) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	InputMap.action_set_deadzone(action, 0.2)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)
	for button in buttons:
		var event := InputEventJoypadButton.new()
		event.button_index = button
		InputMap.action_add_event(action, event)
	if axis >= 0:
		var event := InputEventJoypadMotion.new()
		event.axis = axis
		event.axis_value = value
		InputMap.action_add_event(action, event)

func _input(event: InputEvent) -> void:
	var next := gamepad
	if event is InputEventJoypadButton and event.pressed:
		next = true
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.3:
		next = true
	elif event is InputEventKey and event.pressed:
		next = false
	elif event is InputEventMouseButton and event.pressed:
		next = false
	if next != gamepad:
		gamepad = next
		device_changed.emit()

func hint(action: String) -> String:
	var keyboard := {"interact": "Enter / E", "ui_accept": "Enter", "ui_cancel": "Esc", "pause": "Esc", "journal": "J"}
	# Generic positional labels also work on non-Xbox pads.
	var pad := {"interact": "Bottom button", "ui_accept": "Bottom button", "ui_cancel": "Right button", "pause": "Start / Right button", "journal": "Top button"}
	return str((pad if gamepad else keyboard).get(action, action))
