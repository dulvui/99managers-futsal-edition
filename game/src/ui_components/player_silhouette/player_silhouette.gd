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


func _ready() -> void:
	load_image()
	set_color()


func load_image() -> void:
	var random_index: int = RngUtil.rng.randi_range(0, SILHOUETTE_PATHS.size())
	var random_path: String = SILHOUETTE_PATHS[random_index]
	if random_path == Global.player_silhouette_last_path:
		random_index -= 1
		random_path = SILHOUETTE_PATHS[random_index]
	texture = load(random_path)
	Global.player_silhouette_last_path = random_path


func set_color() -> void:
	modulate = ThemeUtil.configuration.style_important_color
