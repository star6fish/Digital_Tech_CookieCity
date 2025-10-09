extends Control

@export var help_screen : Control
@export var help_screen_container : VBoxContainer

var help_screen_open : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Help button is pressed
func _on_button_pressed_help() -> void:
	
	var tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	
	if help_screen_open == true:
		
		help_screen_open = false
		
		tween.tween_property(help_screen, "scale", Vector2(0, 0), 0.2)
		tween.parallel().tween_property(help_screen, "rotation_degrees", 180, 0.25)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, "visible_characters", 0, 0.25)
		
	elif help_screen_open == false:
		
		help_screen_open = true
		
		tween.tween_property(help_screen, "scale", Vector2(1, 1), 0.25)
		tween.parallel().tween_property(help_screen, "rotation_degrees", 0, 0.25)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, "visible_characters", i.text.length(), 0.25)
