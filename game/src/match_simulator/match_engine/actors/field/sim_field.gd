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
const LINE_WIDTH: float = 0.10 * PIXEL_FACTOR  # in cm

# distance between wall and line
const WALL_DISTANCE: int = 5 * PIXEL_FACTOR


# Note: don't use Rect2, to keep simple and human-readable names for coordinates
var size: Vector2  # with borders
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
var goalkeeper_ball: bool
var kickin: bool

# add all resources here, so they can be accessedeasily
# especiially inside the state machines
var ball: SimBall
var left_team: SimTeam
var right_team: SimTeam

var calculator: SimFieldCalculator

# walls to limit ball space
var wall_top: CollidingActor
var wall_bottom: CollidingActor
var wall_left: CollidingActor
var wall_right: CollidingActor


func _init(rng: RandomNumberGenerator) -> void:
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
	ball = SimBall.new(rng)
	ball.setup(self)
	
	# flags
	clock_running = false
	goalkeeper_ball = false
	kickin = false

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
	calculator.update()
	ball.update()

	# check field bounds
	if clock_running:
		if not _check_goal_line():
			_check_touch_line()
		goals.check_post_colissions(ball)

		# collissions
		# _check_ball_wall_colissions()
		_check_ball_players_colissions()
		# _check_player_colissions()


func force_update_calculator() -> void:
	calculator.update(true)


func bound(pos: Vector2) -> Vector2:
	pos.x = maxi(mini(int(pos.x), int(line_right)), 1)
	pos.y = maxi(mini(int(pos.y), int(line_bottom)), 1)
	return pos


func _check_touch_line() -> void:
	# kick in / y axis
	if ball.pos.y < line_top:
		var intersection: Variant = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, top_left, top_right
		)
		if intersection:
			clock_running = false
			ball.set_pos(intersection)
			touch_line_out.emit()
			return
	if ball.pos.y > line_bottom:
		var intersection: Variant = Geometry2D.segment_intersects_segment(
			ball.last_pos, ball.pos, bottom_left, bottom_right
		)
		if intersection:
			clock_running = false
			ball.set_pos(intersection)
			touch_line_out.emit()
			return


func _check_goal_line() -> bool:
	# left
	if ball.pos.x < line_left:
		clock_running = false

		if goals.is_goal_left(ball):
			ball.stop()
			goal_left.emit()
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


func _check_ball_wall_colissions() -> void:
	var colission: Variant

	if ball.direction.y < 0:
		colission = wall_top.collides(ball.last_pos, ball.pos)
		if colission != null:
			ball.direction = colission
			return
	else:
		colission = wall_bottom.collides(ball.last_pos, ball.pos)
		if colission != null:
			ball.direction = colission
			return
	
	if ball.direction.x < 0:
		colission = wall_left.collides(ball.last_pos, ball.pos)
		if colission != null:
			ball.direction = colission
			return
	else:	
		colission = wall_right.collides(ball.last_pos, ball.pos)
		if colission != null:
			ball.direction = colission
			return


func _check_ball_players_colissions() -> void:
	if not ball.is_moving():
		return

	if ball.colission_timer > 0:
		ball.colission_timer -= 1
		return

	for player: SimPlayer in left_team.players:
		if player.collides(ball):
			ball.stop()
			return

	for player: SimPlayer in right_team.players:
		if player.collides(ball):
			ball.stop()
			return


func _check_player_colissions() -> void:
	if clock_running:
		for player: SimPlayer in left_team.players:
			for player2: SimPlayer in right_team.players:
				if player.collides(player2):
					player.stop()


