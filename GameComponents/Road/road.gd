# Node3D representing the manager for the musical bars in the game.
extends Node3D

# Reference to the node containing musical bars.
@onready var bars_node: Node3D = %BarsNode
# Reference to the user's heads-up display (HUD).
@onready var user_hud: Control = get_parent().get_node('CanvasLayer/UserHUD')

# PackedScene for the musical bar.
var bar_scene: PackedScene = preload("res://GameComponents/Bar/bar.tscn")
# Array to store the active musical bars.
var bars: Array = []

# Length of a musical bar in meters.
var bar_length_in_meters: float
# Current location of the bars in the game world.
var current_location: Vector3
# Speed vector for the movement of the bars.
var speed: Vector3
# Scaling factor for the musical notes.
var note_scale: float

# Index of the current musical bar.
var current_bar_index: int
# Data for the musical tracks.
var tracks_data: Array
# Scaled amount of bars to be displayed on the screen.
var scaled_bar_amount: float
# Maximum index of musical bars.
var max_index: int
# Reference to the main game node.
var game: Node3D

# Set up the musical bars for the game.
#
# Parameters:
# - game_config: A Node3D representing the game configuration node.
#
# Example usage:
# ```gdscript
# setup(game_config)
# ```
func setup(game_config: Node3D) -> void:
	game = game_config
	var game_speed: float = game.speed
	speed = Vector3(0, 0, game_speed)
	bar_length_in_meters = game.bar_length_in_m
	current_location = Vector3(0, 0, -bar_length_in_meters)
	note_scale = game.note_scale

	current_bar_index = 0
	tracks_data = game.map.tracks
	scaled_bar_amount = max(ceil(32 / bar_length_in_meters), 16)
	max_index = 0
	for t: Dictionary in tracks_data:
		max_index = max(max_index, len(t.bars))
	add_bars(scaled_bar_amount)

# Process method called on every frame to update the position of musical bars.
#
# Parameters:
# - delta: The time in seconds since the last frame.
#
# Example usage:
# ```gdscript
# func _process(delta: float) -> void:
#     process_bars(delta)
# ```
func _process(delta: float) -> void:
	bars_node.translate(speed * delta)
	for bar: Node3D in bars:
		if bar.position.z + bars_node.position.z >= bar_length_in_meters:
			remove_bar(bar)
			add_bar()

# Method to add a musical bar to the scene.
#
# Example usage:
# ```gdscript
# func add_bar() -> void:
#     add_bar()
# ```
func add_bar() -> void:
	if (current_bar_index >= max_index):
		return
	
	var bar: Node3D = bar_scene.instantiate()
	bar.position = Vector3(current_location.x, current_location.y, current_location.z)
	bar.note_scale = note_scale
	bar.bar_data = get_bar_data()
	bar.speed = speed
	bars.append(bar)
	bars_node.add_child(bar)
	current_location += Vector3(0, 0, -bar_length_in_meters)
	current_bar_index += 1

# Method to retrieve the data for the current musical bar.
#
# Example usage:
# ```gdscript
# func get_bar_data() -> Array:
#     var barData: Array = get_bar_data()
# ```
func get_bar_data() -> Array:
	var irene_data: Dictionary = tracks_data[0].bars[current_bar_index]
	var seulgi_data: Dictionary = tracks_data[1].bars[current_bar_index]
	var wendy_data: Dictionary = tracks_data[2].bars[current_bar_index]
	var joy_data: Dictionary = tracks_data[3].bars[current_bar_index]
	var yeri_data: Dictionary = tracks_data[4].bars[current_bar_index]
	return [irene_data, seulgi_data, wendy_data, joy_data, yeri_data]

# Method to remove a musical bar from the scene.
#
# Parameters:
# - bar: The Node3D representing the musical bar to be removed.
#
# Example usage:
# ```gdscript
# func remove_bar(bar: Node3D) -> void:
#     remove_bar(bar)
# ```
func remove_bar(bar: Node3D) -> void:
	bar.queue_free()
	bars.erase(bar)
	if(len(bars) == 0) and current_bar_index == max_index:
		user_hud.song_finished()
		get_parent().map_finished()

# Method to add a specified number of musical bars to the scene.
#
# Parameters:
# - l: The number of musical bars to add.
#
# Example usage:
# ```gdscript
# func add_bars(l: float) -> void:
#     add_bars(16)
# ```
func add_bars(l: float) -> void:
	for _i: float in range(l):
		add_bar()
