# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualActor
extends Node2D

var time_passed: float
var update_interval: float
var factor: float

var last_pos: Vector2
var pos: Vector2


func _physics_process(delta: float) -> void:
	if not Global.match_paused:
		time_passed += delta
		# limit to 1.0 to not go over
		factor = min(1.0, time_passed / update_interval)
		position = last_pos.lerp(pos, factor)


func setup(p_pos: Vector2) -> void:
	pos = p_pos
	update_interval = 0
	last_pos = p_pos
	time_passed = 0.0
	factor = 0
	update_interval = 1.0 / Const.TICKS


func update(p_pos: Vector2) -> void:
	pos = p_pos
	last_pos = position
	time_passed = 0.0
	factor = 0
