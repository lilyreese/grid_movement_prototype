@tool
class_name Game_Grid extends Resource

@export var cell_size:Vector2 = Vector2(80,80)

var _half_cell_size:Vector2 = cell_size / 2

func convert_world_position_to_grid_coordinate(world_position:Vector2) -> Vector2:
	var out:Vector2 = (world_position / cell_size).floor()
	return out
	
func convert_grid_coordinate_to_world_position(grid_coordinate:Vector2) -> Vector2:
	var out:Vector2 = (grid_coordinate * cell_size) + _half_cell_size
	return out
	
func get_hash(cell:Vector2) -> int:
	var out:int = int(cell.x + (cell_size.x * cell.y))
	return out
