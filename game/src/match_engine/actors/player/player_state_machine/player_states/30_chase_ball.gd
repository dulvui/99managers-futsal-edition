# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateChaseBall
extends PlayerStateMachineState


func _init() -> void:
	super("PlayerStateChaseBall")


func enter() -> void:
	owner.player.follow(owner.field.ball)


func execute() -> void:
	# check for foul
	var controlling_player: SimPlayer = owner.team.team_opponents.player_control()
	if owner.player.collides(controlling_player):
		# TODO take aggressivity and other attributes into account
		owner.team.stats.tackles += 1
		if owner.player.rng.randi_range(0, 100) > 80:
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

