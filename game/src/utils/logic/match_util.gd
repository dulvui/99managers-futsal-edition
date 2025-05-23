# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchUtil

var rng_util: RngUtil


func _init(p_rng_util: RngUtil = RngUtil.new()) -> void:
	rng_util = p_rng_util


func initialize_matches(world: World) -> void:
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			if nation.is_competitive():
				# first, initialize leauge matches
				for league: League in nation.leagues:
					_initialize_club_league_matches(league, league.get_teams_basic())

				# seconldy, initialize national cups
				_initialize_club_national_cup(nation)

		# third, initialize continental cups
		if continent.is_competitive():
			# TODO: fix overlay with national cups
			# _initialize_club_continental_cup(continent)
			_initialize_nations_continental_cup(continent)

	# last, initialize world cup
	# _initialize_world_cup(world)


func initialize_playoffs(league: League) -> void:
	if league.playoff_teams == 0:
		return

	var teams: Array[TeamBasic] = []
	var sorted_table: Array[TableValue] = league.table.to_sorted_array()

	# remove directly promoted
	for i: int in league.direct_promotion_teams:
		sorted_table.pop_front()

	# remaining teams in order are playoff teams
	for i: int in league.playoff_teams:
		var value: TableValue = sorted_table.pop_front()
		if value == null:
			push_error("no team left for playoff")
		else:
			teams.append(value.team)

	league.playoffs.name = tr("Playoffs")
	league.playoffs.set_id()
	league.playoffs.setup_knockout(teams)


func initialize_playouts(league: League) -> void:
	if league.playout_teams == 0:
		return

	var teams: Array[TeamBasic] = []
	var sorted_table: Array[TableValue] = league.table.to_sorted_array()

	# remove directly relegated
	for i: int in league.direct_relegation_teams:
		sorted_table.pop_back()

	# remaining teams in order are playoff teams
	for i: int in league.playout_teams:
		var value: TableValue = sorted_table.pop_back()
		if value == null:
			push_error("no team left for playout")
		else:
			teams.append(value.team)

	league.playouts.name = tr("Playouts")
	league.playouts.set_id()
	league.playouts.setup_knockout(teams)


func create_combinations(
	competition: Competition,
	p_teams: Array[TeamBasic],
) -> MatchDays:
	var match_days: MatchDays = MatchDays.new()
	var teams: Array = p_teams.duplicate(true)

	var random_teams: Array[TeamBasic] = teams.duplicate(true)
	rng_util.shuffle(random_teams)

	var last_team: TeamBasic = random_teams.pop_front()

	var home: bool = true

	for i: int in random_teams.size():
		var current_match_day: MatchDay = MatchDay.new()
		var match_one: Match
		if home:
			match_one = Match.new()
			match_one.setup(last_team, random_teams[0], competition.id, competition.name)
		else:
			match_one = Match.new()
			match_one.setup(random_teams[0], last_team, competition.id, competition.name)
		current_match_day.append(match_one)

		var copy: Array[TeamBasic] = random_teams.duplicate(true)
		copy.remove_at(0)

		for j: int in range(0, (teams.size() / 2.0) - 1):
			var home_index: int = j
			var away_index: int = -j - 1

			var match_two: Match
			if home:
				match_two = Match.new()
				match_two.setup(
					copy[home_index], copy[away_index], competition.id, competition.name
				)
			else:
				match_two = Match.new()
				match_two.setup(
					copy[away_index], copy[home_index], competition.id, competition.name
				)
			current_match_day.append(match_two)

		match_days.append(current_match_day)
		_shift_array(random_teams)
		home = not home

	# second round, by simply switching home/away
	var temp_match_days: MatchDays = MatchDays.new()
	for match_day: MatchDay in match_days.days:
		var current_match_dayz: MatchDay = MatchDay.new()
		for match_first: Match in match_day.matches:
			var match_second: Match = match_first.inverted()
			current_match_dayz.append(match_second)
		temp_match_days.append(current_match_dayz)

	for temp_match_day: MatchDay in temp_match_days.days:
		match_days.append(temp_match_day)

	return match_days


func add_matches_to_list(
	competition: Competition,
	match_days: MatchDays,
	date: Dictionary = Global.calendar.date,
) -> void:
	var month: int = date.month
	var day: int = date.day
	var year: int = date.year

	# league matches are always Saturday
	var weekday: Enum.Weekdays = Enum.Weekdays.SATURDAY
	# cup matches Wednesday
	if competition is Cup:
		weekday = Enum.Weekdays.WEDNESDAY
		# except finals, are Sundays
		var cup: Cup = competition as Cup
		if cup.is_final():
			weekday = Enum.Weekdays.SUNDAY

	# start with given weekday of next week
	for i: int in range(8, 1, -1):
		if Global.calendar.day(month, i).weekday == weekday:
			day = i
			break

	for match_day: MatchDay in match_days.days:
		# check if next month
		if day >= Global.calendar.month(month).days.size():
			month += 1
			day = 1
			# start also new month with Saturday
			for i: int in 7:
				if Global.calendar.day(month, i).weekday == weekday:
					day = i
					break

		# set day/month on match day
		match_day.day = day
		match_day.month = month

		# assign matches
		Global.match_list.add_matches(match_day.matches, day, month, year)
		# restart from same weekday
		day += 7


func _initialize_club_league_matches(competition: Competition, teams: Array[TeamBasic]) -> void:
	var match_days: MatchDays = create_combinations(competition, teams)
	add_matches_to_list(competition, match_days)


func _initialize_club_national_cup(p_nation: Nation) -> void:
	# setup cup
	p_nation.cup.set_id()
	p_nation.cup.name = p_nation.name + " " + tr("Cup")
	var teams: Array[TeamBasic]
	for league: League in p_nation.leagues:
		teams.append_array(league.get_teams_basic())

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)
	p_nation.cup.setup_knockout(teams)


func _initialize_club_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_clubs.set_id()
	p_continent.cup_clubs.name = p_continent.name + " " + tr("Cup")
	var teams: Array[TeamBasic]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append_array(nation.get_continental_cup_qualified_teams())

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)

	p_continent.cup_clubs.setup(teams)


func _initialize_nations_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_nations.set_id()
	p_continent.cup_nations.name = p_continent.name + " " + tr("Nations cup")
	var teams: Array[TeamBasic]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append(nation.team.to_basic())

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)

	p_continent.cup_nations.setup(teams)


func _initialize_world_cup(world: World) -> void:
	# setup cup
	world.world_cup.set_id()
	world.world_cup.name = tr("World cup")

	var teams: Array[TeamBasic]
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			teams.append(nation.team.to_basic())

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)

	world.world_cup.setup(teams)


func _shift_array(array: Array) -> void:
	var temp: TeamBasic = array[0]
	for i: int in range(array.size() - 1):
		array[i] = array[i + 1]
	array[array.size() - 1] = temp

