# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStatePass
extends PlayerStateMachineState


# 120 squared
const PERFECT_PASS_DISTANCE_SQUARED: int = 19600


func _init() -> void:
	super("PlayerStatePass")


func execute() -> void:
	# find best pass
	var best_player: SimPlayer
	var delta: float = 1.79769e308 # max float
	for player: SimPlayer in owner.team.players:
		if player != owner.player:
			var distance: float = player.pos.distance_squared_to(owner.player.pos)
			if distance < delta:
				delta = distance
				best_player = player
	
	owner.team.player_receive_ball(best_player)
	owner.field.ball.short_pass(owner.team.player_receive_ball().pos, 40)
	owner.team.stats.passes += 1
	
	owner.team.player_receive_ball().state_machine.set_state(PlayerStateReceive.new())

	set_state(PlayerStateAttack.new())
	return

