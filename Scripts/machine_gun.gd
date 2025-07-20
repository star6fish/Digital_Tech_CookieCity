extends Node3D

@onready var global = get_node("/root/Global")

var building_damage : int = 0


# Damages the building
func _damage(damage):
	building_damage += damage
	set_meta("health", building_damage)
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
