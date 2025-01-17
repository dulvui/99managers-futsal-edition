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

# key players attack
var _player_control: SimPlayer
var _player_support: SimPlayer
var _player_receive_ball: SimPlayer
# key players defense
var _player_chase: SimPlayer
# key players generic
var _player_nearest_to_ball: SimPlayer


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
	for player: SimPlayer in players:
		player.update()
	
	# recover bench players stamina
	for player: SimPlayer in all_players.slice(5):
		player.recover_stamina()
	
	# TODO
	# check injuries

	auto_change()
	
	state_machine.execute()


func set_state(state: TeamStateMachineState) -> void:
	state_machine.set_state(state)


#
# CHANGES
#
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

		reset_key_players()


func change_players_request() -> void:
	# compare sim players and team players order
	# if different, set change request flag
	for i: int in all_players.size():
		if all_players[i].player_res.id != res_team.players[i].id:
			change_request = true
			return


func auto_change() -> void:
	# auto change players, if no change request already pending
	var do_change: bool = res_team.formation.change_strategy == Formation.ChangeStrategy.AUTO or simulated
	if do_change and not change_request:
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



#
# KEY PLAYERS
#
func reset_key_players() -> void:
	_player_control = null
	_player_support = null
	_player_receive_ball = null
	_player_nearest_to_ball = null


func player_nearest_to_ball() -> SimPlayer:
	_player_nearest_to_ball = find_nearest_player_to(field.ball.pos)
	return _player_nearest_to_ball


func player_control(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		_player_control = p_player
	elif _player_control == null:
		_player_control = player_nearest_to_ball()
	return _player_control


func player_receive_ball(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		_player_receive_ball = p_player
	elif _player_receive_ball == null:
		_player_receive_ball = player_nearest_to_ball()
	_player_receive_ball.set_state(PlayerStateReceive.new())
	return _player_receive_ball


func player_support(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		_player_support = p_player
	elif _player_support == null:
		_player_support = player_nearest_to_ball()
	_player_support.set_state(PlayerStateSupport.new())
	return _player_support


func player_chase(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		_player_chase = p_player
	elif _player_chase == null:
		_player_chase = player_nearest_to_ball()
	_player_chase.set_state(PlayerStateChaseBall.new())
	return _player_chase


func find_nearest_player_to(position: Vector2, exclude: Array[SimPlayer] = []) -> SimPlayer:
	var nearest: SimPlayer = null
	for player: SimPlayer in players:
		if not player in exclude:
			if nearest == null:
				nearest = player
				continue
			
			if player.pos.distance_squared_to(position) < nearest.pos.distance_squared_to(position):
				nearest = player
	return nearest


#
# HELPER FUNCTIONS
#
func shoot_on_goal(_player: Player) -> void:
	stats.shots += 1


#
# SIGNALS
#
func _on_player_interception() -> void:
	interception.emit()


