# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

var config_version: StringName = "1"
var version: StringName = ProjectSettings.get_setting("application/config/version")
var config: SettingsConfig

# generator config
var start_date: Dictionary
var generation_seed: String
var generation_state: int
var generation_player_names: Enum.PlayerNames
# saves which season this is, starting from 0
var current_season: int
# global game states
var match_speed: Enum.MatchSpeed

# saves match pause state
var match_paused: bool

# resources
var world: World
# active resources references, from world
var team: Team
var league: League
var manager: Manager
# csv
var match_list: MatchList
var offer_list: OfferList
var inbox: Inbox
var calendar: Calendar

# save states
var save_states: SaveStates

# generation warnings and errors
var generation_warnings: Array[Enum.GenerationWarning]
var generation_errors: Array[Enum.GenerationError]

# save last player silhouette path to prevent showing the same multiple times
var player_silhouette_last_path: String


func _ready() -> void:
	print("version " + Global.version)
	config = DataUtil.load_config()
	TranslationServer.set_locale(config.language)
	get_tree().root.content_scale_factor = config.theme_scale

	save_states = DataUtil.load_save_states()
	RngUtil.setup_rngs()

	generation_warnings = []
	generation_errors = []


func select_team(p_team: Team) -> void:
	team = p_team
	world.active_team_id = team.id
	league = world.get_league_by_id(team.league_id)


func initialize_game(testing: bool = false) -> void:
	# save save state and show loading screen
	if not testing:
		save_states.new_save_state()

	offer_list = OfferList.new()
	inbox = Inbox.new()
	calendar = Calendar.new()
	match_list = MatchList.new()

	print("matches initialized")
	inbox.welcome_manager()


func reset_data() -> void:
	team = null
	world = null
	league = null
	offer_list = null
	inbox = null
	manager = null


func next_day() -> void:
	calendar.next_day()

	if match_list.is_match_day():
		inbox.next_match(match_list.get_active_match(calendar.day()))

	offer_list.update_day()

	# new week starts
	if calendar.day().weekday == Enum.Weekdays.MONDAY:
		# update finances
		for t: Team in world.get_all_teams():
			t.finances.update_week(t)

	# check if cups are ready for next stage
	for cup: Cup in world.get_all_cups():
		cup.next_stage()

	# check if playoffs and playouts ready for next stage
	for p_league: League in world.get_all_leagues(true):
		if p_league.playoffs.is_started():
			p_league.playoffs.next_stage()
		if p_league.playouts.is_started():
			p_league.playouts.next_stage()


func next_season(save_data: bool = true) -> void:
	current_season += 1

	# TODO
	# set new goals for manager
	# player contracts
	# transfer markets
	# save competition results in history

	if calendar.day().weekday == Enum.Weekdays.MONDAY:
		# update finances
		for t: Team in world.get_all_teams():
			t.finances.update_season(t)

	var player_util: PlayerUtil = PlayerUtil.new()
	player_util.players_progress_season()
	player_util.check_contracts_terminated()

	world.promote_and_relegate_teams()
	match_list.archive_season()

	calendar.initialize(true)


	var match_util: MatchUtil = MatchUtil.new(world)
	match_util.initialize_matches()

	if save_data:
		save_all_data()


func save_all_data() -> void:
	DataUtil.save_config()
	DataUtil.save_save_states()
	DataUtil.save_save_state()
	DataUtil.save_save_state_data()


func load_save_state() -> bool:
	var save_sate: SaveState = save_states.get_active()
	if save_sate:
		start_date = save_sate.start_date
		IdUtil.id_by_type = save_sate.id_by_type
		current_season = save_sate.current_season
		match_speed = save_sate.match_speed
		generation_seed = save_sate.generation_seed
		generation_state = save_sate.generation_state
		generation_player_names = save_sate.generation_player_names
		# DataUtil.load_save_state_data()
		ThreadUtil.load_data()
		return true

	return false

