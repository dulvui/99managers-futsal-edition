# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchSimulator
extends Control

signal action_message(message: String)

const CAMERA_SPEED: int = 4

var passed_time: float = 0
var wait_time: float

var engine: MatchEngine

@onready var visual_match: VisualMatch = %VisualMatch
@onready var sub_viewport: SubViewport = %SubViewport
@onready var camera: Camera2D = %Camera2D
@onready var visual_state_machine: VisualStateMachine = %VisualStateMachine


func _physics_process(delta: float) -> void:
	camera.position = camera.position.lerp(visual_match.ball.global_position, delta * CAMERA_SPEED)

	if Global.match_paused:
		return
	
	passed_time += delta
	if passed_time >= wait_time:
		passed_time = 0

		engine.update()


func setup(home_team: Team, away_team: Team, match_seed: int) -> void:
	
	engine = MatchEngine.new()
	engine.setup(home_team, away_team, match_seed)

	# connect change players signals to visuals
	engine.home_team.player_changed.connect(
		func() -> void:
			visual_match.home_team.change_players(engine.home_team)
	)
	engine.away_team.player_changed.connect(
		func() -> void:
			visual_match.away_team.change_players(engine.away_team)
	)

	# connect time control signals
	engine.half_time.connect(func() -> void: pause())
	engine.full_time.connect(func() -> void: pause())

	set_speed()

	# setup visual match
	# get colors
	visual_match.setup(engine, wait_time)

	# visual state machine for debug
	visual_state_machine.setup(visual_match.home_team, visual_match.away_team)

	# adjust sub viewport to field size + borders
	sub_viewport.size = visual_match.field.field.size

	# set camera limits
	var camera_offset: int = 100
	camera.limit_left = -camera_offset
	camera.limit_top = -camera_offset
	camera.limit_right = engine.field.size.x + camera_offset
	camera.limit_bottom = engine.field.size.y + camera_offset

	# reset match_paused
	Global.match_paused = false
	

func simulate() -> void:
	engine.simulate()


func pause_toggle() -> bool:
	Global.match_paused = not Global.match_paused
	return Global.match_paused


func pause() -> void:
	Global.match_paused = true


func continue_match() -> void:
	Global.match_paused = true


func match_finished() -> void:
	action_message.emit("match finished")
	Global.match_paused = true


func set_speed() -> void:
	wait_time = 1.0 / Const.TICKS_PER_SECOND / Global.speed_factor
	print(wait_time)
