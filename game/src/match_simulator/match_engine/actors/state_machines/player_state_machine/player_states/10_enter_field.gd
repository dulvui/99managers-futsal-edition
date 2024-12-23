# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateEnterField
extends PlayerStateMachineState


func enter() -> void:
	# move to center
	owner.player.set_destination(owner.field.center)


func execute() -> void:
	# start positon is reached
	if owner.player.destination_reached():
		set_state(PlayerStateStartPosition.new())
