# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStateFreeKick
extends TeamStateMachineState


func _init() -> void:
	super("TeamStateFreeKick")


func enter() -> void:
	# define penalty spot side
	var penalty_spot: Vector2
	if owner.team.has_ball and owner.team.left_half:
		penalty_spot = owner.field.penalty_areas.spot_right
	else:
		penalty_spot = owner.field.penalty_areas.spot_left
	# set ball position
	owner.field.ball.set_pos(penalty_spot)
	
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
		shooting_player.set_state(PlayerStatePenaltyShoot.new())
	else:
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())


func execute() -> void:
	pass
	# if team has ball
	# move player to free kick
	# shoot
	# else
	# some players make wall
