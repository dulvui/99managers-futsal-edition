# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name CSVUtil

const MAX_FILE_SIZE: int = 1_000_000 # 100MB

var file_util: FileUtil
var backup_util: BackupUtil

# headers
var headers: PackedStringArray

var active_line: PackedStringArray
var line_index: int
var column_index: int


func _init() -> void:
	file_util = FileUtil.new()
	backup_util = BackupUtil.new()

	headers = PackedStringArray()
	headers.append_array(Const.CSV_HEADERS)
	headers.append_array(Const.PLAYER_ATTRIBUTES_GOALKEEPER)
	headers.append_array(Const.PLAYER_ATTRIBUTES_MENTAL)
	headers.append_array(Const.PLAYER_ATTRIBUTES_PHYSICAL)
	headers.append_array(Const.PLAYER_ATTRIBUTES_TECHNICAL)


func csv_to_teams(csv: Array[PackedStringArray], world: World) -> void:
	line_index = 0

	# last values found in last line read
	# can be reused for next line, since lines most likely are grouped by team
	var nation: Nation = null
	var league: League = null
	var team: Team = null

	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		# team
		var nation_code: String = _get_string_or_default()
		var league_name: String = _get_string_or_default()
		var team_name: String = _get_string_or_default()
		var team_budget: int = _get_int_or_default()
		var stadium_name: String = _get_string_or_default()
		var stadium_capacity: int = _get_int_or_default()
		var stadium_year_built: int = _get_int_or_default()

		# nation
		if nation == null or nation.code != nation_code:
			nation = world.get_nation_by_code(nation_code)
		if nation == null:
			push_warning("no nation with code \"%s\" found in line %d" % [nation_code, line_index])
			continue

		# league
		if league == null or league.name != league_name:
			league = League.new()
			league.set_id()
			league.name = league_name
			league.nation_name = nation.name
			league.pyramid_level = nation.leagues.size() + 1
			nation.leagues.append(league)

		# team
		if team == null or team.name != team_name:
			team = Team.new()
			team.set_id()
			team.league_id = league.id
			team.name = team_name
			team.finances.balance[-1] = team_budget
			team.stadium.name = stadium_name
			team.stadium.capacity = stadium_capacity
			team.stadium.year_built = stadium_year_built

			league.add_team(team)


func players_to_csv(world: World) -> Array[PackedStringArray]:
	var lines: Array[PackedStringArray] = []

	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					for player: Player in team.players:
						lines.append(_player_to_line(player, nation, league, team))

	var csv: Array[PackedStringArray] = []
	csv.append(headers)
	csv.append_array(lines)

	return csv


func csv_to_players(csv: Array[PackedStringArray], world: World, first_time: bool = false) -> void:
	line_index = 0

	# remove header
	csv.pop_front()

	# last values found in last line read
	# can be reused for next line, since lines most likely are grouped by team
	var nation: Nation = null
	var league: League = null
	var team: Team = null

	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		# team
		var nation_code: String = _get_string_or_default()
		var league_name: String = _get_string_or_default()
		var team_name: String = _get_string_or_default()

		# nation
		if nation == null:
			nation = world.get_nation_by_code(nation_code)
		elif nation_code.length() > 0 and nation.code != nation_code:
			nation = world.get_nation_by_code(nation_code)

		if nation == null:
			push_error(
				"no nation with code \"%s\" found in line %d \n %s"
				 % [nation_code, line_index, active_line]
			)
			continue

		# league
		if league == null:
			league = world.get_league_by_name(league_name, nation)
		elif league_name.length() > 0 and league.name != league_name:
			league = world.get_league_by_name(league_name, nation)

		if league == null:
			push_warning("league not found in line %d" % line_index)
			continue

		# team
		if team == null:
			team = league.get_team_by_name(team_name)
		elif team_name.length() > 0 and team.name != team_name:
			team = league.get_team_by_name(team_name)

		if team == null:
			push_warning("team not found in line %d" % line_index)
			continue

		var player: Player = _line_to_player(
			league.id, league.name, team.id, team.name, first_time
		)

		if player != null:
			team.players.append(player)


func free_agents_to_csv(world: World) -> Array[PackedStringArray]:
	var lines: Array[PackedStringArray] = []

	for player: Player in world.free_agents.list:
		lines.append(_player_to_line(player))

	var csv: Array[PackedStringArray] = []
	csv.append_array(lines)

	return csv


func csv_to_free_agents(csv: Array[PackedStringArray], world: World) -> void:
	line_index = 0

	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		var player: Player = _line_to_player()
		if player != null:
			world.free_agents.list.append(player)


func csv_to_match_days(csv: Array[PackedStringArray]) -> Array[MatchDays]:
	line_index = 0

	var list: Array[MatchDays] = []

	# active days
	var match_days: MatchDays = null
	var match_day: MatchDay = null
	var current_match_days_index: int = 0

	# for quick access to find first legs
	var quick_access: Dictionary[int, Match] = {}

	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		var match_days_index: int =_get_int_or_default()
		var day: int =_get_int_or_default()
		var month: int =_get_int_or_default()
		var year: int =_get_int_or_default()
		var id: int = _get_int_or_default()
		var home_id: int = _get_int_or_default()
		var home_name: String = _get_string_or_default()
		var home_league_id: int = _get_int_or_default()
		var away_id: int = _get_int_or_default()
		var away_name: String = _get_string_or_default()
		var away_league_id: int = _get_int_or_default()
		var over: int = _get_bool_or_default()
		var home_goals: int = _get_int_or_default()
		var away_goals: int = _get_int_or_default()
		var home_penalties_goals: int = _get_int_or_default()
		var away_penalties_goals: int = _get_int_or_default()
		var competition_id: int = _get_int_or_default()
		var competition_name: String = _get_string_or_default()
		var no_draw: bool = _get_bool_or_default()
		var first_leg_id: int = _get_int_or_default()

		# check active match days
		if match_days == null or match_days_index != current_match_days_index:
			current_match_days_index = match_days_index
			match_days = MatchDays.new()
			list.append(match_days)

		# check active match day
		if match_day == null or day != match_day.day or month != match_day.month:
			match_day = MatchDay.new()
			match_day.day = day
			match_day.month = month
			match_day.year = year
			match_days.days.append(match_day)

		var matchz: Match = Match.new()
		matchz.id = id

		matchz.home = TeamBasic.new()
		matchz.home.id = home_id
		matchz.home.name = home_name
		matchz.home.league_id = home_league_id

		matchz.away = TeamBasic.new()
		matchz.away.id = away_id
		matchz.away.name = away_name
		matchz.away.league_id = away_league_id

		matchz.over = over
		matchz.home_goals = home_goals
		matchz.away_goals = away_goals
		matchz.home_penalties_goals = home_penalties_goals
		matchz.away_penalties_goals = away_penalties_goals
		matchz.competition_id = competition_id
		matchz.competition_name = competition_name
		matchz.no_draw = no_draw

		# find first leg
		if first_leg_id > -1:
			if quick_access.has(first_leg_id):
				matchz.first_leg = quick_access[first_leg_id]
			else:
				push_error("first leg with id %d not found" % first_leg_id)
		else:
			quick_access[id] = matchz

		match_day.matches.append(matchz)

	return list


func match_days_to_csv(match_days_list: Array[MatchDays]) -> Array[PackedStringArray]:
	var csv: Array[PackedStringArray] = []

	var index: int = -1
	for match_days: MatchDays in match_days_list:
		index += 1
		for match_day: MatchDay in match_days.days:
			for matchz: Match in match_day.matches:
				var line: PackedStringArray = PackedStringArray()

				line.append(str(index))
				line.append(str(match_day.day))
				line.append(str(match_day.month))
				line.append(str(match_day.year))
				line.append(str(matchz.id))
				line.append(str(matchz.home.id))
				line.append(matchz.home.name)
				line.append(str(matchz.home.league_id))
				line.append(str(matchz.away.id))
				line.append(matchz.away.name)
				line.append(str(matchz.away.league_id))
				line.append(str(int(matchz.over)))
				line.append(str(matchz.home_goals))
				line.append(str(matchz.away_goals))
				line.append(str(matchz.home_penalties_goals))
				line.append(str(matchz.away_penalties_goals))
				line.append(str(matchz.competition_id))
				line.append(matchz.competition_name)
				line.append(str(int(matchz.no_draw)))
				if matchz.first_leg == null:
					line.append("-1")
				else:
					line.append(str(matchz.first_leg.id))

				csv.append(line)

	return csv


func calendar_to_csv(calendar: Calendar) -> Array[PackedStringArray]:
	var csv: Array[PackedStringArray] = []

	# first line is calendar.date
	var date_line: PackedStringArray = PackedStringArray()
	date_line.append(str(calendar.date.day))
	date_line.append(str(calendar.date.month))
	date_line.append(str(calendar.date.year))
	csv.append(date_line)

	# iterate over single days
	for	month: Month in calendar.months:
		for day: Day in month.days:
			var line: PackedStringArray = PackedStringArray()

			line.append(str(day.day))
			line.append(str(day.month))
			line.append(str(day.year))
			line.append(str(day.weekday))
			line.append(str(int(day.market)))

			csv.append(line)

	return csv


func csv_to_calendar(csv: Array[PackedStringArray]) -> Calendar:
	var calendar: Calendar = Calendar.new()

	# first line is calendar.date
	var first_line: PackedStringArray = csv.pop_front()
	_set_active_line(first_line)
	calendar.date.day = _get_int_or_default()
	calendar.date.month = _get_int_or_default()
	calendar.date.year = _get_int_or_default()

	# save active month, to append new month when month changes
	var active_month: int = 1
	calendar.months.append(Month.new())

	# iterate over single days
	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		var day: Day = Day.new()
		day.day = _get_int_or_default()
		day.month = _get_int_or_default()
		day.year = _get_int_or_default()
		day.weekday = _get_int_or_default() as Enum.Weekdays
		day.market = _get_bool_or_default()

		if active_month != day.month:
			active_month = day.month
			calendar.months.append(Month.new())

		calendar.months[-1].days.append(day)

	return calendar


func inbox_to_csv(inbox: Inbox) -> Array[PackedStringArray]:
	var csv: Array[PackedStringArray] = []

	for email: EmailMessage in inbox.list:
		var line: PackedStringArray = PackedStringArray()

		line.append(str(email.id))
		line.append(str(email.foreign_id))
		line.append(str(email.type))
		line.append(email.subject)
		line.append(email.text)
		line.append(email.sender)
		line.append(email.receiver)
		line.append(FormatUtil.day(email.date))
		line.append(str(int(email.read)))
		line.append(str(int(email.starred)))

		csv.append(line)

	return csv


func csv_to_inbox(csv: Array[PackedStringArray]) -> Inbox:
	var inbox: Inbox = Inbox.new()

	for line: PackedStringArray in csv:

		if line.size() < 3:
			continue

		_set_active_line(line)

		var email: EmailMessage = EmailMessage.new()

		email.id = _get_int_or_default()
		email.foreign_id = _get_int_or_default()
		email.type = _get_int_or_default() as EmailMessage.Type
		email.subject = _get_string_or_default()
		email.text = _get_string_or_default()
		email.sender = _get_string_or_default()
		email.receiver = _get_string_or_default()
		var date: String = _get_string_or_default()
		email.date = FormatUtil.day_from_string(date)
		email.read = _get_bool_or_default()
		email.starred = _get_bool_or_default()

		inbox.list.append(email)

	return inbox


func offer_list_to_csv(_offer_list: OfferList) -> Array[PackedStringArray]:
	var csv: Array[PackedStringArray] = []

	# for offer: Offer in offer_list.buy_clause:
	# 	var line: PackedStringArray = PackedStringArray()
	#
	# 	csv.append_array(line)

	return csv


func csv_to_offer_list(_csv: Array[PackedStringArray]) -> OfferList:
	var offer_list: OfferList = OfferList.new()

	return offer_list


#
# helper methods
#

# use result, since on next call array will be reused for performance
func res_to_line(resource: Resource, p_headers: PackedStringArray) -> PackedStringArray:
	var line: PackedStringArray = PackedStringArray()

	for header: String in p_headers:
		var value: Variant = resource.get(header)
		if value == null:
			line.append("")
		else:
			line.append(str(value))

	return line


func validate_csv_file(file_path: String) -> bool:
	# open file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var error: Error = file.get_error()
	if error != OK:
		push_error("error while opening csv file at %s" % file_path)
		Global.generation_errors.append(Enum.GenerationError.ERR_READ_FILE)
		return false


	var file_size: int = file.get_length()
	if file_size > MAX_FILE_SIZE:
		push_error("error csv file too big. size %d bytes" % file_size)
		Global.generation_errors.append(Enum.GenerationError.ERR_FILE_TOO_BIG)
		return false

	# read as text to see if utf8
	# var text: String = file.get_as_text()
	file.get_as_text()
	error = file.get_error()
	if error != OK:
		push_error("error while reading file as text. error %d" % error)
		Global.generation_errors.append(Enum.GenerationError.ERR_FILE_NOT_UTF8)
		return false

	# validate header row CONTINENT, NATION, CITY, TEAM
	# check size
	var header_line: PackedStringArray = file.get_csv_line()
	if header_line.size() != headers.size():
		push_error("error csv file has wrong header amount")
		Global.generation_errors.append(Enum.GenerationError.ERR_CSV_HEADER_SIZE)
		return false

	# check order and format
	for i: int in header_line.size():
		var header: String = header_line[i]
		header = header.to_lower()
		header = header.strip_edges()
		if header != headers[i].to_lower():
			push_error(
				"error csv header wrong format. expecetd %s but found %s" % [headers[i], header]
			)
			Global.generation_errors.append(Enum.GenerationError.ERR_CSV_HEADER_FORMAT)
			return false

	# text server for validation
	var text_server: TextServer = TextServerManager.get_primary_interface()
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()

		error = file.get_error()
		if error == Error.ERR_FILE_EOF:
			break

		# check for errors
		if error != Error.OK:
			push_error("error while reading lines from csv with code %d" % error)
			Global.generation_errors.append(Enum.GenerationError.ERR_READ_FILE)
			return false

		# check columns size same as headers
		if line.size() > headers.size() or line.size() == 0:
			push_error("wrong column size in row %d" % error)
			Global.generation_errors.append(Enum.GenerationError.ERR_COLUMN_SIZE)
			return false

		# check if string is valid utf8 character
		for string: String in line:
			if not _is_valid_string(string, text_server):
				push_error("not valid string found: %s" % string)
				Global.generation_errors.append(Enum.GenerationError.ERR_CSV_INVALID_FORMAT)
				return false
	return true


func save_csv(path: String, csv: Array[PackedStringArray], append: bool = false) -> String:
	var file: FileAccess

	file = file_util.write(path, append)

	if file == null:
		push_error("error while opening file: file is null")
		return ""

	# go to end of file to append
	if append:
		file.seek_end()

	# save to file
	for line: PackedStringArray in csv:
		file.store_csv_line(line)

	file.close()

	# get
	path = file.get_path()
	backup_util.create(path)
	return path


func read_csv(path: String) -> Array[PackedStringArray]:
	var file: FileAccess = file_util.read(path)

	if file == null:
		push_error("error while reading csv file %s" % path)
		return []

	var csv: Array[PackedStringArray] = []
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() > 0:
			csv.append(line)

	file.close()
	return csv


func get_error() -> Error:
	return file_util.err


func _player_to_line(
	player: Player, nation: Nation = null, league: League = null, team: Team = null
) -> PackedStringArray:
	var player_line: PackedStringArray = PackedStringArray()

	# check if free agent
	if nation != null:
		# team
		player_line.append(nation.code)
		player_line.append(league.name)
		player_line.append(team.name)
		player_line.append(str(team.finances.balance[-1]))
		player_line.append(team.stadium.name)
		player_line.append(str(team.stadium.capacity))
		player_line.append(str(team.stadium.year_built))

	# player
	player_line.append(player.name)
	player_line.append(player.surname)
	player_line.append(str(player.value))
	player_line.append(FormatUtil.day(player.birth_date))
	player_line.append(player.nation)
	player_line.append(str(player.nr))
	player_line.append(str(player.foot_left))
	player_line.append(str(player.foot_right))
	player_line.append(_get_position_type_text(player.position.main))
	var alt_positions: Array[StringName] = []
	for type: Position.Type in player.position.alternatives:
		alt_positions.append(_get_position_type_text(type))
	player_line.append(_array_to_csv_list(alt_positions))
	player_line.append(str(player.injury_factor))
	# add double quotes so that sheet editors see it as strings and not numbers
	player_line.append("\"%s\"" % player.eyecolor)
	player_line.append("\"%s\"" % player.haircolor)
	player_line.append("\"%s\"" % player.skintone)

	# attributes
	player_line.append_array(
		res_to_line(player.attributes.goalkeeper, Const.PLAYER_ATTRIBUTES_GOALKEEPER)
	)
	player_line.append_array(
		res_to_line(player.attributes.mental, Const.PLAYER_ATTRIBUTES_MENTAL)
	)
	player_line.append_array(
		res_to_line(player.attributes.physical, Const.PLAYER_ATTRIBUTES_PHYSICAL)
	)
	player_line.append_array(
		res_to_line(player.attributes.technical, Const.PLAYER_ATTRIBUTES_TECHNICAL)
	)

	#
	# now internal data, not coming from user at setup
	#
	player_line.append(str(player.id))
	player_line.append(str(player.prestige))
	player_line.append(str(player.morality))
	player_line.append(str(player.form))
	player_line.append(str(player.stamina))

	# contract
	player_line.append(str(player.contract.income))
	player_line.append(FormatUtil.day(player.contract.start_date))
	player_line.append(FormatUtil.day(player.contract.end_date))
	player_line.append(str(player.contract.buy_clause))
	player_line.append(str(int(player.contract.is_on_loan)))

	# statistics
	player_line.append(str(player.statistics.games_played))
	player_line.append(str(player.statistics.goals))
	player_line.append(str(player.statistics.assists))
	player_line.append(str(player.statistics.yellow_cards))
	player_line.append(str(player.statistics.red_cards))
	player_line.append(str(player.statistics.average_vote))

	return player_line


func _line_to_player(
	league_id: int = 0,
	league_name: String = "",
	team_id: int = 0,
	team_name: String = "",
	first_time: bool = false,
) -> Player:

	# check if free agent
	if team_id > 0:
		# skip stadium section
		column_index += 4

	# player
	var name: String = _get_string_or_default()
	var surname: String = _get_string_or_default()
	var value: String = _get_string_or_default()
	var birth_date: String = _get_string_or_default()
	var nationality: String = _get_string_or_default()
	var nr: int = _get_int_or_default()
	var foot_left: int = _get_int_or_default()
	var foot_right: int = _get_int_or_default()
	var position: String = _get_string_or_default()
	var alt_positions: String = _get_string_or_default()
	var injury_factor: int = _get_int_or_default()
	var eyecolor: String = _get_string_or_default()
	var haircolor: String = _get_string_or_default()
	var skintone: String = _get_string_or_default()

	# player
	if name.is_empty() or surname.is_empty():
		return null

	var player: Player = Player.new()
	if first_time:
		player.set_id()
	player.name = name
	player.surname = surname
	player.value = int(value)
	player.team = team_name
	player.birth_date = FormatUtil.day_from_string(birth_date)
	player.nation = nationality
	player.nr = int(nr)
	player.foot_left = int(foot_left)
	player.foot_right = int(foot_right)
	player.injury_factor = int(injury_factor)
	# remove quotes
	player.eyecolor = eyecolor.replace("\"", "")
	player.haircolor = haircolor.replace("\"", "")
	player.skintone = skintone.replace("\"", "")

	# positions
	player.position.main = Enum.get_position_type_from_string(position)
	alt_positions = alt_positions.replace("\"", "")
	var alt_positions_array: PackedStringArray = alt_positions.split(",")
	for alt_position_string: String in alt_positions_array:
		alt_position_string = alt_position_string.strip_edges()
		player.position.alternatives.append(
			Enum.get_position_type_from_string(alt_position_string)
		)

	# next values are attributes
	# attributes get set by iterating over attribute name arrays/headers
	# attributes
	for attribute: String in Const.PLAYER_ATTRIBUTES_GOALKEEPER:
		player.attributes.goalkeeper.set(attribute, _get_attribute_or_default())
	for attribute: String in Const.PLAYER_ATTRIBUTES_MENTAL:
		player.attributes.mental.set(attribute, _get_attribute_or_default())
	for attribute: String in Const.PLAYER_ATTRIBUTES_PHYSICAL:
		player.attributes.physical.set(attribute, _get_attribute_or_default())
	for attribute: String in Const.PLAYER_ATTRIBUTES_TECHNICAL:
		player.attributes.technical.set(attribute, _get_attribute_or_default())

	player.team_id = team_id
	player.league_id = league_id
	player.league = league_name

	if first_time:
		return player

	#
	# now internal data, not coming from user at setup
	#
	player.id = _get_int_or_default()
	player.prestige = _get_float_or_default()
	player.morality = _get_int_or_default() as Enum.Morality
	player.form = _get_int_or_default() as Enum.Form
	player.stamina = _get_float_or_default()

	# contract
	player.contract.income = _get_int_or_default()
	player.contract.start_date = FormatUtil.day_from_string(_get_string_or_default())
	player.contract.end_date = FormatUtil.day_from_string(_get_string_or_default())
	player.contract.buy_clause = _get_int_or_default()
	player.contract.is_on_loan = _get_int_or_default()

	# statistics
	player.statistics.games_played = _get_int_or_default()
	player.statistics.goals = _get_int_or_default()
	player.statistics.assists = _get_int_or_default()
	player.statistics.yellow_cards = _get_int_or_default()
	player.statistics.red_cards = _get_int_or_default()
	player.statistics.average_vote = _get_float_or_default()

	return player


func _array_to_csv_list(array: Array[StringName]) -> String:
	if array == null or array.size() == 0:
		return ""
	var string: StringName = ", ".join(array)
	return "\"%s\"" % string


func _is_valid_string(string: String, text_server: TextServer) -> bool:
	if string.is_empty():
		return true
	if string.is_valid_float():
		return true

	# check if valid unicode
	for i: int in string.length():
		var unicode_char: int = string.unicode_at(i)
		# space
		if unicode_char == 32:
			return true
		# comma
		if unicode_char == 44:
			return true
		# hyphen
		if unicode_char == 45:
			return true
		# colon
		if unicode_char == 58:
			return true
		# slash
		if unicode_char == 47:
			return true
		# all type of quotes
		# '
		if unicode_char == 39:
			return true
		# "
		if unicode_char == 34:
			return true
		# ‘
		if unicode_char == 8216:
			return true
		# ’
		if unicode_char == 8217:
			return true
		# ‛
		if unicode_char == 8219:
			return true
		# “
		if unicode_char == 8220:
			return true
		# ”
		if unicode_char == 8221:
			return true
		# „
		if unicode_char == 8222:
			return true
		# ‟
		if unicode_char == 8223:
			return true

		var valid_letter: bool = text_server.is_valid_letter(unicode_char)
		var valid_number: bool = string[i].is_valid_float()

		if not valid_letter and not valid_number:
			print("csv line not vaild: %s" % string)
			print("not allowed unicode sign: %s code: %d" % [char(unicode_char), unicode_char])
			return false

	return true


func _set_active_line(line: PackedStringArray) -> void:
	active_line = line
	column_index = -1
	line_index += 1


func _get_string_or_default() -> String:
	column_index += 1
	if column_index >= active_line.size():
		return ""
	return active_line[column_index]


func _get_int_or_default() -> int:
	column_index += 1
	if column_index >= active_line.size():
		return 0
	return int(active_line[column_index])


func _get_float_or_default() -> float:
	column_index += 1
	if column_index >= active_line.size():
		return 0.0
	return float(active_line[column_index])


# saved in csv as 0, 1
func _get_bool_or_default() -> bool:
	column_index += 1
	if column_index >= active_line.size():
		return false
	return bool(int(active_line[column_index]))


func _get_attribute_or_default() -> int:
	var value: int = _get_int_or_default()
	if value < 1:
		return 0
	if value > 20:
		return 0
	return value


# declare func from enum.gd here to prevent thrad call deffered error
func _get_position_type_text(p_type: Position.Type) -> String:
	match p_type:
		Position.Type.G:
			return "G"
		Position.Type.DL:
			return "DL"
		Position.Type.DC:
			return "DC"
		Position.Type.DR:
			return "DR"
		Position.Type.C:
			return "C"
		Position.Type.WL:
			return "WL"
		Position.Type.WR:
			return "WR"
		Position.Type.PL:
			return "PL"
		Position.Type.PC:
			return "PC"
		Position.Type.PR:
			return "PR"
	return ""

