# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func enter() -> void:
	owner.player.follow(owner.ball)


func execute() -> void:
	# update follow distance, depending on how close ball is to own goal
	if owner.player.left_half:
		var distance_to_goal: float = owner.field.goals.left.distance_squared_to(owner.ball.pos)
		owner.player.follow_distance_squared = distance_to_goal / 100.0
	else:
		var distance_to_goal: float = owner.field.goals.right.distance_squared_to(owner.ball.pos)
		owner.player.follow_distance_squared = distance_to_goal / 100.0

	# check for foul
	var controlling_player: SimPlayer = owner.team.team_opponents.player_control()
	if owner.player.collides(controlling_player):
		# TODO take aggressivity and other attributes into account
		owner.team.stats.tackles += 1
		if owner.rng.randi_range(0, 100) > 95:
			# TODO check yellow/red card
			owner.team.foul.emit(controlling_player.pos)
			return
		else:
			owner.team.stats.tackles_success += 1
	
	# check if ball can be taken
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

