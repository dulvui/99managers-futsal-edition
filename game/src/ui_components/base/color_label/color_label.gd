# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name ColorLabel
extends Label

@export var value_name: String

func setup(p_value_name: String) -> void:
	value_name = p_value_name
	tooltip_text = value_name


func set_value(value: Variant) -> void:
	text = str(value)

	if is_instance_of(value, TYPE_INT):
		ThemeUtil.bold(self)
		if value < 11:
			label_settings = ThemeUtil.label_settings_low
		elif value < 16:
			label_settings = ThemeUtil.label_settings_mid
		else:
			label_settings = ThemeUtil.label_settings_high

	# check if not number, treadet as string
	elif is_instance_of(value, TYPE_STRING) and not (value as String).is_valid_int():
		horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

