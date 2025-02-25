# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ColorVariation
extends Resource

@export var normal: Color
@export var pressed: Color
@export var hover: Color
@export var focus: Color
@export var disabled: Color


func _init(color: Color) -> void:
	# color
	normal = color
	focus = color.lightened(0.1)
	pressed = color.darkened(0.1)
	hover = color.lightened(0.3)
	disabled = color.darkened(0.4)

	# alpsha channel
	focus.a = color.a * 0.9
	pressed.a = color.a * 0.9
	hover.a = color.a * 0.9
	disabled.a = color.a * 0.6
