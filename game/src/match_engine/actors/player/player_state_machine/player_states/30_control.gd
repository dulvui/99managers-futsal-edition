# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateControl
extends PlayerStateMachineState

# half field width
const MAX_SHOOT_DISTANCE_SQUARED: int = int(pow(SimField.WIDTH / 2.0, 2))
# half field height
const PERFECT_PASS_DISTANCE_SQUARED: int = int(pow(SimField.HEIGHT / 2.0, 2))
const BLOCK_DISTANCE_SQUARED: int = int(pow(SimField.WIDTH / 20.0, 2))

var shoot_direction: Vector2
var shooting_ability: int
var opponent_goal: Vector2


func _init() -> void:
	super("PlayerStateControl")


func enter() -> void:
	# use players shooting attributes, to players with better shooging
	# make more and better attempts
	# how many aim attempts the player takes
	shooting_ability = owner.player.player_res.attributes.technical.shooting

	# save opponent goal
	if owner.player.left_half:
		opponent_goal = owner.field.goals.right
	else:
		opponent_goal = owner.field.goals.left
	

func execute() -> void:
	# if player doesn't touch balls, follow it
	if not owner.player.is_touching_ball():
		owner.player.follow(owner.field.ball)
		return

	owner.player.stop()
	owner.field.ball.stop()

	if should_shoot():
		# print("shoot on goal")
		var power: int = owner.rng.randi_range(30, 50)
		power += owner.player.player_res.attributes.technical.shooting

		# shoot on goal
		owner.field.ball.impulse(shoot_direction, power)
		# set opponent goalkeeper in save state
		owner.team.team_opponents.players[0].set_state(PlayerStateGoalkeeperSaveShot.new())
		return

	# if should_dribble():
	# 	# slightly kick ball towards goal
	# 	if owner.team.left_half:
	# 		owner.field.ball.impulse(owner.player.pos + Vector2(50, 0), 11)
	# 	else:
	# 		owner.field.ball.impulse(owner.player.pos + Vector2(-50, 0), 11)
	# 	owner.player.follow(owner.field.ball, 10)
	# 	return

	if owner.player.rng.randi() % 2 == 0:
		pass_ball()
		set_state(PlayerStateAttack.new())
	else:
		pass_ball_random()
		set_state(PlayerStateAttack.new())


func should_shoot() -> bool:
	# check if player is close enough to shoot
	var distance_squared: float = owner.player.pos.distance_squared_to(opponent_goal)
	if distance_squared > MAX_SHOOT_DISTANCE_SQUARED:
		return false

	# define random attempts to aim and see how many players oppose
	var attempts: int = owner.rng.randi_range(1, shooting_ability)
	for i: int in attempts:
		var y: int = owner.rng.randi_range(owner.field.goals.post_top, owner.field.goals.post_bottom)
		var shot_attempt: Vector2 = Vector2(opponent_goal.x, y)

		# check if opponent players block shot
		var gets_blocked: bool = false
		for player: SimPlayer in owner.team.team_opponents.players:
			var closest_point_to_trajectory: Vector2 = Geometry2D.get_closest_point_to_segment(
				player.pos,
				owner.field.ball.pos,
				shot_attempt
			)
			var distance: float = closest_point_to_trajectory.distance_squared_to(player.pos)
			if distance < BLOCK_DISTANCE_SQUARED:
				gets_blocked = true
				break

		if not gets_blocked:
			shoot_direction = owner.field.ball.pos.direction_to(shot_attempt)
			return true

	return false


func pass_ball() -> void:
	# find best pass
	var best_player: SimPlayer
	var delta: float = owner.field.WIDTH * owner.field.HEIGHT
	for player: SimPlayer in owner.team.players:
		if player != owner.player:
			var distance: float = player.pos.distance_squared_to(owner.player.pos)
			if distance < delta:
				delta = distance
				best_player = player

	owner.team.player_receive_ball(best_player)
	owner.field.ball.impulse(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1


func pass_ball_random() -> void:
	var random_player: SimPlayer
	var random_index: int = owner.rng.randi() % 5

	if random_index == owner.team.players.find(owner.player):
		random_index += 1
		random_index %= 5

	random_player = owner.team.players[random_index]

	owner.team.player_receive_ball(random_player)
	owner.field.ball.impulse(owner.team.player_receive_ball().pos, 20)
	owner.team.stats.passes += 1
