# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node
class_name SimTeam

const sim_player_scene:PackedScene = preload("res://src/match-simulator-v2/action-util-v2/actors/sim_player/sim_player.tscn")

var res_team:Team

@onready var goalkeeper:SimGoalkeeper = $SimGoalkeeper
var players:Array[SimPlayer]

var active_player:SimPlayer


var ball:SimBall
var field:SimField
var has_ball:bool
var left_half:bool

func set_up(
	p_res_team:Team,
	p_field:SimField,
	p_ball:SimBall,
	p_left_half:bool,
	color:Color,
	p_has_ball:bool,
	) -> void:
	res_team = p_res_team
	field = p_field
	ball = p_ball
	has_ball = p_has_ball
	left_half = p_left_half
	
	if left_half:
		goalkeeper.set_up(res_team.get_goalkeeper(), field.goal_left, p_ball, field, left_half)
	else:
		goalkeeper.set_up(res_team.get_goalkeeper(), field.goal_right, p_ball, field, left_half)
	goalkeeper.set_color(color)
	
	var pos_index: int = 0
	for player:Player in res_team.get_field_players():
		var sim_player:SimPlayer = sim_player_scene.instantiate()
		add_child(sim_player)
		
		var start_pos:Vector2 = res_team.formation.get_field_pos(field.size, pos_index, left_half)
		pos_index += 1
		
		sim_player.set_up(player, start_pos, p_ball, field, left_half)
		sim_player.set_color(color)
		players.append(sim_player)
		# player signals
		sim_player.short_pass.connect(pass_to_random_player)
	
	# move attacker to kickoff and pass to random player
	if has_ball:
		active_player = players[-1]
		active_player.set_pos(field.center)
		
		ball.kick(players[0].pos, 10, SimBall.State.PASS)

func pass_to_random_player() -> void:
	var r_pos:Vector2 = players.pick_random().pos
	ball.kick(r_pos, 10, SimBall.State.PASS)
	
func update() -> void:
	goalkeeper.update()
	for player:SimPlayer in players:
		player.update()
		
func sort_distance_to_ball(asc:bool = true) -> Array[SimPlayer]:
	var distance:float = ball.pos.distance_to(players[0].pos)
	for i in range(1, players.size() - 1):
		var distance_to_ball:float = ball.pos.distance_to(players[i].pos)
		if distance_to_ball < distance:
			distance = distance_to_ball
	return distance
