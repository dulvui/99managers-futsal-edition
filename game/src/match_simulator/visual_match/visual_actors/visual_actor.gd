# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualActor
extends Node2D

var last_update_time: float
var update_interval: float
var factor: float

var last_pos: Vector2
var pos: Vector2


func _physics_process(delta: float) -> void:
	if not Global.match_paused:
		last_update_time += delta
		factor = last_update_time / update_interval
		position = last_pos.lerp(pos, factor)


func setup(p_pos: Vector2, p_update_interval: float) -> void:
	update_interval = p_update_interval
	pos = p_pos
	last_pos = p_pos
	last_update_time = 0.0
	factor = 1.0


func update(p_pos: Vector2) -> void:
	pos = p_pos
	last_pos = position
	last_update_time = 0.0


