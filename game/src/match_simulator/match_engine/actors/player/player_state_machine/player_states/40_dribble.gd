# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateDribble
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateDribble")


func enter() -> void:
	# slightly kick ball towards goal
	if owner.team.left_half:
		owner.field.ball.dribble(owner.player.pos + Vector2(50, 0), 10)
	else:
		owner.field.ball.dribble(owner.player.pos + Vector2(-50, 0), 10)
	owner.player.follow(owner.field.ball, 20)
	set_state(PlayerStateControl.new())

