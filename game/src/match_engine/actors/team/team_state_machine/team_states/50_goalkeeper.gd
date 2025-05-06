# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateGoalkeeper
extends TeamStateMachineState

var goalkeeper: SimPlayer


func _init() -> void:
	super("TeamStateGoalkeeper")


func enter() -> void:
	if owner.team.has_ball:
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				goalkeeper = player
				owner.team.player_control(goalkeeper)
				goalkeeper.set_state(PlayerStateFindBestPass.new()) 
			else:
				player.move_defense_pos()
				player.set_state(PlayerStateIdle.new())
	else:
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				player.set_state(PlayerStateGoalkeeperFollowBall.new())
			else:
				player.move_defense_pos()
				player.set_state(PlayerStateIdle.new())


func execute() -> void:
	if goalkeeper == null:
		return

	# wait until goalkeeper has made the pass
	if goalkeeper.state_machine.state is PlayerStateFindBestPass:
		return

	set_state(TeamStateAttack.new())
	owner.team.team_opponents.set_state(TeamStateDefend.new())

