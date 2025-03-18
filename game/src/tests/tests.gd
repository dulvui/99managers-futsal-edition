# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

class_name Tests
extends Node

@onready var test_calendar: TestCalendar = $TestCalendar
@onready var test_generator: TestGenerator = $TestGenerator
@onready var test_match_engine: TestMatchEngine = $TestMatchEngine
@onready var test_gameloop: TestGameloop = $TestGameloop
@onready var test_match_util: TestMatchUtil = $TestMatchUtil
@onready var test_res_util: TestRestUtil = $TestResUtil
@onready var test_format_util: TestFormatUtil = $TestFormatUtil


func _ready() -> void:
	print("Start test suite")

	tests_fast()
	tests_intensive()

	print("Stop test suite")
	get_tree().quit()


func tests_fast() -> void:
	print("start tests: fast..")

	# JSON res util currenlty not used and not working
	# test_res_util.test()

	test_format_util.test()
	test_match_util.test()
	test_calendar.test()
	test_generator.test()
	print("start tests: fast done.")


func tests_intensive() -> void:
	print("start tests: intenstive...")
	test_match_engine.test()
	test_gameloop.test()
	print("start tests: intenstive done.")


static func setup_mock_world(use_test_file: bool = false) -> bool:
	if Global.world == null:
		print("setting up mock world...")
		Global.start_date = Time.get_date_dict_from_system()
		Global.manager = create_mock_manager()
		Global.world = create_mock_world(use_test_file)

		var team: Team
		for continent: Continent in Global.world.continents:
			if continent.is_competitive():
				for nation: Nation in continent.nations:
					if nation.is_competitive():
						team = nation.leagues[0].teams[0]
						break
				break

		Global.select_team(team)
		Global.initialize_game(true)
		Global.start_date = Time.get_date_dict_from_system()
		print("setting up mock world done.")
		return true
	return false


static func find_next_matchday() -> void:
	if not Global.world:
		return

	# search next match day
	while Global.world.calendar.day().get_matches(Global.league.id).size() == 0:
		Global.world.calendar.next_day()


static func create_mock_world(use_test_file: bool) -> World:
	# create world
	var world_generator: GeneratorWorld = GeneratorWorld.new()
	var world: World = world_generator.init_world()

	# generate teams
	var generator: Generator = Generator.new()

	if use_test_file:
		return generator.generate_teams(world, Generator.TEST_WORLD_CSV_PATH)
	
	world = generator.generate_teams(world)

	for c: int in range(2):
		var continent: Continent = Continent.new()
		continent.name = "Mock continent " + str(c)
		for n: int in range(2):
			var nation: Nation = Nation.new()
			nation.name = "Mock nation " + str(n)
			for l: int in range(2):
				var league: League = create_mock_league(l, 6)
				nation.leagues.append(league)
			continent.nations.append(nation)

		world.continents.append(continent)

	return world


static func create_mock_league(nr: int = randi_range(0, 99), teams: int = 10) -> League:
	var league: League = League.new()
	league.set_id()
	league.name = "Mock league " + str(nr)

	for i: int in range(teams):
		var team: Team = create_mock_team(i)
		team.set_id()
		league.add_team(team)

	return league


static func create_mock_team(nr: int = randi_range(1, 99)) -> Team:
	var team: Team = Team.new()
	team.set_id()
	team.name = "Mock Team " + str(nr)
	# set random team colors
	team.colors = [Color.RED.to_html(true)]
	team.colors.append(Color.BLACK.to_html(true))

	for i: int in range(1, Const.LINEUP_PLAYERS_AMOUNT + 8):
		var player: Player = create_mock_player(i)
		team.players.append(player)

	return team


static func create_mock_player(nr: int = randi_range(1, 99)) -> Player:
	var player: Player = Player.new()
	player.set_id()
	player.name = "Mock"
	player.surname = "Player " + str(nr)
	player.nr = nr
	player.birth_date = Time.get_date_dict_from_system()
	player.contract.start_date = Time.get_date_dict_from_system()
	player.contract.end_date = Time.get_date_dict_from_system()

	return player


static func create_mock_manager() -> Manager:
	var manager: Manager = Manager.new()
	manager.set_id()
	manager.name = "Mike"
	manager.surname = "Mock"
	return manager


static func is_run_as_current_scene(node: Node) -> bool:
	# setup automatically, if run in editor and is run by 'Run current scene'
	return OS.has_feature("editor") and node.get_parent() == node.get_tree().root
