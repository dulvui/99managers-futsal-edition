# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StadiumColorsList

var index: int
var list: Array[StadiumColors]


func _init() -> void:
	index = 0
	list = []

	list.append(
		StadiumColors.new(
			tr("Orange"),
			Color.ORANGE,
			Color.ORANGE_RED,
		)
	)

	list.append(
		StadiumColors.new(
			tr("Blue"),
			Color.MEDIUM_AQUAMARINE,
			Color.CADET_BLUE,
			Color.PEACH_PUFF,
		)
	)

	list.append(
		StadiumColors.new(
			tr("Red"),
			Color.MAROON,
			Color.FIREBRICK,
			Color.PINK,
		)
	)

	list.append(
		StadiumColors.new(
			tr("Green"),
			Color.LIGHT_SEA_GREEN,
			Color.LIGHT_GREEN,
			Color.LIGHT_YELLOW,
			Color.DARK_GREEN,
		)
	)

	list.append(
		StadiumColors.new(
			tr("White"),
			Color.WHITE,
			Color.WHITE,
			Color.BLACK,
			Color.WHITE,
		)
	)

	list.append(
		StadiumColors.new(
			tr("Black"),
			Color.BLACK,
			Color.BLACK,
			Color.WHITE,
			Color.BLACK,
		)
	)


func select(p_index: int) -> StadiumColors:
	index = p_index
	return list[index]

