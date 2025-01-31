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
