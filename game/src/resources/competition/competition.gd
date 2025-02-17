# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Competition
extends JSONResource

@export var id: int
# 1 is best, bigger is lower league
@export var pyramid_level: int
@export var name: String
# total price money
@export var price_money: int


func _init(
	p_id: int = -1,
	p_pyramid_level: int = 1,
	p_name: String = "",
	p_price_money: int = 0,
) -> void:
	id = p_id
	pyramid_level = p_pyramid_level
	name = p_name
	price_money = p_price_money


func set_id() -> void:
	id = IdUtil.next_id(IdUtil.Types.COMPETITION)


