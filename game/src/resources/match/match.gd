# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Match
extends JSONResource

@export var id: int
@export var home: TeamBasic
@export var away: TeamBasic
@export var over: bool
@export var home_goals: int
@export var away_goals: int
@export var home_penalties_goals: int
@export var away_penalties_goals: int
@export var competition_id: int
@export var competition_name: String
@export var no_draw: bool
# for easier two legs knockout
@export var first_leg: Match


func _init(
	p_id: int = -1,
	p_home: TeamBasic = TeamBasic.new(),
	p_away: TeamBasic = TeamBasic.new(),
	p_over: bool = false,
	p_competition_id: int = -1,
	p_competition_name: String = "",
	p_home_goals: int = -1,
	p_away_goals: int = -1,
	p_home_penalties_goals: int = 0,
	p_away_penalties_goals: int = 0,
	p_no_draw: bool = false,
	p_first_leg: Match = null,
) -> void:
	id = p_id
	home = p_home
	away = p_away
	over = p_over
	competition_id = p_competition_id
	competition_name = p_competition_name
	home_goals = p_home_goals
	away_goals = p_away_goals
	home_penalties_goals = p_home_penalties_goals
	away_penalties_goals = p_away_penalties_goals
	no_draw = p_no_draw
	first_leg = p_first_leg


func setup(
	p_home: TeamBasic,
	p_away: TeamBasic,
	p_competition_id: int,
	p_competition_name: String,
	p_first_leg: Match = null
) -> void:
	competition_id = p_competition_id
	competition_name = p_competition_name
	first_leg = p_first_leg

	id = IdUtil.next_id(IdUtil.Types.MATCH)

	# make sure teams are basic
	if p_home is Team:
		home = (p_home as Team).get_basic()
	else:
		home = p_home
	if p_away is Team:
		away = (p_away as Team).get_basic()
	else:
		away = p_away



func set_result(
	p_home_goals: int,
	p_away_goals: int,
	p_home_penalties_goals: int = 0,
	p_away_penalties_goals: int = 0,
	world: World = Global.world
) -> void:
	home_goals = p_home_goals
	away_goals = p_away_goals
	home_penalties_goals = p_home_penalties_goals
	away_penalties_goals = p_away_penalties_goals

	over = true

	# save in competition table/knockout
	# needs to be done here, so it can be used from match and dashboard
	if world:
		var competition: Competition = world.get_competition_by_id(competition_id)

		if competition is League:
			var league: League = competition as League
			league.table.add_result(home.id, away.id, home_goals, away_goals)
	
		elif competition is Cup:
			var cup: Cup = competition as Cup
			cup.add_result(
				home.id, away.id, home_goals, away_goals, home_penalties_goals, away_penalties_goals
			)
		else:
			push_error("error competition with no valid type. name: %s id: %d" % [competition_name, competition_id])


func get_result(include_first_leg: bool = false) -> String:
	if home_goals == -1 and away_goals == -1:
		return ""

	var home_total_goals: int = home_goals
	var away_total_goals: int = away_goals

	if include_first_leg and first_leg != null:
		home_total_goals += first_leg.away_goals
		away_total_goals += first_leg.home_goals

	# with penalties
	if home_penalties_goals * away_penalties_goals > 0:
		return "%d(%d):(%d)%d" % [home_total_goals, home_penalties_goals, away_penalties_goals, away_total_goals]
	return "%d:%d" % [home_total_goals, away_total_goals]


func get_winner() -> TeamBasic:
	var home_total_goals: int = home_goals + home_penalties_goals
	var away_total_goals: int = away_goals + away_penalties_goals

	if first_leg != null:
		# first leg will never have penalty shootout
		home_total_goals += first_leg.away_goals
		away_total_goals += first_leg.home_goals

	if home_total_goals == away_total_goals:
		return null
	elif home_total_goals > away_total_goals:
		return home
	else:
		return away


func get_looser() -> TeamBasic:
	var home_total_goals: int = home_goals + home_penalties_goals
	var away_total_goals: int = away_goals + away_penalties_goals

	if first_leg != null:
		# first leg will never have penalty shootout
		home_total_goals += first_leg.away_goals
		away_total_goals += first_leg.home_goals

	if home_total_goals == away_total_goals:
		return null
	elif home_total_goals < away_total_goals:
		return home
	else:
		return away


# checks if match is played by active team
func has_active_team() -> bool:
	if Global.team == null:
		return false
	return Global.team.id == home.id or Global.team.id == away.id


func inverted(is_second_leg: bool = false) -> Match:
	var inverted_match: Match = Match.new()
	inverted_match.setup(away, home, competition_id, competition_name)

	if is_second_leg:
		inverted_match.first_leg = self

	return inverted_match
