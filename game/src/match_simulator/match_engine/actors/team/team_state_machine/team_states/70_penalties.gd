# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name TeamStatePenalties
extends TeamStateMachineState


var shooting_player_index: int
var shooting_player: SimPlayer
var goalkeeper: SimPlayer


func _init() -> void:
	super("TeamStatePenalties")


func enter() -> void:
	# start first non goalkeeper player
	shooting_player_index = 0

	# move players to center in line
	for player: SimPlayer in owner.team.players:
		move_to_center(player)
		
		# set all players to right half, so they shoot on left goal
		player.left_half = false
		
		if player.is_goalkeeper:
			goalkeeper = player
	
	if owner.team.has_ball:
		next_shooter(false)
	else:
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())


func execute() -> void:
	# wait for turn to shoot
	if not owner.team.has_ball:
		return
	# wait for shooting player to shoot
	elif shooting_player != null:
		if shooting_player.state_machine.state is PlayerStatePenalty:
			return
		# player has shoot
		owner.team.penalties_shot_taken()
		owner.team.team_opponents.gain_possession()
		move_to_center(shooting_player)
		shooting_player	= null
		owner.field.penalties_ready = false
		goalkeeper.set_state(PlayerStateGoalkeeperPenalty.new())
	# team gains poss, select next shooter
	else:
		move_to_center(goalkeeper)
		next_shooter()


func move_to_center(player: SimPlayer) -> void:
	if player == null:
		return

	var deviation: Vector2 = Vector2(0, 20 * (owner.team.players.find(player) + 1))
	if owner.team.left_half:
		deviation = -deviation
	player.set_destination(owner.field.center)
	player.set_state(PlayerStateIdle.new())


func next_shooter(increment: bool = true) -> void:
	if increment:
		shooting_player_index += 1
	
	shooting_player = owner.team.players[shooting_player_index]
	owner.team.players[shooting_player_index].set_state(PlayerStatePenalty.new())


