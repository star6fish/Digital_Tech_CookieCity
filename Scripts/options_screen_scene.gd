extends Control

@onready var global = get_node("/root/Global")

@export var options_container : VBoxContainer

@export var main_scene : PackedScene

var save_path = "user://save_data"


# Saves the game data
func _save_game():
	
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	
	var game_save = {cookie_dough = global.cookie_dough, buildings = global.save_buildings, options = global.options}
	
	save.store_var(game_save)
	
	save.close()


# Resets the games data amd resets the game as well
func _reset_game_save():
	
	global.cookie_dough = 250
	
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	
	var game_save = {cookie_dough = 250, buildings = []}
	
	save.store_var(game_save)
	
	save.close()


func _setting(option, toggle):
	
	global.options[option] = toggle
	
	if option == "Black And White":
		get_node("BlackAndWhite").visible = toggle
	elif option == "High Contrast":
		get_node("HighContrast").visible = toggle
	
	_save_game()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in get_children():
		if i.has_meta("option"):
			i._reset_tick()
	
	if global.options["Black And White"] == true:
		get_node("BlackAndWhite").visible = true
	
	if global.options["High Contrast"] == true:
		get_node("HighContrast").visible = true


func _on_button_2_pressed_back() -> void:
	if global.options_back == "Main Screen":
		get_tree().change_scene_to_file("res://Scenes/main_screen_scene.tscn")
	elif global.options_back == "Game Screen":
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _on_button_3_pressed_resetdata() -> void:
	_reset_game_save()
