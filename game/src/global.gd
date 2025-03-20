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
# saves current id for resources
var id_by_type: Dictionary

# saves match pause state
var match_paused: bool

# resources
var world: World
var transfers: Transfers
var inbox: Inbox
# active resources references, from world
var team: Team
var league: League
var manager: Manager

# save states
var save_states: SaveStates

# generation warnings and errors
var generation_warnings: Array[Enum.GenerationWarning]
var generation_errors: Array[Enum.GenerationError]

# save last player silhouette path to prevent showing the same multiple times
var player_silhouette_last_path: String


func _ready() -> void:
	print("version " + Global.version)
	config = ResUtil.load_config()
	TranslationServer.set_locale(config.language)
	get_tree().root.content_scale_factor = config.theme_scale

	save_states = ResUtil.load_save_states()
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

	transfers = world.transfers
	inbox = world.inbox

	print("matches initialized")
	EmailUtil.welcome_manager()


func next_day() -> void:
	world.calendar.next_day()

	if world.calendar.is_match_day():
		EmailUtil.next_match(world.calendar.get_next_match())

	TransferUtil.update_day()

	# new week starts
	if world.calendar.day().weekday == Enum.Weekdays.MONDAY:
		# update finances
		for t: Team in world.get_all_teams():
			t.finances.update_week(t)


func next_season() -> void:
	current_season += 1

	# TODO
	# set new goals for manager
	# player contracts
	# transfer markets
	# save competition results in history

	if world.calendar.day().weekday == Enum.Weekdays.MONDAY:
		# update finances
		for t: Team in world.get_all_teams():
			t.finances.update_season(t)

	PlayerProgress.players_progress_season()

	world.promote_and_relegate_teams()

	world.calendar.initialize(true)

	var match_util: MatchUtil = MatchUtil.new(world)
	match_util.initialize_matches()
	save_all_data()


func save_all_data() -> void:
	ResUtil.save_config()
	ResUtil.save_save_states()
	ResUtil.save_save_state()
	ResUtil.save_save_state_data()


func load_save_state() -> bool:
	var save_sate: SaveState = save_states.get_active()
	if save_sate:
		start_date = save_sate.start_date
		id_by_type = save_sate.id_by_type
		current_season = save_sate.current_season
		match_speed = save_sate.match_speed
		generation_seed = save_sate.generation_seed
		generation_state = save_sate.generation_state
		generation_player_names = save_sate.generation_player_names
		# ResUtil.load_save_state_data()
		ThreadUtil.load_data()
		return true

	return false
