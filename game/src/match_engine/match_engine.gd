# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

signal half_time
signal full_time
signal penalties_start
signal match_finish

signal goal
signal key_action

var matchz: Match

var field: SimField
var home_team: SimTeam
var away_team: SimTeam
var left_team: SimTeam
var right_team: SimTeam

# all ticks, when clock is running and not running
var ticks: int
# ticks only when clock is running
var ticks_clock: int
# real time seconds every Const.TICKS
var seconds: int
# to debug and prevent endless simulation/games
var ticks_clock_not_running: int

# stats
var possession_counter: float

# time flags
var no_draw: bool
var overtime: bool
var match_over: bool

var rng: RngUtil


func setup(p_matchz: Match, p_home_team: Team = null, p_away_team: Team = null) -> void:
	matchz = p_matchz

	rng = RngUtil.new(str(matchz.id))

	no_draw = matchz.no_draw
	overtime = false
	match_over = false

	field = SimField.new()

	field.touch_line_out.connect(_on_touch_line_out)
	field.goal_line_out_left.connect(_on_goal_line_out_left)
	field.goal_line_out_right.connect(_on_goal_line_out_right)
	field.goal_left.connect(_on_goal_left)
	field.goal_right.connect(_on_goal_right)

	ticks = 0
	ticks_clock = 0
	seconds = 0
	possession_counter = 0.0
	ticks_clock_not_running = 0

	# var left_plays_left: bool = rng.randi_range(0, 1) == 0
	var home_plays_left: bool = true
	var home_has_ball: bool = rng.randi_range(0, 1) == 0

	# set up home/away team
	var home_res: Team = p_home_team
	var away_res: Team = p_away_team
	if home_res == null:
		home_res = Global.world.get_team_by_id(matchz.home.id, matchz.competition_id)
	if away_res == null:
		away_res = Global.world.get_team_by_id(matchz.away.id, matchz.competition_id)

	home_team = SimTeam.new(rng)
	away_team = SimTeam.new(rng)
	home_team.setup(home_res, field, home_plays_left, home_has_ball)
	away_team.setup(away_res, field, not home_plays_left, not home_has_ball)

	home_team.team_opponents = away_team
	away_team.team_opponents = home_team

	# set left/right pointers to home/away team
	left_team = home_team
	right_team = away_team
	field.left_team = home_team
	field.right_team = away_team

	# fouls signals
	home_team.foul.connect(_on_home_commits_foul)
	away_team.foul.connect(_on_away_commits_foul)

	# test penalties
	if DebugUtil.penalties_test:
		no_draw = true
		_on_half_time()
		_on_full_time()
		_on_overtime()
		_on_full_overtime()


func update() -> void:
	ticks += 1

	# teams/players logic/state machine updates
	if ticks % Const.TICKS_LOGIC == 0:
		left_team.update()
		right_team.update()

	# players movements
	# before field update, to detect collisions on tick earlier
	left_team.move()
	right_team.move()

	# field/ball updates more frequently on every tick
	# for better collision detection
	field.update()

	# clock not running
	if not field.clock_running:
		# for debugging and match stuck diagnosis
		ticks_clock_not_running += 1
		if ticks_clock_not_running > 20 * Const.TICKS:
			push_error("clock not running for over 20 seconds...")
			breakpoint
		return

	# clock running
	ticks_clock += 1
	ticks_clock_not_running = 0

	# wait to reach needed ticks for one second
	if ticks_clock % Const.TICKS != 0:
		return

	# update real time in seconds
	seconds += 1

	# update possession stats
	if home_team.has_ball:
		possession_counter += 1
	home_team.stats.possession = int(possession_counter / seconds * 100.0)
	away_team.stats.possession = 100 - home_team.stats.possession

	# break or over checks
	match seconds:
		Const.HALF_TIME_SECONDS:
			_on_half_time()
		Const.FULL_TIME_SECONDS:
			_on_full_time()
		Const.OVER_TIME_SECONDS:
			_on_overtime()
		Const.FULL_OVER_TIME_SECONDS:
			_on_full_overtime()


func simulate(end_seconds: int = -1) -> void:
	# save simulated flags, to restore if end_seconds < FULL_TIME_SECONDS
	var home_simulated: bool = home_team.simulated
	var away_simulated: bool = away_team.simulated
	# set simulation flags to activate auto changes ecc
	home_team.simulated = true
	away_team.simulated = true

	# simulate until match is over
	if end_seconds < 0:
		while not match_over:
			update()
	# simulate only until end_seconds, not until match is over
	else:
		while seconds < end_seconds:
			update()

		# restore simulation flags
		home_team.simulated = home_simulated
		away_team.simulated = away_simulated


func simulate_match(p_matchz: Match, fast: bool = false) -> void:
	matchz = p_matchz

	# full engine simulation
	if not fast:
		setup(matchz)
		simulate()
		return

	# fast match simulation with simple random numbers
	rng = RngUtil.new(str(matchz.id))

	var home_goals: int = rng.randi() % 10
	var away_goals: int = rng.randi() % 10
	var home_penalties_goals: int = 0
	var away_penalties_goals: int = 0

	# combination of all goals of first and second match
	var total_home_goals: int = home_goals
	var total_away_goals: int = away_goals

	# add goals from first match
	if matchz.first_leg != null:
		# home/away sides need to be inverted
		total_home_goals += matchz.first_leg.away_goals
		total_away_goals += matchz.first_leg.home_goals

	# check if penalties are needed
	if matchz.no_draw and total_home_goals == total_away_goals:
		# fast and easy
		# just score 4 goals and assign 5th goal to winner
		home_penalties_goals = 4
		away_penalties_goals = 4
		if rng.randi() % 2 == 0:
			home_penalties_goals += 1
		else:
			away_penalties_goals += 1

	matchz.set_result(
		home_goals,
		away_goals,
		home_penalties_goals,
		away_penalties_goals,
	)


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


func _on_home_commits_foul(foul_position: Vector2) -> void:
	_check_foul_result(home_team, foul_position)
	key_action.emit()


func _on_away_commits_foul(foul_position: Vector2) -> void:
	_check_foul_result(away_team, foul_position)
	key_action.emit()


func _check_foul_result(commiting_team: SimTeam, foul_position: Vector2) -> void:
	commiting_team.stats.fouls_count += 1
	commiting_team.stats.fouls += 1
	commiting_team.team_opponents.gain_possession()
	field.clock_running = false

	# check penalty
	if commiting_team.left_half:
		if Geometry2D.is_point_in_polygon(foul_position, field.penalty_areas.left):
			commiting_team.team_opponents.stats.penalties += 1
			field.ball.set_pos(field.penalty_areas.spot_left)
			home_team.set_state(TeamStatePenalty.new())
			away_team.set_state(TeamStatePenalty.new())
			return
	else:
		if Geometry2D.is_point_in_polygon(foul_position, field.penalty_areas.right):
			commiting_team.team_opponents.stats.penalties += 1
			field.ball.set_pos(field.penalty_areas.spot_right)
			home_team.set_state(TeamStatePenalty.new())
			away_team.set_state(TeamStatePenalty.new())
			return

	# check penalty 10m
	if commiting_team.stats.fouls_count >= 6:
		if commiting_team.left_half:
			commiting_team.team_opponents.stats.penalties_10m += 1
			field.ball.set_pos(field.penalty_areas.spot_10m_left)
			home_team.set_state(TeamStatePenalty.new())
			away_team.set_state(TeamStatePenalty.new())
			return

		commiting_team.team_opponents.stats.penalties_10m += 1
		field.ball.set_pos(field.penalty_areas.spot_10m_right)
		home_team.set_state(TeamStatePenalty.new())
		away_team.set_state(TeamStatePenalty.new())
		return

	# free kick
	commiting_team.team_opponents.stats.free_kicks += 1
	field.ball.set_pos(foul_position)
	home_team.set_state(TeamStateFreeKick.new())
	away_team.set_state(TeamStateFreeKick.new())


func _on_goal_line_out_left() -> void:
	# corner
	if left_team.has_ball:
		right_possess()
		right_team.stats.corners += 1
		right_team.set_state(TeamStateCorner.new())
		left_team.set_state(TeamStateCorner.new())
		key_action.emit()
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
		key_action.emit()
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


func _on_goal_right() -> void:
	left_team.stats.goals += 1
	left_team.set_state(TeamStateGoalCelebrate.new())
	right_team.set_state(TeamStateStartPositions.new())
	right_possess()
	goal.emit()


func _teams_switch_sides() -> void:
	# reset foul counter
	home_team.stats.fouls_count = 0
	away_team.stats.fouls_count = 0

	# invert team references
	if home_team.left_half:
		left_team = away_team
		right_team = home_team
	else:
		left_team = home_team
		right_team = away_team
	field.left_team = away_team
	field.right_team = home_team

	# set all left_half flag
	left_team.left_half = true
	right_team.left_half = false
	for player: SimPlayer in left_team.players:
		player.left_half = true
	for player: SimPlayer in right_team.players:
		player.left_half = false

	# update starting positions
	left_team.set_start_positions()
	right_team.set_start_positions()


func _recover_stamina(minutes: int) -> void:
	var recovery: int = minutes * Const.TICKS_LOGIC * 60
	for player: SimPlayer in left_team.players:
		player.res.recover_stamina(recovery)
	for player: SimPlayer in right_team.players:
		player.res.recover_stamina(recovery)


func _on_half_time() -> void:
	half_time.emit()

	_recover_stamina(15)
	_teams_switch_sides()
	left_team.set_state(TeamStateEnterField.new())
	right_team.set_state(TeamStateEnterField.new())
	field.ball.set_pos(field.center)


func _on_full_time() -> void:
	overtime = no_draw and home_team.stats.goals == away_team.stats.goals

	if overtime:
		field.ball.set_pos(field.center)
		_teams_switch_sides()
		_recover_stamina(5)
	else:
		_match_over()

	full_time.emit()


func _on_overtime() -> void:
	field.ball.set_pos(field.center)
	_teams_switch_sides()
	_recover_stamina(5)


func _on_full_overtime() -> void:
	field.penalties = home_team.stats.goals == away_team.stats.goals
	if field.penalties:
		overtime = false
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
		# connect team penaties shot signals
		left_team.penalties_shot.connect(_check_penalties_over)
		right_team.penalties_shot.connect(_check_penalties_over)

		penalties_start.emit()

		# TODO show player order selection, and add ALL players
		# for now, simply 5 players shot in array order
		left_team.set_state(TeamStatePenalties.new())
		right_team.set_state(TeamStatePenalties.new())
	else:
		_match_over()


func _check_penalties_over() -> void:
	var home_shots: int = home_team.stats.penalty_shootout_shots
	var home_goals: int = home_team.stats.penalty_shootout_goals

	var away_shots: int = away_team.stats.penalty_shootout_shots
	var away_goals: int = away_team.stats.penalty_shootout_goals

	# check if teams still need to shoot 5 shots per team
	if home_shots + away_shots < Const.PENALTY_KICKS * 2:
		var home_goals_max: int = home_goals + Const.PENALTY_KICKS - home_shots
		var away_goals_max: int = away_goals + Const.PENALTY_KICKS - away_shots
		# check if home made more goals than away has made and away still can make
		if home_goals > away_goals_max:
			_match_over()
			return
		# check if away made more goals than home has made and home still can make
		if away_goals > home_goals_max:
			_match_over()
			return
	# check if one team missed and the other made goal
	elif home_shots == away_shots:
		if home_goals != away_goals:
			_match_over()
			return


func _on_penalties_goal() -> void:
	if left_team.has_ball:
		left_team.stats.penalty_shootout_goals += 1
	else:
		right_team.stats.penalty_shootout_goals += 1


func _match_over() -> void:
	match_over = true
	field.clock_running = false

	# assign result
	matchz.set_result(
		home_team.stats.goals,
		away_team.stats.goals,
		home_team.stats.penalty_shootout_goals,
		away_team.stats.penalty_shootout_shots,
	)

	match_finish.emit()

