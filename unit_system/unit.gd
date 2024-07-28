@tool
class_name Unit extends Path2D

signal finished_walking

@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var sprite_2d: Sprite2D = $PathFollow2D/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_label: Label = $DebugLabel

@export var game_grid:Game_Grid = preload("res://grid_system/game_grid.tres")

@export var move_range:int = 3

@export var move_speed:float = 500

@export var sprite:Texture:
	set = _set_sprite
	
@export var current_cell:Vector2:
	set = _set_current_cell
	
@export var is_selected:bool = false:
	set = _set_is_selected

var _is_walking:bool = false:
	set = _set_is_walking

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
	
func _ready() -> void:
	set_process(false)
	
	current_cell = game_grid.convert_world_position_to_grid_coordinate(position)
	position = game_grid.convert_grid_coordinate_to_world_position(current_cell)
	
	if not Engine.is_editor_hint():
		curve = Curve2D.new()
		
func _process(delta: float) -> void:
	path_follow_2d.progress += move_speed * delta
	
	if path_follow_2d.progress_ratio >= 1:
		_is_walking = false
		path_follow_2d.progress = 0
		
		
		position = game_grid.convert_grid_coordinate_to_world_position(current_cell)
		path_follow_2d.position = Vector2.ZERO
		
		curve.clear_points()
		
		finished_walking.emit()
	
func walk_along_path(cell_path:PackedVector2Array) -> void:
	if cell_path.is_empty():
		return
		
	for cell:Vector2 in cell_path:
		curve.add_point(to_local(game_grid.convert_grid_coordinate_to_world_position(cell)))
	
	current_cell = cell_path[-1]	
	
	_is_walking = true
	
func _set_sprite(value:Texture):
	sprite = value
	
	if not sprite_2d:
		await ready
	
	sprite_2d.texture = value

func _set_current_cell(value:Vector2) -> void:
	current_cell = value
	
	if not debug_label:
		await ready
		
	debug_label.text = str(value)
	
	if Engine.is_editor_hint():
		position = game_grid.convert_grid_coordinate_to_world_position(current_cell)

func _notification(what: int) -> void:
	if not Engine.is_editor_hint():
		return
		
	if position == Vector2.ZERO:
		return
	
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		current_cell = game_grid.convert_world_position_to_grid_coordinate(position)

func _set_is_selected(value:bool) -> void:
	is_selected = value
	
	if not animation_player:
		await ready
		
	if is_selected:
		animation_player.play("selected")
	else:
		animation_player.play("idle")
		
func _set_is_walking(value:bool) -> void:
	_is_walking = value
	set_process(_is_walking)
