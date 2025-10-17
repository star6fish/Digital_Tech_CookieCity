extends Control

@onready var global = get_node("/root/Global")


# Resets the tick to be visible if the option is true
func _reset_tick():
	var option : String = get_meta("option")
	var optiion_on : bool = global.options[option]
	
	get_node("Tick").visible = optiion_on


# Option is pressed
func _on_button_pressed() -> void:
	
	var option : String = get_meta("option")
	var option_on : bool = global.options[option]
	
	if option_on == true:
		global.options[option] = false
	elif option_on == false:
		global.options[option] = true
	
	option_on = global.options[option]
	
	get_parent()._toggle_setting(option, option_on)
	
	_reset_tick()
