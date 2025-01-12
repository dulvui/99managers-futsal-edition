# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateAttackPass
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateAttackPass")


func execute() -> void:
	random_pass()
	owner.team.player_control = null
	set_state(PlayerStateWait.new())
	return


func exit() -> void:
	owner.team.player_control = null


func random_pass() -> void:
	owner.team.stats.passes += 1
	var random_player: int = RngUtil.match_rng.randi_range(0, 4)
	
	# make sure player is not passing ball himself
	if random_player == owner.team.players.find(owner.team.player_control):
		random_player += 1
		random_player %= 5
	
	owner.team.player_receive_ball = owner.team.players[random_player]
	
	if owner.team.player_receive_ball == null:
		return

	owner.field.ball.short_pass(owner.team.player_receive_ball.pos, 40)
	
	owner.team.player_receive_ball.state_machine.set_state(PlayerStateAttackReceive.new())


