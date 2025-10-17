extends Control

@onready var global = get_node("/root/Global")

@export var main_scene : PackedScene

@export var black_and_white : ColorRect
@export var high_contrast : ColorRect

const SAVE_PATH : String = "user://save_data"
const MAIN_SCREEN_PATH : String = "res://Scenes/main_screen_scene.tscn"
const GAME_PATH : String = "res://Scenes/main_scene.tscn"


# Saves the game data
func _save_game():
	
	var save = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var game_save : Dictionary = {cookie_dough = global.cookie_dough, 
		buildings = global.save_buildings, 
		options = global.options}
	
	save.store_var(game_save)
	
	save.close()


# Resets the games data amd resets the game as well
func _reset_game_save():
	
	global.cookie_dough = global.default_cookie_dough
	
	var save = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var game_save : Dictionary = {cookie_dough = global.cookie_dough, buildings = [], options = global.options}
	
	save.store_var(game_save)
	
	save.close()


# Updates the global options and saves the game data
func _toggle_setting(option, toggle):
	
	global.options[option] = toggle
	
	if option == "Black And White":
		black_and_white.visible = toggle
	elif option == "High Contrast":
		high_contrast.visible = toggle
	
	_save_game()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in get_children():
		if i.has_meta("option"):
			i._reset_tick()
	
	if global.options["Black And White"] == true:
		black_and_white.visible = true
		
	if global.options["High Contrast"] == true:
		high_contrast.visible = true


# Back button is pressed
func _on_button_2_pressed_back() -> void:
	if global.options_back == "Main Screen":
		get_tree().change_scene_to_file(MAIN_SCREEN_PATH)
	elif global.options_back == "Game Screen":
		get_tree().change_scene_to_file(GAME_PATH)


# Reset data button is pressed
func _on_button_3_pressed_resetdata() -> void:
	_reset_game_save()
