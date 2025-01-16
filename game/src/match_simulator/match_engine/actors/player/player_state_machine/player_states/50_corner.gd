# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateCorner
extends PlayerStateMachineState


var wait_counter: int
var wait: int


func _init() -> void:
	super("PlayerStateCorner")
	wait_counter = 0


func enter() -> void:
	if owner.player.is_goalkeeper:
		return
	
	# check if player chould kick corner
	if owner.team.has_ball and owner.team.player_control == owner.player:
		wait = RngUtil.match_rng.randi_range(2 * Const.TICKS_PER_SECOND, 5 * Const.TICKS_PER_SECOND)
		owner.player.set_destination(owner.field.ball.pos)
		return

	# move player into the area
	# by moving it near the penalty spot, with random deviation
	# TODO replace with corner tatics
	var deviation: Vector2 = Vector2(RngUtil.match_rng.randi_range(-50, 50),RngUtil.match_rng.randi_range(-50, 50))
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
	if owner.team.player_control == owner.player:
		if owner.player.destination_reached():
			wait_counter += 1
			if wait_counter >= wait:
				owner.team.player_control.set_state(PlayerStatePass.new())
