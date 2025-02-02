# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStatePenalties
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStatePenalties")


func enter() -> void:
	var deviation: Vector2 = Vector2(0, 20 * (owner.team.players.find(owner.player) + 1))
	if owner.team.left_half:
		deviation = -deviation
	
	var destination: Vector2 = owner.field.center + deviation
	owner.player.head_look = destination
	owner.player.set_destination(destination)


func execute() -> void:
	# wait for player to reach spot
	if not owner.player.destination_reached():
		return

	owner.player.head_look = Vector2.ZERO
