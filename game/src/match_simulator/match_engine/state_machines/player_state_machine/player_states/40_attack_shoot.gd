# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttackShoot
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateAttackShoot")


func enter() -> void:
	owner.field.ball.shoot_on_goal(owner.player.player_res, owner.team.left_half)
	set_state(PlayerStateWait.new())
	return


func exit() -> void:
	owner.team.player_control = owner.team.player_empty

