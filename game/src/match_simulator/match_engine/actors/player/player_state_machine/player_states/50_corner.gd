# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateCorner
extends PlayerStateMachineState


var wait_counter: int
var wait: int


func _init() -> void:
	super("PlayerStateCorner")


func enter() -> void:
	wait_counter = 0

	if owner.player.is_goalkeeper:
		owner.player.set_state(PlayerStateGoalkeeperFollowBall.new())
		return
	
	# check if player kicks corner
	if owner.team.has_ball and owner.team.player_control() == owner.player:
		wait = owner.rng.randi_range(2 * Const.TICKS_PER_SECOND, 5 * Const.TICKS_PER_SECOND)
		owner.player.set_destination(owner.field.ball.pos)
		return

	# move player into the area
	# by moving it near the penalty spot, with random deviation
	# TODO replace with corner tatics
	var deviation: Vector2 = Vector2(owner.rng.randi_range(-50, 50),owner.rng.randi_range(-50, 50))
	if owner.team.left_half:
		if owner.team.has_ball:
			owner.player.set_destination(owner.field.penalty_areas.spot_right + deviation)
		else:
			owner.player.set_destination(owner.field.penalty_areas.spot_left + deviation)
	else:
		if owner.team.has_ball:
			owner.player.set_destination(owner.field.penalty_areas.spot_left + deviation)
		else:
			owner.player.set_destination(owner.field.penalty_areas.spot_right + deviation)


func execute() -> void:
	if owner.team.player_control() == owner.player:
		if owner.player.destination_reached():
			wait_counter += 1
			if wait_counter >= wait:
				corner_kick()
				owner.player.set_state(PlayerStateAttack.new())


func exit() -> void:
	owner.field.clock_running = true


func corner_kick() -> void:
	for player: SimPlayer in owner.team.players:
		if player != owner.player and not player.is_goalkeeper:
			owner.team.player_receive_ball(player)
			owner.field.ball.short_pass(player.pos, 100)
			return
