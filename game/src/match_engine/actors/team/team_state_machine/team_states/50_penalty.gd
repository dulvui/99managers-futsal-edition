# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalty
extends TeamStateMachineState

var shooting_player: SimPlayer
var goalkeeper: SimPlayer


func _init() -> void:
	super("TeamStatePenalty")


func enter() -> void:
	owner.field.penalty = true

	# assume ball has already been set to penalty spot
	# this works for penalties and penatlies 10m
	var penalty_spot: Vector2 = owner.field.ball.pos
	
	# move players to above penalty spot line and min 5m away from spot
	for player: SimPlayer in owner.team.players:
		if not player.is_goalkeeper:
			# start from min 5m distance
			var deviation: int = owner.field.PIXEL_FACTOR * 5
			# add random 0 to 10 meters
			deviation += player.rng.randi_range(0, owner.field.PIXEL_FACTOR * 10)
			# randomly make deviation negative
			if player.rng.randi() % 2 == 0:
				deviation = -deviation
			player.set_destination(Vector2(penalty_spot.x, penalty_spot.y + deviation))
			player.set_state(PlayerStateIdle.new())
	
	if owner.team.has_ball:
		shooting_player = owner.team.players[-1]
		# find best penalty taker currently on field
		for player: SimPlayer in owner.team.players:
			if player.is_goalkeeper:
				continue
			if player.player_res.attributes.technical.penalty > \
					shooting_player.player_res.attributes.technical.penalty:
				shooting_player = player
		shooting_player.set_state(PlayerStatePenaltyShoot.new())
	else:
		goalkeeper = owner.team.players[0]
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())


func execute() -> void:
	if owner.team.has_ball:
		if shooting_player != null:
			# wait for shooting player to shoot
			if shooting_player.state_machine.state is PlayerStatePenaltyShoot:
				return
			owner.team.set_state(TeamStateAttack.new())
			owner.team.team_opponents.set_state(TeamStateDefend.new())


func exit() -> void:
	owner.field.penalty = false

