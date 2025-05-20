# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name StadiumColors

var name: String
# colors
var outbound: Color
var floorz: Color
var center_circle: Color
var line: Color
# goal stripe colors
var goal_1: Color
var goal_2: Color


func _init(
	p_name: String = "",
	p_floorz: Color = Color.ORANGE,
	p_center_circle: Color = Color.ORANGE,
	p_line: Color = Color.WHITE,
	p_outbound: Color = Color.CADET_BLUE,
	p_goal_1: Color = Color.WHITE,
	p_goal_2: Color = Color.FIREBRICK,
) -> void:
	name = p_name
	floorz = p_floorz
	center_circle = p_center_circle
	line = p_line
	outbound = p_outbound
	goal_1 = p_goal_1
	goal_2 = p_goal_2

