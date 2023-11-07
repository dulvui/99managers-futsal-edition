# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

# Action util that handles every action of the game.
# First the player with the ball attacks and the corresponding player of
# the other team reposonds with a defense action and accordign to individual
# player attributes and team tactics a result gets calculated.

extends Node

class_name ActionUtil


signal possession_change
signal shot(player:Player, success:bool)
signal pazz(player:Player, success:bool)
signal foul(player:Player)
signal penalty(player:Player)
signal freekick(player:Player)
signal corner(player:Player)
signal red_card(player:Player)
signal kick_in(player:Player)
signal yellow_card(player:Player)

signal action_message

# in which sector of the field the player is situated
# so better decisions can be made depeneding on the sector a player is
enum Sector {ATTACK, CENTER, DEFENSE}
enum State {NORMAL, KICK_OFF, PENALTY, FREE_KICK, KICK_IN, CORNER}

enum Defense {INTERCEPT, WAIT, TACKLE, RUN, BLOCK, HEADER}

enum Attack {PASS, CROSS, DRIBBLE, RUN, SHOOT}
#enum Pass { SHORT_PASS, LONG_PASS, CROSS}
#enum Shoot {SHOOT, LONG_SHOOT, HEADER}

@onready
var home_team:Node = $HomeTeam
@onready
var away_team:Node = $AwayTeam

var current_state:int

const MAX_ACTION_BUFFER_SIZE:int = 5
var action_buffer:Array = []

var attacking_player:Player
var defending_player:Player


func _ready() -> void:
	randomize()

func set_up(_home_team:Team, _away_team:Team) -> void:
	home_team.set_up(_home_team)
	away_team.set_up(_away_team)
	
	current_state = State.KICK_OFF


func update() -> void:
	var attack:int = _attack()
	var attack_success:bool = _get_result(attack)
	
	var foul:bool = false
	var goal:bool = false
	var corner:bool = false
	var kick_in:bool = false
	
	# change active players and possession
	if attack_success:
		match attack:
			Attack.PASS: # , AttackCROSS
				_change_active_players()
			Attack.RUN, Attack.DRIBBLE:
				_change_defender()
			Attack.SHOOT: # , Attack.HEADER
				goal = _check_goal()
				if not goal:
					# TODO emit corner signal for visual action
					corner = _check_corner()
	else:
		foul = _check_foul()
		if foul:
			# TODO emit ponalty/freekick signal for visual action
			var card = _check_card()
			print("Foul with " + card + " card.")
			action_message.emit("Foul with " + card + " card.")
			_check_penalty_or_freekick()
		else:
			kick_in = _check_kick_in()
#		emit_signal("possession_change")
		_change_possession()
		_change_attacker()
	
	if not goal and not corner and not kick_in and not foul:
		current_state = State.NORMAL
	
	
	# increase stats
	match attack:
		Attack.PASS:
			pazz.emit(home_team.has_ball, attack_success)
		Attack.SHOOT:
			shot.emit(home_team.has_ball, attack_success, null)


	home_team.update_players()
	away_team.update_players()
#	home_stats.update_possession(home_team.has_ball)
#	away_stats.update_possession(away_team.has_ball)
	_log(attack, attack_success)
	_action_buffer(attack, attack_success)
	
func change_players(_home_team:Team,_away_team:Team) -> void:
	# reset action buffer, becasue change happened and
	# changed player is not visible in field anymore
	action_buffer = []
	home_team.set_up(_home_team)
	away_team.set_up(_away_team)
	
# returns true if attack wins, false if defense wins
func _get_result(attack:int) -> bool:
	# select attributes to use as value for random result calculation
	
	var attacker_attributes:int = 0
	var defender_attributes:int = 0
	
	if current_state == State.NORMAL:
		if home_team.has_ball:
			attacker_attributes = home_team.active_player.get_attack_attributes(attack)
			defender_attributes = away_team.active_player.get_defense_attributes(attack)
		else:
			attacker_attributes = away_team.active_player.get_attack_attributes(attack)
			defender_attributes = home_team.active_player.get_defense_attributes(attack)
	else:
		return true
	
	# calculate random action winner
	var max_value:int = attacker_attributes + defender_attributes
	var random:int = randi() % int(max_value)
	var result:bool = false
	
	if random < attacker_attributes:
		result = true
	return result
	
func _attack() -> int:
	# improve later watching current sector and player attributes
	match current_state:
		State.KICK_OFF, State.KICK_IN:
			return Attack.PASS
		State.PENALTY, State.FREE_KICK, State.PENALTY:
			return Attack.SHOOT
		State.CORNER:
			if randi() % 2 == 0: # use player preferences/attirbutes
				return Attack.CROSS
			else:
				return Attack.PASS
		_:
			var random_attack_factor:int = randi() % Constants.ATTACK_FACTOR
			if random_attack_factor < Constants.RUN_FACTOR:
				return Attack.RUN
			elif random_attack_factor < Constants.PASS_FACTOR:
				return Attack.PASS
			elif random_attack_factor < Constants.DRIBBLE_FACTOR:
				return Attack.DRIBBLE
			else:
				return Attack.SHOOT

func _log(attack:int, result:bool) -> void:
	action_message.emit(home_team.active_player.name + " vs " + away_team.active_player.name + " " + str(Attack.keys()[attack]) + " - " + str(result))

func _action_buffer(attack:int, result:bool) -> void:
	var attacking_player_nr:int
	var defending_player_nr:int
	
	if home_team.has_ball:
		attacking_player_nr = home_team.active_player.nr
		defending_player_nr = away_team.active_player.nr
	else:
		attacking_player_nr = away_team.active_player.nr
		defending_player_nr = home_team.active_player.nr
	
	action_buffer.append({
		"action" : Attack.keys()[attack],
		"state" : State.keys()[current_state],
		"is_home" : home_team.has_ball,
		"success" : result,
		"attacking_player_nr" : attacking_player_nr,
		"defending_player_nr" : defending_player_nr,
	})
	
	if action_buffer.size() > MAX_ACTION_BUFFER_SIZE:
		action_buffer.pop_front()

func _check_goal() -> bool:
	var goalkeeper_attributes:int
	if home_team.has_ball:
		goalkeeper_attributes = away_team.goalkeeper.get_goalkeeper_attributes()
	else:
		goalkeeper_attributes = away_team.goalkeeper.get_goalkeeper_attributes()
	
	var random_goal:int = randi() % int(goalkeeper_attributes)
	
	goalkeeper_attributes *= Constants.GOAL_KEEPER_FACTOR[State.keys()[current_state]]
	
	#decrease more if away keeper has to save
	if home_team.has_ball:
		goalkeeper_attributes *= Constants.GOAL_KEEPER_AWAY_FACTOR
	
	if random_goal > goalkeeper_attributes:
		# goal
		if home_team.has_ball:
			shot.emit(home_team.has_ball, true, home_team.active_player)
			action_message.emit("GOAL for " + home_team.name)
		else:
			shot.emit(home_team.has_ball, true, away_team.active_player)
			action_message.emit("GOAL for " + away_team.name)
		_change_possession()
		return true
	else:
		if home_team.has_ball:
			emit_signal("shot",false, home_team.has_ball, home_team.active_player)
		else:
			emit_signal("shot",false, home_team.has_ball, away_team.active_player)
	return false
	
	
# ACTION EVENT CHECKS
func _check_corner() -> bool:
	var random:int = randi() % Constants.MAX_FACTOR
	if random < Constants.CORNER_AFTER_SAFE_FACTOR:
		current_state = State.CORNER
		corner.emit()
		return true
	return false
	
func _check_foul() -> bool:
	var random:int = randi() % Constants.MAX_FACTOR
	if random < Constants.FOUL_FACTOR:
		foul.emit(home_team.has_ball)
		return true
	return false
	
func _check_penalty_or_freekick() -> bool:
	var random:int = randi() % Constants.MAX_FACTOR
	if random > Constants.PENALTY_FACTOR:
		current_state = State.FREE_KICK
		freekick.emit()
		action_message.emit("FREE_KICK")
		return true
	else:
		current_state = State.PENALTY
		action_message.emit("PENALTY")
		penalty.emit()
		return true

	
func _check_card() -> String:
	var random:int = randi() % Constants.MAX_FACTOR
	if random > Constants.RED_CARD_FACTOR:
		red_card.emit()
		return "red"
	elif random > Constants.YELLOW_CARD_FACTOR:
		yellow_card.emit()
		return "yellow"
	return "no-card"
	
func _check_kick_in() -> bool:
	var random:int = randi() % Constants.MAX_FACTOR
	if random < Constants.KICK_IN_FACTOR:
		current_state = State.KICK_IN
		kick_in.emit()
		return true
	return false

# PLAYER/POSSESSION CHANGE
func _change_possession() -> void:
	home_team.has_ball = not home_team.has_ball
	away_team.has_ball = not away_team.has_ball
	
func _change_active_players() -> void:
	home_team.change_active_player()
	away_team.change_active_player()
	
func _change_defender() -> void:
	if home_team.has_ball:
		away_team.change_active_player()
	else:
		home_team.change_active_player()

func _change_attacker() -> void:
	if away_team.has_ball:
		away_team.change_active_player()
	else:
		home_team.change_active_player()
