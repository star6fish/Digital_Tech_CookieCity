extends Node3D

@onready var global = get_node("/root/Global")

@export var building_template : PackedScene

@export var panel_selected : StyleBoxFlat
@export var panel_unselected : StyleBoxFlat

var buildings : Dictionary = Global.buildings

var current_building : Node3D = null

# Loads the building catalogue on the screen
func _load_building_catalogue():
	
	$Control.get_node("ScrollContainer").visible = true
	
	for i : String in buildings:
		var building = buildings[i]
		
		var new_building_template : Control = building_template.instantiate()
		
		new_building_template.set_meta("building", i)
		
		new_building_template.get_node("Label3").text = i
		new_building_template.get_node("Label4").text = "$ " + str(building.price)
		
		var new_font_size : int = clamp(200 / clamp(i.length(), 12, INF), 2, 20)
		
		new_building_template.get_node("Label3").set("theme_override_font_sizes/font_size", new_font_size)
		
		get_node("Control/ScrollContainer/HBoxContainer").add_child(new_building_template)
		
		
# Selects the building that the player has pressed
func _select_building(building_name):
	
	current_building = global.buildings[building_name].scene.instantiate()
	
	add_child(current_building)
	
	current_building.position = Vector3(-0.188, 0, -3.622)
	
	for i : Control in get_node("Control/ScrollContainer/HBoxContainer").get_children():
		if i.get_meta("building") == building_name:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_selected)
		else:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_unselected)
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_building_catalogue()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if current_building != null:
		var mouse_position = get_viewport().get_mouse_position()
		
		var space_state = get_world_3d().direct_space_state
		
		var origin = $Camera3D.project_ray_origin(mouse_position)
		var direction = $Camera3D.project_ray_normal(mouse_position)
		
		var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 20000)
		query.collide_with_areas = true
		var mouse_position3D = space_state.intersect_ray(query)
		print(mouse_position3D)
		
		#current_building.position = mouse_position3D
