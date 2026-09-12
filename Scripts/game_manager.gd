extends Node2D

enum game_states{
	placing_characters,
	selecting_character,
	choosing_actions,
	performing_actions,
	changing_turns
}
var game_state: game_states = game_states.selecting_character

var is_white_turn: bool = true

var has_piece_moved:bool = false
var has_piece_actioned: bool = false:
	set(value):
		if value == true:
			has_piece_moved = true

@export var starting_characters: Dictionary[Vector2i, character]
@export var character_node: PackedScene

@export var game_board: TileMapLayer

@onready var all_entitys: Dictionary[Vector2i, Node2D]

var occupied_cells: Dictionary[Vector2i, Node2D]:
	get:
		return all_entitys




var current_target_entity: Node2D = null

var current_target_coords: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	InstantiateStartingCharacters()

func InstantiateStartingCharacters():
	for i in starting_characters:
		var a = character_node.instantiate()
		add_child(a)
		a.position = game_board.map_to_local(i)
		a.Instantiate(starting_characters[i], i)
		all_entitys.get_or_add(i, a)

func ChangeTurn():
	has_piece_actioned = false
	has_piece_moved = false
	
	is_white_turn = !is_white_turn
	game_state = game_states.choosing_actions
	

func _process(delta: float) -> void:
	GameInput(GetTargetCoords())
	
		
func GameInput(target_coords: Vector2i):
	if current_target_coords != target_coords:
		current_target_coords = target_coords
		#print_debug(current_target_coords)
		
	#HighLightBasedOnCoords(target_coords)
	
	if Input.is_action_just_pressed("Primary Input"):
		if game_state == game_states.selecting_character:
			var selected = AttemptSelectEntityAtCoords(target_coords)
			print_debug(selected)
			if selected == "SUCCESS":
				
				#current_target_entity.attack_cell_distances = current_target_entity.entity_data.CellDistanceFromCoords(current_target_entity.current_coords, terrain_tile_map_layer, empty_array)
				
				#distance of all cells
				var cell_distances = current_target_entity.data.CellDistanceFromCoords(current_target_entity.current_coords, game_board, occupied_cells, current_target_entity.data.movement_type)
				var move_distances = current_target_entity.data.MoveDistanceFromCoords(current_target_entity.current_coords, game_board, occupied_cells, current_target_entity.data.movement_type)
				
				current_target_entity.cell_distances = cell_distances
				current_target_entity.move_distances = move_distances
				#distance of all cells with attackable entitys
				#var all_attackable_cells = current_target_entity.entity_data.CellDistanceFromCoords(current_target_entity.current_coords, game_board, empty_array, current_target_entity.data.attack_type)
				#var cells_with_attackable_entitys: Dictionary[Vector2i, int]
				#for i in all_attackable_cells :
					#for j in all_entitys:
						#if i == j:
							#cells_with_attackable_entitys.get_or_add(i, all_attackable_cells[i])
				#current_target_entity.attack_cell_distances = cells_with_attackable_entitys
				
				#distance of all cells able to be moved to
				#var cells_to_avoid: Array[Vector2i] = all_entitys.keys()
				#current_target_entity.movement_cell_distances = current_target_entity.entity_data.CellDistanceFromCoords(current_target_entity.current_coords, game_board, cells_to_avoid, current_target_entity.entity_data.movement_type)
				#
				
				game_state = game_states.choosing_actions
				
		elif game_state == game_states.choosing_actions:
			var action_results: String = "FAILURE"
			
			
					
			
			##ATTACK!
			#if action_results == "FAILURE":
				#action_results = AttemptAttackEntityAtCoords(current_target_entity, target_coords)
			if action_results == "FAILURE":
				action_results = AttemptMoveEntityToCoords(current_target_entity, target_coords)
				
			#if using an action on the character using the action
			if action_results == "FAILURE":
				if current_target_entity.current_coords == target_coords:
					game_state = game_states.selecting_character
					action_results = "SUCCESS"
					print_debug("current_target_coords: "+str(current_target_entity.current_coords))
					
			if action_results == "SUCCESS":
				game_state = game_states.selecting_character
				
			print_debug(action_results)
	
func UpdateEntityCoords(entity: Node2D, new_coords: Vector2i):
	var old_coords = entity.current_coords
	if old_coords != Vector2i(-1, -1):
		all_entitys.erase(old_coords)
	all_entitys.get_or_add(new_coords, entity)
	
	entity.current_coords = new_coords
	entity.cell_distances.clear()
	
	print_debug("move: "+entity.data.name+" to: "+str(new_coords))

func AttemptMoveEntityToCoords(entity: Node2D, target_coords: Vector2i) -> String:
	##if coord are not on terrain
	#if AreCoordsOnTerrain(target_coords) == "FAILURE":
		#return "FAILURE"
	#if target_coords has an entity
	print_debug(target_coords)
	
	if all_entitys.has(target_coords):
		return "FAILURE"
		
	if !entity.move_distances.has(target_coords):
		return "FAILURE"
	#get path
	#var cells_to_avoid: Array[Vector2i] = all_entitys.keys()
	#var cell_distances_movement = entity.entity_data.CellDistanceFromCoords(entity.current_coords, terrain_tile_map_layer, cells_to_avoid)
	var path = entity.data.PathfindToCoords(entity.current_coords, target_coords, entity.move_distances)
	#target_coords too far away
	if path.size() > entity.data.move:
		return "FAILURE"
	
	#No path to target
	if path.size() == 0:
		return "FAILURE"
	
	MoveEntityToCoords(entity, path)
	return "SUCCESS"
	
func MoveEntityToCoords(entity: Node2D, path: Array[Vector2i]):
	
	#var path = entity.entity_data.PathfindToCoords(entity.current_coords, target_coords, entity.cell_distances)
	#print_debug("cell_distances: "+str(entity.cell_distances))
	#print_debug("path: "+str(path))
	var current_entity_coords = entity.current_coords
	var target_entity_coords = current_entity_coords
	for cell in path:
		target_entity_coords += cell
	
	UpdateEntityCoords(entity, target_entity_coords)
	
	
	var next_cell_coords = current_entity_coords
	for cell in path:
		
		var current_cell_coords = next_cell_coords
		#entity.position = terrain_tile_map_layer.map_to_local(temp_current_entity_coords+cell)
		next_cell_coords += cell
		
		#var target_coords_x = Vector2i(target_entity_coords.x, premove_entity_coords.y)
		var target_coords = Vector2i(next_cell_coords.x, next_cell_coords.y)
		
		#var target_pos_x = terrain_tile_map_layer.map_to_local(target_coords_x)
		var target_pos = game_board.map_to_local(target_coords)
		
		#var target_pos_x_distance = (premove_entity_coords-target_coords_x).length()
		var target_pos_distance = (current_cell_coords-target_coords).length()
		
		#print_debug(target_pos_x_distance)
		print_debug(target_pos_distance)
		
		var tween = get_tree().create_tween()
		
		#tween.tween_property(entity, "position", target_pos_x, 0.1*target_pos_x_distance)
		await tween.tween_property(entity, "position", target_pos, 0.3*target_pos_distance).finished
		
func AreCoordsValidEntityCoords(target_coords: Vector2i) -> String:
	if AreCoordsOnTerrain(target_coords) == "FAILURE":
		return "FAILURE"
	if game_board.get_cell_tile_data(target_coords).get_custom_data("Wall"):
		return "FAILURE"
	return "SUCCESS"
					
func AreCoordsOnTerrain(target_coords: Vector2i) -> String:
	var cells = game_board.get_used_cells()
	#print_debug("cells: "+str(cells))
	#print_debug("target_coords: "+str(target_coords))
	for i in cells:
		if target_coords == i:
			#print_debug(i)
			return "SUCCESS"
	return "FAILURE"
#return coords of the mouse on terrain
func GetTargetCoords() -> Vector2i:
	var mouse_position = get_global_mouse_position()
	var local_mouse_pos = game_board.to_local(mouse_position)
	var target_coords = game_board.local_to_map(local_mouse_pos)
	
	#Check if target_coords is a valid coord on terrain
	var result = AreCoordsOnTerrain(target_coords)
	if result == "SUCCESS":
		return target_coords
	#Vector2i(-1, -1) represents null
	return Vector2i(-1, -1)
		

func AttemptSelectEntityAtCoords(target_coords: Vector2i) -> String:
	for i in all_entitys:
		if target_coords == i:
				
				current_target_entity = all_entitys[i]
				return "SUCCESS"
	return "FAILURE"
	
