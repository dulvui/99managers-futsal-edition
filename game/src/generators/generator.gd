# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later
class_name Generator
extends Node

const TEST_WORLD_CSV_PATH: String = "res://data/world/test_world.csv"
const WORLD_CSV_PATH: String = "res://data/world/world.csv"
const NAMES_DIR: String = "res://data/player_names/"

# defines noise added to attribute factors
const NOISE: int = 3

# defines year, when history starts
const HISTORY_YEARS: int = 10

# person colors
const SKINTONE: Array[Color] = [
	Color("#FFE0BD"),
	Color("#F6D3BD"),
	Color("#E8BEAC"),
	Color("#D4AA78"),
	Color("#E0AC69"),
	Color("#C68642"),
	Color("#A16E4B"),
	Color("#8D5524"),
	Color("#3B2219"),
]
const HAIR_COLORS: Array[Color] = [
	Color("#040200"),
	Color("#1C1C1C"),
	Color("#23120B"),
	Color("#3D2314"),
	Color("#5A3825"),
	Color("#CC9966"),
	Color("#F6D02F"),
	Color("#F2A900"),
	Color("#C65D3B"),
	# Color.TRANSPARENT, # bald
]
const EYE_COLORS: Array[Color] = [
	Color.BROWN,
	Color.AQUAMARINE,
	Color.GREEN,
	Color.GRAY,
]

var leagues_data: Dictionary = {}
var names: Dictionary = {}

# for birthdays range
var date: Dictionary
var max_timestamp: int
var min_timestamp: int


func generate_world(use_test_file: bool = false) -> World:
	var world: World = _generate_world_from_csv(use_test_file)
	
	# create date ranges
	# starts from current year and subtracts min/max years
	# youngest player can be 15 and oldest 45
	if Global.save_states and Global.save_states.temp_state:
		date = Global.save_states.temp_state.start_date
	else:
		date = Time.get_date_dict_from_system()
	var max_date: Dictionary = date.duplicate()
	max_date.month = 1
	max_date.day = 1
	max_date.year -= 15
	max_timestamp = Time.get_unix_time_from_datetime_dict(max_date)
	max_date.year -= 30
	min_timestamp = Time.get_unix_time_from_datetime_dict(max_date)


	# generate players
	_load_person_names(world)
	for continent: Continent in world.continents:
		for nation: Nation in continent.nations:
			# backup teams
			var backup_league: League = League.new()
			backup_league.name = "BACKUP"
			backup_league.pyramid_level = nation.leagues.size() + 1
			for team: Team in nation.backup_teams:
				_initialize_team(world, nation, backup_league, team)
			
			# league teams
			for league: League in nation.leagues:
				for team: Team in league.teams:
					_initialize_team(world, nation, league, team)

			# national team
			nation.team.name = nation.name
			# add nations best players
			nation.team.players = world.get_best_players_by_nationality(nation)
			nation.team.staff = _create_staff(world, nation.team.get_prestige(), nation, 1)
			nation.team.formation = nation.team.staff.manager.formation
			# TODO replace with actual national colors
			_set_random_shirt_colors(nation.team)

	# first generate clubs history with promotions, delegations, cup wins
	_generate_club_history(world)
	# then generate player histroy with trasnfers and statistics
	_generate_player_history(world)

	return world


func _initialize_team(
	world: World,
	nation: Nation,
	league: League,
	team: Team,
) -> void:
	var temp_team_prestige: int = _get_team_prestige(league.pyramid_level)

	# create team
	_set_random_shirt_colors(team)

	team.stadium = Stadium.new()
	team.stadium.name = team.name + " Stadium"
	team.stadium.capacity = RngUtil.rng.randi_range(
		temp_team_prestige * 1000, temp_team_prestige * 10000
	)
	team.stadium.year_built = RngUtil.rng.randi_range(date.year - 70, date.year - 1)

	team.staff = _create_staff(world, team.get_prestige(), nation, league.pyramid_level)

	# assign manager preffered formation to team
	team.formation = team.staff.manager.formation
	
	# assign players after formation has been choosen, to assign correct players positions
	_assign_players_to_team(world, league, team, nation, temp_team_prestige)

	# calc budget, after players/stuff have been created
	# so budget will alwyas be bigger as minimum needed
	team.finances.expenses = _get_salary_budget(team.players, team.staff)
	# calulate balance
	team.finances.balance = team.finances.expenses
	# add random bonus depending on team prestige
	team.finances.balance += RngUtil.rng.randi_range(temp_team_prestige * 1_000, temp_team_prestige * 100_000)


func _assign_players_to_team(
	world: World,league: League, team: Team, nation: Nation, prestige: int
) -> Team:
	var nr: int = 1
	
	# lineup
	for amount: int in team.formation.goalkeeper:
		var position_type: Position.Type = Position.Type.G

		var random_nation: Nation = _get_random_nationality(
			world, nation, prestige, league.pyramid_level
		)
		var player: Player = _create_player(
			world, random_nation, nr, prestige, position_type, league, team
		)
		team.players.append(player)
		nr += 1
	for amount: int in team.formation.defense:
		var position_type: Position.Type = _get_random_defense_position_type()

		var random_nation: Nation = _get_random_nationality(
			world, nation, prestige, league.pyramid_level
		)
		var player: Player = _create_player(
			world, random_nation, nr, prestige, position_type, league, team
		)
		team.players.append(player)
		nr += 1
	for amount: int in team.formation.center:
		var position_type: Position.Type = _get_random_center_position_type()

		var random_nation: Nation = _get_random_nationality(
			world, nation, prestige, league.pyramid_level
		)
		var player: Player = _create_player(
			world, random_nation, nr, prestige, position_type, league, team
		)
		team.players.append(player)
		nr += 1
	for amount: int in team.formation.attack:
		var position_type: Position.Type = _get_random_attack_position_type()

		var random_nation: Nation = _get_random_nationality(
			world, nation, prestige, league.pyramid_level
		)
		var player: Player = _create_player(
			world, random_nation, nr, prestige, position_type, league, team
		)
		team.players.append(player)
		nr += 1
	
	# bench and rest
	for position_type: int in Position.Type.values():
		var amount: int = RngUtil.rng.randi_range(2, 5)
		if position_type == Position.Type.G:
			amount = 3

		for i in amount:
			var random_nation: Nation = _get_random_nationality(
				world, nation, prestige, league.pyramid_level
			)
			var player: Player = _create_player(
				world, random_nation, nr, prestige, position_type, league, team
			)
			team.players.append(player)
			nr += 1

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
	attributes.kicking = _in_bounds_random(factor, max_potential)
	attributes.handling = _in_bounds_random(factor, max_potential)
	attributes.diving = _in_bounds_random(factor, max_potential)
	attributes.speed = _in_bounds_random(factor, max_potential)
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
	attributes.stamina = _in_bounds_random(physical_factor, max_potential)
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
	attribtues.teamwork = _in_bounds_random(offensive_factor, max_potential)
	attribtues.vision = _in_bounds_random(offensive_factor, max_potential)
	attribtues.work_rate = _in_bounds_random(offensive_factor, max_potential)
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

	return RngUtil.rng.randi_range(max(total_factor - 20, 0), total_factor) * 1000


func _get_random_foot() -> Player.Foot:
	if RngUtil.rng.randi() % 5 == 0:
		return Player.Foot.L
	return Player.Foot.R


func _get_random_form() -> Player.Form:
	var factor: int = RngUtil.rng.randi() % 100
	if factor < 5:
		return Player.Form.INJURED
	if factor < 15:
		return Player.Form.RECOVER
	if factor < 60:
		return Player.Form.GOOD
	return Player.Form.BEST


func _get_random_morality() -> Player.Morality:
	var factor: int = RngUtil.rng.randi() % 100
	if factor < 5:
		return Player.Morality.WORST
	if factor < 15:
		return Player.Morality.BAD
	if factor < 60:
		return Player.Morality.GOOD
	return Player.Morality.BEST


func _get_contract(person: Person) -> Contract:
	var contract: Contract = Contract.new()
	contract.income = person.prestige * person.get_age(date)  # TODO use better logic
	contract.start_date = date
	contract.end_date = date
	contract.bonus_goal = 0
	contract.bonus_clean_sheet = 0
	contract.bonus_assist = 0
	contract.bonus_league_title = 0
	contract.bonus_nat_cup_title = 0
	contract.bonus_inter_cup_title = 0
	contract.buy_clause = 0
	contract.is_on_loan = false
	return contract


func _get_person_name(nation: Nation) -> String:
	# TODO randomly use names from other nations, with low probability
	var nation_string: String = nation.name.to_lower()
	
	# check if names exist for nation, if not, pick random
	if not names.has(nation_string):
		nation_string = RngUtil.pick_random(names.keys())

	if Global.generation_player_names == Const.PlayerNames.MALE:
		var size: int = (names[nation_string]["first_names_male"] as Array).size()
		return names[nation_string]["first_names_male"][RngUtil.rng.randi() % size]
	if Global.generation_player_names == Const.PlayerNames.FEMALE:
		var size: int = (names[nation_string]["first_names_female"] as Array).size()
		return names[nation_string]["first_names_female"][RngUtil.rng.randi() % size]

	var size_female: int = (names[nation_string]["first_names_female"] as Array).size()
	var size_male: int = (names[nation_string]["first_names_male"] as Array).size()
	var female_names: Array = names[nation_string]["first_names_female"]
	var male_names: Array = names[nation_string]["first_names_male"]

	var mixed_names: Array = []
	mixed_names.append_array(female_names)
	mixed_names.append_array(male_names)

	return mixed_names[RngUtil.rng.randi() % (size_female + size_male)]


func _get_person_surname(world: World, nation: Nation) -> String:
	# TODO bigger proability for neighbour nations (needs data)

	# 10% change of having random nation's surname
	var different_nation_factor: int = RngUtil.rng.randi() % 100
	if different_nation_factor > 90:
		nation = RngUtil.pick_random(world.get_all_nations())

	var nation_string: String = nation.name.to_lower()
	
	# check if names exist for nation, if not, pick random
	if not names.has(nation_string):
		nation_string = RngUtil.pick_random(names.keys())

	var size: int = (names[nation_string]["last_names"] as Array).size()
	return names[nation_string]["last_names"][RngUtil.rng.randi() % size]


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
	_set_person_colors(manager)
	manager.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	manager.nation = nation.name
	manager.name = _get_person_name(nation)
	manager.surname = _get_person_surname(world, nation)

	manager.contract = _get_contract(manager)

	# create random preferred tactics
	manager.formation.set_variation(RngUtil.pick_random(Formation.Variations.values()))
	manager.formation.tactic_offense.intensity = RngUtil.rng.randf()
	manager.formation.tactic_offense.tactic = RngUtil.pick_random(TacticOffense.Tactics.values())
	manager.formation.tactic_defense.marking = RngUtil.pick_random(TacticDefense.Marking.values())
	manager.formation.tactic_defense.pressing = RngUtil.pick_random(TacticDefense.Pressing.values())

	return manager


func _create_president(
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> President:
	var president: President = President.new()
	_set_person_colors(president)
	president.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	president.nation = nation.name
	president.name = _get_person_name(nation)
	president.surname = _get_person_surname(world, nation)
	president.contract = _get_contract(president)
	return president


func _create_scout(
	world: World, team_prestige: int, team_nation: Nation, pyramid_level: int
) -> Scout:
	var scout: Scout = Scout.new()
	_set_person_colors(scout)
	scout.prestige = _in_bounds_random(team_prestige)
	var nation: Nation = _get_random_nationality(world, team_nation, team_prestige, pyramid_level)
	scout.nation = nation.name
	scout.name = _get_person_name(nation)
	scout.surname = _get_person_surname(world, nation)
	scout.contract = _get_contract(scout)
	return scout


func _create_player(
	world: World,
	nation: Nation,
	nr: int,
	p_prestige: int,
	p_position_type: Position.Type,
	p_league: League,
	p_team: Team,
) -> Player:
	var player: Player = Player.new()
	_set_person_colors(player)
	_random_positions(player, p_position_type)

	# RngUtil.rng.random date from 1970 to 2007
	var birth_date: Dictionary = Time.get_datetime_dict_from_unix_time(
		RngUtil.rng.randi_range(0, max_timestamp)
	)

	var prestige: int = _get_player_prestige(p_prestige)

	player.value = _get_value(date.year - birth_date.year, prestige, player.position)
	player.name = _get_person_name(nation)
	player.surname = _get_person_surname(world, nation)
	player.team = p_team.name
	player.team_id = p_team.id
	player.league = p_league.name
	player.league_id = p_league.id
	player.statistics.team_name = p_team.name
	player.birth_date = birth_date
	player.nation = nation.name
	player.foot = _get_random_foot()
	player.morality = _get_random_morality()
	player.form = _get_random_form()
	player.prestige = prestige
	player.injury_factor = RngUtil.rng.randi_range(1, 20)
	# if player is loyal, he doesnt want to leave the club,
	# otherwise he leaves esaily, also on its own
	player.loyality = RngUtil.rng.randi_range(1, 20)
	player.contract = _get_contract(player)
	player.nr = nr

	player.attributes = Attributes.new()
	player.attributes.goalkeeper = _get_goalkeeper_attributes(
		date.year - birth_date.year, prestige, player.position
	)
	player.attributes.mental = _get_mental(date.year - birth_date.year, prestige)
	player.attributes.technical = _get_technical(
		date.year - birth_date.year, prestige, player.position
	)
	player.attributes.physical = _get_physical(
		date.year - birth_date.year, prestige, player.position
	)

	var statistics: Statistics = Statistics.new()
	statistics.games_played = 0
	statistics.goals = 0
	statistics.assists = 0
	statistics.yellow_card = 0
	statistics.red_card = 0
	statistics.average_vote = 0
	player.statistics = statistics
	# TODO create history

	return player


func _random_positions(player: Player, p_position_type: Position.Type) -> void:
	# assign main positions
	var position: Position = Position.new()
	position.type = p_position_type
	position.random_variations()
	player.position = position

	# TODO should goalkeeper have alt positions?
	# TODO adapt to make alteratinos more cohereant
	#      to attributes, like defender should have good defense stats
	var alt_positions: Array[Position] = []
	var alt_positions_keys: Array[Variant] = Position.Type.values()
	RngUtil.shuffle(alt_positions_keys)

	for i: int in RngUtil.rng.randi_range(0, alt_positions_keys.size()):
		var alt_position: Position = Position.new()
		alt_position.type = alt_positions_keys[i]
		alt_position.random_variations()
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
	if RngUtil.rng.randi_range(1, 100) > 100 - (prestige * 2 / pyramid_level):
		return world.get_all_nations()[RngUtil.rng.randi_range(
			0, world.get_all_nations().size() - 1
		)]
	return nation


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


func _load_person_names(world: World) -> void:
	for nation: Nation in world.get_all_nations():
		var names_file: FileAccess = FileAccess.open(
			NAMES_DIR + nation.name.to_lower() + ".json", FileAccess.READ
		)
		# check first if file exists
		if names_file:
			names[nation.name.to_lower()] = JSON.parse_string(names_file.get_as_text())


func _get_salary_budget(players: Array[Player], staff: Staff) -> int:
	var salary_budget: int = 0

	# sum up all players salary
	for player: Player in players:
		salary_budget += player.contract.income

	# sum up staff salary
	salary_budget += staff.get_salary()

	return salary_budget


func _generate_club_history(world: World) -> void:
	# TODO world cup history (once national teams exist)
	# TODO continental national teams cup

	# calculate random results for x years
	for year: int in HISTORY_YEARS + 1:
		for contient: Continent in world.continents:
			for nation: Nation in contient.nations:
				for league: League in nation.leagues:
					# create match combinations
					var match_days: Array[Array] = MatchCombinationUtil.create_combinations(
						league, league.teams
					)

					# generate random results for every match
					for match_day: Array in match_days:
						for matchz: Match in match_day:
							var home_goals: int = RngUtil.rng.randi_range(
								0, matchz.home.get_prestige() / 2
							)
							var away_goals: int = RngUtil.rng.randi_range(
								0, matchz.away.get_prestige() / 2
							)
							matchz.set_result(home_goals, away_goals, world)

		world.promote_and_delegate_teams()


func _generate_player_history(_world: World) -> void:
	pass


func _generate_world_from_csv(use_test_file: bool = false) -> World:
	var world: World = World.new()
	world.initialize()
	
	var world_csv: String = WORLD_CSV_PATH
	if use_test_file:
		world_csv = TEST_WORLD_CSV_PATH

	var file: FileAccess = FileAccess.open(world_csv, FileAccess.READ)

	# get header row
	# CONTINENT, NATION, CITY, POPULATION
	var header_line: PackedStringArray = file.get_csv_line()
	var headers: Array[String] = []
	# transform to array and make lower case
	for header: String in header_line:
		headers.append(header.to_lower())

	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() > 1:
			var continent: String = line[0]
			var nation: String = line[1]
			var league: String = line[2]
			var city: String = line[3]
			_initialize_city(world, continent, nation, league, city)
	
	# sort continents, nations alphabetically
	world.continents.sort_custom(func(a: Continent, b: Continent) -> bool: return a.name < b.name)
	for continent: Continent in world.continents:
		continent.nations.sort_custom(func(a: Nation, b: Nation) -> bool: return a.name < b.name)

	return world


func _initialize_city(
	world: World,
	continent_name: String,
	nation_name: String,
	league_name: String,
	team_name: String
) -> void:
	# setup continent, if not done yet
	var continent: Continent
	var continent_filter: Array[Continent] = world.continents.filter(
		func(c: Continent) -> bool: return c.name == continent_name
	)
	if continent_filter.size() == 0:
		continent = Continent.new()
		continent.name = continent_name
		world.continents.append(continent)
		# TODO create competition history here
	else:
		continent = continent_filter[0]

	# setup nation, if not done yet
	var nation: Nation
	var nation_filter: Array[Nation] = continent.nations.filter(
		func(n: Nation) -> bool: return n.name == nation_name
	)
	if nation_filter.size() == 0:
		nation = Nation.new()
		nation.name = nation_name
		continent.nations.append(nation)
	else:
		nation = nation_filter[0]

	# create team
	var team: Team = Team.new()
	team.name = team_name

	# check if team is backup team
	if league_name.to_lower().strip_edges() == "backup":
		nation.backup_teams.append(team)
	elif league_name.length() > 0:
		# setup league, if not done yet or last league is full
		var league: League
		var league_filter: Array[League] = nation.leagues.filter(
			func(l: League) -> bool: return l.name == league_name
		)
		if league_filter.size() == 0:
			league = League.new()
			league.name = league_name
			league.nation_name = nation.name
			# could bea added direclty to csv
			# with this code, leagues/teams need to be in pyramid level order
			league.pyramid_level = nation.leagues.size() + 1
			nation.leagues.append(league)
		else:
			league = league_filter[0]

		league.add_team(team)


func _set_person_colors(person: Person) -> void:
	person.skintone = RngUtil.pick_random(SKINTONE)
	person.haircolor = RngUtil.pick_random(HAIR_COLORS)
	person.eyecolor = RngUtil.pick_random(EYE_COLORS)


func _set_random_shirt_colors(team: Team) -> void:
	team.colors = []
	team.colors.append(
		Color(
			RngUtil.rng.randf_range(0, 1),
			RngUtil.rng.randf_range(0, 1),
			RngUtil.rng.randf_range(0, 1)
		)
	)
	team.colors.append(team.colors[0].inverted())
	team.colors.append(
		Color(
			RngUtil.rng.randf_range(0, 1),
			RngUtil.rng.randf_range(0, 1),
			RngUtil.rng.randf_range(0, 1)
		)
	)
