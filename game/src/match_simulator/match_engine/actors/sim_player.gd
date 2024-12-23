# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPlayer

# signal short_pass
# signal shoot
# signal interception
# signal tackle
# signal dribble
# signal pass_received

# resources
var player_res: Player
var field: SimField
var state_machine: PlayerStateMachine

# positions
var start_pos: Vector2
var pos: Vector2
var last_pos: Vector2
# movements
var destination: Vector2
var speed: int
#TODO reduce radius with low stamina
var interception_radius: int

# distances, calculated by action util
var distance_to_goal: float
var distance_to_own_goal: float
var distance_to_ball: float
var distance_to_player: float

# goalkeeper properties
var is_goalkeeper: bool
var left_base: Vector2
var right_base: Vector2
var left_half: bool

var has_ball: bool


func _init() -> void:
	# initial test values
	interception_radius = 30
	has_ball = false


func setup(
	p_player_res: Player,
	p_team: SimTeam,
	p_field: SimField,
	p_left_half: bool,
) -> void:
	player_res = p_player_res
	field = p_field
	left_half = p_left_half
	
	state_machine = PlayerStateMachine.new(field, self, p_team)
	
	# goalkeeper properties
	left_base = Vector2(field.line_left + 30, field.size.y / 2)
	right_base = Vector2(field.line_right - 30, field.size.y / 2)


func update() -> void:
	state_machine.execute()
	_move()


func make_goalkeeper() -> void:
	is_goalkeeper = true


func is_touching_ball() -> bool:
	return field.ball.is_touching(pos, interception_radius)


func is_intercepting_ball() -> bool:
	return (
		RngUtil.match_rng.randi_range(1, 100)
		< 59 + player_res.attributes.technical.interception * 2
	)


func set_pos(p_pos: Vector2 = pos) -> void:
	pos = p_pos
	last_pos = pos
	destination = pos
	# reset values
	speed = 0


func set_destination(p_destination: Vector2) -> void:
	if is_goalkeeper:
		destination = get_penalty_area_bounds(p_destination)
	else:
		destination = bound_field(p_destination)
	speed = 20


func destination_reached() -> bool:
	return pos == destination


func stop() -> void:
	speed = 0
	last_pos = pos


func recover_stamina(factor: int = 1) -> void:
	player_res.recover_stamina(factor)


func goalkeeper_follow_ball() -> void:
	# only follow if in own half
	if left_half:
		if field.ball.pos.x < field.size.x / 2:
			set_destination(left_base + left_base.direction_to(field.ball.pos) * 40)
		else:
			set_destination(left_base)
	else:
		if field.ball.pos.x > field.size.x / 2:
			set_destination(right_base + right_base.direction_to(field.ball.pos) * 40)
		else:
			set_destination(right_base)


func get_penalty_area_bounds(p_pos: Vector2) -> Vector2:
	if p_pos.y > field.penalty_area_y_top + 10:
		p_pos.y = field.penalty_area_y_top + 10
	elif p_pos.y < field.penalty_area_y_bottom - 10:
		p_pos.y = field.penalty_area_y_bottom - 10

	if left_half:
		if p_pos.x > field.penalty_area_left_x + 10:
			p_pos.x = field.penalty_area_left_x + 10
		elif p_pos.x < -10:
			p_pos.x = -10
	else:
		if p_pos.x < field.penalty_area_right_x - 10:
			p_pos.x = field.penalty_area_right_x - 10
		elif p_pos.x > field.size.x + field.BORDER_SIZE + 10:
			p_pos.x = field.size.x + field.BORDER_SIZE + 10

	return p_pos


func bound_field(p_pos: Vector2) -> Vector2:
	p_pos.x = maxi(mini(int(p_pos.x), int(field.line_right)), 1)
	p_pos.y = maxi(mini(int(p_pos.y), int(field.line_bottom)), 1)
	return p_pos


func _move() -> void:
	if speed > 0:
		last_pos = pos
		pos = pos.move_toward(destination, speed * Const.SPEED)
		player_res.consume_stamina()


func _block_shot() -> bool:
	if is_touching_ball():
		return (
			RngUtil.match_rng.randi_range(0, 100)
			< 69 + player_res.attributes.goalkeeper.handling * 2
		)
	return false

