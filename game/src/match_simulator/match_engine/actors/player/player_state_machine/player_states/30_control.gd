# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateControl
extends PlayerStateMachineState

# 80 squared
const PERFECT_SHOOT_DISTANCE_SQUARED: int = 5600


func _init() -> void:
	super("PlayerStateControl")


func execute() -> void:
	# check if player is still in control
	if owner.team.player_control() != owner.player:
		set_state(PlayerStateAttack.new())

	# check if player touches balls
	# if not, follow ball
	if not owner.player.is_touching_ball():
		owner.player.follow(owner.field.ball, 40)
		return 
	
	owner.field.ball.stop()

	# check shoot
	if should_shoot():
		# print("shoot")
		set_state(PlayerStateShoot.new())
		return

	# check pass
	if owner.rng.randi() % 100 < 95:
		# print("pass")
		set_state(PlayerStatePass.new())
		return

	# check dribble
	# print("dribble")
	set_state(PlayerStatePass.new())


func should_shoot() -> bool:
	if owner.team.left_half:
		var distance_squared: float = owner.player.pos.distance_squared_to(owner.field.goals.right)
		if distance_squared < PERFECT_SHOOT_DISTANCE_SQUARED:
			return owner.rng.randi() % 100 < 80
	return owner.rng.randi() % 100 < 5


func should_dribble() -> bool:
	# check opposite players between player and goal
	var opposing_player_count: int = 0
	if owner.team.left_half:
		for player: SimPlayer in owner.team.team_opponents.players:
			if player.pos.x > owner.player.pos.x:
				opposing_player_count += 1
	else:
		for player: SimPlayer in owner.team.team_opponents.players:
			if player.pos.x < owner.player.pos.x:
				opposing_player_count += 1
	
	return owner.rng.randi() % 100 < 100 - (opposing_player_count * 20)

