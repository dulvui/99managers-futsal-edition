# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name VisualPlayer
extends Node2D

var sim_player: SimPlayer
var ball: VisualBall

var last_update_time: float
var update_interval: float
var factor: float

var ball_pos: Vector2
var last_pos: Vector2

# real player
@onready var body: Sprite2D = $Sprites/Body
@onready var head: Sprite2D = $Sprites/Head
@onready var hair: Sprite2D = $Sprites/Hair
@onready var eyes: Sprite2D = $Sprites/Eyes

# simple circle
@onready var simple_circle: Sprite2D = $SimpleCircle

@onready var sprites: Node2D = $Sprites
@onready var name_label: Label = $Info/NameLabel
@onready var state_machine_label: Label = %StateMachine


func _physics_process(delta: float) -> void:
	if not Global.match_paused:
		last_update_time += delta
		factor = last_update_time / update_interval
		position = last_pos.lerp(sim_player.pos, factor)

		if sim_player.head_look_direction == Vector2.ZERO:
			sprites.look_at(ball.position)
		else:
			sprites.look_at(sim_player.head_look_direction)
		
		state_machine_label.text = sim_player.state_machine.state.name


func setup(
	p_sim_player: SimPlayer,
	p_ball: VisualBall,
	shirt_color: Color,
	p_update_interval: float,
) -> void:
	sim_player = p_sim_player
	ball = p_ball
	update_interval = p_update_interval
	last_update_time = 0.0
	factor = 1.0
	
	position = sim_player.pos
	last_pos = position

	body.modulate = shirt_color
	
	simple_circle.modulate = shirt_color

	name_label.text = str(sim_player.player_res.nr) + " " + (sim_player.player_res.surname)


	# set colors
	head.modulate = sim_player.player_res.skintone
	hair.modulate = sim_player.player_res.haircolor
	eyes.modulate = sim_player.player_res.eyecolor


func update(p_update_interval: float) -> void:
	update_interval = p_update_interval

	last_update_time = 0
	last_pos = position


func change_player(p_sim_player: SimPlayer) -> void:
	sim_player = p_sim_player
	name_label.text = str(sim_player.player_res.nr) + " " + (sim_player.player_res.surname)


