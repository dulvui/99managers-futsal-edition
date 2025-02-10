# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimTeam

signal player_changed
signal penalties_shot

# player should stay at least 2 minutes in field before he can be changed
const PLAYER_MIN_TICKS_IN_FIELD: int = Const.TICKS_LOGIC * 120

var team_res: Team
var stats: MatchStatistics

var players: Array[SimPlayer]
var field: SimField

var state_machine: TeamStateMachine

var rng: RandomNumberGenerator

var change_request: bool
var has_ball: bool
var left_half: bool
var ready_for_kickoff: bool

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

# changes variables
var auto_change_request: bool
var low_stamina_players: Array[SimPlayer]
var do_change: bool


func _init(p_rng: RandomNumberGenerator) -> void:
	rng = p_rng


func setup(
	p_team_res: Team,
	p_field: SimField,
	p_left_half: bool,
	p_has_ball: bool,
	p_simulated: bool = false,
) -> void:
	team_res = p_team_res
	field = p_field
	left_half = p_left_half
	has_ball = p_has_ball
	simulated = p_simulated

	change_request = false
	ready_for_kickoff = false
	do_change = false

	auto_change_request = false
	low_stamina_players = []

	# check if team is player's team
	simulated = Global.team and Global.team.id != team_res.id

	stats = MatchStatistics.new()
	
	for player: Player in team_res.get_starting_players():
		# setup
		var sim_player: SimPlayer = SimPlayer.new(rng)
		sim_player.setup(player, self, field, left_half)
		players.append(sim_player)

	# set goalkeeper flag
	players[0].make_goalkeeper()

	_set_start_positions()
	
	state_machine = TeamStateMachine.new(rng, field, self)


func update() -> void:
	for player: SimPlayer in players:
		player.update()

	# recover bench players stamina
	for player: Player in team_res.players.slice(5):
		player.recover_stamina()
	
	state_machine.execute()
	
	# TODO
	# check injuries

	# player changes
	if not field.clock_running:
		auto_change()
		if change_request:
			change_players()


func move() -> void:
	for player: SimPlayer in players:
		player.move()


func set_state(state: TeamStateMachineState) -> void:
	state_machine.set_state(state)


func gain_possession() -> void:
	has_ball = true
	team_opponents.has_ball = false


#
# CHANGES
#
func change_players_request() -> void:
	# compare sim players and team players order
	# if different, set change request flag
	for i: int in team_res.get_starting_players().size():
		if players[i].player_res.id != team_res.players[i].id:
			change_request = true
			return


func auto_change() -> void:
	# auto change players, if no change request already pending
	do_change = simulated or team_res.formation.change_strategy == Formation.ChangeStrategy.AUTO
	if do_change and not change_request:
		# reset vars
		auto_change_request = false
		low_stamina_players = []

		# get tired players
		for sim_player: SimPlayer in players:
			if sim_player.player_res.stamina < 0.5 and sim_player.ticks_in_field > PLAYER_MIN_TICKS_IN_FIELD:
				low_stamina_players.append(sim_player)

		# stop if no players need to be changed
		if low_stamina_players.size() == 0:
			return

		# sort bench per stamina
		var bench: Array[Player] = team_res.get_sub_players()
		bench.sort_custom(
			func(a: Player, b: Player) -> bool:
				return a.stamina > b.stamina
		)
		
		# TODO take real positions in field, not player pos
		# because player could play in different position
		
		# find best position machting player and change them
		var no_matching_sim_players: Array[SimPlayer] = []
		for sim_player: SimPlayer in low_stamina_players:
			var possible_sub_players: Array[Player] = bench.filter(
				func(p: Player) -> bool:
					return p.position.match_factor(sim_player.player_res.position) >= 0.5
			)
			if possible_sub_players.size() > 0:
				var sub_player: Player = possible_sub_players.pop_front()
				bench.erase(sub_player)
				team_res.change_players(sim_player.player_res, sub_player)
				auto_change_request = true
			else:
				no_matching_sim_players.append(sim_player)

		# replace players that didnt find a good position match
		for sim_player: SimPlayer in no_matching_sim_players:
			var sub_player: Player = bench.pop_front()
			# check if bench has still players
			if sub_player:
				team_res.change_players(sim_player.player_res, sub_player)
				auto_change_request = true
		
		# trigger change player request only once
		if auto_change_request:
			change_players_request()


func change_players() -> void:
	# adjust starting_players order to team_res players order
	var starting_players: Array[Player] = team_res.get_starting_players()

	for i: int in starting_players.size():
		var player: Player = starting_players[i]
		var sim_player: SimPlayer = players[i]
		if sim_player.player_res.id != player.id:
			sim_player.change_player_res(player)

	player_changed.emit()
	change_request = false


#
# KEY PLAYERS
#
func reset_key_players() -> void:
	_player_control = null
	_player_support = null
	_player_receive_ball = null
	_player_nearest_to_ball = null


func player_nearest_to_ball(exclude: Array[SimPlayer] = []) -> SimPlayer:
	_player_nearest_to_ball = find_nearest_player_to(field.ball.pos, exclude)
	return _player_nearest_to_ball


func player_control(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		if _player_control != null:
			_player_control.set_state(PlayerStateAttack.new())
		_player_control = p_player
		_player_control.set_state(PlayerStateControl.new())
	return _player_control


func player_receive_ball(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		if _player_receive_ball != null:
			_player_receive_ball.set_state(PlayerStateAttack.new())
		_player_receive_ball = p_player
		_player_receive_ball.set_state(PlayerStateReceive.new())
	return _player_receive_ball


func player_support(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		if _player_support != null:
			_player_support.set_state(PlayerStateAttack.new())
		_player_support = p_player
		_player_support.set_state(PlayerStateSupport.new())
	return _player_support


func player_chase(p_player: SimPlayer = null) -> SimPlayer:
	if p_player != null:
		if _player_chase != null:
			_player_chase.set_state(PlayerStateDefend.new())
		_player_chase = p_player
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


func penalties_shot_taken() -> void:
	print("shot")
	stats.penalty_shootout_shots += 1
	penalties_shot.emit()


func _set_start_positions() -> void:
	for player: SimPlayer in players:
		# start pos
		var start_pos: Vector2 = team_res.formation.get_start_pos(
			field.size, players.find(player), left_half
		)
		player.start_pos = start_pos	
