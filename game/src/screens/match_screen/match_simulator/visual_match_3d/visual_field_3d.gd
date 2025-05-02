# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualField3D
extends Node3D

@onready var field: VisualField = %VisualField


func _ready() -> void:
	field.setup(SimField.new(RngUtil.new()))
