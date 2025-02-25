# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualFormationPlayer
extends Control

signal select

var color: Color
var player: Player

@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var prestige: Label = $MarginContainer/VBoxContainer/Prestige
@onready var nr_label: Label = $MarginContainer/VBoxContainer/Nr
@onready var state_color: ColorRect = $ColorRect
@onready var stamina: ProgressBar = $MarginContainer/VBoxContainer/Stamina


func _ready() -> void:
	if player:
		nr_label.text = str(player.nr)
		name_label.text = player.surname
		state_color.color = color
		prestige.text = player.get_prestige_stars()
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
