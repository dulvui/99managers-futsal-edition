# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListRow
extends MarginContainer

signal selected

@onready var player_name: Label = %Name
@onready var player_value: Label = %Value
@onready var button: DefaultButton = %Button

# TODO change button color in base of index

func setup(player: Player, index: int) -> void:
	player_name.text = player.surname
	player_value.text = FormatUtil.currency(player.value)

	button.pressed.connect(func() -> void: selected.emit())

	if index % 2 == 0:
		button.modulate = button.modulate.darkened(0.2)
