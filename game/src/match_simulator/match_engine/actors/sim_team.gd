# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimTeam

signal interception
signal player_changed

var res_team: Team
var stats: MatchStatistics

var players: Array[SimPlayer] # players in field
var all_players: Array[SimPlayer]
var field: SimField

var state_machine: TeamStateMachine

var change_request: bool
var has_ball: bool
var left_half: bool
# false, if team is controlled by player
var simulated: bool


func setup(
	p_res_team: Team,
	p_field: SimField,
	p_left_half: bool,
	p_has_ball: bool,
	p_simulated: bool = false,
) -> void:
	res_team = p_res_team
	field = p_field
	has_ball = p_has_ball
	left_half = p_left_half
	simulated = p_simulated

	change_request = false

	# check if team is player's team
	simulated = Global.team and Global.team.id != res_team.id

	stats = MatchStatistics.new()
	
	for player: Player in res_team.get_lineup_players():
		# setup
		var sim_player: SimPlayer = SimPlayer.new()
		sim_player.setup(player, field, left_half)
		all_players.append(sim_player)
		# player signals
		# sim_player.short_pass.connect(pass_to_random_player.bind(sim_player))
		# sim_player.pass_received.connect(func() -> void: stats.passes_success += 1)
		# sim_player.interception.connect(_on_player_interception)
		# sim_player.shoot.connect(shoot_on_goal.bind(sim_player.player_res))
		#sim_player.dribble.connect(pass_to_random_player)
	
	# copy field players in own array, for easier access
	players = all_players.slice(0, 5)

	# set start position for starting players
	for player: SimPlayer in players:
		# start pos
		var start_pos: Vector2 = res_team.formation.get_start_pos(field.size, players.find(player), left_half)
		player.start_pos = start_pos
	
	# set goalkeeper flag
	players[0].make_goalkeeper()


func setup_state_machine(team_opponents: SimTeam) -> void:
	state_machine = TeamStateMachine.new(field, self, team_opponents)
	

func update() -> void:
	state_machine.execute()

	for player: SimPlayer in players:
		player.update()
	
	# recover bench players stamina
	for player: SimPlayer in all_players.slice(5):
		player.recover_stamina()
	
	# TODO
	# check injuries

	_auto_change()


func check_changes() -> void:
	if change_request:
		# adjust all_players order to res teams players order
		var lineup_players: Array[Player] = res_team.get_lineup_players()
		for i: int in lineup_players.size():
			var player: Player = lineup_players[i]
			if all_players[i].player_res.id != player.id:
				var sim_player: SimPlayer
				for sp: SimPlayer in all_players:
					if sp.player_res.id == player.id:
						sim_player = sp
				all_players.erase(sim_player)
				all_players.insert(i, sim_player)

		players = all_players.slice(0, 5)
		player_changed.emit()
		change_request = false


func pass_to_random_player(_passing_player: SimPlayer = null) -> void:
	stats.passes += 1


func shoot_on_goal(_player: Player) -> void:
	stats.shots += 1


func change_players_request() -> void:
	# compare sim players and team players order
	# if different, set change request flag
	for i: int in all_players.size():
		if all_players[i].player_res.id != res_team.players[i].id:
			change_request = true
			return


func nearest_player_to_ball() -> SimPlayer:
	# TODO optimize me, use one copy and don't create new every time
	# only on player change or simlar, create new copy
	var players_copy: Array[SimPlayer] = players.duplicate()
	players_copy.sort_custom(_sort_distance_to_ball)
	return players_copy[0]


func _sort_distance_to_ball(a: SimPlayer, b: SimPlayer) -> bool:
	return a.distance_to_ball < b.distance_to_ball


func _on_player_interception() -> void:
	interception.emit()


func _auto_change() -> void:
	# auto change players, if no change request already pending
	var auto_change: bool = res_team.formation.change_strategy == Formation.ChangeStrategy.AUTO or simulated
	if auto_change and not change_request:
		var auto_change_request: bool = false
		var low_stamina_players: Array[SimPlayer] = []

		# get tired players
		for player: SimPlayer in players:
			if player.player_res.stamina < 0.5:
				low_stamina_players.append(player)

		# sort bench per stamina
		var bench: Array[SimPlayer] = all_players.slice(5)
		bench.sort_custom(
			func(a: SimPlayer, b: SimPlayer) -> bool:
				return a.player_res.stamina >= b.player_res.stamina
		)
		
		# find best position machting player and change them
		var no_matching: Array[SimPlayer] = []
		for player: SimPlayer in low_stamina_players:
			var possible_subs: Array[SimPlayer] = bench.filter(
				func(p: SimPlayer) -> bool:
					return p.player_res.position.match_factor(player.player_res.position) >= 0.5
			)
			if possible_subs.size() > 0:
				var sub: SimPlayer = possible_subs.pop_front()
				bench.erase(sub)
				res_team.change_players(player.player_res, sub.player_res)
				auto_change_request = true
			else:
				no_matching.append(player)

		# replace players that didnt find a good position match
		for player: SimPlayer in no_matching:
			var sub: SimPlayer = bench.pop_front()
			# check if bench has still players
			if sub:
				res_team.change_players(player.player_res, sub.player_res)
				auto_change_request = true
		
		# trigger change player request only once
		if auto_change_request:
			change_players_request()


