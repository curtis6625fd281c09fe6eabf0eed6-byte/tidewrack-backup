extends RefCounted
class_name UIHelpers

static func button(text: String, callback: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(240, 44)
	result.add_theme_font_size_override("font_size", 20)
	result.pressed.connect(callback)
	return result

static func modal(title: String, width: float = 600.0) -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.06, 0.94)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.name = "Column"
	column.custom_minimum_size.x = width
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 28)
	column.add_child(label)
	root.set_meta("column", column)
	return root

static func column(root: Control) -> VBoxContainer:
	return root.get_meta("column") as VBoxContainer

static func text(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	return label
