extends Node

var current_building : Node3D = null

var cookie_dough : int = 250

var buildings : Dictionary = {
	"House" = {"scene" = load("res://Scenes/house.tscn"), "price" = 50, "health" = 100},
	"Shop" = {"scene" = load("res://Scenes/shop.tscn"), "price" = 100, "health" = 100},
	"Skyscraper" = {"scene" = load("res://Scenes/skyscraper.tscn"), "price" = 100000, "health" = 100},
	#"Cannon" = {"scene" = load("res://Scenes/cannon.tscn"), "price" = 100, "health" = 100},
	#"Tank" = {"scene" = load("res://Scenes/tank.tscn"), "price" = 250, "health" = 100},
	"Machine Gun" = {"scene" = load("res://Scenes/machine_gun.tscn"), "price" = 250, "health" = 100, "damage" = 10},
	#"Fighter Jet" = {"scene" = load("res://Scenes/fighter_jet.tscn"), "price" = 5000, "health" = 100}
}

var enemies : Dictionary = {
	"Gummy Worm" = {"scene" = load("res://Scenes/gummy_worm.tscn"), "speed" = 10, "damage" = 10, "health" = 100}
}

var enemy_spawn_positions : Array = [Vector3(-14, -0.5, 13), Vector3(-13, -0.5, 13), Vector3(12, -0.5, 13), Vector3(11, -0.5, 13), Vector3(-0.27, -0.5, 13), Vector3(-1, -0.5, 13)]
