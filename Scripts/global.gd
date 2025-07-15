extends Node

var cookie_dough : int = 0

var buildings : Dictionary = {
	"House" = {"scene" = load("res://Scenes/house.tscn"), "price" = 50},
	"Shop" = {"scene" = load("res://Scenes/shop.tscn"), "price" = 100},
	"Skyscraper" = {"scene" = load("res://Scenes/skyscraper.tscn"), "price" = 100000},
	"Cannon" = {"scene" = load("res://Scenes/cannon.tscn"), "price" = 100},
	"Tank" = {"scene" = load("res://Scenes/tank.tscn"), "price" = 250},
	"Machine Gun" = {"scene" = load("res://Scenes/machine_gun.tscn"), "price" = 250},
	"Fighter Jet" = {"scene" = load("res://Scenes/fighter_jet.tscn"), "price" = 5000}
}
