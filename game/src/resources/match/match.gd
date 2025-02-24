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
	p_home: TeamBasic = null,
	p_away: TeamBasic = null,
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
	p_home_team: TeamBasic,
	p_away_team: TeamBasic,
	p_competition_id: int,
	p_competition_name: String,
	p_first_leg: Match = null
) -> void:
	home = p_home_team
	away = p_away_team
	competition_id = p_competition_id
	competition_name = p_competition_name
	first_leg = p_first_leg

	# make sure teams are basic
	if home is Team:
		home = (home as Team).get_basic()
	if away is Team:
		away = (away as Team).get_basic()

	id = IdUtil.next_id(IdUtil.Types.MATCH)


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
			var league: League = (competition as League)
			league.table().add_result(home.id, away.id, home_goals, away_goals)
		elif competition is Cup:
			var cup: Cup = (competition as Cup)
			cup.add_result(
				home.id, away.id, home_goals, away_goals, home_penalties_goals, away_penalties_goals
			)
		else:
			print("error competition with no valid type; id: " + str(competition_id))


func get_result() -> String:
	if home_goals == -1 and away_goals == -1:
		return ""
	if home_penalties_goals == 0 and away_penalties_goals == 0:
		return "%d : %d" % [home_goals, away_goals]
	
	# with penalties
	return "%d(%d) : (%d)%d" % [home_goals, home_penalties_goals, away_penalties_goals, away_goals]


func inverted(is_second_leg: bool = false) -> Match:
	var inverted_match: Match = Match.new()
	inverted_match.setup(away, home, competition_id, competition_name)
	
	if is_second_leg:
		inverted_match.first_leg = self
	
	return inverted_match


