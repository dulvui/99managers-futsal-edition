# SPDX-FileCopyrightText: 2025 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name LineGraph
extends SubViewportContainer


@onready var sub_viewport: SubViewport = %SubViewport
@onready var canvas: Node2D = %Canvas


func _ready() -> void:
	if Tests.is_run_as_current_scene(self):
		setup([1, 2, 3, 0 , -1], "hello", "world")


func setup(
	values: Array[int],
	_x_axis: String = "",
	_y_axis: String = ""
) -> void:

	var line: PackedVector2Array = PackedVector2Array()
	
	for i: int in values.size():
		line.append(Vector2(i * 10, values[i]))

	canvas.draw_polyline(line, Color.WHITE)

	
