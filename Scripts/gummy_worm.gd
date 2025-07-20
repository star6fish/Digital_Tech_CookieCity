extends Node3D

@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	look_at(Vector3(0, -0.5, 0), Vector3.UP, true)
	
	var tween = get_tree().create_tween()
	
	tween.tween_property($Area3D.get_parent(), "position", Vector3(0, -0.5, 0), 20 - global.enemies[get_meta("enemy_name")].speed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position != Vector3(0, -0.5, 0):
		look_at(Vector3(0, -0.5, 0), Vector3.UP, true)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().has_meta("building_name"):
		area.get_parent()._damage(global.enemies[get_meta("enemy_name")].damage)
