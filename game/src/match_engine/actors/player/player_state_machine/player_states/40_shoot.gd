# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateShoot
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateShoot")


func enter() -> void:
	# shoot on goal
	owner.field.ball.shoot_on_goal(owner.player.player_res, owner.team.left_half)

	# set opponent goalkeeper in save state
	owner.team.team_opponents.players[0].set_state(PlayerStateGoalkeeperSaveShot.new())

	set_state(PlayerStateAttack.new())

