extends Node3D

@onready var global = get_node("/root/Global")

@export var building_template : PackedScene
@export var bullet : PackedScene

@export var panel_selected : StyleBoxFlat
@export var panel_unselected : StyleBoxFlat

var buildings : Dictionary = Global.buildings

var buildings_placed : Array = []

var enemies : Array = []

var mouse_motion = Vector2(0, 0)

var enemy_cooldown : bool = false

var run_update_position = null


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


# Moves the selected building to the mouse
func _move_building_to_mouse():
	pass


# Checks if the placement for the current building is valid
func _update_placement_position(placement_position):
	
		run_update_position = null
	
		var original_positon = placement_position
	
		$RayCast3D.position = Vector3(placement_position.x - 0.5, placement_position.y, placement_position.z + 0.5)
		$RayCast3D2.position = Vector3(placement_position.x + 0.5, placement_position.y, placement_position.z + 0.5)
			
		if $RayCast3D.is_colliding():
			var target = $RayCast3D.get_collider().get_parent().position.z + 1
			placement_position = Vector3(placement_position.x, placement_position.y, target)
				
		if $RayCast3D2.is_colliding():
				
			var target = $RayCast3D2.get_collider().get_parent().position.z + 1
				
			if placement_position.z < target:
				placement_position = Vector3(placement_position.x, placement_position.y, target)
		
		if placement_position != original_positon:
			run_update_position = placement_position
			
		return placement_position


# Selects the building that the player has pressed
func _select_building(building_name):
	
	if building_name == null:
		
		global.current_building = null
		
	elif building_name != null:
		
		global.current_building = global.buildings[building_name].scene.instantiate()
	
		global.current_building.position = Vector3(0, -0.5, 0)
	
		add_child(global.current_building)
	
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
	
	new_bullet.position = building.get_node("Area3D/Shoot").global_position
	new_bullet.look_at(enemy.position, Vector3.UP, true)
	
	var tween = get_tree().create_tween()

	tween.tween_property(new_bullet, "position", enemy.position, 0.1)
	
	var direction = building.position - enemy.position
	
	var target_rotation : Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
	
	tween.parallel().tween_property(building.get_node("Area3D"), "rotation", target_rotation, 0.1)
	
	await get_tree().create_timer(0.1).timeout
	
	new_bullet.queue_free()
	
	if building != null:
		building.set_meta("cooldown", false)


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		
		if global.current_building != null:
			
			mouse_motion = event.relative
			
			var mouse_position = get_viewport().get_mouse_position()
			
			var space_state = get_world_3d().direct_space_state
			
			var origin = $Camera3D.project_ray_origin(mouse_position)
			var direction = $Camera3D.project_ray_normal(mouse_position)
			
			var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * $Camera3D.far, 1)
			
			var mouse_position_3D = space_state.intersect_ray(query)
			
			var new_position = Vector3(0, 0, 0)
			
			if mouse_position_3D.has("position"):
				new_position = mouse_position_3D.position
				
				new_position = Vector3(snapped(new_position.x, 0.25), -0.5, snapped(new_position.z, 0.25))
				
			$RayCast3D.add_exception(global.current_building.get_node("Area3D"))
			$RayCast3D2.add_exception(global.current_building.get_node("Area3D"))
			
			new_position = _update_placement_position(new_position)
			
			var distance = global.current_building.position.distance_to(new_position)
			
			var sensitivity = 2 * (1 - (global.current_building.get_node("Area3D/CollisionShape3D").shape.size.y / 2))
			
			var rotation_placement = Vector3(deg_to_rad(mouse_motion.y) * sensitivity, 0,
			 	deg_to_rad(-mouse_motion.x) * sensitivity)
			
			var tween = get_tree().create_tween()
			
			tween.tween_property(global.current_building, "position", new_position, 0.1)
			tween.parallel().tween_property(global.current_building, "rotation", rotation_placement, 0.1)
			
			#global.current_building.position = new_position
			
	elif event is InputEventMouseButton:
		
		if event.button_index == 1:
			if global.current_building != null:
				buildings_placed.append(global.current_building)
				$RayCast3D.remove_exception(global.current_building.get_node("Area3D"))
				$RayCast3D2.remove_exception(global.current_building.get_node("Area3D"))
				_select_building(null)
				
	elif Input.is_key_pressed(KEY_R) and not event.is_echo():
		if global.current_building != null:
			global.current_building.get_node("Area3D").rotation += Vector3(0, deg_to_rad(45), 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_building_catalogue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if global.current_building != null and mouse_motion == Vector2(0, 0):
		
		if run_update_position != null:
			_update_placement_position(run_update_position)
		
		var new_rotation = Vector3(0, 0, 0)
		
		var tween = get_tree().create_tween()
		tween.tween_property(global.current_building, "rotation", new_rotation, 0.1)
	
	for i in buildings_placed:
		
		if global.buildings[i.get_meta("building_name")].has("damage")\
			and i.has_meta("cooldown")\
			and i.get_meta("cooldown") == false:
			
			for i_2 in i.get_node("Area3D2").get_overlapping_areas():
				if i_2.get_parent().has_meta("enemy_name"):
					_shoot(i, i_2.get_parent())
					
		if i.get_meta("health") >= global.buildings[i.get_meta("building_name")].health:
			buildings_placed.erase(i)
			i.queue_free()
	
	if enemy_cooldown == false:
		_spawn_enemy()
	
	for i in enemies:
		
		if i.position == Vector3(0, -0.5, 0)\
			or i.get_meta("damage") >= global.enemies[i.get_meta("enemy_name")].health:
			enemies.erase(i)
			i.queue_free()

	mouse_motion = Vector2(0, 0)
