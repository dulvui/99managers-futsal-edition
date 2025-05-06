# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name SimFieldCalculator


# can later made dynamic by team tactics long/short pass
# use squared for better performance
const PERFECT_PASS_DISTANCE_SQUARED: int = 1200
const PERFECT_SHOOT_DISTANCE_SQUARED: int = 1800
const BEST_SECTOR_UPDATE_FREQUENCY: int = Const.TICKS * 4

var field: SimField

var sectors: Array[SimFieldSector]
var best_pass_sector: SimFieldSector
var best_shoot_sector: SimFieldSector

# to not create new vars on every update
var post_bottom: Vector2
var post_top: Vector2

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
	
	best_pass_sector = sectors[0]
	best_shoot_sector = sectors[0]


func update(force: bool = false) -> void:
	ticks += 1
	if ticks == BEST_SECTOR_UPDATE_FREQUENCY or force:
		ticks = 0
		_find_best_pass_sector()
		_find_best_shoot_sector()


func _find_best_pass_sector() -> void:
	best_pass_sector.score = 0.0

	var team: SimTeam = field.active_team()

	for sector: SimFieldSector in sectors:
		sector.score = 0.0

		# check pass distance
		var distance: float = field.ball.pos.distance_squared_to(sector.position)
		sector.score += 100.0 / (abs(distance - PERFECT_SHOOT_DISTANCE_SQUARED) + 1)

		# check opposite players in pass trajectory
		if team.is_ball_safe(field.ball.pos, sector.position, 20):
			sector.score += 50.0

		if sector.score > best_pass_sector.score:
			best_pass_sector = sector


func _find_best_shoot_sector() -> void:
	best_shoot_sector.score = 0.0
	
	var goal: Vector2 = field.active_goal()
	var team: SimTeam = field.active_team()

	for sector: SimFieldSector in sectors:
		sector.score = 0.0

		# check shoot distance
		var distance: float = sector.position.distance_squared_to(goal)
		sector.score += 100.0 / (abs(distance - PERFECT_PASS_DISTANCE_SQUARED) + 1)

		# check opposite players in shoot trajectory
		if team.is_ball_safe(sector.position, goal, 40):
			sector.score += 60.0

		if sector.score > best_shoot_sector.score:
			best_shoot_sector = sector

