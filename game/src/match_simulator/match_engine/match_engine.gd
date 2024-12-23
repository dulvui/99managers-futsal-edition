# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchEngine

const INTERCEPTION_TIMER_START: int = 3

var field: SimField
var home_team: SimTeam
var away_team: SimTeam

var home_plays_left: bool

var ticks: int

# for trajectory calculations
var post_bottom: Vector2
var post_top: Vector2
var players: Array[SimPlayer]

var goalkeeper: SimPlayer

var shoot_trajectory_polygon: PackedVector2Array

var nearest_player: SimPlayer

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

	shoot_trajectory_polygon = PackedVector2Array()

	#RngUtil.match_rng.state = 0
	RngUtil.match_rng.seed = hash(match_seed)

	home_plays_left = RngUtil.match_rng.randi_range(0, 1) == 0
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
	field.ball.update()

	calc_distances()

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


func simulate(matchz: Match) -> Match:
	print("simulating match...")
	var start_time: int = Time.get_ticks_msec()
	setup(matchz.home, matchz.away, matchz.id)

	# first half
	var time: int = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.ball.clock_running:
			time += 1
	
	half_time()
	# second half
	print("half time...")
	time = 0
	while time < Const.HALF_TIME_SECONDS * Const.TICKS_PER_SECOND:
		update()
		if field.ball.clock_running:
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
	home_plays_left = not home_plays_left
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


func calc_distances() -> void:
	for player: SimPlayer in home_team.players + away_team.players:
		calc_distance_to_goal(player, home_team.left_half)
		calc_distance_to_own_goal(player, home_team.left_half)
		calc_player_to_ball_distance(player)
	calc_free_shoot_trajectory()


func calc_distance_to_goal(player: SimPlayer, left_half: bool) -> void:
	if left_half:
		player.distance_to_goal = calc_distance_to(player.pos, field.goal_right)
	player.distance_to_goal = calc_distance_to(player.pos, field.goal_left)


func calc_distance_to_own_goal(player: SimPlayer, left_half: bool) -> void:
	if left_half:
		player.distance_to_own_goal = calc_distance_to(player.pos, field.goal_left)
	player.distance_to_own_goal = calc_distance_to(player.pos, field.goal_right)


func calc_player_to_ball_distance(player: SimPlayer) -> void:
	player.distance_to_ball = calc_distance_to(player.pos, field.ball.pos)


func calc_distance_to(from: Vector2, to: Vector2) -> float:
	return from.distance_squared_to(to)


func calc_free_shoot_trajectory() -> void:
	field.ball.players_in_shoot_trajectory = 0

	if home_team.has_ball:
		goalkeeper = away_team.players[0]
		players = away_team.players
	else:
		goalkeeper = home_team.players[0]
		players = home_team.players

	if left_is_active_goal():
		post_top = field.goal_post_top_left
		post_bottom = field.goal_post_bottom_left
	else:
		post_top = field.goal_post_top_right
		post_bottom = field.goal_post_bottom_right

	# square from ball +/- 150 to goal posts and +/- 50 to ball
	# used to check empty net and players in trajectory
	# point_is_in_triangle() is too narrow
	shoot_trajectory_polygon.clear()
	shoot_trajectory_polygon.append(field.ball.pos + Vector2(0, 50))
	shoot_trajectory_polygon.append(field.ball.pos + Vector2(0, -50))
	shoot_trajectory_polygon.append(post_top + Vector2(0, -150))
	shoot_trajectory_polygon.append(post_bottom + Vector2(0, 150))

	field.ball.empty_net = not Geometry2D.is_point_in_polygon(goalkeeper.pos, shoot_trajectory_polygon)

	for player: SimPlayer in players:
		if Geometry2D.is_point_in_polygon(player.pos, shoot_trajectory_polygon):
			field.ball.players_in_shoot_trajectory += 1


func left_is_active_goal() -> bool:
	if home_plays_left and home_team.has_ball:
		return false
	if home_plays_left and away_team.has_ball:
		return true
	if not home_plays_left and home_team.has_ball:
		return true
	return false


func set_goalkeeper_ball(home: bool) -> void:
	if home:
		home_possess()
		goalkeeper = home_team.players[0]
	else:
		away_possess()
		goalkeeper = away_team.players[0]


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


func away_possess() -> void:
	away_team.has_ball = true
	home_team.has_ball = false


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
		(home_team.has_ball and home_plays_left and field.ball.pos.x < 600)
		or (home_team.has_ball and not home_plays_left and field.ball.pos.x > 600)
	):
		set_corner(false)
	elif (
		(away_team.has_ball and home_plays_left and field.ball.pos.x > 600)
		or (home_team.has_ball and not home_plays_left and field.ball.pos.x < 600)
	):
		set_corner(true)

	# goalkeeper ball
	elif field.ball.pos.x < 600:
		# left
		field.ball.set_pos_xy(field.line_left + 40, field.size.y / 2)
		set_goalkeeper_ball(home_plays_left)
	else:
		# right
		field.ball.set_pos_xy(field.line_right - 40, field.size.y / 2)
		set_goalkeeper_ball(not home_plays_left)


func _on_touch_line_out() -> void:
	if home_team.has_ball:
		away_possess()
		away_team.stats.kick_ins += 1
	else:
		home_possess()
		home_team.stats.kick_ins += 1


func _on_goal() -> void:
	if home_team.has_ball:
		home_team.stats.goals += 1
		away_possess()
	else:
		away_team.stats.goals += 1
		home_possess()

	#print("%s : %s"%[home_team.stats.goals, away_team.stats.goals])


