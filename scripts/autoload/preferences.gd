extends Node
var config_path := "user://settings.cfg"
var volume := 0.8
var fullscreen := false

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(config_path) == OK:
		var value: Variant = config.get_value("audio", "volume", 0.8)
		if value is float or value is int:
			volume = clampf(float(value), 0.0, 1.0)
		fullscreen = config.get_value("video", "fullscreen", false) == true
	apply_volume(volume)
	apply_fullscreen(fullscreen)

func apply_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), volume == 0.0)

func apply_fullscreen(value: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)

func save() -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	return config.save(config_path)
