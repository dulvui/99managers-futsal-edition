# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateStartPosition
extends PlayerStateMachineState


func enter() -> void:
	# move to position
	var player: SimPlayer = owner.player
	player.set_destination(player.start_pos)


func execute() -> void:
	
	if owner.player.destination_reached():
		change_to(PlayerStateWait.new())
