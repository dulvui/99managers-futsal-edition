# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamBasic
extends JSONResource

@export var id: int
@export var league_id: int
@export var name: String


func _init(
	p_id: int = -1,
	p_league_id: int = -1,
	p_name: String = "",
) -> void:
	id = p_id
	league_id = p_league_id
	name = p_name


