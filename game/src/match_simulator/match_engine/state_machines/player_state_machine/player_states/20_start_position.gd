# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateStartPosition
extends PlayerStateMachineState


func enter() -> void:
	# move to position
	owner.player.set_destination(owner.player.start_pos)


func execute() -> void:
	
	if owner.player.destination_reached():
		set_state(PlayerStateWait.new())