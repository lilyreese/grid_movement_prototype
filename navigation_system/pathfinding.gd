class_name Pathfinding extends RefCounted

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var grid:Game_Grid = preload("res://grid_system/game_grid.tres")

var _astar:AStar2D = AStar2D.new()

var cell_mapping:Dictionary = {}

func _init(cells:PackedVector2Array) -> void:
	for cell in cells:
		cell_mapping[cell] = grid.get_hash(cell)
		
	_add_points()
	_connect_points()
		
# Adicione as celulas ao grid do A* (Point)
# (1,1) = ID
func _add_points() -> void:
	for point in cell_mapping:
		_astar.add_point(cell_mapping[point], point)

# Conectar as células (Points)
func _connect_points() -> void:
	for point in cell_mapping:
		for neighbor in _find_neighbors(point):
			_astar.connect_points(cell_mapping[point], cell_mapping[neighbor])
	
func _find_neighbors(cell:Vector2) -> PackedVector2Array:
	var out:PackedVector2Array = []
	
	for direction in DIRECTIONS:
		var neighbor:Vector2 = cell+direction
		
		if not cell_mapping.has(neighbor):
			continue
		
		if _astar.are_points_connected(cell_mapping[cell], cell_mapping[neighbor]):
			continue
		
		out.push_back(neighbor)
		
	return out
	
# Calcular o caminho entre o começo e o destino

func calculate_point_path(start:Vector2, end:Vector2) -> PackedVector2Array:
	var start_index:int = grid.get_hash(start)
	var end_index:int = grid.get_hash(end)
	
	if not _astar.has_point(start_index) or not _astar.has_point(end_index):
		return PackedVector2Array()
	
	return _astar.get_point_path(start_index, end_index)
