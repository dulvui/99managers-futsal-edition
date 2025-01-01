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
var head_look_direction: Vector2
#TODO reduce radius with low stamina
var interception_radius: int

# distances, calculated by action util
var distance_to_ball: float

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

	head_look_direction = Vector2.ZERO


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


func set_state(state: PlayerStateMachineState) -> void:
	state_machine.set_state(state)


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


func set_destination(p_destination: Vector2, p_speed: int = 20) -> void:
	destination = field.bound(p_destination)
	speed = p_speed


func destination_reached() -> bool:
	return pos == destination


func stop() -> void:
	speed = 0
	last_pos = pos


func recover_stamina(factor: int = 1) -> void:
	player_res.recover_stamina(factor)


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

