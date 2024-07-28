class_name Cursor extends Node2D

@export var game_grid:Game_Grid = preload("res://grid_system/game_grid.tres")

signal cursor_moved(to_cell)
signal cursor_interacted(cell)

var _current_cell:Vector2 = Vector2.ZERO:
	set = _set_current_cell

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_current_cell = game_grid.convert_world_position_to_grid_coordinate(event.position)
		
	if event.is_action_released("cursor_interact"):
		cursor_interacted.emit(_current_cell)

func _draw() -> void:
	draw_rect(Rect2(-game_grid.cell_size /2, game_grid.cell_size), Color.ALICE_BLUE, false, 3.0)

func _set_current_cell(value:Vector2) -> void:
	if value.is_equal_approx(_current_cell):
		return
		
	_current_cell = value
	
	position = game_grid.convert_grid_coordinate_to_world_position(_current_cell)
	
	cursor_moved.emit(_current_cell)
	
	pass
