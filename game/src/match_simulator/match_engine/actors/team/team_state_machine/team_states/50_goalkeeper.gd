# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoalkeeper
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateGoalkeeper")


func enter() -> void:
	if owner.team.has_ball:
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				player.set_state(PlayerStateGoalkeeperBall.new())
			else:
				player.move_offense_pos()
	else:
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				player.set_state(PlayerStateGoalkeeperFollowBall.new())
			else:
				player.move_defense_pos()


func execute() -> void:
	if owner.field.clock_running:
		if owner.team.has_ball:
			set_state(TeamStateDefend.new())
		else:
			set_state(TeamStateAttack.new())
