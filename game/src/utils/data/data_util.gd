# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node


const USER_PATH: StringName = "user://"
const SAVE_STATES_PATH: StringName = "user://save_states/"

const CONFIG_FILE: StringName = "settings_config"
const CHECKSUM_FILE: StringName = "checksums"
const SAVE_STATE_FILE: StringName = "save_state"
const SAVE_STATES_FILE: StringName = "save_states"
const DATA_FILE: StringName = "data"

var backup_util: BackupUtil
var json_util: JSONUtil
var csv_util: CSVUtil
var checksum_list: ChecksumList

# flag if match list history should be saved
var write_match_history: bool


func _init() -> void:
	backup_util = BackupUtil.new()
	json_util = JSONUtil.new()
	csv_util = CSVUtil.new()
	
	json_util.load(CHECKSUM_FILE, checksum_list)
	if checksum_list == null:
		checksum_list = ChecksumList.new()
	
	write_match_history = false


func save_config() -> void:
	json_util.save(CONFIG_FILE, Global.config)


func load_config() -> SettingsConfig:
	var config: SettingsConfig = SettingsConfig.new()
	json_util.load(CONFIG_FILE, config)
	if config == null:
		return SettingsConfig.new()
	return config


func load_save_states() -> SaveStates:
	var save_states: SaveStates = SaveStates.new()
	json_util.load(SAVE_STATES_FILE, save_states)
	if save_states == null:
		return SaveStates.new()
	# scan for new save states
	save_states.scan()
	return save_states


func save_save_states() -> void:
	json_util.save(SAVE_STATES_FILE, Global.save_states)


func load_save_state(id: String) -> SaveState:
	var save_state: SaveState = SaveState.new()
	json_util.save(id + "/" + SAVE_STATE_FILE, save_state)
	if save_state == null:
		return SaveState.new()
	return save_state


func save_save_state() -> void:
	var active: SaveState = Global.save_states.get_active()
	if active == null:
		print("no active save state found to save")
		return
	# save id by type
	active.id_by_type = IdUtil.id_by_type
	json_util.save(active.id + "/" + SAVE_STATE_FILE, active)

	# save checksum
	checksum_list.save(active.id + "/" + SAVE_STATE_FILE)
	json_util.save(CHECKSUM_FILE, checksum_list)


func load_save_state_data() -> void:
	var active: SaveState = Global.save_states.get_active()
	IdUtil.id_by_type = active.id_by_type

	_load_data(active)

	Global.team = Global.world.get_active_team()
	Global.manager = Global.team.staff.manager
	Global.league = Global.world.get_league_by_id(Global.team.league_id)


func save_save_state_data() -> void:
	var active: SaveState = Global.save_states.get_active()
	if active == null:
		print("no active save state found to save data")
		return
	_save_data(active)


func _load_data(save_state: SaveState) -> void:
	var path: String = save_state.id + "/"

	# load main data from json
	var world: World = World.new()
	json_util.load(path + DATA_FILE, world)
	Global.world = world

	# the rest is loaded as csv
	var csv_path: String = SAVE_STATES_PATH + save_state.id + "/"

	# players csv
	var players_csv_path: String = csv_path + Const.CSV_PLAYERS_FILE
	csv_util.csv_to_players(
		csv_util.read_csv(players_csv_path), world
	)

	# free_agents csv
	var free_agents_csv_path: String = csv_path + Const.CSV_FREE_AGENTS_FILE
	csv_util.csv_to_free_agents(
		csv_util.read_csv(free_agents_csv_path), world
	)

	# history match days csv, read only
	Global.match_list = MatchList.new()
	var history_matches_path: String = csv_path + Const.CSV_MATCH_HISTORY_FILE
	Global.match_list.history_match_days = csv_util.csv_to_match_days(
		csv_util.read_csv(history_matches_path)
	)

	# match days csv
	var matches_path: String = csv_path + Const.CSV_MATCH_LIST_FILE
	var match_days: Array[MatchDays] = csv_util.csv_to_match_days(
		csv_util.read_csv(matches_path)
	)
	if match_days.size() == 1:
		Global.match_list.match_days = match_days[0]
	else:
		push_error("error while loading matchdays, match days from csv is not 1")
	
	# calendar csv
	var calendar_path: String = csv_path + Const.CSV_CALENDAR_FILE
	Global.calendar = csv_util.csv_to_calendar(csv_util.read_csv(calendar_path))

	# inbox csv
	var inbox_path: String = csv_path + Const.CSV_INBOX_FILE
	Global.inbox = csv_util.csv_to_inbox(csv_util.read_csv(inbox_path))

	# offer list csv
	var transfer_list_path: String = csv_path + Const.CSV_OFFER_LIST_FILE
	Global.transfer_list = csv_util.csv_to_transfer_list(csv_util.read_csv(transfer_list_path))


func _save_data(save_state: SaveState) -> void:
	print("save data...")
	var path: String = save_state.id + "/"
	json_util.save(path + DATA_FILE, Global.world)

	# create backup
	backup_util.create(path + DATA_FILE)

	checksum_list.save(path + DATA_FILE)

	var csv_path: String = SAVE_STATES_PATH + save_state.id + "/"

	# players
	csv_util.save_csv(
		csv_path + Const.CSV_PLAYERS_FILE,
		csv_util.players_to_csv(Global.world)
	)
	checksum_list.save(csv_path + Const.CSV_PLAYERS_FILE)

	# free agents
	csv_util.save_csv(
		csv_path + Const.CSV_FREE_AGENTS_FILE,
		csv_util.free_agents_to_csv(Global.world)
	)
	checksum_list.save(csv_path + Const.CSV_FREE_AGENTS_FILE)
	
	# history match days csv
	# TODO: could be optimized even more by just appending new history,
	# instead of writing full history
	if write_match_history:
		csv_util.save_csv(
			csv_path + Const.CSV_MATCH_HISTORY_FILE,
			csv_util.match_days_to_csv(Global.match_list.history_match_days),
		)
		write_match_history = false
		checksum_list.save(csv_path + Const.CSV_MATCH_HISTORY_FILE)

	# match days csv
	csv_util.save_csv(
		csv_path + Const.CSV_MATCH_LIST_FILE,
		csv_util.match_days_to_csv([Global.match_list.match_days]),
	)
	checksum_list.save(csv_path + Const.CSV_MATCH_LIST_FILE)

	# calendar
	# TODO can be optimized by saving only date that changes in first line
	csv_util.save_csv(
		csv_path + Const.CSV_CALENDAR_FILE,
		csv_util.calendar_to_csv(Global.calendar)
	)
	checksum_list.save(csv_path + Const.CSV_CALENDAR_FILE)

	# inbox
	csv_util.save_csv(
		csv_path + Const.CSV_INBOX_FILE,
		csv_util.inbox_to_csv(Global.inbox)
	)
	checksum_list.save(csv_path + Const.CSV_INBOX_FILE)

	# offer list
	csv_util.save_csv(
		csv_path + Const.CSV_OFFER_LIST_FILE,
		csv_util.transfer_list_to_csv(Global.transfer_list)
	)
	checksum_list.save(csv_path + Const.CSV_OFFER_LIST_FILE)

	# save checksum list list once at end
	json_util.save(path + CHECKSUM_FILE, checksum_list)

