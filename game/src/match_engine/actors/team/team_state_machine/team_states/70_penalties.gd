# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalties
extends TeamStateMachineState

var shooting_player_index: int
var shooting_player: SimPlayer
var goalkeeper: SimPlayer


func _init() -> void:
	super("TeamStatePenalties")


func enter() -> void:
	# start first non goalkeeper player
	shooting_player_index = 1

	# move players to center in line
	for player: SimPlayer in owner.team.players:
		player.set_state(PlayerStatePenalties.new())

		if player.is_goalkeeper:
			goalkeeper = player

	if owner.team.has_ball:
		next_shooter(false)
	else:
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())


func execute() -> void:
	# wait for turn to shoot
	if not owner.team.has_ball:
		return

	# wait for shooting player to shoot
	if shooting_player != null:
		if shooting_player.state_machine.state is PlayerStatePenaltyShoot:
			return
		# player has shoot
		owner.team.penalties_shot_taken()
		# move player that has just shot to center
		shooting_player.set_state(PlayerStatePenalties.new())
		shooting_player = null
		# make goalkeeper active
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())
		# change possession
		owner.team.team_opponents.gain_possession()
	# team just gained possess
	else:
		# move goalkeeper to center
		goalkeeper.set_state(PlayerStatePenalties.new())
		# select next shooter
		next_shooter()


func next_shooter(increment: bool = true) -> void:
	if increment:
		shooting_player_index += 1
		shooting_player_index %= owner.team.players.size()

	# set ball position
	owner.ball.set_pos(owner.field.penalty_areas.spot_left)
	shooting_player = owner.team.players[shooting_player_index]
	owner.team.players[shooting_player_index].set_state(PlayerStatePenaltyShoot.new())
