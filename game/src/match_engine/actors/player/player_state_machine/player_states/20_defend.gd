# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateDefend
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateDefense")


func execute() -> void:
	if owner.player.is_goalkeeper:
		set_state(PlayerStateGoalkeeperFollowBall.new())
	else:
		owner.player.move_defense_pos()

