
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimFieldCalculator


var field: SimField

var sectors: Array[SimFieldSector]
var best_sector: SimFieldSector


# to not create new vars on every update
var post_bottom: Vector2
var post_top: Vector2
var players: Array[SimPlayer]
var goalkeeper: SimPlayer
var shoot_trajectory_polygon: PackedVector2Array
var nearest_player: SimPlayer


func _init(p_field: SimField) -> void:
	field = p_field
	shoot_trajectory_polygon = PackedVector2Array()
	

	# initialize field sectors for best position calculations
	sectors = []
	for x: int in field.size.x / 20:
		for y: int in field.size.y / 20:
			var sector: SimFieldSector = SimFieldSector.new()
			sector.setup(x, y)
			sectors.append(sector)
	
	best_sector = sectors[0]


func update() -> void:
	_calc_best_supporting_sector()
	_calc_player_distances()


func _calc_best_supporting_sector() -> void:
	best_sector.score = 0

	for sector: SimFieldSector in sectors:
		sector.score = 0
		
		# check if goal can be shoot from there
		# check if pass can be made


		if sector.score > best_sector.score:
			best_sector = sector


func _calc_player_distances() -> void:
	for player: SimPlayer in field.home_team.players + field.away_team.players:
		_calc_distance_to_goal(player, field.home_team.left_half)
		_calc_distance_to_own_goal(player, field.home_team.left_half)
		_calc_player_to_ball_distance(player)
	_calc_free_shoot_trajectory()


func _calc_distance_to_goal(player: SimPlayer, left_half: bool) -> void:
	if left_half:
		player.distance_to_goal = _calc_distance_to(player.pos, field.goal_right)
	player.distance_to_goal = _calc_distance_to(player.pos, field.goal_left)


func _calc_distance_to_own_goal(player: SimPlayer, left_half: bool) -> void:
	if left_half:
		player.distance_to_own_goal = _calc_distance_to(player.pos, field.goal_left)
	player.distance_to_own_goal = _calc_distance_to(player.pos, field.goal_right)


func _calc_player_to_ball_distance(player: SimPlayer) -> void:
	player.distance_to_ball = _calc_distance_to(player.pos, field.ball.pos)


func _calc_distance_to(from: Vector2, to: Vector2) -> float:
	return from.distance_squared_to(to)


func _calc_free_shoot_trajectory() -> void:
	field.ball.players_in_shoot_trajectory = 0

	if field.home_team.has_ball:
		goalkeeper = field.away_team.players[0]
		players = field.away_team.players
	else:
		goalkeeper = field.home_team.players[0]
		players = field.home_team.players

	if _left_is_active_goal():
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


func _left_is_active_goal() -> bool:
	if field.home_team.left_half and field.home_team.has_ball:
		return false
	if field.home_team.left_half and field.away_team.has_ball:
		return true
	if not field.home_team.left_half and field.home_team.has_ball:
		return true
	return false
