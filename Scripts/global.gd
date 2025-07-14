extends Node

var cookie_dough : int = 0

var buildings : Dictionary = {
	"House" = {"scene" = "res://Scenes/house.tscn", "price" = 50},
	"Shop" = {"scene" = "res://Scenes/shop.tscn", "price" = 100},
	"Skyscraper" = {"scene" = get_node("res://Scenes/skyscraper.tscn"), "price" = 100000},
	"Cannon" = {"scene" = get_node("res://Scenes/cannon.tscn"), "price" = 100},
	"Tank" = {"scene" = get_node("res://Scenes/tank.tscn"), "price" = 250},
	"Machine Gun" = {"scene" = get_node("res://Scenes/machine_gun.tscn"), "price" = 250},
	"Fighter Jet" = {"scene" = get_node("res://Scenes/fighter_jet.tscn"), "price" = 5000}
}
