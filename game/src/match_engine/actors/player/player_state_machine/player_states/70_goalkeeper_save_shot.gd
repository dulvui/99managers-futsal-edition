# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperSaveShot
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperSaveShot")


func enter() -> void:
	# theoretical ball ray/destination
	var ball_destination: Vector2 = owner.ball.pos
	ball_destination += owner.ball.direction * SimField.WIDTH

	# use ball destination to get best saving point
	var save_spot: Vector2 = Geometry2D.get_closest_point_to_segment(
		owner.player.pos,
		owner.ball.pos,
		ball_destination
	)

	owner.player.set_destination(save_spot, 20)

