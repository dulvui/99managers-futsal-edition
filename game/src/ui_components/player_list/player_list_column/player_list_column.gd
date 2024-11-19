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


func setup(
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
			label.setup(col_name)

			if value is Dictionary:
				value = FormatUtil.format_date(value as Dictionary)
			elif value is String and not col_name in NOT_TRANSLATED_COLUMS:
				value = str(value).to_upper()

			label.set_value(value)


func update_values(players: Array[Player]) -> void:
	var values: Array[Variant] = players.map(map_function)

	for i: int in color_labels.size():
		if i < values.size():
			color_labels[i].show()
			if values[i] is Dictionary:
				values[i] = FormatUtil.format_date(values[i] as Dictionary)
			elif values[i] is String and not col_name in NOT_TRANSLATED_COLUMS:
				values[i] = str(values[i]).to_upper()
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
