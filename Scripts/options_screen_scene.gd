extends Control

@onready var global = get_node("/root/Global")

@export var options_container : VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in options_container.get_children():
		i.reset_tick()
		

func _on_button_2_pressed_back() -> void:
	if global.options_back == "Main Screen":
		get_tree().change_scene_to_file("res://Scenes/main_screen_scene.tscn")
	elif global.options_back == "Game Screen":
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _on_button_3_pressed_resetdata() -> void:
	pass # Replace with function body.
