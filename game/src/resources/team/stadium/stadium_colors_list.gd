# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StadiumColorsList

var index: int
var list: Array[StadiumColors]


func _init() -> void:
	index = 0
	list = []

	# default
	list.append(StadiumColors.new(tr("Orange")))

	# blue
	list.append(
		StadiumColors.new(
			tr("Blue"),
			Color.BLUE,
			Color.CADET_BLUE,
		)
	)

	# red
	list.append(
		StadiumColors.new(
			tr("Red"),
			Color.RED,
			Color.FIREBRICK,
		)
	)


func select(p_index: int) -> StadiumColors:
	index = p_index
	return list[index]

