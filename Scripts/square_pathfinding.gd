extends Character
class_name SquarePathfinding

func MoveDistanceFromCoords(current_coords:Vector2i, game_tile_map_layer: TileMapLayer, occupied_cells: Dictionary[Vector2i, Node2D], directions: direction_types) -> Dictionary[Vector2i, int]:
	var dir = enum_to_direction[directions]
		
	var reachable_cells: Dictionary[Vector2i, int] = {current_coords: 0}
	var scanned_cells: Dictionary[Vector2i, int] = {}
	var cells_to_scan: Dictionary[Vector2i, int] = {current_coords: 0}
	var cells_to_scan_next: Dictionary[Vector2i, int] = {}
	var used_cells = game_tile_map_layer.get_used_cells()
	
	for m in move:
		for i in cells_to_scan:
			for d in dir:
				
				#Conditions
				if scanned_cells.has(i+d):
					continue
				if !used_cells.has(i+d):
					continue
				if occupied_cells.has(i+d):
					continue
				
				reachable_cells.get_or_add(i+d, m+1)
				cells_to_scan_next.get_or_add(i+d, m+1)

			scanned_cells.get_or_add(i, cells_to_scan[i])
		cells_to_scan.clear()
		cells_to_scan.assign(cells_to_scan_next)
	
	return reachable_cells

func AttackDistanceFromCoords(current_coords:Vector2i, game_tile_map_layer: TileMapLayer, occupied_cells: Dictionary[Vector2i, Node2D], directions: direction_types) -> Dictionary[Vector2i, int]:
	var dir = enum_to_direction[directions]
		
	var reachable_cells: Dictionary[Vector2i, int] = {current_coords: 0}
	var scanned_cells: Dictionary[Vector2i, int] = {}
	var cells_to_scan: Dictionary[Vector2i, int] = {current_coords: 0}
	var cells_to_scan_next: Dictionary[Vector2i, int] = {}
	var used_cells = game_tile_map_layer.get_used_cells()
	
	for m in reach:
		for i in cells_to_scan:
			for d in dir:
				
				#Conditions
				if scanned_cells.has(i+d):
					continue
				if !used_cells.has(i+d):
					continue
				if i+d == current_coords:
					continue
					
				cells_to_scan_next.get_or_add(i+d, m+1)
				
				if occupied_cells.has(i+d):
					reachable_cells.get_or_add(i+d, m+1)

			scanned_cells.get_or_add(i, cells_to_scan[i])
		cells_to_scan.clear()
		cells_to_scan.assign(cells_to_scan_next)
	
	print_debug(reachable_cells)
	return reachable_cells
