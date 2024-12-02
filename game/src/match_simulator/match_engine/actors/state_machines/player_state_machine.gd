# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name PlayerStateMachine
extends StateMachine


func update(
	p_team_has_ball: bool,
	p_is_touching_ball: bool,
	p_distance_to_player: float,
	) -> void:
	super(p_team_has_ball, p_is_touching_ball, p_distance_to_player)

	match state:
		State.IDLE:
			_state_idle()
		State.RECEIVING_PASS:
			_state_receive_pass()
		State.RECEIVED_PASS:
			state = State.IDLE
		State.DRIBBLE:
			state = State.IDLE
		State.MOVE:
			state = State.IDLE
		State.PRESSING:
			if is_touching_ball:
				state = State.TACKLE
		State.TACKLE:
			state = State.IDLE
		State.PASSING:
			state = State.IDLE
		State.SHOOTING:
			state = State.IDLE
		State.TACKLE:
			state = State.IDLE
	# print("nr %d has ball %s state %s"%[player_res.nr, team_has_ball, State.keys()[state]])


func _state_idle() -> void:
	if is_touching_ball:
		if team_has_ball:
			if _should_shoot():
				state = State.SHOOTING
			else:
				state = State.PASSING
			# elif _should_pass():
			# 	state = State.PASSING
			# elif _should_dribble():
			# 	state = State.DRIBBLE
		else:
			state = State.TACKLE
	else:
		state = State.MOVE


func _state_receive_pass() -> void:
	if is_touching_ball:
		state = State.RECEIVED_PASS
	elif same_state_count > 12:
		state = State.IDLE


func _should_dribble() -> bool:
	# check something, but for now, nothing comes to my mind
	return RngUtil.match_rng.randi_range(1, 100) > 70


func _should_shoot() -> bool:
	if ball.empty_net:
		return true
	if ball.players_in_shoot_trajectory < 2:
		return RngUtil.match_rng.randi_range(1, 100) > 95
	return RngUtil.match_rng.randi_range(1, 100) > 98


func _should_pass() -> bool:
	if distance_to_player < 50:
		return RngUtil.match_rng.randi_range(1, 100) < 60
	return RngUtil.match_rng.randi_range(1, 100) < 10
