extends Node3D

@onready var global = get_node("/root/Global")

var building_damage = 0


# Damages the building
func _damage(damage):
	
	building_damage += damage
	
	if building_damage >= global.buildings[get_meta("building_name")].health:
		queue_free()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
