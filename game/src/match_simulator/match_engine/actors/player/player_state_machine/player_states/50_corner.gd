# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateCorner
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateCorner")


func enter() -> void:
	if owner.player.is_goalkeeper:
		return

	var deviation: Vector2 = Vector2(RngUtil.match_rng.randi_range(-50, 50),RngUtil.match_rng.randi_range(-50, 50))

	if owner.team.left_half:
		if owner.team.has_ball:
			owner.player.set_destination(owner.field.penalty_areas.spot_right + deviation)
		else:
			owner.player.set_destination(owner.field.penalty_areas.spot_left + deviation)
	else:
		if owner.team.has_ball:
			owner.player.set_destination(owner.field.penalty_areas.spot_left + deviation)
		else:
			owner.player.set_destination(owner.field.penalty_areas.spot_right + deviation)


func execute() -> void:
	pass
