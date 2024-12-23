# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttackReceive
extends PlayerStateMachineState


func enter() -> void:
	owner.player.stop()


func execute() -> void:
	if owner.player.is_touching_ball():
		owner.field.ball.stop()
		owner.team.player_control = owner.player
		set_state(PlayerStateAttackPass.new())
