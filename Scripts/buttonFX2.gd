extends Control

@export var button : Node

var hovering : bool = false

var button_effect_speed : float = 0.1

var default_scale : Vector2 = Vector2(1, 1)
var down_scale : Vector2 = Vector2(0.97, 0.97)
var up_scale : Vector2 = Vector2(1.1, 1.1)


# Pressing button
func _on_button_button_down() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(button, "scale", down_scale, button_effect_speed)


# Stopped pressing button
func _on_button_button_up() -> void:
	var tween : Tween = create_tween()
	
	if hovering == true:
		tween.tween_property(button, "scale", up_scale, button_effect_speed)
	elif hovering == false:
		tween.tween_property(button, "scale", default_scale, button_effect_speed)


# Hovering on button
func _on_button_mouse_entered() -> void:
	hovering = true
	
	var tween : Tween = create_tween()
	tween.tween_property(button, "scale", up_scale, button_effect_speed)


# Stopped hovering on button
func _on_button_mouse_exited() -> void:
	hovering = false
	
	var tween : Tween = create_tween()
	tween.tween_property(button, "scale", default_scale, button_effect_speed)
	
