# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateKickoff
extends PlayerStateMachineState


func execute() -> void:
	# start positon is reached
	if owner.player.destination_reached():
		set_state(PlayerStateStartPosition.new())
