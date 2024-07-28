class_name Walkable_Cell_Overlay extends TileMap

func draw_overlay(cells:PackedVector2Array) -> void:
	clear_overlay()
	for cell:Vector2 in cells:
		set_cell(0,cell, 1, Vector2.ZERO, 0)

func clear_overlay() -> void:
	clear()
