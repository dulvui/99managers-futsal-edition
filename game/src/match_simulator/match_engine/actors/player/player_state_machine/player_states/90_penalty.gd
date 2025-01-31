# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStatePenalty
extends PlayerStateMachineState



func _init() -> void:
	super("PlayerStatePenalty")


func enter() -> void:
	owner.field.ball.set_pos(owner.field.penalty_areas.spot_left)
	owner.player.set_destination(owner.field.penalty_areas.spot_left)


func execute() -> void:
	# wait for player to reach spot
	if not owner.player.destination_reached():
		return
	
	# wait for goalkeeper to be ready
	if not owner.field.penalties_ready:
		return

	# TODO use penalty abilities
	owner.field.ball.shoot_on_goal(owner.player.player_res, true)

	# go idle and let team move player back to center, if needed
	owner.player.set_state(PlayerStateIdle.new())
