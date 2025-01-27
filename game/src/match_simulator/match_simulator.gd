# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchSimulator
extends Control

signal action_message(message: String)
signal show_me
signal hide_me

const ENGINE_FUTURE_SECONDS: int = 5
const CAMERA_SPEED: int = 4

var passed_time: float = 0
var wait_time: float
var show_action_ticks: int

var engine: MatchEngine
# engine to calculate ENGINE_FUTURE_SECONDS seconds in the future
# to be able to show real engine results when key action or goal happens
var engine_future: MatchEngine

@onready var visual_match: VisualMatch = %VisualMatch
@onready var sub_viewport: SubViewport = %SubViewport
@onready var camera: Camera2D = %Camera2D
@onready var visual_state_machine: VisualStateMachine = %VisualStateMachine


func _physics_process(delta: float) -> void:
	# do nothing while paused
	if Global.match_paused:
		return

	# update engine show visual match	
	if is_match_visible():
		visual_match.show_actors()
		camera.position = camera.position.lerp(visual_match.ball.global_position, delta * CAMERA_SPEED)
		# show full match or only show key actions and goals
		passed_time += delta
		if passed_time >= wait_time:
			passed_time = 0

			# update engines
			engine.update()
			engine_future.update()
			
			# update visual match
			visual_match.update_ball()
			if engine.ticks % Const.STATE_UPDATE_TICKS == 0:
				visual_match.update_players()

			if show_action_ticks > 0:
				show_action_ticks -= 1

	# update engine fast
	else:
		hide_me.emit()
		visual_match.hide_actors()
		# simulate engine and future engine
		for i: int in ENGINE_FUTURE_SECONDS:
			# update engines
			engine.update()
			engine_future.update()	


func setup(home_team: Team, away_team: Team, match_seed: int) -> void:
	show_action_ticks = 0
	wait_time = 1.0 / Const.TICKS_PER_SECOND
	
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
	
	# future engine
	engine_future = MatchEngine.new(true)
	# for the future engine deep copy teams
	# future calcuations shall not affect real teams
	engine_future.setup(home_team.duplicate_real_deep(), away_team.duplicate_real_deep(), match_seed)
	# show action on goal
	engine_future.goal.connect(
		func() -> void:
			show_action_ticks = ENGINE_FUTURE_SECONDS * Const.TICKS_PER_SECOND * 3
			# remove random delay, to make timing unpredictable
			show_action_ticks -= engine.rng.randi() % ENGINE_FUTURE_SECONDS
			show_me.emit()
			print("FUTURE GOAL at %d"%engine_future.time)
	)
	# already simulate to future
	for i: int in ENGINE_FUTURE_SECONDS * Const.TICKS_PER_SECOND:
		engine_future.update()
	

func simulate() -> void:
	engine.simulate()


func is_match_visible() -> bool:
	return Global.match_speed == Const.MatchSpeed.FULL_GAME or show_action_ticks > 0


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

