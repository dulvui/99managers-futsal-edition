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
			
			var ticks: int = show_action_ticks

			if Global.match_speed == Const.MatchSpeed.FULL_GAME:
				_update_engine()
				ticks = engine.ticks
			
			# update visual ball
			var ball_entry: MatchBufferEntryBall = ball_buffer.get_entry()
			visual_match.ball.update(ball_entry.pos)

			# update visual teams
			if ticks % Const.TICKS_LOGIC == 0:
				var teams_entry: MatchBufferEntryTeams = teams_buffer.get_entry()
				visual_match.home_team.update(
					teams_entry.home_pos,
					teams_entry.home_info,
					teams_entry.home_head_look
				)
				visual_match.away_team.update(
					teams_entry.away_pos,
					teams_entry.away_info,
					teams_entry.away_head_look
				)
			
			# reduce show action counter
			if show_action_ticks > 0:
				show_action_ticks -= 1
				print(show_action_ticks)

	# update engine fast
	else:
		# hide_me.emit()
		visual_match.hide_actors()

		for i: int in ENGINE_FUTURE_SECONDS:
			_update_engine()


func setup(matchz: Match) -> void:
	show_action_ticks = 0
	wait_time = 1.0 / Const.TICKS
	
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
	ball_buffer.setup(1000)
	teams_buffer = MatchBufferTeams.new()
	teams_buffer.setup(1000)
	stats_buffer = MatchBufferStats.new()
	stats_buffer.setup(1000)


func simulate() -> void:
	engine.simulate()


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
	var seconds: int = visual_rng.randi_range(3, 5) 
	show_action_ticks = Const.TICKS * seconds
	var timestamp: int = engine.ticks - show_action_ticks
	if timestamp > engine.ticks:
		timestamp =	engine.ticks
	ball_buffer.start_replay(timestamp)
	teams_buffer.start_replay(timestamp)
	stats_buffer.start_replay(timestamp)


func _update_engine() -> void:
	engine.update()
	ball_buffer.save(engine)
	if engine.ticks % Const.TICKS_LOGIC == 0:
		teams_buffer.save(engine)


