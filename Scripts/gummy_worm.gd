extends Node3D

@onready var global = get_node("/root/Global")
@onready var tween = get_tree().create_tween()

var enemy_damage : int = 0

var buildings_hit : Array = []

# Damages enemy
func _damage(damage):
	enemy_damage += damage
	set_meta("damage", enemy_damage)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	look_at(Vector3(0, -0.5, 0), Vector3.UP, true)
	
	tween.tween_property($Area3D.get_parent(), "position", Vector3(0, -0.5, 0), 20 - global.enemies[get_meta("enemy_name")].speed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position != Vector3(0, -0.5, 0):
		look_at(Vector3(0, -0.5, 0), Vector3.UP, true)
		
	for i in $Area3D.get_overlapping_areas():
		if i.name != "Area3D2"\
			and i.get_parent().has_meta("building_name")\
			and i.get_parent() != global.current_building\
			and not buildings_hit.has(i.get_parent()):
			
			buildings_hit.append(i.get_parent())
			
			i.get_parent()._damage(global.enemies[get_meta("enemy_name")].damage)
			tween.pause()
			await get_tree().create_timer(1).timeout
			tween.play()
