extends Control

var hovering : bool = false


func _on_button_button_down() -> void:
	var tween = create_tween()
	tween.tween_property($Panel2, "scale", Vector2(0.97, 0.97), 0.1)


func _on_button_button_up() -> void:
	var tween = create_tween()
	
	if hovering == true:
		tween.tween_property($Panel2, "scale", Vector2(1.1, 1.1), 0.1)
	elif hovering == false:
		tween.tween_property($Panel2, "scale", Vector2(1, 1), 0.1)

	
func _on_button_mouse_entered() -> void:
	hovering = true
	
	var tween = create_tween()
	tween.tween_property($Panel2, "scale", Vector2(1.1, 1.1), 0.15)


func _on_button_mouse_exited() -> void:
	hovering = false
	
	var tween = create_tween()
	tween.tween_property($Panel2, "scale", Vector2(1, 1), 0.15)


func _on_button_pressed() -> void:
	get_parent().get_parent().get_parent().get_parent()._select_building(get_meta("building"))
	
