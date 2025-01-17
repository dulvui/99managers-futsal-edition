# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateDribble
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateDribble")


func enter() -> void:
	if owner.team.left_half:
		owner.field.ball.dribble(owner.player.pos + Vector2(50, 0), 2)
	else:
		owner.field.ball.dribble(owner.player.pos + Vector2(-50, 0), 2)
	set_state(PlayerStateAttack.new())
	return


func exit() -> void:
	owner.team.player_control = null

