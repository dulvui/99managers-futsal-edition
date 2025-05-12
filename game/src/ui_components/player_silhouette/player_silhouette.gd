# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends TextureRect


const SILHOUETTE_PATHS: Array[StringName] = [
	"res://assets/player_silhouettes/silhouette-football-04.svg",
	"res://assets/player_silhouettes/silhouette-football-08.svg",
	"res://assets/player_silhouettes/silhouette-football-10.svg",
	"res://assets/player_silhouettes/silhouette-football-11.svg",
	"res://assets/player_silhouettes/silhouette-football-12.svg",
	"res://assets/player_silhouettes/silhouette-football-15.svg",
	"res://assets/player_silhouettes/silhouette-football-16.svg",
	"res://assets/player_silhouettes/silhouette-football-18.svg",
	"res://assets/player_silhouettes/silhouette-football-19.svg",
	"res://assets/player_silhouettes/silhouette-football-20.svg",
	"res://assets/player_silhouettes/silhouette-football-22.svg",
	"res://assets/player_silhouettes/silhouette-football-24.svg",
	"res://assets/player_silhouettes/silhouette-football-25.svg",
	"res://assets/player_silhouettes/silhouette-football-26.svg",
	"res://assets/player_silhouettes/silhouette-football-28.svg",
	"res://assets/player_silhouettes/silhouette-football-32.svg",
]

var rng: RngUtil


func _ready() -> void:
	rng = RngUtil.new()
	rng.randomize()

	# load image
	var random_index: int = rng.randi_range(0, SILHOUETTE_PATHS.size() - 1)
	var random_path: String = SILHOUETTE_PATHS[random_index]
	if random_path == Global.player_silhouette_last_path:
		random_index -= 1
		random_path = SILHOUETTE_PATHS[random_index]
	texture = load(random_path)
	Global.player_silhouette_last_path = random_path

	_set_color()

	# update color if theme is changed
	ThemeUtil.theme_changed.connect(_set_color)


func _set_color() -> void:
	modulate = ThemeUtil.configuration.background_secondary_color

