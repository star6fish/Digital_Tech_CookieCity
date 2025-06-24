extends Control


func _on_button_button_down() -> void:
	pass


func _on_button_button_up() -> void:
	pass # Replace with function body.


func _on_button_mouse_entered() -> void:
	
	var tween = create_tween()

	tween.tween_property($Panel2, "scale", Vector2(1.5, 1.5), 0.25)

func _on_button_mouse_exited() -> void:
	var tween = create_tween()
	
	tween.tween_property($Panel2, "scale", Vector2(1, 1), 0.25)
