# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimField

signal touch_line_out

signal goal_line_out_left
signal goal_line_out_right

signal goal_left
signal goal_right

# 1 meter = x PIXEL_FACTOR
const PIXEL_FACTOR: int = 28

const BORDER_SIZE: int = 2 * PIXEL_FACTOR
const WIDTH: int = 42 * PIXEL_FACTOR
const HEIGHT: int = 25 * PIXEL_FACTOR
const CENTER_CIRCLE_RADIUS: int = 3 * PIXEL_FACTOR
const LINE_WIDTH: float = 0.10 * PIXEL_FACTOR # in cm

# distance between wall and line
const WALL_DISTANCE: int = 5 * PIXEL_FACTOR

# Note: don't use Rect2, to keep simple and human-readable names for coordinates
var size: Vector2 # with borders
var center: Vector2
# corners
var top_left: Vector2
var top_right: Vector2
var bottom_left: Vector2
var bottom_right: Vector2
# lines
var line_top: int
var line_bottom: int
var line_left: int
var line_right: int

var goals: SimGoals
var penalty_areas: SimPenaltyAreas

var clock_running: bool
var kickoff: bool
var kickin: bool
var corner: bool
var penalty: bool
var free_kick: bool

var penalties: bool
# flag to see if during penalties goalkeeper and player are ready
# could potentially be replaced with referree
var penalty_ready: bool

var free_kick_spot: Vector2

# add all resources here, so they can be accessedeasily
# especiially inside the state machines
var ball: SimBall
var left_team: SimTeam
var right_team: SimTeam

# only once instance is needed, because only on team is attacking at the time
var calculator: SimFieldCalculator

# walls to limit ball space
var wall_top: CollidingActor
var wall_bottom: CollidingActor
var wall_left: CollidingActor
var wall_right: CollidingActor


func _init() -> void:
	#size = sprite.texture.get_size()
	size = Vector2(WIDTH + BORDER_SIZE * 2, HEIGHT + BORDER_SIZE * 2)

	center = Vector2(size.x / 2, size.y / 2)

	line_top = BORDER_SIZE
	line_bottom = line_top + HEIGHT
	line_left = BORDER_SIZE
	line_right = line_left + WIDTH

	top_left = Vector2(line_left, line_top)
	top_right = Vector2(line_right, line_top)
	bottom_left = Vector2(line_left, line_bottom)
	bottom_right = Vector2(line_right, line_bottom)

	# goals
	goals = SimGoals.new(self)
	goals.post_hit_left.connect(_on_goals_post_hit_left)
	goals.post_hit_right.connect(_on_goals_post_hit_right)

	# penalty area
	penalty_areas = SimPenaltyAreas.new(self, goals)

	# ball
	ball = SimBall.new()
	ball.setup(self)

	# flags
	clock_running = false
	kickoff = false
	kickin = false
	corner = false
	free_kick = false
	penalty = false

	penalties = false
	penalty_ready = false

	# field calculator
	calculator = SimFieldCalculator.new(self)

	# walls
	wall_top = CollidingActor.new(
		top_left + Vector2(-WALL_DISTANCE, -WALL_DISTANCE),
		top_right + Vector2(WALL_DISTANCE, -WALL_DISTANCE)
	)
	wall_bottom = CollidingActor.new(
		bottom_left + Vector2(-WALL_DISTANCE, WALL_DISTANCE),
		bottom_right + Vector2(WALL_DISTANCE, WALL_DISTANCE)
	)
	wall_left = CollidingActor.new(
		top_left + Vector2(-WALL_DISTANCE, -WALL_DISTANCE),
		bottom_left + Vector2(-WALL_DISTANCE, WALL_DISTANCE)
	)
	wall_right = CollidingActor.new(
		top_right + Vector2(WALL_DISTANCE, -WALL_DISTANCE),
		bottom_right + Vector2(WALL_DISTANCE, WALL_DISTANCE)
	)


func update() -> void:
	ball.update()

	calculator.update()

	_check_clock_running()

	# check field bounds
	if clock_running:
		# TODO save post reflection and
		# check if directon goes still towards goal
		goals.check_post_collisions(ball)
		if not _check_goal_line():
			_check_touch_line()

		# _check_ball_wall_collisions()
		_check_ball_players_collisions()
	elif penalties:
		goals.check_post_collisions(ball)
		# _check_ball_wall_collisions()
		_check_goal_line_penalties()
		_check_ball_players_collisions()


func force_update_calculator() -> void:
	calculator.update(true)


func bound(pos: Vector2) -> Vector2:
	pos.x = maxi(mini(int(pos.x), int(line_right)), 1)
	pos.y = maxi(mini(int(pos.y), int(line_bottom)), 1)
	return pos


func active_goal() -> Vector2:
	if left_team.has_ball:
		return goals.right
	return goals.left


func active_team() -> SimTeam:
	if left_team.has_ball:
		return left_team
	return right_team


# return ticks needed to reach destination with given force
# returns FULL_TIME_TICKS if cannot be reached in time
func get_ticks_to_reach(from: Vector2, to: Vector2, force: float, friction: float) -> int:
	var direction: Vector2 = from.direction_to(to)
	var ticks: int = 0
	var distance: float = from.distance_squared_to(to)

	# use 10px squared as min distance, for performance
	while distance > 100:
		from += direction * force * Const.SPEED
		ticks += 1
		force -= friction

		# will never reach target
		if force < 0.0:
			# simply return biiiiig number
			return Const.FULL_TIME_TICKS

		distance = from.distance_squared_to(to)

	return ticks


func _check_touch_line() -> void:
	# left
	if ball.pos.y < line_top:
		var intersection: Variant = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, top_left, top_right
		)
		if intersection:
			clock_running = false
			var vector: Vector2 = intersection
			ball.set_pos(vector)
			touch_line_out.emit()
			return
	# right
	if ball.pos.y > line_bottom:
		var intersection: Variant = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, bottom_left, bottom_right
		)
		if intersection:
			clock_running = false
			var vector: Vector2 = intersection
			ball.set_pos(vector)
			touch_line_out.emit()
			return


func _check_goal_line() -> bool:
	# left
	if ball.pos.x < line_left:
		clock_running = false

		if goals.is_goal_left(ball):
			ball.stop()
			goal_left.emit()
			kickoff = true
			return true

		# corner
		if ball.pos.y < center.y:
			ball.set_pos(top_left)
		else:
			ball.set_pos(bottom_left)

		goal_line_out_left.emit()
		return true

	# right
	if ball.pos.x > line_right:
		clock_running = false

		if goals.is_goal_right(ball):
			ball.stop()
			goal_right.emit()
			kickoff = true
			return true

		# corner
		if ball.pos.y < center.y:
			ball.set_pos(top_right)
		else:
			ball.set_pos(bottom_right)

		goal_line_out_right.emit()
		return true

	return false


func _on_goals_post_hit_left() -> void:
	left_team.stats.shots_hit_post += 1


func _on_goals_post_hit_right() -> void:
	left_team.stats.shots_hit_post += 1


func _check_ball_wall_collisions() -> void:
	var reflection: Variant

	# up, check top wall
	if ball.direction.y < 0:
		reflection = wall_top.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			return
	else:
	# down, check bottom wall
		reflection = wall_bottom.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			return

	# left, check left wall
	if ball.direction.x < 0:
		reflection = wall_left.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			return
	else:
	# right, check right wall
		reflection = wall_right.collides(ball.last_pos, ball.pos)
		if reflection != null:
			ball.direction = reflection
			return


func _check_ball_players_collisions() -> void:
	if not ball.is_moving():
		return

	for player: SimPlayer in left_team.players + right_team.players:
		if ball.collides_with_player(player):

			# player gains control, except for penalties
			if not penalties:
				player.gain_control()

			return


func _check_goal_line_penalties() -> void:
	# left
	if ball.pos.x < line_left:
		if goals.is_goal_left(ball):
			goal_left.emit()
		ball.stop()
	# right
	if ball.pos.x > line_right:
		if goals.is_goal_right(ball):
			goal_right.emit()
		ball.stop()


func _check_clock_running() -> void:
	if kickoff:
		clock_running = false
		return
	if kickin:
		clock_running = false
		return
	if corner:
		clock_running = false
		return
	if free_kick:
		clock_running = false
		return
	if penalty:
		clock_running = false
		return
	clock_running = true

