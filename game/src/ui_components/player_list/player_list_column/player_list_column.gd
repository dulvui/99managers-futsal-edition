# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListColumn
extends VBoxContainer

signal sort

const ColorLabelScene: PackedScene = preload(Const.SCENE_COLOR_LABEL)

var color_labels: Array[ColorLabel] = []
var buttons: Array[Button] = []
var col_name: String
var map_function: Callable

@onready var sort_button: Button = $SortButton


func setup(p_col_name: String, players: Array[Player], p_map_function: Callable) -> void:
	col_name = p_col_name
	map_function = p_map_function

	if col_name == Const.SURNAME:
		sort_button.text = p_col_name
		sort_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		size_flags_horizontal = Control.SIZE_EXPAND
		size_flags_vertical = Control.SIZE_EXPAND
	else:
		# sort_button.text = p_col_name.substr(0, 3)
		sort_button.text = p_col_name

	sort_button.tooltip_text = p_col_name


	var values: Array[Variant] = players.map(map_function)

	if col_name == Const.SURNAME:
		for value: Variant in values:
				var button: Button = DefaultButton.new()
				button.text = str(value)
				button.tooltip_text = col_name

				button.custom_minimum_size.x = 200
				button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

				add_child(button)
				buttons.append(button)
	else:
		for value: Variant in values:
			var label: ColorLabel = ColorLabelScene.instantiate()
			color_labels.append(label)
			add_child(label)
			label.tooltip_text = col_name
			label.setup(col_name)
			label.set_value(value)

func update_values(players: Array[Player]) -> void:
	var values: Array[Variant] = players.map(map_function)

	for i: int in color_labels.size():
		if i < values.size():
			color_labels[i].show()
			color_labels[i].set_value(values[i])
		else:
			color_labels[i].hide()

	# name buttons
	for i: int in buttons.size():
		if i < values.size():
			buttons[i].show()
			buttons[i].text = str(values[i])
		else:
			buttons[i].hide()


func _on_sort_button_pressed() -> void:
	sort.emit()
