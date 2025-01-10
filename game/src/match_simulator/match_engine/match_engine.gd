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

	field.goal_line_out.connect(_on_goal_line_out)
	field.touch_line_out.connect(_on_touch_line_out)
	field.goal.connect(_on_goal)

	ticks = 0
	possession_counter = 0.0


	RngUtil.match_rng.seed = hash(match_seed)

	var home_plays_left: bool = RngUtil.match_rng.randi_range(0, 1) == 0
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
	

	assert(home_team.has_ball != away_team.has_ball)


func simulate(matchz: Match) -> Match:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()
	setup(matchz.home, matchz.away, matchz.id)

	# first half
	var time: int = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.clock_running:
			time += 1
	
	print("half time...")
	half_time()
	# second half
	time = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.clock_running:
			time += 1
	full_time()

	matchz.home_goals = home_team.stats.goals
	matchz.away_goals = away_team.stats.goals

	var load_time: int = Time.get_ticks_msec() - start_time
	print("benchmark in: " + str(load_time) + " ms")

	print("result: " + matchz.get_result())
	print("shots: h%d - a%d" % [home_team.stats.shots, away_team.stats.shots])
	print("simulating match done.")
	return matchz


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


func set_goalkeeper_ball(home: bool) -> void:
	if home:
		home_possess()
	else:
		away_possess()


func set_corner(home: bool) -> void:
	if home:
		home_possess()
		home_team.stats.corners += 1
	else:
		away_possess()
		away_team.stats.corners += 1


func home_possess() -> void:
	home_team.has_ball = true
	away_team.has_ball = false
	# recacluate best sector, after flags change
	field.force_update_calculator()


func away_possess() -> void:
	away_team.has_ball = true
	home_team.has_ball = false
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


func _on_goal_line_out() -> void:
	if (
		(home_team.has_ball and home_team.left_half and field.ball.pos.x < 600)
		or (home_team.has_ball and not home_team.left_half and field.ball.pos.x > 600)
	):
		set_corner(false)
	elif (
		(away_team.has_ball and home_team.left_half and field.ball.pos.x > 600)
		or (home_team.has_ball and not home_team.left_half and field.ball.pos.x < 600)
	):
		set_corner(true)

	# goalkeeper ball
	elif field.ball.pos.x < 600:
		# left
		field.ball.set_pos_xy(field.line_left + 40, field.size.y / 2)
		set_goalkeeper_ball(home_team.left_half)
	else:
		# right
		field.ball.set_pos_xy(field.line_right - 40, field.size.y / 2)
		set_goalkeeper_ball(not home_team.left_half)


func _on_touch_line_out() -> void:
	if home_team.has_ball:
		away_possess()
		away_team.stats.kick_ins += 1
	else:
		home_possess()
		home_team.stats.kick_ins += 1
	
	home_team.set_state(TeamStateKickin.new())
	away_team.set_state(TeamStateKickin.new())


func _on_goal() -> void:
	if home_team.has_ball:
		home_team.stats.goals += 1
		away_possess()
	else:
		away_team.stats.goals += 1
		home_possess()

	#print("%s : %s"%[home_team.stats.goals, away_team.stats.goals])


