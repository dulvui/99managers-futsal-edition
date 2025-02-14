# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node


func initialize_matches(world: World = Global.world) -> void:
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
	_initialize_world_cup(world)


func create_combinations(competition: Competition, p_teams: Array[Team]) -> Array[Array]:
	var match_days: Array[Array]
	var teams: Array = p_teams.duplicate(true)

	var random_teams: Array[Team] = teams.duplicate(true)
	RngUtil.shuffle(random_teams)

	var last_team: Team = random_teams.pop_front()

	var home: bool = true

	for i: int in random_teams.size():
		var current_match_day: Array = []
		var match_one: Match
		if home:
			match_one = Match.new()
			match_one.setup(last_team, random_teams[0], competition.id, competition.name)
		else:
			match_one = Match.new()
			match_one.setup(random_teams[0], last_team, competition.id, competition.name)
		current_match_day.append(match_one)

		var copy: Array = random_teams.duplicate(true)
		copy.remove_at(0)

		for j in range(0, (teams.size() / 2) - 1):
			var home_index: int = j
			var away_index: int = -j - 1

			var match_two: Match
			if home:
				match_two = Match.new()
				match_two.setup(copy[home_index], copy[away_index], competition.id, competition.name)
			else:
				match_two = Match.new()
				match_two.setup(copy[away_index], copy[home_index], competition.id, competition.name)
			current_match_day.append(match_two)

		match_days.append(current_match_day)
		_shift_array(random_teams)
		home = not home

	# second round
	var temp_match_days: Array[Array] = []
	for match_dayz: Array[Match] in match_days:
		var current_match_dayz: Array = []
		for match_dayss: Match in match_dayz:
			var matchzz: Match = Match.new()
			matchzz.setup(match_dayss.away, match_dayss.home, competition.id, competition.name)
			current_match_dayz.append(matchzz)
		temp_match_days.append(current_match_dayz)

	for temp: Array in temp_match_days:
		match_days.append(temp)

	return match_days


func add_matches_to_calendar(
	competition: Competition,
	match_days: Array[Array],
	date: Dictionary = Global.world.calendar.date,
) -> void:
	var month: int = date.month
	var day: int = date.day

	# league machtes are always saturday
	var weekday: Enum.Weekdays = Enum.Weekdays.SATURDAY
	# cup matches wednesday
	if competition is Cup:
		weekday = Enum.Weekdays.WEDNESDAY
		# except finals, are sundays
		var cup: Cup = (competition as Cup)
		if cup.is_final():
			weekday = Enum.Weekdays.SUNDAY
		
	# start with given weekday of next week
	for i: int in range(8, 1, -1):
		if Global.world.calendar.day(month, i).weekday == weekday:
			day = i
			break

	for matches: Array[Match] in match_days:
		# check if next month
		if day >= Global.world.calendar.month(month).days.size():
			month += 1
			day = 0
			# start also new month with saturday
			for i: int in 7:
				if Global.world.calendar.day(month, i).weekday == weekday:
					day = i
					break

		# assign matches
		Global.world.calendar.day(month, day).add_matches(matches, competition.id)
		# restart from same weekday
		day += 7


func _initialize_club_league_matches(competition: Competition, teams: Array[Team]) -> void:
	var match_days: Array[Array] = create_combinations(competition, teams)
	add_matches_to_calendar(competition, match_days)


func _initialize_club_national_cup(p_nation: Nation) -> void:
	# setup cup
	p_nation.cup.name = p_nation.name + " " + tr("Cup")
	var all_teams_by_nation: Array[Team]
	for league: League in p_nation.leagues:
		all_teams_by_nation.append_array(league.teams)

	p_nation.cup.setup_knockout(all_teams_by_nation)

	# create matches for first round group a
	var matches: Array[Array] = p_nation.cup.get_matches()
	# add to calendar
	add_matches_to_calendar(p_nation.cup, matches)


func _initialize_club_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_clubs.name =  p_continent.name + " " + tr("Cup")
	var teams: Array[Team]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append_array(nation.get_continental_cup_qualified_teams())

	p_continent.cup_clubs.setup(teams)

	# create matches for first round group a
	# for now, only single leg
	var matches: Array[Array] = p_continent.cup_clubs.get_matches()
	add_matches_to_calendar(p_continent.cup_clubs, matches)


func _initialize_nations_continental_cup(p_continent: Continent) -> void:
	# setup cup
	p_continent.cup_nations.name =  p_continent.name + " " + tr("Nations cup")
	var teams: Array[Team]

	# get qualified teams from every nation
	for nation: Nation in p_continent.nations:
		teams.append(nation.team)

	p_continent.cup_nations.setup(teams)

	# create matches for first round group a
	# for now, only single leg
	var matches: Array[Array] = p_continent.cup_nations.get_matches()
	add_matches_to_calendar(p_continent.cup_nations, matches)


func _initialize_world_cup(world: World) -> void:
	# setup cup
	world.world_cup.name = tr("World cup")

	var teams: Array[Team]
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			teams.append(nation.team)
	
	# limit to 20 teams for now
	# TODO choose best teams
	if teams.size() > 16:
		teams = teams.slice(0, 16)
	
	world.world_cup.setup(teams)

	# create matches for first round group a
	var matches: Array[Array] = world.world_cup.get_matches()
	# add to calendar
	add_matches_to_calendar(world.world_cup, matches)


func _shift_array(array: Array) -> void:
	var temp: Team = array[0]
	for i: int in range(array.size() - 1):
		array[i] = array[i + 1]
	array[array.size() - 1] = temp
