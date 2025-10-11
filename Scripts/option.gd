extends Control

@onready var global = get_node("/root/Global")


# Resets the tick to be visible if the option is true
func _reset_tick():
	get_node("Tick").visible = global.options[get_meta("option")]


# Option is pressed
func _on_button_pressed() -> void:
	if global.options[get_meta("option")] == true:
		global.options[get_meta("option")] = false
	elif global.options[get_meta("option")] == false:
		global.options[get_meta("option")] = true
	
	get_parent()._setting(get_meta("option"), global.options[get_meta("option")])
	
	_reset_tick()
