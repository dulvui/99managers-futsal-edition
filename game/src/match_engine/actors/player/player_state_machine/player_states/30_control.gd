# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateControl
extends PlayerStateMachineState

# 80 squared
const PERFECT_SHOOT_DISTANCE_SQUARED: int = 5600
# 120 squared
const PERFECT_PASS_DISTANCE_SQUARED: int = 19600


func _init() -> void:
	super("PlayerStateControl")


func execute() -> void:
	# if player doesn't touch balls, follow it
	if not owner.player.is_touching_ball():
		owner.player.follow(owner.field.ball)
		return 
	
	owner.player.stop()
	owner.field.ball.stop()
	
	# player is touching ball
	# try to shoot, dribble and pass
	
	if should_shoot():
		set_state(PlayerStateShoot.new())
		return

	# if should_dribble():
	# 	set_state(PlayerStateDribble.new())
	# 	return

	if owner.player.rng.randi() % 2 == 0:
		pass_ball()
	else:
		pass_ball_random()
	set_state(PlayerStateAttack.new())


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


func pass_ball() -> void:
	# find best pass
	var best_player: SimPlayer
	var delta: float = 1.79769e308 # max float
	for player: SimPlayer in owner.team.players:
		if player != owner.player:
			var distance: float = player.pos.distance_squared_to(owner.player.pos)
			if distance < delta:
				delta = distance
				best_player = player
	
	owner.team.player_receive_ball(best_player)
	owner.field.ball.short_pass(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1



func pass_ball_random() -> void:
	var random_player: SimPlayer
	var random_index: int = owner.rng.randi() % 5
	
	if random_index == owner.team.players.find(owner.player):
		random_index += 1
		random_index %= 5

	random_player = owner.team.players[random_index]

	owner.team.player_receive_ball(random_player)
	owner.field.ball.short_pass(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1
