extends Node3D

@onready var global = get_node("/root/Global")

@export var building_template : PackedScene

var buildings : Dictionary = Global.buildings

func _load_building_catalogue():
	
	$Control.get_node("ScrollContainer").visible = true
	
	for i : String in buildings:
		var building = buildings[i]
		
		var new_building_template : Control = building_template.instantiate()
		
		new_building_template.get_node("Label3").text = i
		new_building_template.get_node("Label4").text = "$ " + str(building.price)
		
		var new_font_size : int = clamp(200 / clamp(i.length(), 12, INF), 2, 20)
		
		new_building_template.get_node("Label3").set("theme_override_font_sizes/font_size", new_font_size)
		
		$Control.get_node("ScrollContainer").get_node("HBoxContainer").add_child(new_building_template)
		
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_building_catalogue()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
