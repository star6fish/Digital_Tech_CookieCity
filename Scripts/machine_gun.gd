extends Node3D

@onready var global = get_node("/root/Global")

@export var explosion_crums : PackedScene

var building_damage : int = 0


# Damages the building
func _damage(damage, target_position):
	building_damage += damage
	set_meta("health", building_damage)
	
	if explosion_crums != null:
		
		var explosion_crum = explosion_crums.instantiate()
		
		explosion_crum.position = (target_position - global_position) + Vector3(0, 0.5, 0)
		
		add_child(explosion_crum)
		
		await get_tree().create_timer(1).timeout
		
		explosion_crum.queue_free()
