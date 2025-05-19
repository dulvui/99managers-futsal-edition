# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualFormationPlayer
extends Control

signal select

var player: Player

@onready var name_label: Label = %Name
@onready var stars: Label = %Stars
@onready var nr_label: Label = %Nr
@onready var stamina: ProgressBar =%Stamina


func _ready() -> void:
	if player:
		nr_label.text = str(player.nr)
		name_label.text = player.surname
		stars.text = FormatUtil.stars(player.prestige)
		stamina.value = player.stamina


func _process(_delta: float) -> void:
	if player:
		stamina.value = player.stamina


func set_player(p_player: Player, _team: Team = null) -> void:
	player = p_player

	# if team:
	# 	if team.is_lineup_player(player):
	# 		color = Color.PALE_GREEN
	# 	elif team.is_sub_player(player):
	# 		color = Color.SKY_BLUE
	# 	else:
	# 		color = Color.DARK_RED


func _on_select_pressed() -> void:
	select.emit()
