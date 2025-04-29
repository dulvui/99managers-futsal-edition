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

	shoot()

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


func shoot() -> void:
	var left_half: bool = owner.field.ball.pos.x < SimField.WIDTH / 2.0

	var power: float = 20 + owner.player.player_res.attributes.technical.shooting
	power *= owner.rng.randf_range(2.0, 3.0)

	owner.field.ball.colission_timer = 0

	var random_target: Vector2
	if left_half:
		random_target = owner.field.goals.left
	else:
		random_target = owner.field.goals.right

	# 1.0 best, 0.05 worst
	var aim_factor: float = 20.0 / owner.player.player_res.attributes.technical.penalty
	# 0.6 best, 1.55 worst
	var aim: float = 0.6 + (1.0 - aim_factor)

	random_target += Vector2(0, owner.rng.randf_range(-SimGoals.SIZE * aim, SimGoals.SIZE * aim))

	var direction: Vector2 = owner.field.ball.pos.direction_to(random_target)
	owner.field.ball.impulse(direction, power)

