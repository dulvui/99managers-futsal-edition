
# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimFieldCalculator


# can later made dynamic by team tactics long/short pass
const PERFECT_PASS_DISTANCE: int = 30
const BEST_SECTOR_UPDATE_FREQUENCY: int = Const.TICKS * 4

var field: SimField

var sectors: Array[SimFieldSector]
var best_sector: SimFieldSector


# to not create new vars on every update
var post_bottom: Vector2
var post_top: Vector2
var players: Array[SimPlayer]


var ticks: int


func _init(p_field: SimField) -> void:
	field = p_field

	var sector_size: int = int(field.size.x / 6)

	# initialize field sectors for best position calculations
	sectors = []
	for x: int in range(sector_size, field.size.x, sector_size):
		for y: int in range(sector_size, field.size.y, sector_size):
			var sector: SimFieldSector = SimFieldSector.new()
			sector.setup(x,  y)
			sectors.append(sector)
	
	best_sector = sectors[0]


func update(force: bool = false) -> void:
	ticks += 1
	if ticks == BEST_SECTOR_UPDATE_FREQUENCY or force:
		ticks = 0
		_calc_best_supporting_sector()


func _calc_best_supporting_sector() -> void:
	best_sector.score = 0

	for sector: SimFieldSector in sectors:
		sector.score = 0
		
		# check pass distance
		var distance_to_ball: float = _calc_distance_to(field.ball.pos, sector.position)
		sector.score += 100.0 / (abs(distance_to_ball - PERFECT_PASS_DISTANCE) + 1)
		
		# check opposite players in pass trajectory
		var players_in_pass_trajectory: int = _calc_players_in_pass_trajectory(sector.position)
		sector.score += 100.0 / (players_in_pass_trajectory + 1)

		# check opposite players in shoot trajectory
		var players_in_shoot_trajectory: int = _calc_players_in_shoot_trajectory(sector.position)
		sector.score += 100.0 / (players_in_shoot_trajectory + 1)

		if sector.score > best_sector.score:
			best_sector = sector


func _calc_distance_to_goal(position: Vector2, left_half: bool) -> void:
	if left_half:
		return _calc_distance_to(position, field.goals.right)
	return _calc_distance_to(position, field.goals.left)


func _calc_distance_to(from: Vector2, to: Vector2) -> float:
	return from.distance_squared_to(to)


func _calc_players_in_shoot_trajectory(position: Vector2) -> int:
	var players_in_trajectory: int = 0
	
	if field.left_team.has_ball:
		post_top = field.goals.post_top_right
		post_bottom = field.goals.post_bottom_right
	else:
		post_top = field.goals.post_top_left
		post_bottom = field.goals.post_bottom_left

	if field.left_team.has_ball:
		players = field.right_team.players
	else:
		players = field.left_team.players
	
	for player: SimPlayer in players:
		if Geometry2D.point_is_inside_triangle(player.pos, position, post_top, post_bottom):
			players_in_trajectory += 1
	
	return players_in_trajectory


func _calc_players_in_pass_trajectory(position: Vector2) -> int:
	var players_in_trajectory: int = 0
	
	if field.left_team.has_ball:
		players = field.right_team.players
	else:
		players = field.left_team.players
	
	for player: SimPlayer in players:
		if Geometry2D.segment_intersects_circle(
			field.ball.pos, position, player.pos, player.collision_radius
		) > -1:
			players_in_trajectory += 1
	
	return players_in_trajectory

