# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerContract
extends Contract

var buy_clause: int
var goal_bonus: int
var assist_bonus: int
var is_on_loan: bool


func _init(
	p_buy_clause: int = 0,
	p_goal_bonus: int = 0,
	p_assist_bonus: int = 0,
	p_is_on_loan: bool = false,
) -> void:
	buy_clause = p_buy_clause
	goal_bonus = p_goal_bonus
	assist_bonus = p_assist_bonus
	is_on_loan = p_is_on_loan

