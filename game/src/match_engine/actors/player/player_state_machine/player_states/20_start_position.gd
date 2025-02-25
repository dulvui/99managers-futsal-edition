# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateStartPosition
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateStartPosition")


func enter() -> void:
	owner.player.move_defense_pos()
	owner.player.look_towards_destination()


func execute() -> void:
	if not owner.player.destination_reached():
		return

	owner.player.head_look = Vector2.ZERO
	owner.player.set_state(PlayerStateIdle.new())
