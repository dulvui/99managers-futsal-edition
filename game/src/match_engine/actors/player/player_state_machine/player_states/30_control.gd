# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateControl
extends PlayerStateMachineState

# half field width
const MAX_SHOOT_DISTANCE_SQUARED: int = int(pow(SimField.WIDTH / 2.0, 2))

var shot_direction: Vector2
var shot_force: float
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
		# shoot on goal
		owner.field.ball.impulse(shot_direction, shot_force)
		# set opponent goalkeeper in save state
		owner.team.team_opponents.players[0].set_state(PlayerStateGoalkeeperSaveShot.new())
		return


	if owner.player.rng.randi() % 2 == 0:
		pass_ball()
		return

	# dribble, by slightly kicking ball towards goal
	if owner.team.left_half:
		owner.field.ball.impulse(owner.player.pos + Vector2(50, 0), 11)
	else:
		owner.field.ball.impulse(owner.player.pos + Vector2(-50, 0), 11)
	owner.player.follow(owner.field.ball, 10)


func should_shoot() -> bool:
	# check if player is close enough to shoot
	var distance_squared: float = owner.player.pos.distance_squared_to(opponent_goal)
	if distance_squared > MAX_SHOOT_DISTANCE_SQUARED:
		return false

	# difine force
	shot_force = owner.rng.randi_range(30, 50)
	shot_force += owner.player.player_res.attributes.technical.shooting


	# define random attempts to aim and see how many players oppose
	var attempts: int = owner.rng.randi_range(1, shooting_ability)
	for i: int in attempts:
		var y: int = owner.rng.randi_range(owner.field.goals.post_top, owner.field.goals.post_bottom)
		var shot_attempt: Vector2 = Vector2(opponent_goal.x, y)

		# check if opponent players block shot
		if owner.team.is_ball_safe_from_opponents(shot_attempt, shot_force):
			shot_direction = owner.field.ball.pos.direction_to(shot_attempt)
			return true

	return false


func pass_ball() -> void:
	var pass_force: float = 20

	# find best pass
	var best_player: SimPlayer
	var delta: float = SimField.WIDTH * SimField.HEIGHT
	for player: SimPlayer in owner.team.players:
		if player != owner.player:

			if not owner.team.is_ball_safe_from_opponents(player.pos, pass_force):
				continue

			var distance: float = player.pos.distance_squared_to(owner.player.pos)
			if distance < delta:
				delta = distance
				best_player = player
	
	# no player found
	if	best_player == null:
		return

	owner.team.player_receive_ball(best_player)
	owner.field.ball.impulse(owner.team.player_receive_ball().pos, pass_force)
	owner.team.stats.passes += 1

	set_state(PlayerStateAttack.new())
