# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_failed

const USER_PATH: StringName = "user://"
const SAVE_STATES_PATH: StringName = USER_PATH + "save_states/"

const SAVE_STATES_FILE: StringName =  SAVE_STATES_PATH + "save_states.json"
const CONFIG_FILE: StringName = SAVE_STATES_PATH + "settings_config.json"
const CHECKSUM_FILE: StringName = "checksums.json"
const SAVE_STATE_FILE: StringName = "save_state.json"
const DATA_FILE: StringName = "data.json"

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
	write_match_history = false


func save_config() -> void:
	json_util.save(CONFIG_FILE, Global.config)
	backup_util.create(CONFIG_FILE)


func load_config() -> SettingsConfig:
	var config: SettingsConfig = SettingsConfig.new()
	var err: Error = json_util.load(CONFIG_FILE, config)

	# try backup on failure
	if err != OK:
		if backup_util.restore(CONFIG_FILE):
			json_util.load(CONFIG_FILE, config)
	
	return config


func load_save_states() -> SaveStates:
	var save_states: SaveStates = SaveStates.new()
	var err: Error = json_util.load(SAVE_STATES_FILE, save_states)

	# try backup on failure
	if err != OK:
		if backup_util.restore(SAVE_STATES_FILE):
			json_util.load(SAVE_STATES_FILE, save_states)

	# scan for new save states
	save_states.scan()
	return save_states


func save_save_states() -> void:
	json_util.save(SAVE_STATES_FILE, Global.save_states)
	backup_util.create(SAVE_STATES_FILE)


func load_save_state(id: String) -> SaveState:
	var save_state: SaveState = SaveState.new()
	var path: String = SAVE_STATES_PATH + id + "/"

	_load_checksum_list(path)

	# load main data from json
	if not _validate_file(path + SAVE_STATE_FILE):
		loading_failed.emit()
		return null
	json_util.load(path + SAVE_STATE_FILE, save_state)
	return save_state


func load_data() -> void:
	var active: SaveState = Global.save_states.get_active()
	var path: String = SAVE_STATES_PATH + active.id + "/"
	
	_load_checksum_list(path)

	var world: World = World.new()

	Main.call_deferred("update_loading_progress", 0.1)

	# load main data from json
	if not _validate_file(path + DATA_FILE):
		loading_failed.emit()
		return
	var err: Error = json_util.load(path + DATA_FILE, world)
	if err != OK:
		loading_failed.emit()
		return

	Global.world = world

	Main.call_deferred("update_loading_progress", 0.2)

	# players csv
	var csv_path: String = path + Const.CSV_PLAYERS_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	var csv: Array[PackedStringArray] = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	csv_util.csv_to_players(csv, world)
	Main.call_deferred("update_loading_progress", 0.3)

	# free_agents csv
	csv_path = path + Const.CSV_FREE_AGENTS_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	csv_util.csv_to_free_agents(csv, world)
	Main.call_deferred("update_loading_progress", 0.4)

	# history match days csv, read only
	csv_path = path + Const.CSV_MATCH_HISTORY_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	Global.match_list = MatchList.new()
	Global.match_list.history_match_days = csv_util.csv_to_match_days(csv)
	Main.call_deferred("update_loading_progress", 0.5)

	# match days csv
	csv_path = path + Const.CSV_MATCH_LIST_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	var match_days: Array[MatchDays] = csv_util.csv_to_match_days(csv)
	# assign match list
	if match_days.size() == 1:
		Global.match_list.match_days = match_days[0]
	else:
		push_error("error while loading matchdays, match days from csv is not 1")
	Main.call_deferred("update_loading_progress", 0.6)
	
	# calendar csv
	csv_path = path + Const.CSV_CALENDAR_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	Global.calendar = csv_util.csv_to_calendar(csv)
	Main.call_deferred("update_loading_progress", 0.7)

	# inbox csv
	csv_path = path + Const.CSV_INBOX_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	Global.inbox = csv_util.csv_to_inbox(csv)
	Main.call_deferred("update_loading_progress", 0.8)

	# offer list csv
	csv_path = path + Const.CSV_OFFER_LIST_FILE
	if not _validate_file(csv_path):
		loading_failed.emit()
		return
	csv = csv_util.read_csv(csv_path)
	# check for errors
	err = csv_util.get_error()
	if err != OK:
		loading_failed.emit()
		return
	Global.transfer_list = csv_util.csv_to_transfer_list(csv)
	Main.call_deferred("update_loading_progress", 0.9)

	# assign all global references
	IdUtil.id_by_type = active.id_by_type
	Global.team = Global.world.get_active_team()
	Global.manager = Global.team.staff.manager
	Global.league = Global.world.get_league_by_id(Global.team.league_id)

	Main.call_deferred("update_loading_progress", 1.0)


func save_data() -> void:
	print("save data...")
	Main.call_deferred("update_loading_progress", 0.1)

	var active: SaveState = Global.save_states.get_active()
	if active == null:
		print("no active save state found to save")
		return

	var path: String = SAVE_STATES_PATH + active.id + "/"
	_load_checksum_list(path)

	# save id by type, first
	active.id_by_type = IdUtil.id_by_type
	# save save state
	json_util.save(path + SAVE_STATE_FILE, active)

	# add save state checksum
	checksum_list.save(path + SAVE_STATE_FILE)

	# save world
	json_util.save(path + DATA_FILE, Global.world)
	backup_util.create(path + DATA_FILE)
	checksum_list.save(path + DATA_FILE)

	# players
	csv_util.save_csv(
		path + Const.CSV_PLAYERS_FILE,
		csv_util.players_to_csv(Global.world)
	)
	checksum_list.save(path + Const.CSV_PLAYERS_FILE)
	backup_util.create(path + Const.CSV_PLAYERS_FILE)
	Main.call_deferred("update_loading_progress", 0.3)

	# free agents
	csv_util.save_csv(
		path + Const.CSV_FREE_AGENTS_FILE,
		csv_util.free_agents_to_csv(Global.world)
	)
	checksum_list.save(path + Const.CSV_FREE_AGENTS_FILE)
	backup_util.create(path + Const.CSV_FREE_AGENTS_FILE)
	Main.call_deferred("update_loading_progress", 0.4)
	
	# history match days csv
	# TODO: could be optimized even more by just appending new history,
	# instead of writing full history
	if write_match_history:
		csv_util.save_csv(
			path + Const.CSV_MATCH_HISTORY_FILE,
			csv_util.match_days_to_csv(Global.match_list.history_match_days),
		)
		write_match_history = false
		backup_util.create(path + Const.CSV_MATCH_HISTORY_FILE)
		checksum_list.save(path + Const.CSV_MATCH_HISTORY_FILE)


	# match days csv
	csv_util.save_csv(
		path + Const.CSV_MATCH_LIST_FILE,
		csv_util.match_days_to_csv([Global.match_list.match_days]),
	)
	checksum_list.save(path + Const.CSV_MATCH_LIST_FILE)
	backup_util.create(path + Const.CSV_MATCH_LIST_FILE)
	Main.call_deferred("update_loading_progress", 0.6)

	# calendar
	# TODO can be optimized by saving only date that changes in first line
	csv_util.save_csv(
		path + Const.CSV_CALENDAR_FILE,
		csv_util.calendar_to_csv(Global.calendar)
	)
	checksum_list.save(path + Const.CSV_CALENDAR_FILE)
	backup_util.create(path + Const.CSV_CALENDAR_FILE)
	Main.call_deferred("update_loading_progress", 0.7)

	# inbox
	csv_util.save_csv(
		path + Const.CSV_INBOX_FILE,
		csv_util.inbox_to_csv(Global.inbox)
	)
	checksum_list.save(path + Const.CSV_INBOX_FILE)
	backup_util.create(path + Const.CSV_INBOX_FILE)
	Main.call_deferred("update_loading_progress", 0.8)

	# offer list
	csv_util.save_csv(
		path + Const.CSV_OFFER_LIST_FILE,
		csv_util.transfer_list_to_csv(Global.transfer_list)
	)
	checksum_list.save(path + Const.CSV_OFFER_LIST_FILE)
	backup_util.create(path + Const.CSV_OFFER_LIST_FILE)

	# save checksum
	json_util.save(path + CHECKSUM_FILE, checksum_list)
	backup_util.create(path + CHECKSUM_FILE)

	Main.call_deferred("update_loading_progress", 1.0)


func _validate_file(path: String) -> bool:
	if checksum_list.check(path):
		return true
	# validation failed, restore backup and check
	backup_util.restore(path)
	breakpoint
	return checksum_list.check(path)


func _load_checksum_list(path: StringName) -> void:
	checksum_list = ChecksumList.new()
	var err: Error = json_util.load(path + CHECKSUM_FILE, checksum_list)
	if err != OK:
		backup_util.restore(path + CHECKSUM_FILE)
		err = json_util.load(path + CHECKSUM_FILE, checksum_list)
		if err != OK:
			push_error("error while loading checksum list from path %s with code %d" % [path + CHECKSUM_FILE, err])


