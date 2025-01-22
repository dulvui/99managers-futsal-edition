# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimPlayer
extends MovingActor

# resources
var player_res: Player
var field: SimField
var state_machine: PlayerStateMachine

var rng: RandomNumberGenerator

# positions
var start_pos: Vector2
# movements
var head_look_direction: Vector2

# goalkeeper properties
var is_goalkeeper: bool
var left_base: Vector2
var right_base: Vector2
var left_half: bool

var has_ball: bool

# save time player is in field, to prevent changing player just entered
# only injury or manual change can change player with low time in field
var ticks_in_field: int


func _init(p_rng: RandomNumberGenerator, p_radius: float = 20) -> void:
	super(p_radius, false)
	rng = p_rng
	# initial test values
	has_ball = false

	head_look_direction = Vector2.ZERO

	ticks_in_field = 0


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
	ticks_in_field += 1
	move()

	state_machine.execute()
	
	if speed > 0:
		player_res.consume_stamina(speed)


func change_player_res(p_player_res: Player) -> void:
	player_res = p_player_res
	ticks_in_field = 0


func set_state(state: PlayerStateMachineState) -> void:
	state_machine.set_state(state)


func make_goalkeeper() -> void:
	is_goalkeeper = true


func is_touching_ball() -> bool:
	return collides(field.ball)


func move_offense_pos() -> void:
	var deviation_x: int = rng.randi_range(-10, 10)
	var deviation_y: int = rng.randi_range(-10, 10)
	var deviation: Vector2 = Vector2(field.size.x / 3 + deviation_x, deviation_y)

	if not left_half:
		deviation.x = -deviation.x

	set_destination(start_pos + deviation, 20)


func move_defense_pos() -> void:
	var deviation_x: int = rng.randi_range(-10, 10)
	var deviation_y: int = rng.randi_range(-10, 10)
	var deviation: Vector2 = Vector2(deviation_x, deviation_y)

	set_destination(start_pos + deviation)


