# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStatePenaltyShoot
extends PlayerStateMachineState

var wait: int
var wait_after_shot: int


func _init() -> void:
	super("PlayerStatePenaltyShoot")


func enter() -> void:
	owner.player.head_look = owner.field.ball.pos
	owner.player.set_destination(owner.field.ball.pos)

	wait = 3
	wait_after_shot = owner.player.rng.randi_range(2, 7)

	owner.player.can_collide = false


func execute() -> void:
	# wait for player to reach spot
	if not owner.player.destination_reached():
		return

	owner.player.head_look = Vector2.ZERO

	# wait for goalkeeper to be ready
	if not owner.field.penalty_ready:
		return

	owner.field.ball.penalty(owner.player.player_res)

	# set opponent goalkeeper movement to true
	# so he will start to move towards a random save spot
	owner.team.team_opponents.players[0].can_move = true

	if wait_after_shot > 0:
		wait_after_shot -= 1
		return

	# go idle and let team move player back to center, if needed
	owner.player.set_state(PlayerStateIdle.new())


func exit() -> void:
	owner.player.can_collide = true

