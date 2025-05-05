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
			sector.setup(x, y)
			sectors.append(sector)

	best_sector = sectors[0]


func update(force: bool = false) -> void:
	ticks += 1
	if ticks == BEST_SECTOR_UPDATE_FREQUENCY or force:
		ticks = 0
		_best_supporting_sector()


func _best_supporting_sector() -> void:
	best_sector.score = 0

	for sector: SimFieldSector in sectors:
		sector.score = 0

		# check pass distance
		var distance_to_ball: float = _distance_to(field.ball.pos, sector.position)
		sector.score += 100.0 / (abs(distance_to_ball - PERFECT_PASS_DISTANCE) + 1)

		# check opposite players in pass trajectory
		if _is_safe_pass_trajectory(sector.position):
			sector.score += 50.0

		# check opposite players in shoot trajectory
		if _is_safe_shoot_trajectory(sector.position):
			sector.score += 100.0

		if sector.score > best_sector.score:
			best_sector = sector


func _distance_to_goal(position: Vector2, left_half: bool) -> void:
	if left_half:
		return _distance_to(position, field.goals.right)
	return _distance_to(position, field.goals.left)


func _distance_to(from: Vector2, to: Vector2) -> float:
	return from.distance_squared_to(to)


func _is_safe_shoot_trajectory(position: Vector2) -> bool:
	if field.left_team.has_ball:
		return field.right_team.is_ball_safe_from_opponents(position, 40)
	return field.left_team.is_ball_safe_from_opponents(position, 40)


func _is_safe_pass_trajectory(position: Vector2) -> bool:
	if field.left_team.has_ball:
		return field.right_team.is_ball_safe_from_opponents(position, 20)
	return field.left_team.is_ball_safe_from_opponents(position, 20)

