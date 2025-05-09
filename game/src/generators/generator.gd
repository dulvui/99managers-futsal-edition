# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Generator

# defines noise added to attribute factors
const NOISE: int = 3

# person colors
const SKINTONE: Array[String] = [
	"FFE0BD",
	"F6D3BD",
	"E8BEAC",
	"D4AA78",
	"E0AC69",
	"C68642",
	"A16E4B",
	"8D5524",
	"3B2219",
]
const HAIR_COLORS: Array[String] = [
	"040200",
	"1C1C1C",
	"23120B",
	"3D2314",
	"5A3825",
	"CC9966",
	"F6D02F",
	"F2A900",
	"C65D3B",
	# Color.TRANSPARENT, # bald
]
const EYE_COLORS: Array[String] = [
	"040200",
	"000000",
]

var leagues_data: Dictionary = {}

# for birthdays range
var start_date: Dictionary
var year: int
var player_max_timestamp: int
var player_min_timestamp: int
var staff_max_timestamp: int
var staff_min_timestamp: int
# for contracts
var contract_max_year: int
var contract_min_year: int

var names: GeneratorNames
var all_nations: Array[Nation]

var player_names: Enum.PlayerNames
var rng_util: RngUtil


func _init(
	generation_seed: String,
	p_player_names: Enum.PlayerNames
) -> void:
	rng_util = RngUtil.new(generation_seed, p_player_names)
	player_names = p_player_names


func initialize_world(world: World, world_file_path: String = Const.WORLD_CSV_PATH) -> bool:
	var csv_util: CSVUtil = CSVUtil.new()
	# reset warnings/errors
	Global.generation_warnings = []
	Global.generation_errors = []
	Main.call_deferred("update_loading_progress", 0.0)

	# set start date/year
	start_date = Global.start_date
	year = start_date.year

	# save once instead of fetching every time, many many times
	all_nations = world.get_all_nations()

	# initialize calendar
	Global.calendar = Calendar.new()
	Global.calendar.initialize()

	# other csv resources
	Global.transfer_list = TransferList.new()
	Global.inbox = Inbox.new()
	Global.match_list = MatchList.new()

	# validate custom file first, if custom file is used
	var custom_file: bool = world_file_path != Const.WORLD_CSV_PATH
	if custom_file:
		var is_valid_csv: bool = csv_util.validate_csv_file(world_file_path)
		if not is_valid_csv:
			push_error("csv file not valid %s" % world_file_path)
			return false

	# read csv and create teams, without players
	var csv: Array[PackedStringArray] = csv_util.read_csv(world_file_path)
	# remove header
	csv.pop_front()
	csv_util.csv_to_teams(csv, world)

	# validate world
	var validator: GeneratorValidator = GeneratorValidator.new()
	var is_valid_world: bool = validator.validate_world(world)
	if not is_valid_world:
		push_error("world not valid %s" % world_file_path)
		return false

	Main.call_deferred("update_loading_progress", 0.1)

	# initialize league promotion/relegation amounts
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			# calculate league size, relegations, promotions and playoffs
			var leagues_amount: int = nation.leagues.size()

			# promotion/relegation and playoff/playout team amount
			for i: int in leagues_amount:
				var league: League = nation.leagues[i]

				# all leagues have playoff teams
				if league.teams.size() >= 20:
					league.playoff_teams = 16
				elif league.teams.size() >= 12:
					league.playoff_teams = 8
				else:
					league.playoff_teams = 4

				# relegation teams for upper leagues, so last league will not have relegations
				# and direct promotion teams is exact relegation amount from upper league
				if i > 0:
					var upper_league: League = nation.leagues[i - 1]
					if upper_league.teams.size() > 16:
						upper_league.direct_relegation_teams = 2
						upper_league.playout_teams = 2
					elif upper_league.teams.size() > 8:
						upper_league.direct_relegation_teams = 1
						upper_league.playout_teams = 2
					elif upper_league.teams.size() >= 4:
						upper_league.direct_relegation_teams = 1
						# no playoffs, since upper league has no playouts
						# alternative: direct_promotion_teams - 1, if direct_promotion_teams > 0
						league.playoff_teams = 0
						upper_league.playout_teams = 0
					league.direct_promotion_teams = upper_league.direct_relegation_teams

	Main.call_deferred("update_loading_progress", 0.2)

	# history
	var history: GeneratorHistory = GeneratorHistory.new(rng_util)
	# first generate clubs history with promotions, delegations, cup wins
	history.generate_club_history(world)

	Main.call_deferred("update_loading_progress", 0.3)

	# now also read players from, after history generation
	csv_util.csv_to_players(csv, world, true)

	Main.call_deferred("update_loading_progress", 0.5)


	# initialize min/max date ranges for birthdays, contracts ecc
	_init_date_ranges()

	# load player names
	names = GeneratorNames.new(world, player_names, rng_util)

	# initialize players and other custom team properties after club history
	# because histroy generation swaps team ids and names
	var success_players: bool = _generate_players(world)

	Main.call_deferred("update_loading_progress", 0.7)

	# go back if players are not valid
	if not success_players:
		print("error reading players from file %d errors occurred." % Global.generation_errors.size())
		return false

	# then generate player histroy with transfers and statistics
	history.generate_player_history(world)

	Main.call_deferred("update_loading_progress", 0.8)

	# initialize national teams
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			# national team
			nation.team.set_id()
			nation.team.name = nation.name
			# add nations best players
			nation.team.players = world.get_best_players_by_nationality(nation)
			nation.team.staff = _create_staff(nation.team.get_prestige(), nation, 1)
			nation.team.formation = nation.team.staff.manager.formation
			# TODO replace with actual national colors
			_set_random_shirt_colors(nation.team)

	Main.call_deferred("update_loading_progress", 0.9)

	# create matches for current season
	var match_util: MatchUtil = MatchUtil.new()
	match_util.initialize_matches(world)

	Main.call_deferred("update_loading_progress", 1.0)

	return true


func _init_date_ranges() -> void:
	# player age from 15 to 45
	var player_max_date: Dictionary = start_date.duplicate()
	player_max_date.month = 1
	player_max_date.day = 1
	player_max_date.year -= 15
	player_min_timestamp = Time.get_unix_time_from_datetime_dict(player_max_date)
	player_max_date.year -= 30
	player_max_timestamp = Time.get_unix_time_from_datetime_dict(player_max_date)

	# staff age from 25 to 70
	var staff_max_date: Dictionary = start_date.duplicate()
	staff_max_date.month = 1
	staff_max_date.day = 1
	staff_max_date.year -= 25

	staff_min_timestamp = Time.get_unix_time_from_datetime_dict(staff_max_date)
	staff_max_date.year -= 50
	staff_max_timestamp = Time.get_unix_time_from_datetime_dict(staff_max_date)

	# contract date ranges
	contract_max_year = start_date.year + Const.CONTRACT_MAX_DURATION
	contract_min_year = start_date.year - Const.CONTRACT_MAX_DURATION + 1


func _generate_players(world: World) -> bool:
	# generate missing players
	var players_count: int = 0
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					_generate_missing_properties(nation, league, team)
					players_count += team.players.size()

	Main.call_deferred("update_loading_progress", 0.6)

	# generate free agents, around 10% of total players
	var free_agents_amount: int = int(players_count * Const.FREE_AGENTS_PERCENTAGE)
	# make sure minimum is respected
	free_agents_amount = min(free_agents_amount, Const.FREE_AGENTS_AMOUNT_MIN)
	for i: int in free_agents_amount:
		var player: Player = Player.new()
		player.set_id()
		_initialize_player(player)
		world.free_agents.append(player)

	return true


func _assign_players_to_team(
	league: League, team: Team, nation: Nation, prestige: int
) -> Team:

	# team not enough players
	if team.players.size() < Const.TEAM_PLAYERS_AMOUNT_MIN:
		# lineup
		for amount: int in team.formation.goalkeeper:
			var position_type: Position.Type = Position.Type.G

			var random_nation: Nation = _get_random_nationality(
				nation, prestige, league.pyramid_level
			)
			var player: Player = Player.new()
			_initialize_player(
				player, league, team, random_nation, prestige, position_type
			)
			team.players.append(player)
		for amount: int in team.formation.defense:
			var position_type: Position.Type = _get_random_defense_position_type()

			var random_nation: Nation = _get_random_nationality(
				nation, prestige, league.pyramid_level
			)
			var player: Player = Player.new()
			_initialize_player(
				player, league, team, random_nation, prestige, position_type
			)
			team.players.append(player)
		for amount: int in team.formation.center:
			var position_type: Position.Type = _get_random_center_position_type()

			var random_nation: Nation = _get_random_nationality(
				nation, prestige, league.pyramid_level
			)
			var player: Player = Player.new()
			_initialize_player(
				player, league, team, random_nation, prestige, position_type
			)
			team.players.append(player)
		for amount: int in team.formation.attack:
			var position_type: Position.Type = _get_random_attack_position_type()

			var random_nation: Nation = _get_random_nationality(
				nation, prestige, league.pyramid_level
			)
			var player: Player = Player.new()
			_initialize_player(
				player, league, team, random_nation, prestige, position_type
			)
			team.players.append(player)

		# bench and rest
		for position_type: int in Position.Type.values().size() - 1: # -1, last is undefined
			var amount: int = rng_util.randi_range(1, 2)
			if position_type == Position.Type.G:
				amount = 3

			for i: int in amount:
				var random_nation: Nation = _get_random_nationality(
					nation, prestige, league.pyramid_level
				)
				var player: Player = Player.new()
				_initialize_player(
					player, league, team, random_nation, prestige, position_type
				)
				team.players.append(player)

	return team


func _get_random_defense_position_type() -> Position.Type:
	return rng_util.pick_random(Position.defense_types)


func _get_random_center_position_type() -> Position.Type:
	return rng_util.pick_random(Position.center_types)


func _get_random_attack_position_type() -> Position.Type:
	return rng_util.pick_random(Position.attack_types)


func _get_random_position_type() -> Position.Type:
	var all_positions: Array[Position.Type] = []

	all_positions.append(Position.Type.G)
	all_positions.append_array(Position.defense_types)
	all_positions.append_array(Position.center_types)
	all_positions.append_array(Position.attack_types)

	return rng_util.pick_random(all_positions)


func _set_goalkeeper_attributes(attributes: Goalkeeper, age: int, prestige: int, position: Position) -> void:
	var age_factor: int = _get_age_factor(age)
	var factor: int = _in_bounds_random(prestige + age_factor)

	# goalkeepers have max potential of 20
	var max_potential: int = _in_bounds_random(factor)

	# non-goalkeepers have max potential of 10,
	# since they could play as goalkeeper in a 4 + 1 field player situation
	if position.main != Position.Type.G:
		max_potential /= 2

	if attributes.reflexes == 0:
		attributes.reflexes = _in_bounds_random(factor, max_potential)
	if attributes.positioning == 0:
		attributes.positioning = _in_bounds_random(factor, max_potential)
	if attributes.save_feet == 0:
		attributes.save_feet = _in_bounds_random(factor, max_potential)
	if attributes.save_hands == 0:
		attributes.save_hands = _in_bounds_random(factor, max_potential)
	if attributes.diving == 0:
		attributes.diving = _in_bounds_random(factor, max_potential)


func _set_physical_attributes(attributes: Physical, age: int, prestige: int, position: Position) -> void:
	var age_factor: int = _get_physical_age_factor(age)

	var pace_factor: int = _in_bounds_random(prestige + age_factor)
	var physical_factor: int = _in_bounds_random(prestige + age_factor)

	# non goalkeepers have max potential
	var max_potential: int = _in_bounds_random(prestige)

	# goalkeepers have max potential of 10,
	# since they could play as goalkeeper in a 4 + 1 field player situation
	if position.main == Position.Type.G:
		max_potential /= 2

	if attributes.pace == 0:
		attributes.pace = _in_bounds_random(pace_factor, max_potential)
	if attributes.acceleration == 0:
		attributes.acceleration = _in_bounds_random(pace_factor, max_potential)
	if attributes.resistance == 0:
		attributes.resistance = _in_bounds_random(physical_factor, max_potential)
	if attributes.strength == 0:
		attributes.strength = _in_bounds_random(physical_factor, max_potential)
	if attributes.agility == 0:
		attributes.agility = _in_bounds_random(physical_factor, max_potential)
	if attributes.jump == 0:
		attributes.jump = _in_bounds_random(physical_factor, max_potential)


func _set_technical_attributes(attributes: Technical, age: int, prestige: int, position: Position) -> void:
	var age_factor: int = _get_age_factor(age)

	# use also pos i calculation
	var pass_factor: int = _in_bounds_random(prestige + age_factor)
	var shoot_factor: int = _in_bounds_random(prestige + age_factor)
	var technique_factor: int = _in_bounds_random(prestige + age_factor)
	var defense_factor: int = _in_bounds_random(prestige + age_factor)

	# non goalkeepers have max potential
	var max_potential: int = _in_bounds_random(prestige)

	# goalkeepers have max potential of 10,
	# since they could play as goalkeeper in a 4 + 1 field player situation
	if position.main == Position.Type.G:
		max_potential /= 2

	if attributes.crossing == 0:
		attributes.crossing = _in_bounds_random(pass_factor, max_potential)
	if attributes.passing == 0:
		attributes.passing = _in_bounds_random(pass_factor, max_potential)
	if attributes.long_passing == 0:
		attributes.long_passing = _in_bounds_random(pass_factor, max_potential)
	if attributes.tackling == 0:
		attributes.tackling = _in_bounds_random(defense_factor, max_potential)
	if attributes.heading == 0:
		attributes.heading = _in_bounds_random(shoot_factor, max_potential)
	if attributes.interception == 0:
		attributes.interception = _in_bounds_random(defense_factor, max_potential)
	if attributes.shooting == 0:
		attributes.shooting = _in_bounds_random(shoot_factor, max_potential)
	if attributes.long_shooting == 0:
		attributes.long_shooting = _in_bounds_random(shoot_factor, max_potential)
	if attributes.free_kick == 0:
		attributes.free_kick = _in_bounds_random(shoot_factor, max_potential)
	if attributes.penalty == 0:
		attributes.penalty = _in_bounds_random(technique_factor, max_potential)
	if attributes.finishing == 0:
		attributes.finishing = _in_bounds_random(shoot_factor, max_potential)
	if attributes.dribbling == 0:
		attributes.dribbling = _in_bounds_random(shoot_factor, max_potential)
	if attributes.blocking == 0:
		attributes.blocking = _in_bounds_random(shoot_factor, max_potential)


func _set_mental_attributes(attribtues: Mental, age: int, prestige: int) -> void:
	var age_factor: int = _get_age_factor(age)

	var offensive_factor: int = _in_bounds_random(prestige + age_factor)
	var defensive_factor: int = _in_bounds_random(prestige + age_factor)

	var max_potential: int = _in_bounds_random(prestige)

	if attribtues.aggression == 0:
		attribtues.aggression = _in_bounds_random(defensive_factor, max_potential)
	if attribtues.anticipation == 0:
		attribtues.anticipation = _in_bounds_random(defensive_factor, max_potential)
	if attribtues.marking == 0:
		attribtues.marking = _in_bounds_random(defensive_factor, max_potential)

	if attribtues.decisions == 0:
		attribtues.decisions = _in_bounds_random(offensive_factor, max_potential)
	if attribtues.concentration == 0:
		attribtues.concentration = _in_bounds_random(offensive_factor, max_potential)
	if attribtues.vision == 0:
		attribtues.vision = _in_bounds_random(offensive_factor, max_potential)
	if attribtues.workrate == 0:
		attribtues.workrate = _in_bounds_random(offensive_factor, max_potential)
	if attribtues.offensive_movement == 0:
		attribtues.offensive_movement = _in_bounds_random(offensive_factor, max_potential)


func _get_physical_age_factor(age: int) -> int:
	# for 24 +- _noise < age factor is negative
	if age < 24 + _noise():
		return rng_util.randi_range(-5, 3)
	return rng_util.randi_range(1, 7)


func _get_age_factor(age: int) -> int:
	# for 34 +- _noise < age < 18 +- _noise age factor is negative
	if age > 34 + _noise() or age < 18 + _noise():
		return rng_util.randi_range(-5, 1)
	# else age factor is positive
	return rng_util.randi_range(-1, 5)


func _get_value(age: int, prestige: int, position: Position) -> int:
	var age_factor: int = max(min(abs(age - 30), 20), 1)
	var pos_factor: int = 0
	if position.main == Position.Type.G:
		pos_factor = 5
	elif (
		position.main == Position.Type.DC
		|| position.main == Position.Type.DR
		|| position.main == Position.Type.DL
	):
		pos_factor = 10
	elif position.main == Position.Type.WL || position.main == Position.Type.WR:
		pos_factor = 15
	else:
		pos_factor = 20

	var total_factor: int = age_factor + pos_factor + prestige

	return rng_util.randi_range(maxi(total_factor - 20, 0), total_factor) * 1000


func _get_random_foot_left() -> int:
	var random: int = rng_util.randi_range(1, 100)
	# 35% have good left foot
	if random < 35:
		return rng_util.randi_range(10, 20)
	return rng_util.randi_range(1, 10)


func _get_random_foot_right() -> int:
	var random: int = rng_util.randi_range(1, 100)
	# 65% have good right foot
	if random < 65:
		return rng_util.randi_range(10, 20)
	return rng_util.randi_range(1, 10)


func _get_random_form() -> Enum.Form:
	var random: int = rng_util.randi_range(1, 100)
	if random < 5:
		return Enum.Form.INJURED
	if random < 15:
		return Enum.Form.RECOVER
	if random < 60:
		return Enum.Form.GOOD
	return Enum.Form.BEST


func _get_random_morality() -> Enum.Morality:
	var random: int = rng_util.randi_range(1, 100)
	if random < 5:
		return Enum.Morality.WORST
	if random < 15:
		return Enum.Morality.BAD
	if random < 50:
		return Enum.Morality.NEUTRAL
	if random < 60:
		return Enum.Morality.GOOD
	return Enum.Morality.BEST


func _create_staff(
	team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Staff:
	var staff: Staff = Staff.new()
	staff.manager = _create_manager(team_prestige, team_nation, pyramid_level)
	staff.president = _create_president(team_prestige, team_nation, pyramid_level)
	staff.scout = _create_scout(team_prestige, team_nation, pyramid_level)
	return staff


func _create_manager(
	team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Manager:
	var manager: Manager = Manager.new()
	manager.set_id()
	manager.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(team_nation, team_prestige, pyramid_level)
	_set_random_person_values(manager, nation)
	manager.nation = nation.name

	# create random preferred tactics
	var variation: Formation.Variations = rng_util.pick_random(Formation.Variations.values())
	manager.formation.set_variation(variation)
	manager.formation.tactic_offense.intensity = rng_util.randf()
	manager.formation.tactic_offense.tactic = rng_util.pick_random(TacticOffense.Tactics.values())
	manager.formation.tactic_defense.marking = rng_util.pick_random(TacticDefense.Marking.values())
	manager.formation.tactic_defense.pressing = rng_util.pick_random(TacticDefense.Pressing.values())

	return manager


func _create_president(
	team_prestige: int, team_nation: Nation, pyramid_level: int
) -> President:
	var president: President = President.new()
	president.set_id()
	president.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(team_nation, team_prestige, pyramid_level)
	_set_random_person_values(president, nation)
	president.nation = nation.name
	return president


func _create_scout(
	team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Scout:
	var scout: Scout = Scout.new()
	scout.set_id()
	var nation: Nation = _get_random_nationality(team_nation, team_prestige, pyramid_level)
	_set_random_person_values(scout, nation)
	scout.prestige = _in_bounds_random(team_prestige)
	scout.nation = nation.name
	return scout


func _initialize_player(
	player: Player,
	p_league: League = null,
	p_team: Team = null,
	nation: Nation = _get_random_nationality(),
	p_team_prestige: int = -1,
	p_position: Position.Type = _get_random_position_type(),
) -> void:
	player.set_id()

	_set_random_person_values(player, nation)

	if player.position.main == Position.Type.UNDEFINED:
		player.position.main = p_position

	if player.position.alternatives.is_empty():
		_random_alt_positions(player)

	var prestige: int = _get_player_prestige(p_team_prestige)

	var birth_date_year: int = player.birth_date.year

	player.value = _get_value(year - birth_date_year, prestige, player.position)
	if p_team:
		player.team = p_team.name
		player.team_id = p_team.id
	if p_league:
		player.league = p_league.name
		player.league_id = p_league.id
	player.nation = nation.name
	if player.foot_left == 0:
		player.foot_left = _get_random_foot_right()
	if player.foot_right == 0:
		player.foot_right = _get_random_foot_right()
	player.morality = _get_random_morality()
	player.form = _get_random_form()
	player.prestige = prestige
	if player.injury_factor == 0:
		player.injury_factor = rng_util.randi_range(1, 20)
	# if player is loyal, he doesnt want to leave the club,
	# otherwise he leaves esaily, also on its own
	if player.loyality == 0:
		player.loyality = rng_util.randi_range(1, 20)

	var age: int = year - birth_date_year
	_set_goalkeeper_attributes(player.attributes.goalkeeper, age, prestige, player.position)
	_set_mental_attributes(player.attributes.mental, age, prestige)
	_set_technical_attributes(player.attributes.technical, age, prestige, player.position)
	_set_physical_attributes(player.attributes.physical, age, prestige, player.position)


func _random_alt_positions(player: Player) -> void:
	# TODO should goalkeeper have alt positions?
	# TODO adapt to make alteratinos more cohereant
	# to attributes, like defender should have good defense stats
	var alt_positions: Array[Variant] = Position.Type.values()
	# remove Position.Type.UNDEFINED
	alt_positions.pop_back()
	rng_util.shuffle(alt_positions)

	for i: int in rng_util.randi_range(0, alt_positions.size() - 1):
		var alt_type: Position.Type = alt_positions[i]
		player.position.alternatives.append(alt_type)


func _get_player_prestige(team_prestige: int) -> int:
	# player prestige is teams prestige +- 5
	return _in_bounds_random(team_prestige)


func _get_team_prestige(pyramid_level: int) -> int:
	var minp: int = Const.MAX_PRESTIGE - pyramid_level * ((rng_util.randi() % 5) + 1)
	var maxp: int = Const.MAX_PRESTIGE - ((pyramid_level - 1) * 3)
	return _in_bounds(rng_util.randi_range(minp, maxp))


func _get_random_nationality(
	nation: Nation = null, prestige: int = -1, pyramid_level: int = -1
) -> Nation:
	if nation == null:
		return rng_util.pick_random(all_nations)

	# (100 - prestige)% given nation, prestige% random nation
	# with prestige, lower division teams have less players from other nations
	if rng_util.randi_range(1, 100) > 100 - (prestige * 2.0 / pyramid_level):
		return rng_util.pick_random(all_nations)
	return nation


func _get_salary_budget(players: Array[Player], staff: Staff) -> int:
	var salary_budget: int = 0

	# sum up all players salary
	for player: Player in players:
		salary_budget += player.contract.income

	# sum up staff salary
	salary_budget += staff.get_salary()

	return salary_budget


func _generate_missing_properties(
	nation: Nation,
	league: League,
	team: Team,
) -> void:
	var temp_team_prestige: int = _get_team_prestige(league.pyramid_level)
	_set_random_shirt_colors(team)

	# stadium
	if team.stadium.name.is_empty():
		team.stadium.name = team.name + " " + tr("Stadium")
	if team.stadium.capacity == 0:
		# range from 200 to 20.000
		team.stadium.capacity = rng_util.randi_range(
			temp_team_prestige * 200, temp_team_prestige * 1_000
		)
	var	year_built: int = team.stadium.year_built
	if year_built == 0:
		year_built = rng_util.randi_range(year - 70, year - 1)
		team.stadium.year_built = year_built
	if team.stadium.year_renewed < year_built:
		var stadium_age: int = year - year_built
		# only if stadium is at least 5 years old
		if stadium_age >= 5:
			team.stadium.year_renewed = year_built + rng_util.randi_range(0, year - stadium_age)
		else:
			team.stadium.year_renewed = year_built

	team.staff = _create_staff(team.get_prestige(), nation, league.pyramid_level)

	# assign manager preffered formation to team
	team.formation = team.staff.manager.formation

	# calc budget, after players/stuff have been created
	# so budget will alwyas be bigger as minimum needed
	team.finances.expenses[-1] = _get_salary_budget(team.players, team.staff)
	# calulate balance
	team.finances.balance[-1] = team.finances.expenses[-1]
	# add random bonus depending on team prestige
	team.finances.balance[-1] += rng_util.randi_range(
		temp_team_prestige * 10_000, temp_team_prestige * 100_000
	)

	# assign missing properties to existing players coming from csv
	for player: Player in team.players:
		_initialize_player(player, league, team, nation, temp_team_prestige)

	# generate missing players
	# after formation has been choosen, to assign correct players positions
	_assign_players_to_team(league, team, nation, temp_team_prestige)

	team.assign_shirt_numbers()


func _set_random_person_values(person: Person, nation: Nation) -> void:
	if person.name.is_empty():
		person.name = names.get_random_name(nation)
	if person.surname.is_empty():
		person.surname = names.get_random_surnname(nation)

	# random birthday
	if person.birth_date.is_empty():
		if person.role == Person.Role.PLAYER:
			var unix_time: int = rng_util.randi_range(player_min_timestamp, player_max_timestamp)
			person.birth_date = Time.get_date_dict_from_unix_time(unix_time)
		else:
			var unix_time: int = rng_util.randi_range(staff_min_timestamp, staff_max_timestamp)
			person.birth_date = Time.get_date_dict_from_unix_time(unix_time)

	# colors
	if person.skintone.is_empty():
		person.skintone = rng_util.pick_random(SKINTONE)
	if person.haircolor.is_empty():
		person.haircolor = rng_util.pick_random(HAIR_COLORS)
	if person.eyecolor.is_empty():
		person.eyecolor = rng_util.pick_random(EYE_COLORS)

	# contract
	if person.role == Person.Role.PLAYER:
		_set_random_player_contract(person as Player)
	else:
		_set_random_staff_contract(person as StaffMember)


func _set_random_player_contract(player: Player) -> void:
	# contract
	var contract: PlayerContract = PlayerContract.new()
	var age: int = player.get_age(start_date)

	contract.income = (player.prestige + age) * 1000
	contract.buy_clause = 0
	# TODO: find way to have loan players on start
	contract.is_on_loan = false

	# calculate start and end date
	var duration: int = rng_util.randi_range(2, Const.CONTRACT_MAX_DURATION)

	# less contract duration for young or old players
	if age < 20 or age > 32:
		duration = rng_util.randi_range(1, int(Const.CONTRACT_MAX_DURATION / 2.0))

	var start: int = 0
	if duration > 1:
		# duration - 1 to have at least 1 year of remaining contract
		start = rng_util.randi_range(1, duration - 1)

	var month: int = 0

	# start during summer market probability 80%
	if rng_util.randi_range(1, 100) <= 80:
		month = rng_util.randi_range(
			Calendar.MARKET_SUMMER_START_MONTH, Calendar.MARKET_SUMMER_END_MONTH
		)
	else:
		# during winter period
		month = rng_util.randi_range(
			Calendar.MARKET_WINTER_START_MONTH, Calendar.MARKET_WINTER_END_MONTH
		)

	# get max day respecting month days and leap years
	var month_max_days: int = _get_month_max_days(month)
	var day: int = rng_util.randi_range(1, month_max_days)

	contract.start_date = {
		"month": month,
		"day": day,
		"year": start_date.year - start,
	}

	contract.end_date = {
		"day": Calendar.SEASON_START_DAY,
		"month": Calendar.SEASON_END_MONTH,
		"year": start_date.year + duration,
	}

	player.contract = contract


func _set_random_staff_contract(member: StaffMember) -> void:
	# contract
	var contract: Contract = Contract.new()
	var age: int = member.get_age(start_date)

	contract.income = (member.prestige + age) * 1000

	# calculate start and end date
	var duration: int = rng_util.randi_range(2, Const.CONTRACT_MAX_DURATION)

	var start: int = 0
	if duration > 1:
		# duration - 1 to have at least 1 year of remaining contract
		start = rng_util.randi_range(1, duration - 1)

	var month: int = Calendar.SEASON_START_MONTH
	var day: int = Calendar.SEASON_START_DAY

	contract.start_date = {
		"month": month,
		"day": day,
		"year": start_date.year - start,
	}

	contract.end_date = {
		"day": Calendar.SEASON_START_DAY,
		"month": Calendar.SEASON_END_MONTH,
		"year": start_date.year + duration,
	}

	member.contract = contract


func _set_random_shirt_colors(team: Team) -> void:
	team.colors = []
	var main_color: Color = Color(
		rng_util.randf_range(0, 1), rng_util.randf_range(0, 1), rng_util.randf_range(0, 1)
	)
	# set transparency to 0
	main_color.a = 1.0

	team.colors.append(main_color.to_html(true))
	team.colors.append(main_color.inverted().to_html(true))
	team.colors.append(
		(
			Color(
				rng_util.randf_range(0, 1),
				rng_util.randf_range(0, 1),
				rng_util.randf_range(0, 1)
			)
			. to_html(true)
		)
	)


#
# helper methods
#
func _noise(factor: int = NOISE) -> int:
	return rng_util.randi_range(-factor, factor)


func _abs_noise(factor: int = NOISE) -> int:
	return rng_util.randi_range(0, factor)


func _in_bounds_random(value: int, max_bound: int = Const.MAX_PRESTIGE) -> int:
	var random_value: int = value + _noise()
	return _in_bounds(random_value, max_bound)


# returns value between 1 and 20
func _in_bounds(value: int, max_bound: int = Const.MAX_PRESTIGE) -> int:
	return maxi(mini(value, max_bound), 1)


func _get_month_max_days(month: int) -> int:
	# months with 31 days
	if month in [1, 3, 5, 7, 8, 10, 12]:
		return 31

	# months with 30 days
	if month in [4, 6, 9, 11]:
		return 30

	# february check leap year
	if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
		return 29
	return 28

