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
var max_timestamp: int
var min_timestamp: int

var names: GeneratorNames

func initialize_world(world: World, world_file_path: String = Const.WORLD_CSV_PATH) -> bool:

	# reset warnings/errors
	Global.generation_warnings = []
	Global.generation_errors = []

	var csv_util: CSVUtil = CSVUtil.new()

	# check if custom file is used
	var custom_file: bool = world_file_path != Const.WORLD_CSV_PATH

	# read csv and create world, without players
	# validate custom file first
	if custom_file:
		var is_valid_csv: bool = csv_util.validate_csv_file(world_file_path)
		if not is_valid_csv:
			push_error("csv file not valid %s" % world_file_path)
			return false
	
	var csv: Array[PackedStringArray] = csv_util.read_csv(world_file_path)
	csv_util.csv_to_world_only_teams(csv, world)
	
	# validate world
	var validator: GeneratorValidator = GeneratorValidator.new()
	var is_valid_world: bool = validator.validate_world(world)
	if not is_valid_world:
		push_error("world not valid %s" % world_file_path)
		return false

	# history
	var history: GeneratorHistory = GeneratorHistory.new()
	# first generate clubs history with promotions, delegations, cup wins
	history.generate_club_history(world)

	# initialize players and other custom team properties after club history
	# because histroy generation swaps team ids and names
	var success_players: bool = _generate_players(world)

	# go back if players are not valid
	if not success_players:
		print("error while reading players from world file %d errors occurred." % Global.generation_errors.size())
		return false

	# then generate player histroy with transfers and statistics
	history.generate_player_history(world)

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

	# initialize national teams
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			# national team
			nation.team.set_id()
			nation.team.name = nation.name
			# add nations best players
			nation.team.players = world.get_best_players_by_nationality(nation)
			nation.team.staff = _create_staff(world, nation.team.get_prestige(), nation, 1)
			nation.team.formation = nation.team.staff.manager.formation
			# TODO replace with actual national colors
			_set_random_shirt_colors(nation.team)

	# make world global, needed for matchutil
	Global.world = world

	# create matches for current season
	var match_util: MatchUtil = MatchUtil.new(world)
	match_util.initialize_matches()
	
	return true


func _generate_players(world: World) -> bool:
	# load player names
	names = GeneratorNames.new(world)

	# create date ranges
	# starts from current year and subtracts min/max years
	# youngest player can be 15 and oldest 45
	start_date = Global.start_date
	year = start_date.year
	var max_date: Dictionary = start_date.duplicate()
	max_date.month = 1
	max_date.day = 1
	max_date.year -= 15
	min_timestamp = Time.get_unix_time_from_datetime_dict(max_date)

	max_date.year -= 30
	max_timestamp = Time.get_unix_time_from_datetime_dict(max_date)

	# generate missing players
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			for league: League in nation.leagues:
				for team: Team in league.teams:
					_generate_missing_properties(world, nation, league, team)
	
	return true


func _assign_players_to_team(
	world: World, league: League, team: Team, nation: Nation, prestige: int
) -> Team:

	# team has no players or not enough
	if team.players.size() < Const.TEAM_PLAYERS_AMOUNT_MIN:
		# lineup
		for amount: int in team.formation.goalkeeper:
			var position_type: Position.Type = Position.Type.G

			var random_nation: Nation = _get_random_nationality(
				world, nation, prestige, league.pyramid_level
			)
			var player: Player = _create_player(
				world, random_nation, prestige, position_type, league, team
			)
			team.players.append(player)
		for amount: int in team.formation.defense:
			var position_type: Position.Type = _get_random_defense_position_type()

			var random_nation: Nation = _get_random_nationality(
				world, nation, prestige, league.pyramid_level
			)
			var player: Player = _create_player(
				world, random_nation, prestige, position_type, league, team
			)
			team.players.append(player)
		for amount: int in team.formation.center:
			var position_type: Position.Type = _get_random_center_position_type()

			var random_nation: Nation = _get_random_nationality(
				world, nation, prestige, league.pyramid_level
			)
			var player: Player = _create_player(
				world, random_nation, prestige, position_type, league, team
			)
			team.players.append(player)
		for amount: int in team.formation.attack:
			var position_type: Position.Type = _get_random_attack_position_type()

			var random_nation: Nation = _get_random_nationality(
				world, nation, prestige, league.pyramid_level
			)
			var player: Player = _create_player(
				world, random_nation, prestige, position_type, league, team
			)
			team.players.append(player)

		# bench and rest
		for position_type: int in Position.Type.values().size() - 1: # -1, last is undefined
			var amount: int = RngUtil.rng.randi_range(1, 2)
			if position_type == Position.Type.G:
				amount = 3

			for i: int in amount:
				var random_nation: Nation = _get_random_nationality(
					world, nation, prestige, league.pyramid_level
				)
				var player: Player = _create_player(
					world, random_nation, prestige, position_type, league, team
				)
				team.players.append(player)

	return team


func _get_random_defense_position_type() -> Position.Type:
	var positions: Array[Position.Type] = []
	positions.append(Position.Type.DC)
	positions.append(Position.Type.DL)
	positions.append(Position.Type.DR)
	return RngUtil.pick_random(positions)


func _get_random_center_position_type() -> Position.Type:
	var positions: Array[Position.Type] = []
	positions.append(Position.Type.C)
	positions.append(Position.Type.WL)
	positions.append(Position.Type.WR)
	return RngUtil.pick_random(positions)


func _get_random_attack_position_type() -> Position.Type:
	var positions: Array[Position.Type] = []
	positions.append(Position.Type.PC)
	positions.append(Position.Type.PL)
	positions.append(Position.Type.PR)
	return RngUtil.pick_random(positions)


func _get_goalkeeper_attributes(age: int, prestige: int, position: Position) -> Goalkeeper:
	var attributes: Goalkeeper = Goalkeeper.new()

	var age_factor: int = _get_age_factor(age)
	var factor: int = _in_bounds_random(prestige + age_factor)

	# goalkeepers have max potential of 20
	var max_potential: int = _in_bounds_random(factor)

	# non-goalkeepers have max potential of 10,
	# since they could play as goalkeeper in a 4 + 1 field player situation
	if position.type != Position.Type.G:
		max_potential /= 2

	attributes.reflexes = _in_bounds_random(factor, max_potential)
	attributes.positioning = _in_bounds_random(factor, max_potential)
	attributes.save_feet = _in_bounds_random(factor, max_potential)
	attributes.save_hands = _in_bounds_random(factor, max_potential)
	attributes.diving = _in_bounds_random(factor, max_potential)
	return attributes


func _get_physical(age: int, prestige: int, position: Position) -> Physical:
	var attributes: Physical = Physical.new()

	var age_factor: int = _get_physical_age_factor(age)

	var pace_factor: int = _in_bounds_random(prestige + age_factor)
	var physical_factor: int = _in_bounds_random(prestige + age_factor)

	# non goalkeepers have max potential
	var max_potential: int = _in_bounds_random(prestige)

	# goalkeepers have max potential of 10,
	# since they could play as goalkeeper in a 4 + 1 field player situation
	if position.type == Position.Type.G:
		max_potential /= 2

	attributes.pace = _in_bounds_random(pace_factor, max_potential)
	attributes.acceleration = _in_bounds_random(pace_factor, max_potential)
	attributes.resistance = _in_bounds_random(physical_factor, max_potential)
	attributes.strength = _in_bounds_random(physical_factor, max_potential)
	attributes.agility = _in_bounds_random(physical_factor, max_potential)
	attributes.jump = _in_bounds_random(physical_factor, max_potential)

	return attributes


func _get_technical(age: int, prestige: int, position: Position) -> Technical:
	var attributes: Technical = Technical.new()

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
	if position.type == Position.Type.G:
		max_potential /= 2

	attributes.crossing = _in_bounds_random(pass_factor, max_potential)
	attributes.passing = _in_bounds_random(pass_factor, max_potential)
	attributes.long_passing = _in_bounds_random(pass_factor, max_potential)
	attributes.tackling = _in_bounds_random(defense_factor, max_potential)
	attributes.heading = _in_bounds_random(shoot_factor, max_potential)
	attributes.interception = _in_bounds_random(defense_factor, max_potential)
	attributes.shooting = _in_bounds_random(shoot_factor, max_potential)
	attributes.long_shooting = _in_bounds_random(shoot_factor, max_potential)
	attributes.free_kick = _in_bounds_random(shoot_factor, max_potential)
	attributes.penalty = _in_bounds_random(technique_factor, max_potential)
	attributes.finishing = _in_bounds_random(shoot_factor, max_potential)
	attributes.dribbling = _in_bounds_random(shoot_factor, max_potential)
	attributes.blocking = _in_bounds_random(shoot_factor, max_potential)
	return attributes


func _get_mental(age: int, prestige: int) -> Mental:
	var attribtues: Mental = Mental.new()

	var age_factor: int = _get_age_factor(age)

	var offensive_factor: int = _in_bounds_random(prestige + age_factor)
	var defensive_factor: int = _in_bounds_random(prestige + age_factor)

	var max_potential: int = _in_bounds_random(prestige)

	attribtues.aggression = _in_bounds_random(defensive_factor, max_potential)
	attribtues.anticipation = _in_bounds_random(defensive_factor, max_potential)
	attribtues.marking = _in_bounds_random(defensive_factor, max_potential)

	attribtues.decisions = _in_bounds_random(offensive_factor, max_potential)
	attribtues.concentration = _in_bounds_random(offensive_factor, max_potential)
	attribtues.vision = _in_bounds_random(offensive_factor, max_potential)
	attribtues.workrate = _in_bounds_random(offensive_factor, max_potential)
	attribtues.offensive_movement = _in_bounds_random(offensive_factor, max_potential)

	return attribtues


func _get_physical_age_factor(age: int) -> int:
	# for  24 +- _noise <  age factor is negative
	if age < 24 + _noise():
		return RngUtil.rng.randi_range(-5, 3)
	return RngUtil.rng.randi_range(1, 7)


func _get_age_factor(age: int) -> int:
	# for  34 +- _noise < age < 18 +- _noise age factor is negative
	if age > 34 + _noise() or age < 18 + _noise():
		return RngUtil.rng.randi_range(-5, 1)
	# else age factor is positive
	return RngUtil.rng.randi_range(-1, 5)


func _get_value(age: int, prestige: int, position: Position) -> int:
	var age_factor: int = max(min(abs(age - 30), 20), 1)
	var pos_factor: int = 0
	if position.type == Position.Type.G:
		pos_factor = 5
	elif (
		position.type == Position.Type.DC
		|| position.type == Position.Type.DR
		|| position.type == Position.Type.DL
	):
		pos_factor = 10
	elif position.type == Position.Type.WL || position.type == Position.Type.WR:
		pos_factor = 15
	else:
		pos_factor = 20

	var total_factor: int = age_factor + pos_factor + prestige

	return RngUtil.rng.randi_range(maxi(total_factor - 20, 0), total_factor) * 1000


func _get_random_foot_left() -> int:
	var random: int = RngUtil.rng.randi_range(1, 100)
	# 35% have good left foot
	if random < 35:
		return RngUtil.rng.randi_range(10, 20)
	return RngUtil.rng.randi_range(1, 10)


func _get_random_foot_right() -> int:
	var random: int = RngUtil.rng.randi_range(1, 100)
	# 65% have good right foot
	if random < 65:
		return RngUtil.rng.randi_range(10, 20)
	return RngUtil.rng.randi_range(1, 10)


func _get_random_form() -> Enum.Form:
	var random: int = RngUtil.rng.randi_range(1, 100)
	if random < 5:
		return Enum.Form.INJURED
	if random < 15:
		return Enum.Form.RECOVER
	if random < 60:
		return Enum.Form.GOOD
	return Enum.Form.BEST


func _get_random_morality() -> Enum.Morality:
	var random: int = RngUtil.rng.randi_range(1, 100)
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
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Staff:
	var staff: Staff = Staff.new()
	staff.manager = _create_manager(world, team_prestige, team_nation, pyramid_level)
	staff.president = _create_president(world, team_prestige, team_nation, pyramid_level)
	staff.scout = _create_scout(world, team_prestige, team_nation, pyramid_level)
	return staff


func _create_manager(
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Manager:
	var manager: Manager = Manager.new()
	manager.set_id()
	manager.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	_set_random_person_values(manager, nation)
	manager.nation = nation.name

	# create random preferred tactics
	var variation: Formation.Variations = RngUtil.pick_random(Formation.Variations.values())
	manager.formation.set_variation(variation)
	manager.formation.tactic_offense.intensity = RngUtil.rng.randf()
	manager.formation.tactic_offense.tactic = RngUtil.pick_random(TacticOffense.Tactics.values())
	manager.formation.tactic_defense.marking = RngUtil.pick_random(TacticDefense.Marking.values())
	manager.formation.tactic_defense.pressing = RngUtil.pick_random(TacticDefense.Pressing.values())

	return manager


func _create_president(
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> President:
	var president: President = President.new()
	president.set_id()
	president.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	_set_random_person_values(president, nation)
	president.nation = nation.name
	return president


func _create_scout(
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Scout:
	var scout: Scout = Scout.new()
	scout.set_id()
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	_set_random_person_values(scout, nation)
	scout.prestige = _in_bounds_random(team_prestige)
	scout.nation = nation.name
	return scout


func _create_player(
	_world: World,
	nation: Nation,
	p_prestige: int,
	p_position_type: Position.Type,
	p_league: League,
	p_team: Team,
) -> Player:
	var player: Player = Player.new()
	player.set_id()

	_set_random_person_values(player, nation)

	random_positions(player, p_position_type)
	var prestige: int = _get_player_prestige(p_prestige)

	var birth_date_year: int = player.birth_date.year

	player.value = _get_value(year - birth_date_year, prestige, player.position)
	player.team = p_team.name
	player.team_id = p_team.id
	player.league = p_league.name
	player.league_id = p_league.id
	player.nation = nation.name
	player.foot_left = _get_random_foot_right()
	player.foot_right = _get_random_foot_right()
	player.morality = _get_random_morality()
	player.form = _get_random_form()
	player.prestige = prestige
	player.injury_factor = RngUtil.rng.randi_range(1, 20)
	# if player is loyal, he doesnt want to leave the club,
	# otherwise he leaves esaily, also on its own
	player.loyality = RngUtil.rng.randi_range(1, 20)

	player.attributes = Attributes.new()
	player.attributes.goalkeeper = _get_goalkeeper_attributes(
		year - birth_date_year, prestige, player.position
	)
	player.attributes.mental = _get_mental(year - birth_date_year, prestige)
	player.attributes.technical = _get_technical(
		year - birth_date_year, prestige, player.position
	)
	player.attributes.physical = _get_physical(
		year - birth_date_year, prestige, player.position
	)

	var statistics: Statistics = Statistics.new()
	statistics.games_played = 0
	statistics.goals = 0
	statistics.assists = 0
	statistics.yellow_cards = 0
	statistics.red_cards = 0
	statistics.average_vote = 0
	player.statistics = statistics
	# TODO create history

	return player


func random_positions(player: Player, p_position_type: Position.Type) -> void:
	# assign main positions
	var position: Position = Position.new()
	position.type = p_position_type
	player.position = position

	# TODO should goalkeeper have alt positions?
	# TODO adapt to make alteratinos more cohereant
	#      to attributes, like defender should have good defense stats
	var alt_positions: Array[Position] = []
	var alt_positions_keys: Array[Variant] = Position.Type.values()
	# remove Position.Type.UNDEFINED
	alt_positions_keys.pop_back()
	RngUtil.shuffle(alt_positions_keys)

	for i: int in RngUtil.rng.randi_range(0, alt_positions_keys.size() - 1):
		var alt_position: Position = Position.new()
		alt_position.type = alt_positions_keys[i]
		alt_positions.append(alt_position)

	player.alt_positions = alt_positions


func _get_player_prestige(team_prestige: int) -> int:
	# player prestige is teams prestige +- 5
	return _in_bounds_random(team_prestige)


func _get_team_prestige(pyramid_level: int) -> int:
	var minp: int = Const.MAX_PRESTIGE - pyramid_level * ((RngUtil.rng.randi() % 5) + 1)
	var maxp: int = Const.MAX_PRESTIGE - ((pyramid_level - 1) * 3)
	return _in_bounds(RngUtil.rng.randi_range(minp, maxp))


func _get_random_nationality(
	world: World, nation: Nation, prestige: int, pyramid_level: int
) -> Nation:
	# (100 - prestige)% given nation, prestige% random nation
	# with prestige, lower division teams have less players from other nations
	if RngUtil.rng.randi_range(1, 100) > 100 - (prestige * 2.0 / pyramid_level):
		return world.get_all_nations()[RngUtil.rng.randi_range(
			0, world.get_all_nations().size() - 1
		)]
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
	world: World,
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
		team.stadium.capacity = RngUtil.rng.randi_range(
			temp_team_prestige * 200, temp_team_prestige * 1_000
		)
	if team.stadium.year_built == 0:
		team.stadium.year_built = RngUtil.rng.randi_range(year - 70, year - 1)

	team.staff = _create_staff(world, team.get_prestige(), nation, league.pyramid_level)

	# assign manager preffered formation to team
	team.formation = team.staff.manager.formation

	# calc budget, after players/stuff have been created
	# so budget will alwyas be bigger as minimum needed
	team.finances.expenses[-1] = _get_salary_budget(team.players, team.staff)
	# calulate balance
	team.finances.balance[-1] = team.finances.expenses[-1]
	# add random bonus depending on team prestige
	team.finances.balance[-1] += RngUtil.rng.randi_range(
		temp_team_prestige * 10_000, temp_team_prestige * 100_000
	)

	# assign players after formation has been choosen, to assign correct players positions
	_assign_players_to_team(world, league, team, nation, temp_team_prestige)

	team.assign_shirt_numbers()


func _set_random_person_values(person: Person, nation: Nation) -> void:
	person.name = names.get_random_name(nation)
	person.surname = names.get_random_surnname(nation)

	# random birthday
	person.birth_date = Time.get_date_dict_from_unix_time(RngUtil.rng.randi_range(min_timestamp, max_timestamp))

	# colors
	person.skintone = RngUtil.pick_random(SKINTONE)
	person.haircolor = RngUtil.pick_random(HAIR_COLORS)
	person.eyecolor = RngUtil.pick_random(EYE_COLORS)

	# contract
	# TODO use different contract for differen roles
	var contract: Contract = Contract.new()
	var age_factor: int = _get_age_factor(person.get_age(start_date))
	contract.income = (person.prestige + age_factor) * 1000
	contract.start_date = start_date
	contract.end_date = start_date
	contract.bonus_goal = 0
	contract.bonus_clean_sheet = 0
	contract.bonus_assist = 0
	contract.bonus_league = 0
	contract.bonus_national_cup = 0
	contract.bonus_continental_cup = 0
	contract.buy_clause = 0
	contract.is_on_loan = false
	person.contract = contract


func _set_random_shirt_colors(team: Team) -> void:
	team.colors = []
	var main_color: Color = Color(
		RngUtil.rng.randf_range(0, 1), RngUtil.rng.randf_range(0, 1), RngUtil.rng.randf_range(0, 1)
	)
	team.colors.append(main_color.to_html(true))
	team.colors.append(main_color.inverted().to_html(true))
	team.colors.append(
		(
			Color(
				RngUtil.rng.randf_range(0, 1),
				RngUtil.rng.randf_range(0, 1),
				RngUtil.rng.randf_range(0, 1)
			)
			. to_html(true)
		)
	)


#
# helper methods
#
func _noise(factor: int = NOISE) -> int:
	return RngUtil.rng.randi_range(-factor, factor)


func _abs_noise(factor: int = NOISE) -> int:
	return RngUtil.rng.randi_range(0, factor)


func _in_bounds_random(value: int, max_bound: int = Const.MAX_PRESTIGE) -> int:
	var random_value: int = value + _noise()
	return _in_bounds(random_value, max_bound)


# returns value between 1 and 20
func _in_bounds(value: int, max_bound: int = Const.MAX_PRESTIGE) -> int:
	return maxi(mini(value, max_bound), 1)

