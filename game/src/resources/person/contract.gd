# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Contract
extends JSONResource

@export var income: int
@export var start_date: Dictionary  # unixtimestamp
@export var end_date: Dictionary


func _init(
	p_income: int = 0,
	p_start_date: Dictionary = {},
	p_end_date: Dictionary = {},
) -> void:
	income = p_income
	start_date = p_start_date
	end_date = p_end_date

