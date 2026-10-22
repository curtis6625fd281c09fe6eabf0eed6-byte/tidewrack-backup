extends Node
## Safe room-entry checkpoints. Live state changes only after full validation.
signal state_changed
const SAVE_VERSION := 2
const SCENES := ["res://scenes/game.tscn", "res://scenes/lamp_room.tscn"]
var save_path := "user://save.json"
var flags: Dictionary = {}
var journal_entries: Array[String] = []
var current_scene: String = SCENES[0]
var spawn_id := "entrance"
var last_error := ""
var recovered_backup := false

func set_flag(key: String, value: Variant) -> void:
	flags[key] = value
	state_changed.emit()

func get_flag(key: String, fallback: Variant = false) -> Variant:
	return flags.get(key, fallback)

func new_game() -> void:
	flags.clear()
	journal_entries.clear()
	current_scene = SCENES[0]
	spawn_id = "entrance"
	last_error = ""
	recovered_backup = false
	state_changed.emit()

func has_save() -> bool:
	return FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path + ".bak")

func snapshot() -> Dictionary:
	return {"version": SAVE_VERSION, "scene": current_scene, "spawn": spawn_id,
		"flags": flags.duplicate(true), "journal": journal_entries.duplicate()}

func _normalize(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return {}
	var version: Variant = data.get("version", 0)
	if (not version is int and not version is float) or float(version) not in [1.0, 2.0]:
		return {}
	var scene: Variant = data.get("scene")
	var saved_flags: Variant = data.get("flags")
	if not scene is String or scene not in SCENES or not saved_flags is Dictionary:
		return {}
	for key in saved_flags:
		if not key is String or not saved_flags[key] is bool:
			return {}
	var spawn: Variant = data.get("spawn", "entrance")
	if not spawn is String or spawn not in ["entrance", "stairs"]:
		return {}
	var entries: Variant = data.get("journal", [])
	if not entries is Array:
		return {}
	var clean_entries: Array[String] = []
	for entry in entries:
		if not entry is String or entry not in ["edith_log", "lamp_notes", "answer"]:
			return {}
		if entry not in clean_entries:
			clean_entries.append(entry)
	return {"version": SAVE_VERSION, "scene": scene, "spawn": spawn,
		"flags": saved_flags.duplicate(true), "journal": clean_entries}

func _read(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1024 * 1024:
		return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {}
	return _normalize(parser.data)

func save_game() -> bool:
	last_error = ""
	var data := _normalize(snapshot())
	if data.is_empty():
		last_error = "Progress could not be validated; existing save was kept."
		return false
	var temp := save_path + ".tmp"
	var backup := save_path + ".bak"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		last_error = "Cannot write save file. Check available disk space."
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or _read(temp).is_empty():
		last_error = "Save verification failed; previous save was kept."
		return false
	# Rotate only a valid primary. Never replace a good backup with corrupt data.
	if FileAccess.file_exists(save_path):
		if not _read(save_path).is_empty():
			if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup) != OK:
				last_error = "Cannot rotate backup; previous save was kept."
				return false
			if DirAccess.rename_absolute(save_path, backup) != OK:
				last_error = "Cannot rotate save; previous save was kept."
				return false
		elif DirAccess.remove_absolute(save_path) != OK:
			last_error = "Cannot replace damaged save."
			return false
	if DirAccess.rename_absolute(temp, save_path) != OK:
		last_error = "Cannot finish save. The previous backup remains available."
		return false
	return true

func load_game() -> bool:
	last_error = ""
	recovered_backup = false
	var data := _read(save_path)
	if data.is_empty():
		data = _read(save_path + ".bak")
		recovered_backup = not data.is_empty()
	if data.is_empty():
		last_error = "No valid save could be loaded. Your current progress has not changed."
		return false
	flags = data.flags
	journal_entries.assign(data.journal)
	current_scene = data.scene
	spawn_id = data.spawn
	state_changed.emit()
	return true

func delete_save() -> void:
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(save_path + suffix):
			DirAccess.remove_absolute(save_path + suffix)
