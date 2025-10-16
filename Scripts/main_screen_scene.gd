extends Control

@onready var global = get_node("/root/Global")

@export var help_screen : Control
@export var help_screen_container : VBoxContainer

@export var black_and_white : ColorRect
@export var high_contrast : ColorRect

var save_path : String = "user://save_data"

var scene_name: String = "Main Screen"

var help_screen_open : bool = false


# Gets the games data
func _get_game_save():
	
	if FileAccess.file_exists(save_path):
		var save = FileAccess.open(save_path, FileAccess.READ)
		return save.get_var()

	else:
		return null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.options_back = scene_name
	
	var game_save = _get_game_save()
	
	global.options = game_save.options
	global.save_buildings = game_save.buildings
	
	if global.options["Black And White"] == true:
		black_and_white.visible = true
		
	if global.options["High Contrast"] == true:
		high_contrast.visible = true


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


# Play button is pressed
func _on_button_pressed_play() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


# Options button is pressed
func _on_button_pressed_options() -> void:
	get_tree().change_scene_to_file("res://Scenes/options_screen_scene.tscn")
