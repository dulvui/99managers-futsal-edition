# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Sponsor
extends JSONResource

@export var name: String
@export var budget: int


func _init(
	p_name: String = "",
	p_budget: int = 0,
) -> void:
	name = p_name
	budget = p_budget
