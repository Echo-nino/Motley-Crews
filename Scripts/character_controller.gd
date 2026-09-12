extends Node2D

@export var data: character
var current_life: int


var current_coords: Vector2i = Vector2i(-1, -1)
var cell_distances: Dictionary[Vector2i, int]
var move_distances: Dictionary[Vector2i, int]


func Instantiate(char_data: character, char_current_coords: Vector2i):
	data = char_data
	$Sprite2D.texture = data.sprite
	$Sprite2D.scale = data.node_size#testing
	current_life = data.life
	
	current_coords = char_current_coords
