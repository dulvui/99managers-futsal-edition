# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperPenalty
extends PlayerStateMachineState

var is_saving: bool
var save_attempt_spot: Vector2
var wait: int


func _init() -> void:
	super("PlayerStateGoalkeeperPenalty")


func enter() -> void:
	wait = 4
	owner.field.penalty_ready = false

	# during penalties, pick always left goal
	if owner.field.penalties or owner.player.left_half:
		owner.player.head_look = owner.field.goals.left
		owner.player.set_destination(owner.field.goals.left)
	else:
		owner.player.head_look = owner.field.goals.right
		owner.player.set_destination(owner.field.goals.right)

	is_saving = false
	# pick random spot where goalkeeper will try to save
	# deviation on y axis from current pos
	var save_attempt_spot_y: int = owner.rng.randi_range(
		int(-SimGoals.SIZE / 2.0), int(SimGoals.SIZE / 2.0)
	)
	var save_attempt_spot_x: int = owner.rng.randi_range(0, 20)
	save_attempt_spot = owner.player.destination + Vector2(save_attempt_spot_x, save_attempt_spot_y)


func execute() -> void:
	if owner.field.penalty_ready:
		return

	if not owner.player.destination_reached():
		return

	# look to ball
	owner.player.head_look = Vector2.ZERO

	# wait before ready
	if wait > 0:
		wait -= 1
		return

	# block goalkeeper from moving
	# when player will shoot, goalkeeper movement gets unlocked
	owner.player.can_move = false
	# set save attempt spot
	owner.player.set_destination(save_attempt_spot, 30)

	# set ready
	owner.field.penalty_ready = true


func exit() -> void:
	owner.field.penalty_ready = false
	owner.player.can_move = true

