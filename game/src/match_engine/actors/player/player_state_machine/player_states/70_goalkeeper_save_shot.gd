# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateGoalkeeperSaveShot
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateGoalkeeperSaveShot")


func enter() -> void:
	# theoretical ball ray/destination
	var ball_destination: Vector2 = owner.field.ball.pos
	ball_destination += owner.field.ball.direction * SimField.WIDTH

	# use ball destination to get best saving point
	var save_spot: Vector2 = Geometry2D.get_closest_point_to_segment(
		owner.player.pos,
		owner.field.ball.pos,
		ball_destination
	)

	owner.player.set_destination(save_spot, 20)


func execute() -> void:
	# touching ball
	if owner.player.is_touching_ball():
		owner.team.gain_possession()
		owner.team.set_state(TeamStateGoalkeeper.new())
		owner.team.team_opponents.set_state(TeamStateGoalkeeper.new())
		return

