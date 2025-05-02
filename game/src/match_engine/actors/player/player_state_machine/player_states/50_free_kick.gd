# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateFreeKick
extends PlayerStateMachineState

var wait: int


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

	wait = owner.rng.randi_range(3, 7)


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
	var power: int = owner.player.player_res.attributes.technical.shooting
	owner.field.ball.colission_timer = 1
	var random_target: Vector2
	if owner.player.left_half:
		random_target = owner.field.goals.right
	else:
		random_target = owner.field.goals.left

	# 1.0 best, 0.05 worst
	var aim_factor: float = 20.0 / owner.player.player_res.attributes.technical.free_kick
	# 0.6 best, 1.55 worst
	var aim: float = 0.6 + (1.0 - aim_factor)

	random_target += Vector2(0, owner.rng.randf_range(-SimGoals.SIZE * aim, SimGoals.SIZE * aim))

	var direction: Vector2 = owner.field.ball.pos.direction_to(random_target)

	owner.field.ball.impulse(direction, power * owner.rng.randi_range(1, 3))


	# go idle and let team move player back to center, if needed
	owner.player.set_state(PlayerStateIdle.new())

