# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerContract
extends Contract

@export var buy_clause: int
@export var is_on_loan: bool


func _init(
	p_buy_clause: int = 0,
	p_is_on_loan: bool = false,
) -> void:
	super()
	buy_clause = p_buy_clause
	is_on_loan = p_is_on_loan

