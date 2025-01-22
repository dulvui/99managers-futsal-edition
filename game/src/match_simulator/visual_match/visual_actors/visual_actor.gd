# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualActor
extends Node2D

var actor: MovingActor

var last_update_time: float
var update_interval: float
var factor: float

var last_pos: Vector2


func _physics_process(delta: float) -> void:
	if not Global.match_paused and Global.match_speed == MatchScreen.Speed.FULL_GAME:
		last_update_time += delta
		factor = last_update_time / update_interval
		position = last_pos.lerp(actor.pos, factor)


func setup(p_actor: MovingActor, p_update_interval: float) -> void:
	actor = p_actor
	update_interval = p_update_interval

	last_update_time = 0.0
	factor = 1.0
	last_pos = actor.pos


func update(p_update_interval: float) -> void:
	update_interval = p_update_interval
	last_update_time = 0
	last_pos = position
