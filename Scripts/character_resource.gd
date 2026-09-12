extends Resource
class_name character

@export var name: String
@export var sprite: Texture


@export var life: int
@export var attack: int
@export var move: int
@export var reach: int

@export var movement_type: direction_types

@export_category("Debug")
@export var node_size: Vector2 = Vector2(1, 1)


enum direction_types{
	Normal,
	Diagonal
}
var directions_normal: Array[Vector2i] = [
			Vector2i(0, 1),
			Vector2i(0, -1),
			Vector2i(1, 0),
			Vector2i(-1, 0)
		]
var directions_diagonal: Array[Vector2i] = [
			Vector2i(1, 1),
			Vector2i(1, -1),
			Vector2i(-1, 1),
			Vector2i(-1, -1)
		]
var enum_to_direction: Dictionary = {
	direction_types.Normal: directions_normal,
	direction_types.Diagonal: directions_diagonal,
	}

func CellDistanceFromCoords(current_coords:Vector2i, game_tile_map_layer: TileMapLayer, occupied_cells: Dictionary[Vector2i, Node2D], directions: direction_types) -> Dictionary[Vector2i, int]:
	#IT FreaCKING WORKS!! Also it is Dijkstra's algorithm
	
	
	var dir = enum_to_direction[directions]
		
	#step 1 & 2
	var unvisited_cells: Dictionary[Vector2i, int] = {}
	var all_cells: Dictionary[Vector2i, int] = {}
	
	
	for i in game_tile_map_layer.get_used_cells():
			
		#check if the cell is occupied
		if occupied_cells.has(i):
			continue
		
			
		#Check if it is a wall
		if game_tile_map_layer.get_cell_tile_data(i).get_custom_data("Wall"):
			continue
		
		if i == current_coords:
			unvisited_cells.get_or_add(i, 0)
			continue
		unvisited_cells.get_or_add(i, 999)
	#print_debug(unvisited_cells)
	all_cells.assign(unvisited_cells)
		
	#step 3
	var current_cell = current_coords
	
	while !unvisited_cells.is_empty():#while
		#this is so stupid, but I can't think of any other way to randomly select a value of unvisited_cells
		for i in unvisited_cells:
			current_cell = i
			break

		for i in unvisited_cells:
			if unvisited_cells[i] < unvisited_cells[current_cell]:
				current_cell = i
			
	#step 4
		
		for i in dir:
			if unvisited_cells.has(current_cell+i):
				var new_distance = all_cells[current_cell] + 1
				if new_distance < unvisited_cells[current_cell+i]:
					unvisited_cells[current_cell+i] = new_distance
					all_cells[current_cell+i] = new_distance
	
	#step 5
		unvisited_cells.erase(current_cell)
		#if all_cells[current_cell] != 999:
			#print_debug(current_cell)
			#game_tile_map_layer.set_cell(current_cell, 0, Vector2i(all_cells[current_cell]+2, 1))

		
	#for i in all_cells:
		##print_debug(all_cells)
		#game_tile_map_layer.set_cell(i, 0, Vector2i(all_cells[i]*3+2, 1))
	
	#print_debug(all_cells)
	return all_cells

func MoveDistanceFromCoords(current_coords:Vector2i, game_tile_map_layer: TileMapLayer, occupied_cells: Dictionary[Vector2i, Node2D], directions: direction_types) -> Dictionary[Vector2i, int]:
	var dir = enum_to_direction[directions]
		
	var reachable_cells: Dictionary[Vector2i, int] = {}
	var used_cells = game_tile_map_layer.get_used_cells()
	
	for d in dir:
		
		for i in 8:#8 is the size of the game board(I will not change the size so it should be fine)
			var cell = current_coords+d*i
			
			#check if the tile is on the board
			if !used_cells.has(cell):
				continue
				
			#check if the cell is occupied except by the character being moved
			if occupied_cells.has(cell):
				if cell != current_coords:
					break
			
			#Check if it is a wall
			if game_tile_map_layer.get_cell_tile_data(cell).get_custom_data("Wall"):
				continue
				
			
				
			reachable_cells.get_or_add(cell, i)
		
	return reachable_cells

func PathfindToCoords(current_coords:Vector2i, target_coords: Vector2i, cell_distances: Dictionary[Vector2i, int]) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	
	#IT FreaCKING WORKS!! Also it is Dijkstra's algorithm
	
	#Problem(Finds the path from target back to current_coords, but I move entity from current_coords to target, so the final result is the same but the path is wrongish)
	var temp_target_coords = target_coords
	var movement_directions = enum_to_direction[movement_type]
	
	for j in cell_distances[target_coords]:#for the distance from target_coords
		for dir in movement_directions:#for each direction the entity can move in
			if cell_distances.has(temp_target_coords - dir):#if the coords are reachable
				if cell_distances[temp_target_coords - dir] < cell_distances[temp_target_coords]:#if the next coords is closer then current coord
					temp_target_coords -= dir
					#print_debug("dir: "+str(dir))
					path.append(dir)
					
	#Invert the path(This is stupid)
	var temp_path: Array[Vector2i]
	for i in path.size():
		temp_path.append(path[path.size()-i-1])
	path = temp_path
	
	#print_debug("cell_distances: "+ str(cell_distances))
	#print_debug("Path: "+str(path))
	
	return path

#func TargetCoordsValidMoveTarget(target_coords: Vector2i, entity_to_move: Node2D, all_entity_coords: Dictionary[Node2D, Vector2i]) -> String:
	##Target_coords is a used cell
	#if !entity_to_move.movement_cell_distances.has(target_coords): #Pathfind(entity_to_move.current_tilemap_coords, terrain_tile_map_layer)[target_coords]:
		#return "FAILURE"
	##Target_coords is within range
	#if entity_to_move.movement_cell_distances[target_coords] > entity_to_move.entity_data.move_speed:
		#return "FAILURE"
	##Target_coords Unreachable
	#if entity_to_move.movement_cell_distances[target_coords] >= 999:
		#return "FAUILURE"
	##Target_coords == current Coords
	#if entity_to_move.current_tilemap_coords == target_coords:
		#return "FAILURE"
	##entity already there
	#for i in all_entity_coords:
		#if target_coords == all_entity_coords[i]:
			#return "FAILURE"
	#return "SUCCESS"
	
