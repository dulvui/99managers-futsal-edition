# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

# match time control
signal half_time
signal full_time
signal update_time
# position updates
signal ball_update
signal players_update
# engine future signals
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

var future: bool

# make private, because _rng shoud never be accessed outside engine
# state would be changed and no longer matches future/past engine state
var _rng: RandomNumberGenerator


func _init(p_future: bool = false) -> void:
	future = p_future


func setup(p_home_team: Team, p_away_team: Team, match_seed: int, p_future: bool = false) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = match_seed

	future = p_future

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
	home_team.setup(p_home_team, field, home_plays_left, home_has_ball)
	away_team = SimTeam.new(_rng)
	away_team.setup(p_away_team, field, not home_plays_left, not home_has_ball)
	home_team.team_opponents =  away_team
	away_team.team_opponents =  home_team
	
	# set left/right pointers to home/away team
	left_team = home_team
	right_team = away_team
	field.left_team = home_team
	field.right_team = away_team


func update() -> void:
	ticks += 1

	# field/ball updates more frequently on every tick
	# for better colission detections
	field.update()
	ball_update.emit()

	# teams/players instead update less frequent
	# state machines don't require high frequency
	if ticks % Const.STATE_UPDATE_TICKS == 0:
		left_team.update()
		right_team.update()
		players_update.emit()

	# time related code
	if field.clock_running:
		# update real time in seconds
		time_ticks += 1
		if time_ticks % Const.TICKS_PER_SECOND == 0:
			time += 1
			update_time.emit()

			# update posession stats
			if home_team.has_ball:
				possession_counter += 1

			home_team.stats.possession = int(possession_counter / time * 100.0)
			away_team.stats.possession = 100 - home_team.stats.possession

			# halftime
			if time == Const.HALF_TIME_SECONDS:
				set_half_time()
			elif time == Const.FULL_TIME_SECONDS:
				set_full_time()


func simulate(end_time: int = Const.FULL_TIME_SECONDS) -> void:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()

	# save simulated flags, to restore if endtime < FULL_TIME_SECONDS
	var home_simulated: bool = home_team.simulated
	var away_simulated: bool = away_team.simulated
	# set simulation flags to activate auto changes ecc
	home_team.simulated = true
	away_team.simulated = true

	# simulate game
	while time < end_time:
		update()
	
	# restore simulation flags, in case only partial game has been simulated
	home_team.simulated = home_simulated
	away_team.simulated = away_simulated
	
	var load_time: int = Time.get_ticks_msec() - start_time
	print("benchmark in: " + str(load_time) + " ms")

	print("result: %d - %d" % [home_team.stats.goals, away_team.stats.goals])
	print("shots:  %d - %d" % [home_team.stats.shots, away_team.stats.shots])
	print("simulating match done.")


func simulate_match(matchz: Match) -> void:
	setup(matchz.home, matchz.away, matchz.id)
	simulate()
	matchz.set_result(home_team.stats.goals, away_team.stats.goals)


func set_half_time() -> void:
	# switch left/right team, assuming home starts always left
	left_team = away_team
	right_team = home_team
	field.left_team = away_team
	field.right_team = home_team
	left_team.left_half = true
	right_team.left_half = false

	for player: SimPlayer in left_team.players:
		player.left_half = true
	for player: SimPlayer in right_team.players:
		player.left_half = false

	field.ball.set_pos(field.center)

	# stamina recovery 15 minutes
	var half_time_ticks: int = 15 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in left_team.players:
		player.player_res.recover_stamina(half_time_ticks)
	for player: SimPlayer in right_team.players:
		player.player_res.recover_stamina(half_time_ticks)
	
	half_time.emit()


func set_full_time() -> void:
	# stamina recovery 30 minutes
	var recovery: int = 30 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in left_team.players:
		player.player_res.recover_stamina(recovery)
	for player: SimPlayer in right_team.players:
		player.player_res.recover_stamina(recovery)
	
	full_time.emit()


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
