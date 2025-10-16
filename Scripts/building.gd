extends Node3D

@onready var global = get_node("/root/Global")

@export var explosion_crumbs : PackedScene

var snap : float = 0.5

var building_damage : int = 0
var crumb_time : int = 1


# Damages the building
func _damage(damage, target_position):
	
	building_damage += damage
	set_meta("health", building_damage)
	
	if explosion_crumbs != null:
		
		var explosion_crumb = explosion_crumbs.instantiate()
		
		var crumb_position : Vector3 = (target_position - global_position) + Vector3(0, snap, 0)
		
		explosion_crumb.position = crumb_position
		
		add_child(explosion_crumb)
		
		await get_tree().create_timer(crumb_time).timeout
		
		explosion_crumb.queue_free()
