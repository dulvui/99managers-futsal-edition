# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualBall
extends Node2D

var sim_ball: SimBall

var last_update_time: float
var update_interval: float
var factor: float

var last_pos: Vector2


func _physics_process(delta: float) -> void:
	if not Global.match_paused:
		last_update_time += delta
		factor = last_update_time / update_interval
		position = last_pos.lerp(sim_ball.next_pos, factor)
		rotate(sim_ball.rotation)


func setup(p_sim_ball: SimBall, p_update_interval: float) -> void:
	update_interval = p_update_interval
	sim_ball = p_sim_ball
	last_update_time = 0.0
	factor = 1.0
	last_pos = sim_ball.pos


func update(p_update_interval: float) -> void:
	update_interval = p_update_interval
	last_update_time = 0
	last_pos = position
