# Class extending Node3D to manage the gameplay environment.
extends Node3D

# Reference to the road Node3D.
@onready var road: Node3D = %Road
# Reference to the music Node3D.
@onready var music: Node3D = %Music
# Reference to the user HUD Control node.
@onready var user_hud: Control = %UserHUD

# Dictionary storing the map data.
var map: Dictionary
# File path of the selected map.
var map_file: String

# Parameters for gameplay.
var tempo: int
var bar_length_in_m: float
var quarter_time_in_sec: float
var speed: float
var note_scale: float
var start_pos_in_sec: float
var score: int = 0
var combo: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_variables()
	calculate_params()
	setup_nodes()

# Function to set initial variables.
func set_variables() -> void:
	map_file = SONG.map_selected.map_file
	map = load_map()

# Function to calculate parameters based on the loaded map.
func calculate_params() -> void:
	var song_tempo: int = map.tempo
	tempo = song_tempo
	bar_length_in_m = 16.8  # Godot meters
	quarter_time_in_sec = 60 / float(tempo)  # 60/60 = 1, 60/85 = 0.71
	speed = bar_length_in_m / float(4 * quarter_time_in_sec)  # each bar has 4 quarters
	note_scale = bar_length_in_m / float(4 * 400)

	var map_start_pos: float = map.start_pos
	start_pos_in_sec = (float(map_start_pos) / 400.0) * quarter_time_in_sec

# Function to load the map data from the specified file.
func load_map() -> Dictionary:
	var file: FileAccess = FileAccess.open(map_file, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var error: Error = json.parse(content)
	if error == OK:
		var result: Dictionary = json.data
		return result
	else:
		return {}

# Function to set up the gameplay nodes (music and road).
func setup_nodes() -> void:
	music.setup(self)
	road.setup(self)

# Placeholder function for building the game map.
func build_map(_empty: String) -> void:
	pass

# Placeholder function called when the game map is finished.
func map_finished() -> void:
	pass
