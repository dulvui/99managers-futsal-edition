# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

const INTERCEPTION_TIMER_START: int = 8

var field: SimField
var home_team: SimTeam
var away_team: SimTeam

var ticks: int

# stats
var possession_counter: float

# count ticks passed between last interception
# to prevent constant possess change and stuck ball
var interception_timer: int


func setup(p_home_team: Team, p_away_team: Team, match_seed: int) -> void:
	field = SimField.new()

	field.touch_line_out.connect(_on_touch_line_out)
	field.goal_line_out_left.connect(_on_goal_line_out_left)
	field.goal_line_out_right.connect(_on_goal_line_out_right)
	field.goal_left.connect(_on_goal_left)
	field.goal_right.connect(_on_goal_right)

	ticks = 0
	possession_counter = 0.0

	RngUtil.match_rng.seed = hash(match_seed)

	# var home_plays_left: bool = RngUtil.match_rng.randi_range(0, 1) == 0
	var home_plays_left: bool = true
	var home_has_ball: bool = RngUtil.match_rng.randi_range(0, 1) == 0

	home_team = SimTeam.new()
	home_team.setup(p_home_team, field, home_plays_left, home_has_ball)
	home_team.interception.connect(_on_home_team_interception)

	away_team = SimTeam.new()
	away_team.setup(p_away_team, field, not home_plays_left, not home_has_ball)
	away_team.interception.connect(_on_away_team_interception)

	home_team.team_opponents =  away_team
	away_team.team_opponents =  home_team

	field.home_team = home_team
	field.away_team = away_team

	interception_timer = 0


func update() -> void:
	field.update()

	home_team.update()
	away_team.update()

	if interception_timer > 0:
		interception_timer -= 1

	if field.clock_running:
		ticks += 1

		# update posession stats
		if home_team.has_ball:
			possession_counter += 1.0
		home_team.stats.possession = possession_counter / ticks * 100
		away_team.stats.possession = 100 - home_team.stats.possession
	else:
		home_team.check_changes()
		away_team.check_changes()


func simulate(end_time: int = Const.FULL_TIME_SECONDS) -> void:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()
	
	# save simulated flags, to restore if endtime < FULL_TIME_SECONDS
	var home_simulated: bool = home_team.simulated
	var away_simulated: bool = away_team.simulated
	# set simulation flags to activate auto changes ecc
	home_team.simulated = true
	away_team.simulated = true

	# first half
	var time: int = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.clock_running:
			time += 1
			
			# stop simulation
			if time == end_time:
				home_team.simulated = home_simulated
				away_team.simulated = away_simulated
				return
	
	print("half time...")
	half_time()
	# second half
	time = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.clock_running:
			time += 1
			# stop simulation
			if time == end_time:
				home_team.simulated = home_simulated
				away_team.simulated = away_simulated
				return
	full_time()

	var load_time: int = Time.get_ticks_msec() - start_time
	print("benchmark in: " + str(load_time) + " ms")

	print("result: %d - %d" % [home_team.stats.goals, away_team.stats.goals])
	print("shots:  %d - %d" % [home_team.stats.shots, away_team.stats.shots])
	print("simulating match done.")


func simulate_match(matchz: Match) -> void:
	setup(matchz.home, matchz.away, matchz.id)
	simulate()
	matchz.set_result(home_team.stats.goals, away_team.stats.goals)


func half_time() -> void:
	home_team.left_half = not home_team.left_half
	field.ball.set_pos(field.center)

	# stamina recovery 15 minutes
	var half_time_ticks: int = 15 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in home_team.players:
		player.recover_stamina(half_time_ticks)
	for player: SimPlayer in away_team.players:
		player.recover_stamina(half_time_ticks)


func full_time() -> void:
	# stamina recovery 30 minutes
	var recovery: int = 30 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in home_team.players:
		player.recover_stamina(recovery)
	for player: SimPlayer in away_team.players:
		player.recover_stamina(recovery)


func home_possess() -> void:
	home_team.has_ball = true
	away_team.has_ball = false
	# recacluate best sector, after flags change
	field.force_update_calculator()


func away_possess() -> void:
	home_team.has_ball = false
	away_team.has_ball = true
	# recacluate best sector, after flags change
	field.force_update_calculator()


func _on_home_team_possess() -> void:
	home_possess()


func _on_away_team_possess() -> void:
	away_possess()


func _on_home_team_foul(player: Player) -> void:
	print("HOME FOUL " + player.surname)
	away_possess()


func _on_away_team_foul(player: Player) -> void:
	print("AWAY FOUL " + player.surname)
	home_possess()


func _on_home_team_interception() -> void:
	if interception_timer > 0:
		return
	interception_timer = INTERCEPTION_TIMER_START
	home_possess()


func _on_away_team_interception() -> void:
	if interception_timer > 0:
		return
	interception_timer = INTERCEPTION_TIMER_START
	away_possess()


func _on_goal_line_out_left() -> void:
	# home team corner
	if away_team.has_ball and away_team.left_half:
		_corner_home()
		return
	
	# away team corner
	if home_team.has_ball and home_team.left_half:
		_corner_away()
		return
	
	# goalkeeper ball
	field.ball.set_pos_xy(field.line_left + 40, field.center.y)


func _on_goal_line_out_right() -> void:
	# home team corner
	if away_team.has_ball and not away_team.left_half:
		_corner_home()
		return
	
	# away team corner
	if home_team.has_ball and not home_team.left_half:
		_corner_away()
		return
	
	# goalkeeper ball
	field.ball.set_pos_xy(field.line_right - 40, field.center.y)


func _corner_home() -> void:
	home_possess()
	home_team.stats.corners += 1
	home_team.set_state(TeamStateCorner.new())
	away_team.set_state(TeamStateCorner.new())


func _corner_away() -> void:
	away_possess()
	away_team.stats.corners += 1
	home_team.set_state(TeamStateCorner.new())
	away_team.set_state(TeamStateCorner.new())


func _on_touch_line_out() -> void:
	if home_team.has_ball:
		away_possess()
		away_team.stats.kick_ins += 1
	else:
		home_possess()
		home_team.stats.kick_ins += 1
	
	home_team.set_state(TeamStateKickin.new())
	away_team.set_state(TeamStateKickin.new())


func _on_goal_left() -> void:
	if away_team.left_half:
		home_team.stats.goals += 1
		away_team.set_state(TeamStateGoalCelebrate.new())
		away_possess()
	else:
		away_team.stats.goals += 1
		home_team.set_state(TeamStateGoalCelebrate.new())
		home_possess()


func _on_goal_right() -> void:
	if home_team.left_half:
		home_team.stats.goals += 1
		home_team.set_state(TeamStateGoalCelebrate.new())
		away_possess()
	else:
		away_team.stats.goals += 1
		away_team.set_state(TeamStateGoalCelebrate.new())
		home_possess()
