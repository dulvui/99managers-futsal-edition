# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")

func enter() -> void:
	owner.player.follow(owner.field.ball, 40)


func execute() -> void:
	if owner.player.is_touching_ball():
		owner.team.player_control(owner.player)
		owner.team.interception.emit()
		set_state(PlayerStateAttack.new())
		return
	
	# make sure goalkeeper doesn't follow ball too far away from penalty area
	if owner.player.is_goalkeeper:
		if owner.player.left_half:
			if owner.player.pos.distance_squared_to(owner.player.left_base) > 5600:
				owner.player.move_defense_pos()
				set_state(PlayerStateIdle.new())
				return
		else:
			if owner.player.pos.distance_squared_to(owner.player.right_base) > 5600:
				owner.player.move_defense_pos()
				set_state(PlayerStateIdle.new())
				return

