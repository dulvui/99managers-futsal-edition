# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name BarGraph
extends VBoxContainer

@onready var positive_values: HBoxContainer = %PositiveValues
@onready var negative_values: HBoxContainer = %NegativeValues


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		var test_values: Array[int] = []
		for i: int in 100:
			test_values.append(randi_range(-100, 100))
		setup(test_values, "hello", "world")


func setup(values: Array[int], _x_axis: String = "", _y_axis: String = "") -> void:
	# find min/max value
	var max_value: int = 0
	for value: int in values:
		if value > max_value:
			max_value = value

	# create bars
	for value: int in values:
		var bar: ProgressBar = ProgressBar.new()
		bar.max_value = max_value
		bar.value = abs(value)
		bar.tooltip_text = str(value)
		bar.show_percentage = false
		bar.size_flags_vertical = Control.SIZE_FILL
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var placeholder: ProgressBar = ProgressBar.new()
		placeholder.max_value = max_value
		placeholder.value = 0
		placeholder.tooltip_text = str(value)
		placeholder.show_percentage = false
		placeholder.size_flags_vertical = Control.SIZE_FILL
		placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		if value >= 0:
			bar.fill_mode = ProgressBar.FillMode.FILL_BOTTOM_TO_TOP
			positive_values.add_child(bar)
			negative_values.add_child(placeholder)
		else:
			bar.fill_mode = ProgressBar.FillMode.FILL_TOP_TO_BOTTOM
			negative_values.add_child(bar)
			positive_values.add_child(placeholder)
