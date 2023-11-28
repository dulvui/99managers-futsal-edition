# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node2D

signal action_finished

const VisualPlayer:PackedScene = preload("res://src/match-simulator/visual-action/actors/player/visual_player.tscn")

const RUN_DISTANCE:int = 300

@onready var WIDTH:int = $Field.width
@onready var HEIGHT:int = $Field.height

@onready var timer:Timer = $Timer
@onready var ball:Node2D = $Ball

@onready var home_goalkeeper:Node2D = $HomeGoalkeeper
@onready var away_goalkeeper:Node2D = $AwayGoalkeeper

@onready var home_goal:Node2D = $HomeGoal
@onready var away_goal:Node2D = $AwayGoal

var home_team:Team
var away_team:Team

var actions = []
var home_visual_players = []
var away_visual_players = []

var is_final_action:bool = false

var is_home_goal:bool
var is_goal:bool
var on_tagret:bool


var is_shooting:bool = false

var attacking_player:Node2D

# position - formation mapping
var formations = {
	"2-2" : ["DL","DR","AL","AR"]
}

@onready var positions = {
	"DL" : {
		"attack" : Vector2(WIDTH * 3 / 8, HEIGHT * 3 / 4),
		"defense" : Vector2(WIDTH * 1 / 8, HEIGHT * 3 / 4)
	},
	"DR" : {
		"attack" : Vector2(WIDTH * 3 / 8, HEIGHT / 4),
		"defense" : Vector2(WIDTH * 1 / 8, HEIGHT / 4)
	},
	"AL" : {
		"attack" : Vector2(WIDTH * 7 / 8, HEIGHT * 3 / 4),
		"defense" : Vector2(WIDTH * 3 / 8, HEIGHT * 3 / 4)
	},
	"AR" : {
		"attack" : Vector2(WIDTH * 7 / 8, HEIGHT / 4),
		"defense" : Vector2(WIDTH * 3 / 8, HEIGHT / 4)
	}
}
# defines +/- the player differs from nomrla position
const POSITION_RANGE = 40

func _ready() -> void:
	randomize()
	_player_setup()

func _physics_process(delta) -> void:
	# look at ball
	if not is_shooting:
		home_goalkeeper.sprite.look_at(ball.global_position)
		away_goalkeeper.sprite.look_at(ball.global_position)
	for player in home_visual_players:
		player.sprite.look_at(ball.global_position)
	for player in away_visual_players:
		player.sprite.look_at(ball.global_position)
		
	# referee
	$Referee/Sprites.look_at(ball.global_position)
	$Referee2/Sprites.look_at(ball.global_position)

		
func set_up(home_goal:bool, _is_goal:bool,_on_target:bool, _home_team:Team, _away_team:Team, action_buffer:Array) -> void:
	is_home_goal = home_goal
	is_goal = _is_goal
	on_tagret = _on_target
	actions = action_buffer.duplicate(true)
	home_team = _home_team.duplicate(true)
	away_team = _away_team.duplicate(true)
	
	# reduce actons randomly
	actions = actions.slice(randi() % actions.size() - 3, actions.size())
	
	
func _player_setup() -> void:
	#home
	var home_index = 0
	var goalkeeper_home = home_team.line_up.goalkeeper
	home_goalkeeper.set_up(goalkeeper_home.nr, Color.LIGHT_BLUE, true, WIDTH, HEIGHT)
	for player in home_team.line_up.players:
		var visual_player = VisualPlayer.instantiate()
		visual_player.set_up(player.nr, Color.BLUE, true, WIDTH, HEIGHT, _get_player_position(home_index, true))
		$HomePlayers.add_child(visual_player)
		home_visual_players.append(visual_player)
		home_index += 1
	
	# away
	var away_index = 0
	var goalkeeper_away = away_team.line_up.goalkeeper
	away_goalkeeper.set_up(goalkeeper_away.nr, Color.LIGHT_CORAL, true, WIDTH, HEIGHT)
	for player in away_team.line_up.players:
		var visual_player = VisualPlayer.instantiate()
		visual_player.set_up(player.nr, Color.RED, false, WIDTH, HEIGHT, _get_player_position(away_index, false))
		$AwayPlayers.add_child(visual_player)
		away_visual_players.append(visual_player)
		away_index += 1

# index: of player in active players representing the position in field
# action_type: attack or defense
func _get_player_position(index, is_home_team) -> Vector2:
	# change valuse depending on formation
	# very index means differnet positon
	# for MVP only use 2-2 fomration
	
	var action_type = "defense"
	if (is_home_team and is_home_goal) or (not is_home_team and not is_home_goal):
		action_type = "attack"
	
	var field_position = formations["2-2"][index]
	var minimum = positions[field_position][action_type]
	var maximum = positions[field_position][action_type]
	
	# TODO adapt values depending on tactics
	var x = randi_range(minimum.x - POSITION_RANGE, minimum.x + POSITION_RANGE)
	var y = randi_range(minimum.y - POSITION_RANGE, minimum.y + POSITION_RANGE)
	
	# if away team move to other side
	if not is_home_team:
		x = WIDTH - x
		y = HEIGHT - y
	
	return Vector2(x,y)

func _action() -> void:
	var action = actions.pop_front()

	if action:
		var attack_nr = action["attacking_player_nr"]
		var defense_nr = action["defending_player_nr"]
		
		# find current player position
		if action["is_home"]:
			for player in home_visual_players:
				if player.nr == attack_nr:
					attacking_player = player
					_player_action(player, action)
		else:
			for player in away_visual_players:
				if player.nr == attack_nr:
					_player_action(player, action)
		
		ball.move(action.position, timer.wait_time)
		
		# referee
		if action.position.x < WIDTH / 2:
			$Referee.follow_ball(action.position, timer.wait_time )
		else:
			$Referee2.follow_ball(action.position, timer.wait_time)
		
		get_tree().call_group("player", "random_movement", timer.wait_time)
	else:
		is_final_action = true
		is_shooting = true
		
		# calculate shot deviation
		var shot_deviation = Vector2(0,randi_range(-50,50))
		if not is_goal:
			if not on_tagret:
				shot_deviation = Vector2(0,randi_range(-250,250))
			# stop ball on goalkeeper position
			if is_home_goal:
				shot_deviation.x -= 90
			else:
				shot_deviation.x += 90
		
		# move ball
		if is_home_goal:
			ball.move(away_goal.global_position + shot_deviation, timer.wait_time / 3, true)
			# goalkeeper save
			if shot_deviation.y < 100 and shot_deviation.y > -100:
				away_goalkeeper.move(away_goal.position + shot_deviation, timer.wait_time / 3)
		else:
			ball.move(home_goal.global_position + shot_deviation, timer.wait_time / 3, true)
			# goalkeeper save
			if shot_deviation.y < 100 and shot_deviation.y > -100:
				home_goalkeeper.move(home_goal.position + shot_deviation, timer.wait_time / 3)
		
		# celebrateeeee
		if is_goal:
			attacking_player.celebrate_goal()

func _player_action(player:Node2D, action:Dictionary) -> void:
	if action["action"] == "RUN":
		var desitionation = player.position +  Vector2(randi_range(-RUN_DISTANCE,RUN_DISTANCE),randi_range(-RUN_DISTANCE,RUN_DISTANCE))
		desitionation = player.move(desitionation, timer.wait_time)
		action["position"] = desitionation
	else:
		action["position"] = player.position

func _get_player_by_nr(players, nr) -> Dictionary:
	for player in players:
		if player["nr"] == nr:
			return player
	# in case the player has been changed or send of the pitch
	# TODO fix logical problem
	return players[randi() % players.size()]


func _on_Timer_timeout() -> void:
	timer.wait_time = randf_range(0.5,1.5)
	timer.start()
	
	if is_final_action:
		action_finished.emit()
	else:
		_action()
