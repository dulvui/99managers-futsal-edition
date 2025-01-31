# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperPenalty
extends PlayerStateMachineState


var is_saving: bool
var save_attempt_spot: Vector2


func _init() -> void:
	super("PlayerStateGoalkeeperPenalty")


func enter() -> void:
	owner.player.move_defense_pos()

	is_saving = false
	# pick random spot where goalkeeper will try to save
	# deviation on y axis from current pos
	var save_attempt_spot_y: int = owner.player.rng.randi_range(-owner.field.goals.size / 2, owner.field.goals.size / 2)
	var save_attempt_spot_x: int = owner.player.rng.randi_range(0, 20)
	save_attempt_spot = Vector2(save_attempt_spot_x, save_attempt_spot_y)


func execute() -> void:
	if not owner.player.destination_reached():
		return
	
	owner.field.penalties_ready = true

	if not is_saving and owner.field.ball.is_moving():
		owner.player.set_destination(save_attempt_spot)
		is_saving = true


