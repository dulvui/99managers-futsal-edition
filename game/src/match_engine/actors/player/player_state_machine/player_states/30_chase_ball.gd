# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func enter() -> void:
	owner.player.follow(owner.field.ball)


func execute() -> void:
	if owner.player.is_touching_ball():
		owner.team.gain_possession()
		owner.team.player_control(owner.player)
		return

	# make sure goalkeeper doesn't follow ball too far away from penalty area
	if owner.player.is_goalkeeper:
		if owner.player.left_half:
			if owner.player.pos.distance_to(owner.player.left_base) > 80:
				set_state(PlayerStateDefend.new())
				return
		else:
			if owner.player.pos.distance_to(owner.player.right_base) > 80:
				set_state(PlayerStateDefend.new())
				return
