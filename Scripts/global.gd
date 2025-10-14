extends Node

var current_building : Node3D = null

var cookie_dough : int = 250

var buildings : Dictionary = {
	"House" = {"scene" = load("res://Scenes/house.tscn"), "icon" = "res://Assets/HouseIcon.png", "price" = 50, "health" = 100},
	"Shop" = {"scene" = load("res://Scenes/shop.tscn"), "icon" = "res://Assets/ShopIcon.png", "price" = 100, "health" = 100},
	"Skyscraper" = {"scene" = load("res://Scenes/skyscraper.tscn"), "icon" = "res://Assets/skyscrapericon.png", "price" = 100000, "health" = 100},
	#"Cannon" = {"scene" = load("res://Scenes/cannon.tscn"), "icon" = "res://Assets/HouseIcon.png", "price" = 100, "health" = 100},
	"Tank" = {"scene" = load("res://Scenes/tank.tscn"), "icon" = "res://Assets/TankIcon.png", "price" = 2500, "health" = 400, damage = 75, "cooldown_time" = 2},
	"Machine Gun" = {"scene" = load("res://Scenes/machine_gun.tscn"), "icon" = "res://Assets/MachinegunnerIcon.png", "price" = 250, "health" = 100, "damage" = 10, "cooldown_time" = 0.1},
	"Fighter Jet" = {"scene" = load("res://Scenes/fighter_jet.tscn"), "icon" = "res://Assets/FighterJetIcon.png", "price" = 5000, "health" = 100, "damage" = 50, "cooldown_time" = 0.1}
}

var enemies : Dictionary = {
	"Gummy Worm" = {"scene" = load("res://Scenes/gummy_worm.tscn"), "speed" = 5, "damage" = 10, "health" = 100},
	"Chocolate Monster" = {"scene" = load("res://Scenes/chocolate_monster.tscn"), "speed" = 10, "damage" = 20, "health" = 25},
	"Gummy Bear" = {"scene" = load("res://Scenes/gummy_bear.tscn"), "speed" = 2, "damage" = 40, "health" = 400},
}

var enemy_spawn_positions : Array = [Vector3(-14, -0.5, 13), Vector3(-13, -0.5, 13), Vector3(12, -0.5, 13), Vector3(11, -0.5, 13), Vector3(-0.27, -0.5, 13), Vector3(-1, -0.5, 13)]

var save_buildings : Array = []

var options : Dictionary = {
	"Bullet Effects" = true,
	"Black And White" = false,
	"Bigger Text" = false,
	"High Contrast" = false,
}

var options_back : String = "Main Screen"
