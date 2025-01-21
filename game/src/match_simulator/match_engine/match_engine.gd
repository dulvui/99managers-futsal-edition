# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

signal half_time
signal full_time
signal update_time

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


func setup(p_left_team: Team, p_right_team: Team, match_seed: int) -> void:
	field = SimField.new()

	field.touch_line_out.connect(_on_touch_line_out)
	field.goal_line_out_left.connect(_on_goal_line_out_left)
	field.goal_line_out_right.connect(_on_goal_line_out_right)
	field.goal_left.connect(_on_goal_left)
	field.goal_right.connect(_on_goal_right)

	ticks = 0
	time_ticks = 0
	time = 0
	possession_counter = 0.0

	RngUtil.match_rng.seed = hash(match_seed)

	# var left_plays_left: bool = RngUtil.match_rng.randi_range(0, 1) == 0
	var left_plays_left: bool = true
	var left_has_ball: bool = RngUtil.match_rng.randi_range(0, 1) == 0

	left_team = SimTeam.new()
	left_team.setup(p_left_team, field, left_plays_left, left_has_ball)
	home_team = left_team

	right_team = SimTeam.new()
	right_team.setup(p_right_team, field, not left_plays_left, not left_has_ball)
	away_team = right_team

	left_team.team_opponents =  right_team
	right_team.team_opponents =  left_team

	field.left_team = left_team
	field.right_team = right_team


func update() -> void:
	ticks += 1

	# field/ball updates more frequently on every tick
	# for better colission detections
	field.update()

	# teams/players instead update less frequent
	# state machines don't require high frequency
	if ticks % Const.STATE_UPDATE_TICKS == 0:
		left_team.update()
		right_team.update()
	
	# time related code
	if field.clock_running:
		# update real time in seconds
		time_ticks += 1
		if time_ticks % Const.TICKS_PER_SECOND == 0:
			time += 1
			update_time.emit()

		# update posession stats
		if left_team.has_ball:
			possession_counter += 1.0

		left_team.stats.possession = possession_counter / time_ticks * 100
		right_team.stats.possession = 100 - left_team.stats.possession

		# halftime
		if time == Const.HALF_TIME_SECONDS:
			set_half_time()
		elif time == Const.FULL_TIME_SECONDS:
			set_full_time()


func simulate(end_time: int = Const.FULL_TIME_SECONDS) -> void:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()

	# save simulated flags, to restore if endtime < FULL_TIME_SECONDS
	var left_simulated: bool = left_team.simulated
	var right_simulated: bool = right_team.simulated
	# set simulation flags to activate auto changes ecc
	left_team.simulated = true
	right_team.simulated = true

	# simulate game
	while time < end_time:
		update()
	
	# restore simulation flags, in case only partial game has been simulated
	left_team.simulated = left_simulated
	right_team.simulated = right_simulated
	
	var load_time: int = Time.get_ticks_msec() - start_time
	print("benchmark in: " + str(load_time) + " ms")

	print("result: %d - %d" % [left_team.stats.goals, right_team.stats.goals])
	print("shots:  %d - %d" % [left_team.stats.shots, right_team.stats.shots])
	print("simulating match done.")


func simulate_match(matchz: Match) -> void:
	setup(matchz.home, matchz.away, matchz.id)
	simulate()
	matchz.set_result(right_team.stats.goals, left_team.stats.goals)


func set_half_time() -> void:
	# switch left/right team
	left_team = away_team
	right_team = home_team

	field.ball.set_pos(field.center)

	# stamina recovery 15 minutes
	var half_time_ticks: int = 15 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in left_team.players:
		player.recover_stamina(half_time_ticks)
	for player: SimPlayer in right_team.players:
		player.recover_stamina(half_time_ticks)
	
	half_time.emit()


func set_full_time() -> void:
	# stamina recovery 30 minutes
	var recovery: int = 30 * Const.TICKS_PER_SECOND * 60
	for player: SimPlayer in left_team.players:
		player.recover_stamina(recovery)
	for player: SimPlayer in right_team.players:
		player.recover_stamina(recovery)
	
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
	field.ball.set_pos_xy(field.line_left + 40, field.center.y)
	left_team.players[0].set_state(PlayerStateGoalkeeperBall.new())


func _on_goal_line_out_right() -> void:
	# corner
	if right_team.has_ball:
		left_possess()
		left_team.stats.corners += 1
		left_team.set_state(TeamStateCorner.new())
		right_team.set_state(TeamStateCorner.new())
		return

	# goalkeeper ball
	field.ball.set_pos_xy(field.line_right - 40, field.center.y)
	right_team.players[0].set_state(PlayerStateGoalkeeperBall.new())


func _on_touch_line_out() -> void:
	if left_team.has_ball:
		right_possess()
		right_team.stats.kick_ins += 1
	else:
		left_possess()
		left_team.stats.kick_ins += 1
	
	left_team.set_state(TeamStateKickin.new())
	right_team.set_state(TeamStateKickin.new())


func _on_goal_left() -> void:
	left_team.stats.goals += 1
	right_team.set_state(TeamStateGoalCelebrate.new())
	left_team.set_state(TeamStateStartPositions.new())
	right_possess()


func _on_goal_right() -> void:
	right_team.stats.goals += 1
	right_team.set_state(TeamStateGoalCelebrate.new())
	left_team.set_state(TeamStateStartPositions.new())
	left_possess()
