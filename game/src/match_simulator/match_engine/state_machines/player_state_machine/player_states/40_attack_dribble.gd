# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttackDribble
extends PlayerStateMachineState


func enter() -> void:
	if owner.team.left_half:
		owner.field.ball.dribble(owner.player.pos + Vector2(50, 0), 10)
	else:
		owner.field.ball.dribble(owner.player.pos + Vector2(-50, 0), 10)
	set_state(PlayerStateWait.new())


func exit() -> void:
	owner.team.player_control = null

