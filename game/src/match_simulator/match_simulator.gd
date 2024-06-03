# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchSimulator
extends Control

signal action_message
signal half_time
signal match_end
signal update

@onready var visual_match: VisualMatch = $SubViewportContainer/SubViewport/VisualMatch
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D

var ticks: int = 0
var time: int = 0
var timer: Timer


func _physics_process(_delta: float) -> void:
	camera.position = visual_match.ball.global_position


func set_up(home_team: Team, away_team: Team, match_seed: int) -> void:
	visual_match.set_up(home_team, away_team, match_seed)

	# adjust sub viewport to field size + borders
	sub_viewport.size = visual_match.visual_field.field.size

	# intialize timer
	timer = Timer.new()
	timer.wait_time = 1.0 / (Const.TICKS_PER_SECOND * Config.speed_factor)
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


func _on_timer_timeout() -> void:
	visual_match.match_engine.update()
	
	visual_match.ball.last_update_time = 0
	visual_match.ball.update_interval = timer.wait_time
	
	ticks += 1
	if ticks == Const.TICKS_PER_SECOND:
		ticks = 0
		time += 1
		_update_time()

 
func _update_time() -> void:
	update.emit()
	# check half/end time
	if time == Const.HALF_TIME_SECONDS:
		timer.paused = true
		half_time.emit()
		visual_match.half_time()
	elif time == Const.HALF_TIME_SECONDS * 2:
		timer.stop()
		match_end.emit()


func pause_toggle() -> bool:
	timer.paused = not timer.paused
	return timer.paused


func pause() -> void:
	timer.paused = true


func continue_match() -> void:
	timer.paused = false


func match_finished() -> void:
	timer.stop()


func set_time() -> void:
	timer.wait_time = 1.0 / (Const.TICKS_PER_SECOND * Config.speed_factor)


func start_match() -> void:
	timer.start()
