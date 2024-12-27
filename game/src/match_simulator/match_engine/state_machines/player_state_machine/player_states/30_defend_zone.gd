# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateDefendZone
extends PlayerStateMachineState


func enter() -> void:
	owner.player.set_destination(owner.player.start_pos)

func execute() -> void:
	if owner.player.destination_reached():
		owner.player.stop()
	
