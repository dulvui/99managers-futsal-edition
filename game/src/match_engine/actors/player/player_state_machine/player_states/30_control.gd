# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateControl
extends PlayerStateMachineState

# min distance from where shoot attempt is made
const MIN_SHOOT_DISTANCE_SQUARED: int = int(pow(SimField.WIDTH / 3.0, 2))

var opponent_goal: Vector2

# shooting
var shot_direction: Vector2
var shot_force: float
var shooting_ability: int

# passing
var best_pass_player: SimPlayer
var pass_direction: Vector2
var pass_force: float = 20


func _init() -> void:
	super("PlayerStateControl")


func enter() -> void:
	owner.player.collision_timer = 0

	# goal keeper should immediate pass ball
	if owner.player.is_goalkeeper:
		set_state(PlayerStateFindBestPass.new())
		return

	# use players shooting attributes, to players with better shooting
	# make more and better attempts
	# how many aim attempts the player takes
	shooting_ability = owner.player.res.attributes.technical.shooting

	# save opponent goal
	if owner.player.left_half:
		opponent_goal = owner.field.goals.right
	else:
		opponent_goal = owner.field.goals.left


func execute() -> void:
	if should_shoot():
		# print("%d shoot" % owner.player.res.nr)
		owner.team.stats.shots += 1
		# shoot on goal
		owner.ball.impulse(shot_direction, shot_force)
		# set opponent goalkeeper to save state
		owner.team.team_opponents.players[0].set_state(
			PlayerStateGoalkeeperSaveShot.new()
		)
		owner.player.collision_timer = Const.TICKS
		set_state(PlayerStateAttack.new())
		return

	if should_pass():
		# print("%d pass to %d" % [
		# 	owner.player.res.nr, best_pass_player.res.nr
		# ])
		owner.team.stats.passes += 1
		owner.team.player_receive_ball(best_pass_player)
		owner.player.collision_timer = Const.TICKS
		owner.ball.impulse(pass_direction, pass_force)
		set_state(PlayerStateAttack.new())
		return

	# dribble, by slightly kicking ball towards goal
	# print("dribble")
	var dribble_direction: Vector2 = owner.player.pos.direction_to(opponent_goal)
	owner.player.collision_timer = Const.TICKS
	owner.ball.impulse(dribble_direction, 8)
	owner.set_state(PlayerStateChaseBall.new())


func should_shoot() -> bool:
	# check if player is close enough to shoot
	var distance_squared: float = owner.player.pos.distance_squared_to(opponent_goal)
	if distance_squared > MIN_SHOOT_DISTANCE_SQUARED:
		return false

	# define force
	shot_force = owner.rng.randi_range(30, 50)
	shot_force += owner.player.res.attributes.technical.shooting

	# define random attempts to aim and see how many players oppose
	var attempts: int = owner.rng.randi_range(1, shooting_ability)
	for i: int in attempts:
		var y: int = owner.rng.randi_range(
			owner.field.goals.post_top, owner.field.goals.post_bottom
		)
		var shot_attempt: Vector2 = Vector2(opponent_goal.x, y)

		# check if opponent players block shot
		if owner.team.is_ball_safe(owner.ball.pos, shot_attempt, shot_force) > 0.6:
			shot_direction = owner.ball.pos.direction_to(shot_attempt)
			return true

	return false


func should_pass() -> bool:
	# find best pass
	best_pass_player = owner.team.find_best_pass(owner.player, pass_force)

	if best_pass_player != null:
		pass_direction = owner.ball.pos.direction_to(best_pass_player.pos)
		return true

	return false

