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

var team_opponents: SimTeam
# key players
var player_control: SimPlayer
var player_support: SimPlayer
var player_receive_ball: SimPlayer
var player_nearest_to_ball: SimPlayer


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
		sim_player.setup(player, self, field, left_half)
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
	state_machine = TeamStateMachine.new(field, self)


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


func kickoff_pass() -> void:
	stats.passes += 1
	var random_player: int = RngUtil.match_rng.randi_range(1, 3)
	player_control = null
	player_receive_ball = players[random_player]
	player_receive_ball.state_machine.set_state(PlayerStateAttackReceive.new())
	field.ball.short_pass(player_receive_ball.pos, 40)


func random_pass() -> void:
	stats.passes += 1
	var random_player: int = RngUtil.match_rng.randi_range(0, 4)
	
	# make sure player is not passing ball himself
	if random_player == players.find(player_control):
		random_player += 1
		random_player %= 5
	
	player_receive_ball = players[random_player]
	player_receive_ball.state_machine.set_state(PlayerStateAttackReceive.new())
	field.ball.short_pass(player_receive_ball.pos, 40)


func chase_ball() -> void:
	if player_control != null:
		if not player_control.state_machine.state is PlayerStateChaseBall:
			player_control.set_state(PlayerStateChaseBall.new())
	elif player_nearest_to_ball != null:
		player_control = player_nearest_to_ball
	else:
		print("no nearest player")


func reset_key_players() -> void:
	player_control = null
	player_support = null
	player_receive_ball = null


func shoot_on_goal(_player: Player) -> void:
	stats.shots += 1


func change_players_request() -> void:
	# compare sim players and team players order
	# if different, set change request flag
	for i: int in all_players.size():
		if all_players[i].player_res.id != res_team.players[i].id:
			change_request = true
			return


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


