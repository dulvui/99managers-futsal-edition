# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateFreeKick
extends PlayerStateMachineState

var wait: int
var wait_after_shot: int


func _init() -> void:
	super("PlayerStateFreeKick")


func enter() -> void:
	owner.player.head_look = owner.field.ball.pos
	# move player 1m behind ball
	var destination: Vector2 = owner.field.ball.pos
	if owner.player.left_half:
		destination += destination.direction_to(owner.field.goals.left) * owner.field.PIXEL_FACTOR * 1
	else:
		destination += destination.direction_to(owner.field.goals.right) * owner.field.PIXEL_FACTOR * 1
	owner.player.set_destination(destination)

	wait = owner.player.rng.randi_range(3, 7)
	wait_after_shot = 1


func execute() -> void:
	# wait for player to reach spot
	if not owner.player.destination_reached():
		return

	owner.player.head_look = Vector2.ZERO

	# wait a bit
	if wait > 0:
		wait -= 1
		return

	# TODO decicde if shooting or passing

	# shoot
	owner.field.ball.free_kick(owner.player)
	# resume clock
	owner.field.clock_running = true

	# go idle and let team move player back to center, if needed
	owner.player.set_state(PlayerStateIdle.new())

	if wait_after_shot > 0:
		wait_after_shot -= 1
		return


