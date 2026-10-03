extends TileMapLayer

var tiles_to_highlight: Array[highlight_data]

#Which ID are for What:
#1 EntityMovement
#2 entityAttack


func HighLightAtCoords(coords: Array[Vector2i], color: Vector2i, id: int):
	#Check if a there are highlighted tiles with the same id and if there are stop them
	for i in tiles_to_highlight:
		
		if i.id == id:
			#print_debug("STop: "+str(id))
			StopHighLightWithID(id)
	
	#Instantiate the data and add it to tiles_to_highlight
	var data = highlight_data.new()
	
	for i in coords:
		data.coords.append(i)
	data.color = color
	data.id = id
	
	
	tiles_to_highlight.append(data)
	UpdateHighlight()
	
	#for j in data.coords:
		#set_cell(j, 0, data.color)
		
func StopHighLightWithID(id: int):
	for i in tiles_to_highlight.size():
		if tiles_to_highlight[i].id == id:
			#for j in tiles_to_highlight[i].coords:
				#print_debug("Stop: "+str(id)+", Coords: "+str(j))
				#UpdateHighlight()
				#erase_cell(j)
			tiles_to_highlight.erase(tiles_to_highlight[i])
			UpdateHighlight()
			break
			
func UpdateHighlight():
	#print_debug("before: "+str(tiles_to_highlight))
	#Sort tiles_to_highlight to keep highlight priority based on id(This method is so bad xd)
	var a: Dictionary[int, highlight_data]
	
	for i in tiles_to_highlight:
		a.get_or_add(i.id, i)
	
	#print_debug("before: "+str(a))
	a.sort()
	#print_debug("after: "+str(a))
	
	tiles_to_highlight.clear()
	for i in a:
		tiles_to_highlight.append(a[i])
	
	#tiles_to_highlight.sort()
	
	#print_debug("after: "+str(tiles_to_highlight))
	clear()
	
	#Must be sorting in descending order(This was changed bc i could not find a way to sort tiles_to_highlight the other way)
	# in descending order instantiat each cell 
	for i in tiles_to_highlight.size():
		var iteration = tiles_to_highlight.size() - i-1
		for j in tiles_to_highlight[iteration].coords:
			#print_debug("test")
			set_cell(j, 0, tiles_to_highlight[iteration].color)
	
func HighLightAllCoordsWithinRange(current_coords:Vector2i, distances: Dictionary[Vector2i, int], ID: int, color: Vector2i):
	var coords_to_highlight: Array[Vector2i] = []
	for i in distances:
		coords_to_highlight.append(i)
	HighLightAtCoords(coords_to_highlight, color, ID)
	
