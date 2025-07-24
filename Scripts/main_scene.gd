extends Node3D

@onready var global = get_node("/root/Global")

@export var building_template : PackedScene
@export var bullet : PackedScene

@export var panel_selected : StyleBoxFlat
@export var panel_unselected : StyleBoxFlat

var buildings : Dictionary = Global.buildings

var buildings_placed : Array = []

var enemies : Array = []

var enemy_cooldown : bool = false

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
	
	if building_name == null:
		
		current_building = null
		
	elif building_name != null:
		
		current_building = global.buildings[building_name].scene.instantiate()
	
		add_child(current_building)
	
	for i : Control in get_node("Control/ScrollContainer/HBoxContainer").get_children():
		if i.get_meta("building") == building_name:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_selected)
		else:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_unselected)


# Spawns an ememy
func _spawn_enemy():
	
	enemy_cooldown = true
	
	var enemy : Node3D = null
	
	var random : int = randf_range(1, global.enemies.size())
	
	var count = 0
	
	for i in global.enemies:
		count += 1
		if count == random:
			enemy = global.enemies[i].scene.instantiate()
			break
	
	enemies.append(enemy)
	
	var enemy_position = null
	
	random = randf_range(1, global.enemy_spawn_positions.size() + 1)
	
	count = 0
	
	for i in global.enemy_spawn_positions:
		count += 1
		if count == random:
			enemy_position = i
			break
			
	enemy.position = enemy_position
	
	add_child(enemy)
	
	await get_tree().create_timer(1).timeout
	
	enemy_cooldown = false


#Shoots enemy
func _shoot(building, enemy):
	
	building.set_meta("cooldown", true)
	
	enemy._damage(global.buildings[building.get_meta("building_name")].damage)
	
	var new_bullet = bullet.instantiate()
	
	add_child(new_bullet)
	
	new_bullet.position = building.get_node("Shoot").global_position
	new_bullet.look_at(enemy.position, Vector3.UP, true)
	
	var tween = get_tree().create_tween()

	tween.tween_property(new_bullet, "position", enemy.position, 0.1)
	
	var direction = building.position - enemy.position
	
	var target_rotation : Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
	
	tween.parallel().tween_property(building, "rotation", target_rotation, 0.1)
	
	await get_tree().create_timer(0.1).timeout
	
	new_bullet.queue_free()
	

	
	if building != null:
		building.set_meta("cooldown", false)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		
		if current_building != null:
			
			var mouse_position = get_viewport().get_mouse_position()
			
			var space_state = get_world_3d().direct_space_state
			
			var origin = $Camera3D.project_ray_origin(mouse_position)
			var direction = $Camera3D.project_ray_normal(mouse_position)
			
			var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * $Camera3D.far)
			
			var mouse_position_3D = space_state.intersect_ray(query)
			
			var new_position = null
			
			if mouse_position_3D.has("position"):
				new_position = mouse_position_3D.position
			else :
				new_position = Vector3(direction.x * 10, -0.5, -10)
				
			current_building.position = Vector3(snapped(new_position.x, 0.25), -0.5, snapped(new_position.z, 0.25))
			
	elif event is InputEventMouseButton:
		
		if event.button_index == 1:
			if current_building != null:
				buildings_placed.append(current_building)
				_select_building(null)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_building_catalogue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for i in buildings_placed:
		
		if global.buildings[i.get_meta("building_name")].has("damage")\
			and i.has_meta("cooldown")\
			and i.get_meta("cooldown") == false:
			
			for i_2 in i.get_node("Area3D").get_overlapping_areas():
				if i_2.get_parent().has_meta("enemy_name"):
					_shoot(i, i_2.get_parent())
					
		if i.get_meta("health") >= global.buildings[i.get_meta("building_name")].health:
			buildings_placed.erase(i)
			i.queue_free()
	
	if enemy_cooldown == false:
		_spawn_enemy()
	
	for i in enemies:
		
		if i.position == Vector3(0, -0.5, 0) \
			or i.get_meta("damage") >= global.enemies[i.get_meta("enemy_name")].health:
			enemies.erase(i)
			i.queue_free()
