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
@export var build_Screen_container : HBoxContainer

const SAVE_PATH : String = "user://save_data"
const SCENE_NAME: String = "Game Screen"
const OPTIONS_PATH : String = "res://Scenes/options_screen_scene.tscn"
const MAIN_SCREEN_PATH : String = "res://Scenes/main_screen_scene.tscn"

var buildings : Dictionary = Global.buildings

var buildings_placed : Array = []
var enemies : Array = []
var ennemy_spawn_saves : Array = []

const SNAP : float = 0.5
const CAMERA_SPEED : float = 0.25
const CAMERA_SPEED_SLOWER : float = CAMERA_SPEED / 4
const BUILDING_SIZE_DEFAULT : float = 0.5
const TWEEN_USER_INTERFACE_SPEED : float = 0.25
const BULLET_SPEED : float = 0.1
const BUILDING_MOVE_EFFECT_SPEED : float = 0.1

const ROTATION_TURN_INCREMENTS : int = 45
const ENEMY_SPAWN_RANGE : int = 25
const BUILDING_MONEY_TAXER : int = 4
const ENEMY_DEFEAT_MONEY : int = 50
const MONEY_COOLDOWN_TIME : int = 5
const GAME_SAVE_COOLDOWN_TIME : int = 5
const ENEMY_COOLDOWN_TIME : int = 2

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
	
	var save = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	global.save_buildings = []
	
	for i in buildings_placed:	
		global.save_buildings.append({type = i.get_meta("building_name"), 
			position = i.position,
			rotation = i.rotation, health = i.get_meta("health")})
	
	var game_save : Dictionary = {cookie_dough = global.cookie_dough,
		buildings = global.save_buildings,
		options = global.options}
	
	save.store_var(game_save)
	
	save.close()
	
	await get_tree().create_timer(GAME_SAVE_COOLDOWN_TIME).timeout
	save_cooldown = false


# Gets the games data
func _get_game_save():
	
	if FileAccess.file_exists(SAVE_PATH):
		var save = FileAccess.open(SAVE_PATH, FileAccess.READ)
		return save.get_var()

	else:
		return null


# Gets the mouse position
func _get_mouse_position():
	
	var mouse_position : Vector2 = get_viewport().get_mouse_position()
	var space_state = get_world_3d().direct_space_state
	
	var origin : Vector3 = $Camera3D.project_ray_origin(mouse_position)
	var direction : Vector3 = $Camera3D.project_ray_normal(mouse_position)
			
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, 
		origin + direction * $Camera3D.far, 1)
	
	var mouse_position_3D : Dictionary = space_state.intersect_ray(query)
			
	var new_position : Vector3 = Vector3(0, 0, 0)
			
	if mouse_position_3D.has("position"):
		new_position = mouse_position_3D.position
		new_position = Vector3(snapped(new_position.x, 0.25),
			-SNAP,
			snapped(new_position.z, 0.25))
				
	return new_position


# Checks if the placement for the current building is valid
func _update_placement_position(placement_position : Vector3, original_mouse_target : Vector3):
	
	var original_position : Vector3 = placement_position
	
	$RayCast3D.position = Vector3(placement_position.x - BUILDING_SIZE_DEFAULT,
	 placement_position.y,
	 placement_position.z + BUILDING_SIZE_DEFAULT)
	
	$RayCast3D2.position = Vector3(placement_position.x + BUILDING_SIZE_DEFAULT,
	 	placement_position.y, 
	 	placement_position.z + BUILDING_SIZE_DEFAULT)
	
	$RayCast3D.force_raycast_update()
	$RayCast3D2.force_raycast_update()
	
	if $RayCast3D.is_colliding():
		var target : float = $RayCast3D.get_collider().get_parent().position.z + 1
		placement_position = Vector3(placement_position.x, placement_position.y, target)
				
	if $RayCast3D2.is_colliding():
				
		var target : float = $RayCast3D2.get_collider().get_parent().position.z + 1
				
		if placement_position.z < target:
			placement_position = Vector3(placement_position.x, placement_position.y, target)
	
	if placement_position != original_position and placement_mouse_target == original_mouse_target: # If the game is still looking for the collision on the current position
		placement_position = await _update_placement_position(
			placement_position,
			original_mouse_target)
		
	return placement_position


# Moves the current building to the mouse
func _move_building_to_mouse_position():
	
	placement_mouse_cooldown = true # Start the cooldown so that there is no overlapping
	
	var new_position : Vector3 = _get_mouse_position()
	
	#if mouse_motion == Vector2(0, 0):# Only push outside buildings if mouse is still so no break the game
	
	var area3D = global.current_building.get_node("Area3D")
	var area3D_2 = null
	
	if global.current_building.has_meta("cooldown"):
		area3D_2 = global.current_building.get_node("Area3D2")
	
	$RayCast3D.add_exception(area3D)
	$RayCast3D2.add_exception(area3D)
	
	if area3D_2 != null:
		$RayCast3D.add_exception(area3D_2)
		$RayCast3D2.add_exception(area3D_2)
	
	new_position = await _update_placement_position(new_position, placement_mouse_target)
	
	placement_mouse_target = new_position
	
	var currrent_building_collision_shape : CollisionShape3D = global.current_building.get_node(
			"Area3D/CollisionShape3D")
	
	var sensitivity : float = 2 * (
		1 - (currrent_building_collision_shape.shape.size.y / 2))
	
	var rotation_placement : Vector3 = Vector3(deg_to_rad(mouse_motion.y) * sensitivity, 0,
		deg_to_rad(-mouse_motion.x) * sensitivity)
	
	var tween : Tween = get_tree().create_tween()
	
	tween.tween_property(global.current_building, "position",
		new_position,
		BUILDING_MOVE_EFFECT_SPEED)
	
	tween.parallel().tween_property(global.current_building, "rotation",
		rotation_placement, 
		BUILDING_MOVE_EFFECT_SPEED)
	
	await get_tree().create_timer(BUILDING_MOVE_EFFECT_SPEED).timeout
	
	if placement_mouse_target == new_position:
		placement_mouse_cooldown = false # When the building is finished tweening stop the cooldown


# Selects the building that the player has pressed
func _select_building(building_name):
	
	var valid : bool = false
	
	if building_name != null and global.cookie_dough >= global.buildings[building_name].price\
		and placement_mouse_cooldown == false:
	
		valid = true
	
	if building_name == null:
		global.current_building = null
		
	if valid == true:
		
		global.current_building = global.buildings[building_name].scene.instantiate()
	
		add_child(global.current_building)
		
		_move_building_to_mouse_position()
	
	for i : Control in build_Screen_container.get_children():
		
		var building_panel : Panel = i.get_node("Panel2")
		
		if i.get_meta("building") == building_name and valid == true:
			building_panel.set("theme_override_styles/panel", panel_selected)
		else:
			building_panel.set("theme_override_styles/panel", panel_unselected)


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
	
	var enemy_position : Vector3 = Vector3(0, 0, 0)
	var valid : bool = false
	
	while valid == false:
		
		valid = true
		
		random = snapped(randf_range(-ENEMY_SPAWN_RANGE, ENEMY_SPAWN_RANGE), SNAP)
		enemy_position = Vector3(random, -SNAP, ENEMY_SPAWN_RANGE)
		
		for i in ennemy_spawn_saves:
			if abs(random - i.x) < SNAP:
				valid = false
			
	ennemy_spawn_saves.append(enemy_position)
			
	enemy.position = enemy_position
	
	add_child(enemy)
	
	await get_tree().create_timer(ENEMY_COOLDOWN_TIME).timeout
	
	enemy_cooldown = false
	
	ennemy_spawn_saves.erase(enemy_position)


#Shoots enemy
func _shoot(building, enemy):
	
	building.set_meta("cooldown", true)
	
	var animation_player : AnimationPlayer = building.get_node("Area3D2/Animated/AnimationPlayer")
	
	var animation_name : String = "Shoot"
	
	animation_player.play(animation_name)
	
	enemy._damage(global.buildings[building.get_meta("building_name")].damage)
	
	var direction : Vector3 = building.position - enemy.position
	
	var target_rotation : Vector3 = Vector3(0, atan2(direction.x, direction.z), 0)
	
	var tween : Tween = get_tree().create_tween()
	
	if building.get_meta("building_name") != "Fighter Jet":
		
		var area3D_2 : Area3D = building.get_node("Area3D2")
		
		tween.tween_property(area3D_2, "rotation", target_rotation, 0.1)
	
	if global.options["Bullet Effects"] == true:
		
		var shoot_node : MeshInstance3D = building.get_node("Area3D2/Shoot")
		
		var bullet_origin : Vector3 = shoot_node.global_position
		
		var new_bullet : Node3D = bullet.instantiate()
		
		add_child(new_bullet)
		
		new_bullet.position = bullet_origin
		new_bullet.look_at(enemy.position, Vector3.UP, true)
		
		tween.parallel().tween_property(new_bullet, "position", enemy.position, BULLET_SPEED)
	
		await get_tree().create_timer(BULLET_SPEED).timeout
	
		new_bullet.queue_free()
	
	if building != null:
		
		var building_name : String = building.get_meta("building_name")
		
		var building_cooldown_time : float = global.buildings[building_name].cooldown_time
		
		var cooldown_time : float = clamp(building_cooldown_time - BULLET_SPEED, 0, INF)
		
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
					
					if global.current_building.position.z < 20:
						
						buildings_placed.append(global.current_building)
						
						var area3D_1 = global.current_building.get_node("Area3D")
						var area3D_2 = null
						
						if global.current_building.has_meta("cooldown"):
							area3D_2 = global.current_building.get_node("Area3D2")
						
						$RayCast3D.remove_exception(area3D_1)
						$RayCast3D2.remove_exception(area3D_1)
						
						if area3D_2 != null:
							$RayCast3D.remove_exception(area3D_2)
							$RayCast3D2.remove_exception(area3D_2)
						
						var current_building_name : String = global.current_building.get_meta(
							"building_name")
						
						global.cookie_dough -= global.buildings[current_building_name].price
						
						_select_building(null)
						
	elif Input.is_key_pressed(KEY_R) and not event.is_echo():
		if global.current_building != null:
			
			var area3D : Area3D = global.current_building.get_node("Area3D")
			
			if global.current_building.has_meta("cooldown"): # If the building is a military building then rotate the second area3D
				area3D = global.current_building.get_node("Area3D2")
		
			area3D.rotation += Vector3(0, deg_to_rad(ROTATION_TURN_INCREMENTS), 0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	global.options_back = SCENE_NAME
	
	if global.options["Black And White"] == true:
		black_and_white.visible = true
		
	if global.options["High Contrast"] == true:
		high_contrast.visible = true

	var game_save : Dictionary = _get_game_save()
	
	for i : Dictionary in game_save.buildings:
		
		var building_name : String = i.type
		var building_health : int = i.health
		var building_position : Vector3 = i.position
	
		var building_rotation : Vector3 = i.rotation
		
		var new_building : Node3D = global.buildings[building_name].scene.instantiate()
		
		add_child(new_building)
		
		new_building.position = building_position
		
		var area3D : Area3D = new_building.get_node("Area3D")
			
		if new_building.has_meta("cooldown"): # If the building is a military building then rotate the second area3D
			area3D = new_building.get_node("Area3D2")
		
		area3D.rotation = building_rotation
		
		new_building.set_meta("health", building_health)
		
		buildings_placed.append(new_building)
	
	global.cookie_dough = game_save.cookie_dough
	
	save_cooldown = false
	
	for i : String in buildings:
		
		var building : Dictionary = buildings[i]
		
		var new_building_template : Control = building_template.instantiate()
		
		new_building_template.set_meta("building", i)
		
		var new_building_template_name_label : Label = new_building_template.get_node("Label3")
		var new_building_template_price_label : Label = new_building_template.get_node("Label4")
		var new_building_template_icon : TextureRect = new_building_template.get_node(
			"TextureRect2")
		
		var new_font_size : int = clamp(200 / clamp(i.length(), 12, INF), 2, 20)
		
		new_building_template_name_label.text = i
		new_building_template_price_label.text = "$ " + str(building.price)
		new_building_template_icon.texture = load(building.icon)
		
		new_building_template_name_label.set("theme_override_font_sizes/font_size", new_font_size)
		
		build_screen_container.add_child(new_building_template)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if global.current_building != null and mouse_motion == Vector2(0, 0):
		
		var new_rotation : Vector3 = Vector3(0, 0, 0)
		
		var tween : Tween = get_tree().create_tween()
		
		tween.tween_property(global.current_building,
			"rotation", new_rotation, 
			BUILDING_MOVE_EFFECT_SPEED)
	
	var forward_direction : Vector3 = camera.transform.basis.z * Vector3(1, 0, 1)
	var side_direction : Vector3 = camera.transform.basis.x
	
	if Input.is_action_pressed("forward"):
		camera.global_position -= forward_direction * CAMERA_SPEED
	elif Input.is_action_pressed("backward"):
		camera.position += forward_direction * CAMERA_SPEED
		
	if Input.is_action_pressed("left"):
		camera.position -= side_direction * CAMERA_SPEED
	elif Input.is_action_pressed("right"):
		camera.position += side_direction * CAMERA_SPEED
	
	if Input.is_key_pressed(KEY_E):
		camera.rotation_degrees += Vector3(0, 1, 0) * CAMERA_SPEED
		camera.position += side_direction * CAMERA_SPEED_SLOWER
	if Input.is_key_pressed(KEY_Q):
		camera.rotation_degrees -= Vector3(0, 1, 0) * CAMERA_SPEED
		camera.position -= side_direction * CAMERA_SPEED_SLOWER
		
	for i in buildings_placed:
		
		if global.buildings[i.get_meta("building_name")].has("damage")\
			and i.has_meta("cooldown")\
			and i.get_meta("cooldown") == false:
			
			for i_2 in i.get_node("Area3D2").get_overlapping_areas():
				
				var parent_node : Node3D = i_2.get_parent()
				
				if parent_node.has_meta("enemy_name"):
					_shoot(i, parent_node)
					break
					
		if i.get_meta("health") >= global.buildings[i.get_meta("building_name")].health:
			buildings_placed.erase(i)
			i.queue_free()
	
	if enemy_cooldown == false:
		_spawn_enemy()
	
	for i in enemies:
		
		var enemy_name : String = i.get_meta("enemy_name")
		
		var enemy_health : int = global.enemies[enemy_name].health
		
		if i.get_meta("damage") >= enemy_health:
			global.cookie_dough += ENEMY_DEFEAT_MONEY
		
		if i.position == Vector3(0, -SNAP, 0)\
			or i.get_meta("damage") >= enemy_health:
			enemies.erase(i)
			i.queue_free()
	
	if money_cooldown == false:
		for i in buildings_placed:
			
			var building_name : String = i.get_meta("building_name")
			
			var building_money : float = (global.buildings[building_name].price 
				/ BUILDING_MONEY_TAXER) + 2000
			
			global.cookie_dough += building_money
		
		money_cooldown = true
		await get_tree().create_timer(MONEY_COOLDOWN_TIME).timeout
		money_cooldown = false
	
	if save_cooldown == false:
		_save_game()
	
	money_label.text = "COOKIE DOUGH: " + str(global.cookie_dough)
	buildings_placed_label.text = "Buildings Placed: " + str(buildings_placed.size())
	
	mouse_motion = Vector2(0, 0)


# Help button is pressed
func _on_button_pressed_help() -> void:
	
	var tween : Tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	
	if help_screen_open == true:
		
		help_screen_open = false
		
		var end_rotation : int = 180
		
		tween.tween_property(help_screen, "scale", Vector2(0, 0), TWEEN_USER_INTERFACE_SPEED)
		tween.parallel().tween_property(help_screen, 
			"rotation_degrees", 
			end_rotation, 
			TWEEN_USER_INTERFACE_SPEED)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, 
				"visible_characters", 
				0,
				TWEEN_USER_INTERFACE_SPEED)
				
	elif help_screen_open == false:
		
		help_screen_open = true
		
		var end_rotation : int = 0
		
		tween.tween_property(help_screen, "scale", Vector2(1, 1), TWEEN_USER_INTERFACE_SPEED)
		
		tween.parallel().tween_property(help_screen, 
			"rotation_degrees", 
			end_rotation, 
			TWEEN_USER_INTERFACE_SPEED)
		
		for i : Label in help_screen_container.get_children():
			i.visible_characters = 0
			tween.parallel().tween_property(i, 
				"visible_characters", 
				i.text.length(), 
				TWEEN_USER_INTERFACE_SPEED)


# Build button is pressed
func _on_button_pressed_build() -> void:
	
	var tween : Tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	
	if build_screen_open == true:
		
		build_screen_open = false
		
		var end_rotation : int = -180
		
		tween.tween_property(build_screen, 
			"position", 
			build_screen_positon_down, 
			TWEEN_USER_INTERFACE_SPEED)
		
		tween.parallel().tween_property(build_screen, 
			"rotation_degrees", 
			end_rotation, 
			TWEEN_USER_INTERFACE_SPEED)
		
	elif build_screen_open == false:
		
		build_screen_open = true
		
		var end_rotation : int = 0
		
		tween.tween_property(build_screen, 
			"position", 
			build_screen_position_up, 
			TWEEN_USER_INTERFACE_SPEED)
			
		tween.parallel().tween_property(build_screen, 
			"rotation_degrees", 
			end_rotation, 
			TWEEN_USER_INTERFACE_SPEED)


func _on_button_pressed_options() -> void:
	get_tree().change_scene_to_file(OPTIONS_PATH)


func _on_button_pressed_main_screen() -> void:
	get_tree().change_scene_to_file(MAIN_SCREEN_PATH)
