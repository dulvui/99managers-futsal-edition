# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Cup
extends Competition

enum Stage {
	NOT_READY,
	GROUP,
	KNOCKOUT,
}

const MAX_TEAMS: int = 32
const TEAMS_PASS_TO_KNOCKOUT: int = 2

@export var groups: Array[Group]
@export var knockout: Knockout
@export var stage: Stage


func _init(
	p_groups: Array[Group] = [],
	p_knockout: Knockout = Knockout.new(),
	p_stage: Stage = Stage.NOT_READY,
) -> void:
	super()
	groups = p_groups
	knockout = p_knockout
	stage = p_stage


func setup(p_teams: Array[TeamBasic]) -> void:
	knockout = Knockout.new()
	stage = Stage.GROUP
	# limit team size
	p_teams = p_teams.slice(0, MAX_TEAMS)

	var group_amount: int = 0

	# adjust teams size, to fit knockout format, sicne can only be 32,16,8,4,2
	if p_teams.size() >= 32:
		p_teams = p_teams.slice(0, 32)
		group_amount = 8
	elif p_teams.size() >= 16:
		p_teams = p_teams.slice(0, 16)
		group_amount = 4
	elif p_teams.size() >= 8:
		p_teams = p_teams.slice(0, 8)
		group_amount = 2
	else:
		# go directly to knockouts
		setup_knockout(p_teams)
		return

	# set up groups
	groups = []
	for i: int in group_amount:
		var group: Group = Group.new()
		groups.append(group)

	# split teams in groups, according to prestige
	for i: int in p_teams.size():
		groups[i % group_amount].add_team(p_teams[i])

	var match_util: MatchUtil = MatchUtil.new()
	match_util.add_matches_to_list(self, create_match_days())


func setup_knockout(
	teams: Array[TeamBasic] = [],
	legs_semi_finals: Knockout.Legs = Knockout.Legs.DOUBLE,
	legs_final: Knockout.Legs = Knockout.Legs.SINGLE,
) -> void:
	stage = Stage.KNOCKOUT
	# if coming from group stage
	if teams.size() == 0:
		# sort teams by table pos
		for group: Group in groups:
			group.sort_teams_by_table_pos()
		# add winning teams to knockout stage
		for group: Group in groups:
			teams.append_array(group.teams.slice(0, TEAMS_PASS_TO_KNOCKOUT))

	knockout.setup(teams, legs_semi_finals, legs_final)

	var match_util: MatchUtil = MatchUtil.new()
	match_util.add_matches_to_list(self, create_match_days())


func add_result(
	home_id: int,
	away_id: int,
	home_goals: int,
	away_goals: int,
	home_penalties_goals: int = 0,
	away_penalties_goals: int = 0,
) -> void:
	if stage == Stage.GROUP:
		var group: Group = _find_group_by_team_id(home_id)
		group.table.add_result(
			home_id, away_id, home_goals, away_goals, home_penalties_goals, away_penalties_goals
		)


func next_stage() -> void:

	if stage == Stage.GROUP:
		# check if group stage is over
		var over_counter: int = 0
		for group: Group in groups:
			if group.is_over():
				over_counter += 1
		if over_counter == groups.size():
			# group stage is over
			setup_knockout()
	elif knockout.prepare_next_round():
		var match_util: MatchUtil = MatchUtil.new()
		match_util.add_matches_to_list(self, create_match_days())


func create_match_days() -> MatchDays:
	if stage == Stage.GROUP:
		return _create_group_match_days()
	return _create_knockout_match_days()


func is_final() -> bool:
	if stage == Stage.GROUP:
		return false
	return knockout.is_final()


func is_started() -> bool:
	return stage != Stage.NOT_READY


func is_over() -> bool:
	if stage == Stage.GROUP:
		return false
	if knockout.final_ids.is_empty():
		return false
	return knockout.is_over()


func is_active() -> bool:
	return groups.size() > 0 or knockout.teams_a.size() > 0


func _create_group_match_days() -> MatchDays:
	var match_days: MatchDays = MatchDays.new()
	var group_match_day_list: Array[MatchDays] = []

	var match_util: MatchUtil = MatchUtil.new()

	for group: Group in groups:
		var group_match_days: MatchDays = match_util.create_combinations(self, group.teams)
		group_match_day_list.append(group_match_days)

	if group_match_day_list.size() == 0:
		return match_days

	# extract all match days from every group
	for day: int in group_match_day_list[0].days.size():
		var match_day: MatchDay = MatchDay.new()
		for group: int in group_match_day_list.size():
			match_day.matches.append_array(group_match_day_list[group].days[day].matches)
		match_days.days.append(match_day)

	return match_days


func _create_knockout_match_days() -> MatchDays:
	return knockout.create_match_days(self)


func _find_group_by_team_id(team_id: int) -> Group:
	for group: Group in groups:
		if group.get_team_by_id(team_id) != null:
			return group
	push_error("error while seerching team with id %s in group" % str(team_id))
	return null

