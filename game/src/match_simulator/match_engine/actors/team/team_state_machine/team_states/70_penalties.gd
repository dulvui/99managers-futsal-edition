# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalties
extends TeamStateMachineState


var shooting_player: int

func _init() -> void:
	super("TeamStatePenalties")


func enter() -> void:
	# start first non goalkeeper player
	shooting_player = 1

	# move players to center in line
	for player: SimPlayer in owner.team.players:
		var deviation: Vector2 = Vector2(0, 20 * (owner.team.players.find(player) + 1))
		if owner.team.left_half:
			deviation = -deviation
		player.set_destination(owner.field.center)
		player.set_state(PlayerStateIdle.new())
	
	if owner.team.has_ball:
		owner.team.players[shooting_player].set_state(PlayerStatePenalty.new())
	else:
		owner.team.players[0].set_state(PlayerStateGoalkeeperPenalty.new())


func execute() -> void:
	pass



