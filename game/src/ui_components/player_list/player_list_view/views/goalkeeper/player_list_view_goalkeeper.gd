# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListViewGoalkeeper
extends PlayerListView

const Row: PackedScene = preload("res://src/ui_components/player_list/player_list_view/views/goalkeeper/player_list_row_goalkeeper.tscn")

func setup(players: Array[Player], row_scene: PackedScene = Row) -> void:
	super(players, row_scene)

