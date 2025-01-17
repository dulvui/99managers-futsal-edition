# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoal
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoal")


func enter() -> void:
	var deviation: Vector2 = Vector2(RngUtil.match_rng.randi_range(-50, 50),RngUtil.match_rng.randi_range(-50, 50))
	if owner.team.has_ball:
		owner.player.set_destination(owner.field.center + deviation)

func execute() -> void:
	pass
