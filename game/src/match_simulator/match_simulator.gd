# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchSimulator
extends Control

signal action_message(message: String)
# signal show_me
# signal hide_me

const ENGINE_FUTURE_SECONDS: int = 10
const CAMERA_SPEED: int = 4

var passed_time: float = 0
var wait_time: float
var show_action_ticks: int

var engine: MatchEngine

# used for randomizations like visual goal delay
# use this to not alter engines rng
var visual_rng: RandomNumberGenerator

# buffer from where visual match acesses positions, info etc...
var ball_buffer: MatchBufferBall
var stats_buffer: MatchBufferStats
var teams_buffer: MatchBufferTeams

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
			save_to_buffer()
			
			# update visual match
			visual_match.update_ball(ball_buffer.get_entry().pos)
			# if engine.ticks % Const.STATE_UPDATE_TICKS == 0:
			# 	visual_match.update_players(buffer)

			if show_action_ticks > 0:
				show_action_ticks -= 1

	# update engine fast
	else:
		# hide_me.emit()
		visual_match.hide_actors()

		for i: int in ENGINE_FUTURE_SECONDS:
			engine.update()
			save_to_buffer()


func setup(matchz: Match) -> void:
	show_action_ticks = 0
	wait_time = 1.0 / Const.TICKS_PER_SECOND
	
	engine = MatchEngine.new()
	engine.setup(matchz)
	engine.goal.connect(_on_engine_goal)

	# setup visual match
	# get colors
	visual_match.setup(self)

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

	# visual rng
	visual_rng = RandomNumberGenerator.new()
	visual_rng.seed = matchz.id

	# buffers
	ball_buffer = MatchBufferBall.new()
	ball_buffer.setup(100)
	teams_buffer = MatchBufferTeams.new()
	stats_buffer = MatchBufferStats.new()


func simulate() -> void:
	engine.simulate()


func save_to_buffer() -> void:
	ball_buffer.save(engine)
	# teams_buffer.save(engine)
	# stats_buffer.save(engine)


func is_match_visible() -> bool:
	return Global.match_speed == Const.MatchSpeed.FULL_GAME or show_action_ticks > 0


func pause_toggle() -> bool:
	Global.match_paused = not Global.match_paused
	return Global.match_paused


func pause() -> void:
	Global.match_paused = true


func match_finished() -> void:
	action_message.emit("match finished")
	Global.match_paused = true


func _on_engine_goal() -> void:
	show_action_ticks = 50
	ball_buffer.start_replay(show_action_ticks)
