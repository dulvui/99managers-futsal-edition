# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerListColumn
extends VBoxContainer

signal sort

const ColorLabelScene: PackedScene = preload("res://src/ui_components/color_label/color_label.tscn")

const NOT_TRANSLATED_COLUMS: Array[StringName] = [
	Const.SURNAME,
	"TEAM",
]

var color_labels: Array[ColorLabel] = []
var buttons: Array[Button] = []
var view_name: String
var col_name: String
var map_function: Callable

@onready var sort_button: Button = $SortButton


func set_up(
	p_view_name: String, p_col_name: String, players: Array[Player], p_map_function: Callable
) -> void:
	view_name = p_view_name
	col_name = p_col_name
	map_function = p_map_function

	sort_button.text = p_col_name.to_upper()
	sort_button.tooltip_text = p_col_name.to_upper()

	var values: Array[Variant] = players.map(map_function)

	for value: Variant in values:
		if col_name == Const.SURNAME :
			var button: Button = Button.new()	
			button.text = str(value)
			button.tooltip_text = col_name
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			add_child(button)
			buttons.append(button)
		else:
			var label: ColorLabel = ColorLabelScene.instantiate()
			color_labels.append(label)
			add_child(label)
			label.tooltip_text = col_name
			label.set_up(col_name)

			if is_instance_of(value, TYPE_STRING) and not col_name in NOT_TRANSLATED_COLUMS:
				value = str(value).to_upper()

			label.set_value(value)


func update_values(players: Array[Player]) -> void:
	var values: Array[Variant] = players.map(map_function)

	for i: int in color_labels.size():
		if i < values.size():
			color_labels[i].show()
			if is_instance_of(values[i], TYPE_STRING) and not col_name in NOT_TRANSLATED_COLUMS:
				values[i] = str(values[i]).to_upper()
			color_labels[i].set_value(values[i])
		else:
			color_labels[i].hide()


func _on_sort_button_pressed() -> void:
	sort.emit()
