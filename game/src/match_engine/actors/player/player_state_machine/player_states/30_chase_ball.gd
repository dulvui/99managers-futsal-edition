# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func execute() -> void:
	print("chase %d" % owner.player.player_res.nr)
	# update follow distance, depending on how close ball is to own goal
	if not owner.team.has_ball:
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
	else:	
		owner.player.follow_distance_squared = 0.0

	owner.player.follow(owner.ball, 10)
	
	# make sure goalkeeper doesn't follow ball too far away from penalty area
	# if owner.player.is_goalkeeper:
	# 	if owner.player.left_half:
	# 		if owner.player.pos.distance_squared_to(owner.player.left_base) > 6400:
	# 			set_state(PlayerStateDefend.new())
	# 			return
	# 	else:
	# 		if owner.player.pos.distance_squared_to(owner.player.right_base) > 6400:
	# 			set_state(PlayerStateDefend.new())
	# 			return

