class_name Game_Board extends Node2D

@onready var units: Node = $Units
@onready var terrain: Node = $Terrain
@onready var cursor: Cursor = $Cursor
@onready var walkable_cell_overlay: Walkable_Cell_Overlay = $Overlays/WalkableCellOverlay

#Dicionário que armazena a posição das unidades
var units_dictionary:Dictionary = {}

var selected_unit:Unit = null

func _ready() -> void:
	cursor.cursor_interacted.connect(_on_cursor_interacted)
	_update_units_dictionary()	

func _update_units_dictionary() -> void:
	units_dictionary.clear()
	for child in units.get_children():
		if not child is Unit:
			child.queue_free()
			push_warning('Nodo que não é unidade localizado na estrutura de Unidades')
		else:
			var unit:Unit = child as Unit
			if units_dictionary.has(unit.current_cell):
				#Amadurecer essa lógica depois
				unit.queue_free()
				push_warning('Unidade em célula já ocupada')
			units_dictionary[unit.current_cell] = unit

func _interact_with_cell(cell:Vector2) -> void:
	if units_dictionary.has(cell):
		_clear_unit_selection()
			
		var unit:Unit = units_dictionary[cell] as Unit
		unit.is_selected = !unit.is_selected
		selected_unit = unit
		walkable_cell_overlay.draw_overlay(_get_walkable_cells_in_range(unit.current_cell, unit.move_range))
		
	# Arrumar essa cagada do walkable cells
	elif selected_unit and cell in _get_walkable_cells_in_range(selected_unit.current_cell, selected_unit.move_range):
		var pathfinding:Pathfinding = Pathfinding.new(_get_walkable_cells_in_range(selected_unit.current_cell, selected_unit.move_range))
		selected_unit.walk_along_path(pathfinding.calculate_point_path(selected_unit.current_cell, cell))
		_update_units_dictionary()
		_clear_unit_selection()
		walkable_cell_overlay.clear_overlay()
	
func _on_cursor_interacted(cell:Vector2) -> void:
	_interact_with_cell(cell)

func _clear_unit_selection() -> void:
	if !selected_unit:
		return
		
	selected_unit.is_selected = false
	selected_unit = null
	
func _is_cell_occupied(cell:Vector2) -> bool:
	if units_dictionary.has(cell):
		return true
	# Adicionar if ocupada por um terreno
	
	# ou bloqueada por alguma outra estrutura que faça sentido 
	
	return false

func _get_walkable_cells_in_range(starting_cell:Vector2, max_range:int) -> PackedVector2Array:
	var out:PackedVector2Array = _flood_fill(starting_cell, max_range)
	return out

func _flood_fill(starting_cell:Vector2, max_range:int) -> PackedVector2Array:
	const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	
	var out:PackedVector2Array = []
	var stack:Array[Vector2] = [starting_cell]
	
	while not stack.is_empty():
		var current:Vector2 = stack.pop_back()
		
		if current in out:
			continue
		
		#Revisitar teste de distância	
		var difference:Vector2 = (current - starting_cell).abs()
		var distance:int = int(difference.x + difference.y)
		
		if distance > max_range:
			continue
		
		out.append(current)
		
		for direction:Vector2 in DIRECTIONS:
			var adjacent_cell:Vector2 = current + direction
			
			if adjacent_cell in out:
				continue
				
			if _is_cell_occupied(adjacent_cell):
				continue
			
			stack.append(adjacent_cell)
	
	return out
