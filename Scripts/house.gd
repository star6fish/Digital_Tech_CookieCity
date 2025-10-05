extends Node3D

@onready var global = get_node("/root/Global")

@export var explosion_crums : PackedScene

var building_damage : int = 0


# Damages the building
func _damage(damage, position):
	building_damage += damage
	set_meta("health", building_damage)
	
	var explosion_crum = explosion_crums.instantiate()
	
	explosion_crum.position = position + Vector3(0, 0.5, 0)
	
	get_parent().add_child(explosion_crum)
	
	await get_tree().create_timer(1).timeout
	
	explosion_crum.queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
