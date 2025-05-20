# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Stadium
extends JSONResource

@export var name: String
@export var capacity: int
@export var year_built: int
@export var year_renewed: int
@export var maintenance_cost: int
@export var ticket_price: int
# only index, to not save colors but only reference
@export var colors_index: int


func _init(
	p_name: String = "",
	p_capacity: int = 0,
	p_year_built: int = 0,
	p_year_renewed: int = 0,
	p_maintencance_cost: int = 0,
	p_ticket_price: int = 0,
	p_colors_index: int = 0,
) -> void:
	name = p_name
	capacity = p_capacity
	year_built = p_year_built
	year_renewed = p_year_renewed
	maintenance_cost = p_maintencance_cost
	ticket_price = p_ticket_price
	colors_index = p_colors_index

