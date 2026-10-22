extends Node
## DialogueManager — plays JSON-driven branching dialogue graphs.
##
## Autoloaded as `DialogueManager`. A graph is a dictionary of node id -> node.
## Each node:
##   { "speaker": String, "text": String,
##     "next": String|null,                     # linear node; null ends the graph
##     "choices": [ {"text": String, "next": String, "set_flag": {..}} ],
##     "set_flag": { "flag_name": value } }      # applied when the node is entered
##
## UI (dialogue_box.gd) listens to these signals; it does not read the graph.

signal dialogue_started
signal line_shown(speaker: String, text: String, choices: Array)
signal dialogue_finished

var _graph: Dictionary = {}
var _current_id: String = ""
var is_active: bool = false


func start(path: String, start_id: String = "start") -> bool:
	if is_active:
		return false
	var graph := _load_graph(path)
	if graph.is_empty() or not graph.has(start_id) or not graph[start_id] is Dictionary:
		return false
	_graph = graph
	is_active = true
	dialogue_started.emit()
	_goto(start_id)
	return true


## Advance a linear node (no choices). Ignored while choices are pending.
func advance() -> void:
	if not is_active:
		return
	var node: Dictionary = _graph.get(_current_id, {})
	if node.has("choices") and not (node["choices"] as Array).is_empty():
		return  # waiting on choose()
	var next: Variant = node.get("next", null)
	if next == null:
		_finish()
	else:
		_goto(str(next))


## Pick choice `index` on a choice node.
func choose(index: int) -> void:
	if not is_active:
		return
	var node: Dictionary = _graph.get(_current_id, {})
	var choices: Array = node.get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	_apply_flags(choice.get("set_flag", {}))
	var next: Variant = choice.get("next", null)
	if next == null:
		_finish()
	else:
		_goto(str(next))


func _goto(id: String) -> void:
	if not _graph.has(id) or not _graph[id] is Dictionary:
		push_error("DialogueManager: missing node '%s'." % id)
		_finish()
		return
	_current_id = id
	var node: Dictionary = _graph[id]
	_apply_flags(node.get("set_flag", {}))
	line_shown.emit(
		str(node.get("speaker", "")),
		str(node.get("text", "")),
		node.get("choices", [])
	)


func _apply_flags(dict: Dictionary) -> void:
	for key in dict:
		GameState.set_flag(str(key), dict[key])


func _finish() -> void:
	is_active = false
	_graph = {}
	_current_id = ""
	dialogue_finished.emit()


func _load_graph(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("DialogueManager: dialogue file not found: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	file.close()
	var parsed: Variant = parser.data
	if error != OK or typeof(parsed) != TYPE_DICTIONARY:
		push_error("DialogueManager: dialogue file is not a JSON object: %s" % path)
		return {}
	if not _valid_graph(parsed):
		return {}
	return parsed


func _valid_graph(graph: Dictionary) -> bool:
	for id in graph:
		var node: Variant = graph[id]
		if not node is Dictionary or not node.get("text") is String:
			return false
		if node.has("speaker") and not node.speaker is String:
			return false
		if node.has("next") == node.has("choices"):
			return false
		var records: Array = [node]
		if node.has("choices"):
			if not node.choices is Array or node.choices.is_empty():
				return false
			for choice in node.choices:
				if not choice is Dictionary or not choice.get("text") is String or not choice.has("next"):
					return false
				records.append(choice)
		for record in records:
			var changes: Variant = record.get("set_flag", {})
			if not changes is Dictionary:
				return false
			for key in changes:
				if not key is String or not changes[key] is bool:
					return false
			if record.has("next") and record.next != null:
				if not record.next is String or not graph.has(record.next):
					return false
	return not graph.is_empty()
