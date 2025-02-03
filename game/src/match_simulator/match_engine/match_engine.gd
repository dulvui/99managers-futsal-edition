# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

signal half_time
signal full_time
signal update_time

signal goal
# signal key_action

var field: SimField
var home_team: SimTeam
var away_team: SimTeam

var left_team: SimTeam
var right_team: SimTeam

var ticks: int
var time_ticks: int
var time: int

# stats
var possession_counter: float

# flag if match goes to overtime and penalties, if finish in draw
var no_draw: bool
var over_time: bool
var penalties: bool
var match_over: bool

# make private, because _rng shoud never be accessed outside engine
# state would be changed and no longer matches future/past engine state
var _rng: RandomNumberGenerator


func setup(p_matchz: Match) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = p_matchz.id

	no_draw = p_matchz.no_draw
	over_time = false
	penalties = false
	match_over = false

	field = SimField.new(_rng)

	field.touch_line_out.connect(_on_touch_line_out)
	field.goal_line_out_left.connect(_on_goal_line_out_left)
	field.goal_line_out_right.connect(_on_goal_line_out_right)
	field.goal_left.connect(_on_goal_left)
	field.goal_right.connect(_on_goal_right)

	ticks = 0
	time_ticks = 0
	time = 0
	possession_counter = 0.0

	# var left_plays_left: bool = _rng.randi_range(0, 1) == 0
	var home_plays_left: bool = true
	var home_has_ball: bool = _rng.randi_range(0, 1) == 0

	# set up home/away team
	home_team = SimTeam.new(_rng)
	away_team = SimTeam.new(_rng)
	home_team.setup(p_matchz.home, field, home_plays_left, home_has_ball)
	away_team.setup(p_matchz.away, field, not home_plays_left, not home_has_ball)

	home_team.team_opponents =  away_team
	away_team.team_opponents =  home_team
	
	# set left/right pointers to home/away team
	left_team = home_team
	right_team = away_team
	field.left_team = home_team
	field.right_team = away_team

	# test penalties
	if DebugUtil.penalties_test:
		no_draw = true
		_on_full_time()
		_on_over_time()
		_on_full_over_time()


func update() -> void:
	ticks += 1

	# field/ball updates more frequently on every tick
	# for better colission detections
	field.update()

	# teams/players instead update less frequent
	# state machines don't require high frequency
	if ticks % Const.TICKS_LOGIC == 0:
		left_team.update()
		right_team.update()

	# time related code
	if field.clock_running:
		# update real time in seconds
		time_ticks += 1
		if time_ticks % Const.TICKS == 0:
			time += 1
			update_time.emit()

			# update posession stats
			if home_team.has_ball:
				possession_counter += 1
			home_team.stats.possession = int(possession_counter / time * 100.0)
			away_team.stats.possession = 100 - home_team.stats.possession

			# time control
			if time == Const.HALF_TIME_SECONDS:
				_on_half_time()
			elif time == Const.FULL_TIME_SECONDS:
				_on_full_time()
			elif over_time:
				if time == Const.OVER_TIME_SECONDS:
					_on_over_time()
				elif time == Const.FULL_OVER_TIME_SECONDS:
					_on_full_over_time()


func simulate(end_time: int = -1) -> void:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()

	# save simulated flags, to restore if endtime < FULL_TIME_SECONDS
	var home_simulated: bool = home_team.simulated
	var away_simulated: bool = away_team.simulated
	# set simulation flags to activate auto changes ecc
	home_team.simulated = true
	away_team.simulated = true

	# simulate game to given end time
	if end_time > 0:
		while time < end_time:
			update()
		# restore simulation flags
		home_team.simulated = home_simulated
		away_team.simulated = away_simulated
	# simulate until match is over
	else:
		while not match_over:
			update()
	
	# print time passed for simulation
	var load_time: int = Time.get_ticks_msec() - start_time
	print("benchmark in: " + str(load_time) + " ms")

	print("result: %d - %d" % [home_team.stats.goals, away_team.stats.goals])
	print("shots:  %d - %d" % [home_team.stats.shots, away_team.stats.shots])
	print("simulating match done.")


func simulate_match(matchz: Match, fast: bool = false) -> void:
	setup(matchz)

	if fast:
		var home_goals: int = _rng.randi() % 10
		var away_goals: int = _rng.randi() % 10
		matchz.set_result(home_goals, away_goals)
		return

	simulate()

	matchz.set_result(home_team.stats.goals, away_team.stats.goals)


func left_possess() -> void:
	left_team.has_ball = true
	right_team.has_ball = false
	# recacluate best sector, after flags change
	field.force_update_calculator()


func right_possess() -> void:
	left_team.has_ball = false
	right_team.has_ball = true
	# recacluate best sector, after flags change
	field.force_update_calculator()


func _on_goal_line_out_left() -> void:
	# corner
	if left_team.has_ball:
		right_possess()
		right_team.stats.corners += 1
		left_team.set_state(TeamStateCorner.new())
		right_team.set_state(TeamStateCorner.new())
		return

	# goalkeeper ball
	left_possess()
	field.ball.set_pos_xy(field.line_left + 40, field.center.y)
	left_team.set_state(TeamStateGoalkeeper.new())
	right_team.set_state(TeamStateGoalkeeper.new())


func _on_goal_line_out_right() -> void:
	# corner
	if right_team.has_ball:
		left_possess()
		left_team.stats.corners += 1
		left_team.set_state(TeamStateCorner.new())
		right_team.set_state(TeamStateCorner.new())
		return

	# goalkeeper ball
	right_possess()
	field.ball.set_pos_xy(field.line_right - 40, field.center.y)
	left_team.set_state(TeamStateGoalkeeper.new())
	right_team.set_state(TeamStateGoalkeeper.new())


func _on_touch_line_out() -> void:
	if left_team.has_ball:
		right_possess()
		right_team.stats.kick_ins += 1
	else:
		left_possess()
		left_team.stats.kick_ins += 1
	
	left_possess()
	left_team.set_state(TeamStateKickin.new())
	right_team.set_state(TeamStateKickin.new())


func _on_goal_left() -> void:
	right_team.stats.goals += 1
	right_team.set_state(TeamStateGoalCelebrate.new())
	left_team.set_state(TeamStateStartPositions.new())
	left_possess()
	goal.emit()
	# to trigger score labels update
	update_time.emit()


func _on_goal_right() -> void:
	left_team.stats.goals += 1
	left_team.set_state(TeamStateGoalCelebrate.new())
	right_team.set_state(TeamStateStartPositions.new())
	right_possess()
	goal.emit()
	# to trigger score labels update
	update_time.emit()


func _teams_switch_sides() -> void:
	if home_team.left_half:
		left_team = away_team
		right_team = home_team
	else:
		left_team = home_team
		right_team = away_team
	
	field.left_team = away_team
	field.right_team = home_team
	left_team.left_half = true
	right_team.left_half = false

	for player: SimPlayer in left_team.players:
		player.left_half = true
	for player: SimPlayer in right_team.players:
		player.left_half = false


func _recover_stamina(minutes: int) -> void:
	var recovery: int = minutes * Const.TICKS_LOGIC * 60
	for player: SimPlayer in left_team.players:
		player.player_res.recover_stamina(recovery)
	for player: SimPlayer in right_team.players:
		player.player_res.recover_stamina(recovery)


func _on_half_time() -> void:
	field.ball.set_pos(field.center)
	_teams_switch_sides()
	_recover_stamina(15)	
	half_time.emit()


func _on_full_time() -> void:
	over_time = no_draw and home_team.stats.goals == away_team.stats.goals
	if over_time:
		field.ball.set_pos(field.center)
		_teams_switch_sides()
		_recover_stamina(5)
	else:
		match_over = true
	full_time.emit()


func _on_over_time() -> void:
	field.ball.set_pos(field.center)
	_teams_switch_sides()
	_recover_stamina(5)	


func _on_full_over_time() -> void:
	penalties = home_team.stats.goals == away_team.stats.goals
	if penalties:
		over_time = false
		_recover_stamina(5)
		# disconnect goal signals
		field.touch_line_out.disconnect(_on_touch_line_out)
		field.goal_line_out_left.disconnect(_on_goal_line_out_left)
		field.goal_line_out_right.disconnect(_on_goal_line_out_right)
		field.goal_left.disconnect(_on_goal_left)
		field.goal_right.disconnect(_on_goal_right)
		# reconnect goal signals
		field.goal_left.connect(_on_penalties_goal)
		field.goal_right.connect(_on_penalties_goal)

		# TODO show player order selection, and add ALL players
		# for now, simply 5 players shot in array order
		field.penalties = true
		left_team.set_state(TeamStatePenalties.new())
		right_team.set_state(TeamStatePenalties.new())
	else:
		match_over = true


func _check_penalties_over() -> void:
	var	home_shots: int = home_team.stats.penalty_shootout_shots
	var	home_goals: int = home_team.stats.penalty_shootout_goals

	var	away_shots: int = away_team.stats.penalty_shootout_shots
	var	away_goals: int = away_team.stats.penalty_shootout_goals

	# check if teams still need to shoot 5 shots per team
	if home_shots + away_shots < Const.PENALTY_KICKS * 2:
		var home_goals_max: int = home_goals + Const.PENALTY_KICKS - home_shots
		var away_goals_max: int = away_goals + Const.PENALTY_KICKS - away_shots
		# check if home made more goals than away has made and away still can make
		if home_goals >	away_goals_max: 
			match_over = true
			penalties = false
			return
		# check if away made more goals than home has made and home still can make
		if away_goals >	home_goals_max: 
			match_over = true
			penalties = false
			return
	# check if one team missed and the other made goal
	elif home_shots == away_shots:
		if home_goals != away_goals:
			match_over = true
			penalties = false
			return


func _on_penalties_goal() -> void:
	if left_team.has_ball:
		left_team.stats.penalty_shootout_goals += 1
	else:
		right_team.stats.penalty_shootout_goals += 1

