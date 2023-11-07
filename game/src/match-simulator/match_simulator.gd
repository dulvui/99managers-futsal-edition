# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal shot
signal action_message
signal half_time
signal match_end
signal update

# seconds for halftime
const HALF_TIME:int = 1200

@onready var action_util:Node = $ActionUtil
@onready var timer:Timer = $Timer

var time:int = 0

var home_has_ball:bool


func set_up(home_team:Team, away_team:Team) -> void:
	action_util.set_up(home_team,away_team)
	
	for speed in Config.speed_factor:
		faster()


func _on_Timer_timeout() -> void:
	time += 1
	
	if time == HALF_TIME:
		timer.paused = true
		emit_signal("half_time")
	elif time == HALF_TIME * 2:
		timer.stop()
		emit_signal("match_end")
	else:
		action_util.update()
		update.emit()


func pause_toggle() -> bool:
	timer.paused = not timer.paused
	return timer.paused


func pause() -> void:
	timer.paused = true


func continue_match() -> void:
	timer.paused = false


func match_finished() -> void:
	timer.stop()


func faster() -> void:
	timer.wait_time /= Constants.MATCH_SPEED_FACTOR


func slower() -> void:
	timer.wait_time *= Constants.MATCH_SPEED_FACTOR


func start_match() -> void:
	timer.start()
	
	# coin toss for ball
	var coin:bool = randi() % 2 == 1
	action_util.home_team.has_ball = coin
	action_util.away_team.has_ball = not coin
	
	home_has_ball = coin


func change_players(home_team:Dictionary,away_team:Dictionary) -> void:
	action_util.change_players(home_team,away_team)


func _on_ActionUtil_action_message(message:String) -> void:
	emit_signal("action_message", message)


func _on_ActionUtil_shot(is_goal:bool, is_home:bool, player:Object) -> void:
	emit_signal("shot", is_goal, is_home, player)
