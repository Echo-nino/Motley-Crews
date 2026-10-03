extends Node2D

@export var data: Character
var current_life: int:
	set(value):
		current_life = value



var current_coords: Vector2i = Vector2i(-1, -1)
var cell_distances: Dictionary[Vector2i, int]
var move_distances: Dictionary[Vector2i, int]
var attack_distances: Dictionary[Vector2i, int]

var is_player_one: bool
var is_dead: bool = false
signal death(coords: Vector2i, node: Node2D)



func Instantiate(char_data: Character, char_current_coords: Vector2i):
	data = char_data
	$Sprite2D.texture = data.sprite
	$Sprite2D.scale = data.node_size#testing
	current_life = data.life
	
	current_coords = char_current_coords

func Damage(damage: int, type: damage_type_class.damage_types):
	var extra_damage: int = 0
	for i in data.abilitys:
		if i is ExtraDamage:
			if i.from_type == type:
				extra_damage += i.amount
	var final_damage = damage + extra_damage
	
	current_life -= final_damage
	print_debug(current_life)
	if current_life <= 0:
		death.emit(current_coords, self)
	print_debug(damage_type_class.damage_types.keys()[type])
	
	
