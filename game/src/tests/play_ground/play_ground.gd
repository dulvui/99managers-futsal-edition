# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayGround
extends Node2D

var sim_field: SimField
var sim_ball: SimBall
var sim_player: SimPlayer

var timer: Timer

@onready var visual_field: VisualField = $VisualField
@onready var visual_ball: VisualBall = $VisualBall
@onready var visual_player: VisualPlayer = $VisualPlayer


func _ready() -> void:
	# setup
	timer = Timer.new()
	timer.wait_time = 1.0 / (Const.TICKS_PER_SECOND * Global.speed_factor)
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	sim_field = SimField.new()
	sim_field.setup()
	visual_field.setup(sim_field)

	sim_ball = SimBall.new()
	sim_ball.setup(sim_field)
	visual_ball.setup(sim_ball, 0.25)

	sim_player = SimPlayer.new()
	sim_player.setup(Player.new(),sim_field, true)

	visual_player.setup(sim_player, visual_ball, Color.RED, timer.wait_time)

	# movements
	#player_moves_to_ball()
	#player_moves()
	player_dribble()


func _on_timer_timeout() -> void:
	sim_ball.update()

	sim_player.update()

	visual_ball.update(timer.wait_time)
	visual_player.update(timer.wait_time)


func player_moves_to_ball() -> void:
	sim_player.set_pos(Vector2(300, 400))
	sim_player.set_destination(Vector2(900, 400))


func player_moves() -> void:
	sim_player.set_pos(Vector2(300, 400))
	sim_player.set_destination(Vector2(900, 800))


func player_dribble() -> void:
	sim_player.set_pos(sim_field.center - Vector2(20, 0))
	sim_player.set_destination(sim_ball.pos)
