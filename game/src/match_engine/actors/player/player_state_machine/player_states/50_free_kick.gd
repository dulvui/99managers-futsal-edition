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
	owner.player.set_destination(owner.field.ball.pos)

	wait = owner.player.rng.randi_range(3, 7)
	wait_after_shot = owner.player.rng.randi_range(2, 7)


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
	owner.field.ball.free_kick(owner.player.player_res)

	if wait_after_shot > 0:
		wait_after_shot -= 1
		return

	# go idle and let team move player back to center, if needed
	owner.player.set_state(PlayerStateIdle.new())


