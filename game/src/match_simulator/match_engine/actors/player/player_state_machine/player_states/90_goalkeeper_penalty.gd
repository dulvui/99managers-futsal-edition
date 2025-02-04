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
	owner.field.penalty_ready = false

	owner.player.head_look = owner.field.goals.left
	owner.player.set_destination(owner.field.goals.left)

	is_saving = false
	# pick random spot where goalkeeper will try to save
	# deviation on y axis from current pos
	var save_attempt_spot_y: int = owner.player.rng.randi_range(-owner.field.goals.size / 2, owner.field.goals.size / 2)
	var save_attempt_spot_x: int = owner.player.rng.randi_range(0, 20)
	save_attempt_spot = owner.player.destination + Vector2(save_attempt_spot_x, save_attempt_spot_y)

	wait = 3


func execute() -> void:
	if not owner.player.destination_reached():
		return
	
	owner.player.head_look = Vector2.ZERO

	if wait > 0:
		wait -= 1
		return

	owner.field.penalty_ready = true

	if not is_saving:
		owner.player.set_destination(save_attempt_spot, 30)
		is_saving = true


func exit() -> void:
	owner.field.penalty_ready = false


