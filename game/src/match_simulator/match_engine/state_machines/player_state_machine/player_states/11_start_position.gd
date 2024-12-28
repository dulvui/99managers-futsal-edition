# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateStartPosition
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateStartPosition")


func enter() -> void:
	# move to position and add some noise
	var start_position: Vector2 = owner.player.start_pos
	start_position.x += RngUtil.match_noise(5, 5)
	start_position.y += RngUtil.match_noise(5, 5)
	owner.player.set_destination(start_position)


func execute() -> void:
	if owner.player.destination_reached():
		set_state(PlayerStateKickoff.new())
