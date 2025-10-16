extends Node3D

@onready var global = get_node("/root/Global")

@export var camera : Camera3D

@export var building_template : PackedScene
@export var bullet : PackedScene
@export var explosion_crums : PackedScene
@export var panel_selected : StyleBoxFlat
@export var panel_unselected : StyleBoxFlat
@export var help_screen : Control
@export var help_screen_container : VBoxContainer
@export var build_screen_container : HBoxContainer
@export var build_screen : ScrollContainer
@export var money_label : Label
@export var buildings_placed_label : Label
@export var time_label : Label
@export var black_and_white : ColorRect
@export var high_contrast : ColorRect

var save_path : String = "user://save_data"
var scene_name: String = "Game Screen"

var buildings : Dictionary = Global.buildings

var buildings_placed : Array = []
var enemies : Array = []
var ennemy_spawn_saves : Array = []

var snap : float = 0.5
var camera_speed : float = 0.25
var camera_speed_slower : float = camera_speed / 4
var building_size_default : float = 0.5
var tween_user_interface_speed : float = 0.25
var bullet_speed : float = 0.1
var building_move_effect_speed : float = 0.1

var rotation_turn : int = 45
var enemy_spawn_range : int = 25
var building_money_taxer : int = 4
var enemy_defeat_money : int = 50
var money_cooldown_time : int = 5
var game_save_cooldown_time : int = 5
var enemy_cooldown_time : int = 2

var placement_mouse_target : Vector3 = Vector3(0, 0, 0)

var mouse_motion : Vector2 = Vector2(0, 0)
var build_screen_position_up : Vector2 = Vector2(26, 447)
var build_screen_positon_down : Vector2 = Vector2(26, 667)

var money_cooldown : bool = false
var enemy_cooldown : bool = false
var save_cooldown : bool = true # Sets to true so that the game does not save the data before the buildings are loaded
var placement_mouse_cooldown : bool = false
var help_screen_open : bool = false
var build_screen_open : bool = false


# Saves the game data
func _save_game():
	
	save_cooldown = true
	
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	
	global.save_buildings = []
	
	for i in buildings_placed:	
		global.save_buildings.append({type = i.get_meta("building_name"), position = i.position, rotation = i.rotation, health = i.get_meta("health")})
	
	var game_save = {cookie_dough = global.cookie_dough, buildings = global.save_buildings, options = global.options}
	
	save.store_var(game_save)
	
	save.close()
	
	await get_tree().create_timer(game_save_cooldown_time).timeout
	save_cooldown = false


# Gets the games data
func _get_game_save():
	
	if FileAccess.file_exists(save_path):
		var save = FileAccess.open(save_path, FileAccess.READ)
		return save.get_var()

	else:
		return null


# Gets the mouse position
func _get_mouse_position():
	
	var mouse_position = get_viewport().get_mouse_position()
	var space_state = get_world_3d().direct_space_state
			
	var origin = $Camera3D.project_ray_origin(mouse_position)
	var direction = $Camera3D.project_ray_normal(mouse_position)
			
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * $Camera3D.far, 1)
	var mouse_position_3D = space_state.intersect_ray(query)
			
	var new_position = Vector3(0, 0, 0)
			
	if mouse_position_3D.has("position"):
		new_position = mouse_position_3D.position
		new_position = Vector3(snapped(new_position.x, 0.25), snap, snapped(new_position.z, 0.25))
				
	return new_position


# Checks if the placement for the current building is valid
func _update_placement_position(placement_position : Vector3):
	
	var original_positon = placement_position
	
	$RayCast3D.position = Vector3(placement_position.x - building_size_default, placement_position.y, placement_position.z + building_size_default)
	$RayCast3D2.position = Vector3(placement_position.x + building_size_default, placement_position.y, placement_position.z + building_size_default)
	
	$RayCast3D.force_raycast_update()
	$RayCast3D2.force_raycast_update()
	
	if $RayCast3D.is_colliding():
		var target = $RayCast3D.get_collider().get_parent().position.z + 1
		placement_position = Vector3(placement_position.x, placement_position.y, target)
				
	if $RayCast3D2.is_colliding():
				
		var target = $RayCast3D2.get_collider().get_parent().position.z + 1
				
		if placement_position.z < target:
			placement_position = Vector3(placement_position.x, placement_position.y, target)
		
	if placement_position != original_positon:
		placement_position = await _update_placement_position(placement_position)
			
	return placement_position


# Moves the current building to the mouse
func _move_building_to_mouse_position():
	
	placement_mouse_cooldown = true # Start the cooldown so that there is no overlapping
	
	var new_position = _get_mouse_position()
	
	$RayCast3D.add_exception(global.current_building.get_node("Area3D"))
	$RayCast3D2.add_exception(global.current_building.get_node("Area3D"))
	
	if global.current_building.get_node("Area3D2"):
		$RayCast3D.add_exception(global.current_building.get_node("Area3D2"))
		$RayCast3D2.add_exception(global.current_building.get_node("Area3D2"))
	
	new_position = await _update_placement_position(new_position)
	
	placement_mouse_target = new_position
	
	var sensitivity = 2 * (1 - (global.current_building.get_node("Area3D/CollisionShape3D").shape.size.y / 2))
	var rotation_placement = Vector3(deg_to_rad(mouse_motion.y) * sensitivity, 0,
	deg_to_rad(-mouse_motion.x) * sensitivity)
	
	var tween = get_tree().create_tween()
	
	tween.tween_property(global.current_building, "position", new_position, building_move_effect_speed)
	tween.parallel().tween_property(global.current_building, "rotation", rotation_placement, building_move_effect_speed)
	
	await get_tree().create_timer(building_move_effect_speed).timeout
	
	if placement_mouse_target == new_position:
		placement_mouse_cooldown = false # When the building is finished tweening stop the cooldown


# Selects the building that the player has pressed
func _select_building(building_name):
	
	var valid = false
	
	if building_name != null and global.cookie_dough >= global.buildings[building_name].price and placement_mouse_cooldown == false:
		valid = true
	
	if building_name == null:
		global.current_building = null
		
	if valid == true:
		
		global.current_building = global.buildings[building_name].scene.instantiate()
	
		add_child(global.current_building)
		
		_move_building_to_mouse_position()
	
	for i : Control in get_node("Control/ScrollContainer/HBoxContainer").get_children():
		if i.get_meta("building") == building_name and valid == true:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_selected)
		else:
			i.get_node("Panel2").set("theme_override_styles/panel", panel_unselected)


# Spawns an ememy
func _spawn_enemy():
	
	enemy_cooldown = true
	
	var enemy : Node3D = null
	
	var random : int = randi_range(1, global.enemies.size())
	
	var count : int = 0
	
	for i in global.enemies:
		count += 1
		if count == random:
			enemy = global.enemies[i].scene.instantiate()
			break
	
	enemies.append(enemy)
	
	var enemy_position = null
	var valid = false
	
	while valid == false:
		
		valid = true
		
		random = snapped(randf_range(-enemy_spawn_range, enemy_spawn_range), snap)
		enemy_position = Vector3(random, snap, enemy_spawn_range)
		
		for i in ennemy_spawn_saves:
			if abs(random - i.x) < snap:
				valid = false
			
	ennemy_spawn_saves.append(enemy_position)
			
	enemy.position = enemy_position
	
	add_child(enemy)
	
	await get_tree().create_timer(enemy_cooldown_time).timeout
	
	enemy_cooldown = false
	
	ennemy_spawn_saves.erase(enemy_position)


#Shoots enemy
func _shoot(building, enemy):
	
	building.set_meta("cooldown", true)
	
	building.get_node("Area3D2/Animated/AnimationPlayer").play("Shoot")
	
	enemy._damage(global.buildings[building.get_meta("building_name")].damage)
	
	var direction = building.position - enemy.position
	
	var target_rotation : Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
	
	var tween = get_tree().create_tween()
	
	if building.get_meta("building_name") != "Fighter Jet":
		tween.tween_property(building.get_node("Area3D2"), "rotation", target_rotation, 0.1)
	
	if global.options["Bullet Effects"] == true:
	
		var new_bullet = bullet.instantiate()
	
		add_child(new_bullet)
		
		new_bullet.position = building.get_node("Area3D2/Shoot").global_position
		new_bullet.look_at(enemy.position, Vector3.UP, true)
		
		tween.parallel().tween_property(new_bullet, "position", enemy.position, bullet_speed)
	
		await get_tree().create_timer(bullet_speed).timeout
	
		new_bullet.queue_free()
	
	if building != null:
		
		var building_cooldown_time = global.buildings[building.get_meta("building_name")].cooldown_time
				
		var cooldown_time = clamp(building_cooldown_time - bullet_speed, 0, INF)
		
		await get_tree().create_timer(cooldown_time).timeout
		
		if building != null:
			building.set_meta("cooldown", false)


# Detects when the player presses a key or clicks or moves their mouse
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
	
		if global.current_building != null:
			
			mouse_motion = event.relative
			_move_building_to_mouse_position()
			
	elif event is InputEventMouseButton:
		
		if event.button_index == 1:
			if global.current_building != null:
				if placement_mouse_cooldown == false: # Making sure that the building is not moving
					
					var area3D_1 = global.current_building.get_node("Area3D")
					var area3D_2 = global.current_building.get_node("Area3D2")
					
					buildings_placed.append(global.current_building)
					$RayCast3D.remove_exception(area3D_1)
					$RayCast3D2.remove_exception(area3D_1)
					
					if area3D_2 != null:
						$RayCast3D.remove_exception(area3D_2)
						$RayCast3D2.remove_exception(area3D_2)
					
					global.cookie_dough -= global.buildings[global.current_building.get_meta("building_name")].price
					_select_building(null)
				
	elif Input.is_key_pressed(KEY_R) and not event.is_echo():
		if global.current_building != null:
			
			var area3D = global.current_building.get_node("Area3D")
			
			area3D.rotation += Vector3(0, deg_to_rad(rotation_turn), 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	global.options_back = scene_name
	
	if global.options["Black And White"] == true:
		black_and_white.visible = true
		
	if global.options["High Contrast"] == true:
		high_contrast.visible = true

	var game_save = _get_game_save()
	
	for i in game_save.buildings:
		
		var building_name = i.type
		var building_health = i.health
		var building_position = i.position
		var building_rotation = i.rotation
		
		var new_building = global.buildings[building_name].scene.instantiate()
		
		add_child(new_building)
		
		new_building.position = building_position
		new_building.rotation = building_rotation
		new_building.set_meta("health", building_health)
		
		buildings_placed.append(new_building)
	
	global.cookie_dough = game_save.cookie_dough
	
	save_cooldown = false
	
	for i : String in buildings:
		
		var building = buildings[i]
		
		var new_building_template : Control = building_template.instantiate()
		
		new_building_template.set_meta("building", i)
		
		var new_building_template_name_label = new_building_template.get_node("Label3")
		var new_building_template_price_label = new_building_template.get_node("Label4")
		var new_building_template_icon = new_building_template.get_node("TextureRect2")
		
		var new_font_size : int = clamp(200 / clamp(i.length(), 12, INF), 2, 20)
		
		new_building_template_name_label.text = i
		new_building_template_price_label.text = "$ " + str(building.price)
		new_building_template_icon.texture = load(building.icon)
		
		new_building_template_name_label.set("theme_override_font_sizes/font_size", new_font_size)

		build_screen_container.add_child(new_building_template)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if global.current_building != null and mouse_motion == Vector2(0, 0):
		
		var new_rotation = Vector3(0, 0, 0)
		
		var tween = get_tree().create_tween()
		tween.tween_property(global.current_building, "rotation", new_rotation, building_move_effect_speed)
		
	var forward_direction : Vector3 = camera.transform.basis.z * Vector3(1, 0, 1)
	var side_direction : Vector3 = camera.transform.basis.x
	
	if Input.is_action_pressed("forward"):
		camera.global_position -= forward_direction * camera_speed
	elif Input.is_action_pressed("backward"):
		camera.position += forward_direction * camera_speed
		
	if Input.is_key_pressed(KEY_A):
		camera.position -= side_direction * camera_speed
	elif Input.is_key_pressed(KEY_D):
		camera.position += side_direction * camera_speed
	
	if Input.is_key_pressed(KEY_E):
		camera.rotation_degrees += Vector3(0, 1, 0) * camera_speed
		camera.position += side_direction * camera_speed_slower
	if Input.is_key_pressed(KEY_Q):
		camera.rotation_degrees -= Vector3(0, 1, 0) * camera_speed
		camera.position -= side_direction * camera_speed_slower
		
	for i in buildings_placed:
		
		if global.buildings[i.get_meta("building_name")].has("damage")\
			and i.has_meta("cooldown")\
			and i.get_meta("cooldown") == false:
			
			for i_2 in i.get_node("Area3D2").get_overlapping_areas():
				
				var parent_node : Node3D = i_2.get_parent()
				
				if parent_node.has_meta("enemy_name"):
					_shoot(i, parent_node)
					
		if i.get_meta("health") >= global.buildings[i.get_meta("building_name")].health:
			buildings_placed.erase(i)
			i.queue_free()
	
	if enemy_cooldown == false:
		_spawn_enemy()
	
	for i in enemies:
		
		var enemy_name = i.get_meta("enemy_name")
		
		var enemy_health = global.enemies[enemy_name].health
		
		if i.get_meta("damage") >= enemy_health:
			global.cookie_dough += enemy_defeat_money
		
		if i.position == Vector3(0, snap, 0)\
			or i.get_meta("damage") >= enemy_health:
			enemies.erase(i)
			i.queue_free()

	if money_cooldown == false:
		for i in buildings_placed:
			
			var building_name = i.get_meta("building_name")
			
			var building_money = global.buildings[building_name].price / building_money_taxer
			
			global.cookie_dough += building_money
		
		money_cooldown = true
		await get_tree().create_timer(money_cooldown_time).timeout
		money_cooldown = false

	if save_cooldown == false:
		_save_game()

	money_label.text = "COOKIE DOUGH: " + str(global.cookie_dough)
	buildings_placed_label.text = "Buildings Placed: " + str(buildings_placed.size())

	mouse_motion = Vector2(0, 0)


# Help button is pressed
func _on_button_pressed_help() -> void:
	
	var tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	
	if help_screen_open == true:
		
		help_screen_open = false
		
		tween.tween_property(help_screen, "scale", Vector2(0, 0), tween_user_interface_speed)
		tween.parallel().tween_property(help_screen, "rotation_degrees", 180, tween_user_interface_speed)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, "visible_characters", 0, tween_user_interface_speed)
		
	elif help_screen_open == false:
		
		help_screen_open = true
		
		tween.tween_property(help_screen, "scale", Vector2(1, 1), tween_user_interface_speed)
		tween.parallel().tween_property(help_screen, "rotation_degrees", 0, tween_user_interface_speed)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, "visible_characters", i.text.length(), tween_user_interface_speed)
			

# Build button is pressed
func _on_button_pressed_build() -> void:
	
	var tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	
	if build_screen_open == true:
		
		build_screen_open = false
		
		tween.tween_property(build_screen, "position", build_screen_positon_down, tween_user_interface_speed)
		tween.parallel().tween_property(build_screen, "rotation_degrees", -180, tween_user_interface_speed)
		
	elif build_screen_open== false:
		
		build_screen_open = true
		
		tween.tween_property(build_screen, "position", build_screen_position_up, tween_user_interface_speed)
		tween.parallel().tween_property(build_screen, "rotation_degrees", 0,tween_user_interface_speed)


func _on_button_pressed_options() -> void:
	get_tree().change_scene_to_file("res://Scenes/options_screen_scene.tscn")


func _on_button_pressed_main_screen() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_screen_scene.tscn")
