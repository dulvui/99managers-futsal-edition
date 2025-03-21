# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name MatchUtil

var world: World


func _init(p_world: World) -> void:
	world = p_world


func initialize_matches() -> void:
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			if nation.is_competitive():
				# first, initialize leauge matches
				for league: League in nation.leagues:
					_initialize_club_league_matches(league, league.teams)

				# seconldy, initialize national cups
				_initialize_club_national_cup(nation)

		# third, initialize continental cups
		if continent.is_competitive():
			_initialize_club_continental_cup(continent)
			_initialize_nations_continental_cup(continent)

	# last, initialize world cup


func initialize_playoffs(league: League, add_to_calendar: bool = true) -> void:
	if league.playoff_teams == 0:
		return

	var p_teams: Array[Team] = []
	var sorted_table: Array[TableValues] = league.table().to_sorted_array()

	# remove directly promoted
	for i: int in league.direct_promotion_teams:
		sorted_table.pop_front()

	# remaining teams in order are playoff teams
	for i: int in league.playoff_teams:
		var value: TableValues = sorted_table.pop_front()
		if value == null:
			push_error("no team left for playoff")
		else:
			p_teams.append(league.get_team_by_id(value.team_id))

	league.playoffs.name = tr("Playoffs")
	league.playoffs.set_id()
	league.playoffs.setup_knockout(p_teams)

	if add_to_calendar:
		var match_days: MatchDays = league.playoffs.get_match_days()
		add_matches_to_calendar(league.playoffs, match_days)


func initialize_playouts(league: League, add_to_calendar: bool = true) -> void:
	if league.playout_teams == 0:
		return

	var p_teams: Array[Team] = []
	var sorted_table: Array[TableValues] = league.table().to_sorted_array()

	# remove directly relegated
	for i: int in league.direct_relegation_teams:
		sorted_table.pop_back()

	# remaining teams in order are playoff teams
	for i: int in league.playout_teams:
		var value: TableValues = sorted_table.pop_back()
		if value == null:
			push_error("no team left for playout")
		else:
			p_teams.append(league.get_team_by_id(value.team_id))

	league.playouts.name = tr("Playouts")
	league.playouts.set_id()
	league.playouts.setup_knockout(p_teams)

	if add_to_calendar:
		var match_days: MatchDays = league.playouts.get_match_days()
		add_matches_to_calendar(league.playouts, match_days)


func create_combinations(competition: Competition, p_teams: Array[Team]) -> MatchDays:
	var match_days: MatchDays = MatchDays.new()
	var teams: Array = p_teams.duplicate(true)

	var random_teams: Array[Team] = teams.duplicate(true)
	RngUtil.shuffle(random_teams)

	var last_team: Team = random_teams.pop_front()

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

		var copy: Array[Team] = random_teams.duplicate(true)
		copy.remove_at(0)

		for j: int in range(0, (teams.size() / 2) - 1):
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


func add_matches_to_calendar(
	competition: Competition,
	match_days: MatchDays,
	date: Dictionary = world.calendar.date,
) -> void:
	var month: int = date.month
	var day: int = date.day

	# league machtes are always saturday
	var weekday: Enum.Weekdays = Enum.Weekdays.SATURDAY
	# cup matches wednesday
	if competition is Cup:
		weekday = Enum.Weekdays.WEDNESDAY
		# except finals, are sundays
		var cup: Cup = competition as Cup
		if cup.is_final():
			weekday = Enum.Weekdays.SUNDAY

	# start with given weekday of next week
	for i: int in range(8, 1, -1):
		if world.calendar.day(month, i).weekday == weekday:
			day = i
			break

	for match_day: MatchDay in match_days.days:
		# check if next month
		if day >= world.calendar.month(month).days.size():
			month += 1
			day = 0
			# start also new month with saturday
			for i: int in 7:
				if world.calendar.day(month, i).weekday == weekday:
					day = i
					break

		# assign matches
		world.calendar.day(month, day).add_matches(match_day.matches)
		# restart from same weekday
		day += 7


func _initialize_club_league_matches(competition: Competition, teams: Array[Team]) -> void:
	var match_days: MatchDays = create_combinations(competition, teams)
	add_matches_to_calendar(competition, match_days)


func _initialize_club_national_cup(p_nation: Nation) -> void:
	# setup cup
	p_nation.cup.set_id()
	p_nation.cup.name = p_nation.name + " " + tr("Cup")
	var teams: Array[Team]
	for league: League in p_nation.leagues:
		teams.append_array(league.teams)

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)
	p_nation.cup.setup_knockout(teams)

	# create matches for first round group a
	var match_days: MatchDays = p_nation.cup.get_match_days()
	# add to calendar
	add_matches_to_calendar(p_nation.cup, match_days)


func _initialize_club_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_clubs.set_id()
	p_continent.cup_clubs.name = p_continent.name + " " + tr("Cup")
	var teams: Array[Team]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append_array(nation.get_continental_cup_qualified_teams())

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)
	p_continent.cup_clubs.setup(teams)

	# create matches for first round group a
	# for now, only single leg
	var match_days: MatchDays = p_continent.cup_clubs.get_match_days()
	add_matches_to_calendar(p_continent.cup_clubs, match_days)


func _initialize_nations_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_nations.set_id()
	p_continent.cup_nations.name = p_continent.name + " " + tr("Nations cup")
	var teams: Array[Team]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append(nation.team)

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)

	p_continent.cup_nations.setup(teams)

	# create matches for first round group a
	# for now, only single leg
	var match_days: MatchDays = p_continent.cup_nations.get_match_days()
	add_matches_to_calendar(p_continent.cup_nations, match_days)


func _initialize_world_cup() -> void:
	# setup cup
	world.world_cup.set_id()
	world.world_cup.name = tr("World cup")

	var teams: Array[Team]
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			teams.append(nation.team)

	# limit teams for now
	# TODO choose best teams
	if teams.size() > 32:
		teams = teams.slice(0, 32)

	world.world_cup.setup(teams)

	# create matches for first round group a
	var match_days: MatchDays = world.world_cup.get_match_days()
	# add to calendar
	add_matches_to_calendar(world.world_cup, match_days)


func _shift_array(array: Array) -> void:
	var temp: Team = array[0]
	for i: int in range(array.size() - 1):
		array[i] = array[i + 1]
	array[array.size() - 1] = temp

