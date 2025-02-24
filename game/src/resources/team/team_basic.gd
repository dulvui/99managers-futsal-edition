# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamBasic
extends JSONResource


@export var id: int
@export var name: String
@export var league_id: int


func _init(
	p_id: int = -1,
	p_name: String = "",
	p_league_id: int = -1,
) -> void:
	id = p_id
	name = p_name
	league_id = p_league_id


