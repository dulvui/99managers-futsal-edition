# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualBall
extends VisualActor

var sim_ball: SimBall


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not Global.match_paused:
		rotate(sim_ball.rotation)


func setup(p_actor: MovingActor, p_update_interval: float) -> void:
	super(p_actor, p_update_interval)
	sim_ball = actor as SimBall
