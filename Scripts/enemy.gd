extends Node3D

@onready var global = get_node("/root/Global")
@onready var animation_player : AnimationPlayer = get_node("Animated/AnimationPlayer")

@onready var tween : Tween = get_tree().create_tween()

var animation_name : String = "ArmatureAction"

var buildings_hit : Array = []

var end_position : Vector3 = Vector3(0, -0.5, 0)

var enemy_damage : int = 0
var eating_time : int = 1


# Damages enemy
func _damage(damage):
	
	enemy_damage += damage
	set_meta("damage", enemy_damage)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var enemy_name : String = get_meta("enemy_name")
	var enemy_speed : int = global.enemies[enemy_name].speed
	
	look_at(Vector3(0, -0.5, 0), Vector3.UP, true)
	
	tween.tween_property($Area3D.get_parent(), "position", end_position, 20 - enemy_speed)
	
	animation_player.play(animation_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	for i in $Area3D.get_overlapping_areas():
		
		if i != null \
			and i.name != "Area3D2"\
			and i.get_parent().has_meta("building_name")\
			and i.get_parent() != global.current_building\
			and not buildings_hit.has(i.get_parent()):
			
			var building_node : Node3D = i.get_parent()
			
			buildings_hit.append(building_node)
			
			var enemy_name : String = get_meta("enemy_name")
			var enemy_attack_damage : int = global.enemies[enemy_name].damage
			
			building_node._damage(enemy_attack_damage, position)
			tween.pause()
			
			animation_player.pause()
			
			await get_tree().create_timer(eating_time).timeout
			tween.play()
			
			animation_player.play(animation_name)
