extends Node2D
class_name Interactable
signal interacted(source: Interactable)
var label := "Object"
var prompt_text := "Examine"
var dialogue_path := ""
var dialogue_start := "start"
var persistent_id := ""
var once := false
var color := Color("#5b7f8c")
var action: Callable
var _used := false

func setup() -> void:
	var marker := ColorRect.new()
	marker.color = color
	marker.size = Vector2(40, 40)
	marker.position = Vector2(-20, -20)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marker)
	var tag := Label.new()
	tag.text = label
	tag.position = Vector2(-65, 26)
	tag.add_theme_font_size_override("font_size", 16)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tag)

func can_interact() -> bool:
	var used := bool(GameState.get_flag("used_" + persistent_id, false)) if persistent_id != "" else _used
	return not (once and used)

func interact() -> bool:
	if not can_interact():
		return false
	var ok := false
	if action.is_valid():
		ok = action.call() == true
	elif dialogue_path != "":
		ok = DialogueManager.start(dialogue_path, dialogue_start)
	if not ok:
		return false
	_used = true
	if once and persistent_id != "":
		GameState.set_flag("used_" + persistent_id, true)
	interacted.emit(self)
	return true
