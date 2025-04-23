# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_failed

const COMPRESSION_ON: bool = true
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP

const USER_PATH: StringName = "user://"
const SAVE_STATES_PATH: StringName = "user://save_states/"

const CONFIG_FILE: StringName = "settings_config"
const SAVE_STATE_FILE: StringName = "save_state"
const SAVE_STATES_FILE: StringName = "save_states"
const DATA_FILE: StringName = "data"

const FILE_SUFFIX: StringName = ".json"
const FILE_SUFFIX_COMPRESS: StringName = ".save"

var backup_util: BackupUtil

# flag if match list history should be saved
var write_match_history: bool


func _init() -> void:
	backup_util = BackupUtil.new()
	write_match_history = false


func save_config() -> void:
	_save_resource(CONFIG_FILE, Global.config)


func load_config() -> SettingsConfig:
	var config: SettingsConfig = SettingsConfig.new()
	_load_resource(CONFIG_FILE, config)
	if config == null:
		return SettingsConfig.new()
	return config


func load_save_states() -> SaveStates:
	var save_states: SaveStates = SaveStates.new()
	_load_resource(SAVE_STATES_FILE, save_states)
	if save_states == null:
		return SaveStates.new()
	# scan for new save states
	save_states.scan()
	return save_states


func save_save_states() -> void:
	_save_resource(SAVE_STATES_FILE, Global.save_states)


func load_save_state(id: String) -> SaveState:
	var save_state: SaveState = SaveState.new()
	_load_resource(id + "/" + SAVE_STATE_FILE, save_state)
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
	_save_resource(active.id + "/" + SAVE_STATE_FILE, active)


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
	_load_resource(path + DATA_FILE, world)
	Global.world = world

	# the rest is loaded as csv
	var csv_util: CSVUtil = CSVUtil.new()
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
	var offer_list_path: String = csv_path + Const.CSV_OFFER_LIST_FILE
	Global.offer_list = csv_util.csv_to_offer_list(csv_util.read_csv(offer_list_path))


func _save_data(save_state: SaveState) -> void:
	print("save data...")
	var path: String = save_state.id + "/"
	_save_resource(path + DATA_FILE, Global.world)

	var csv_path: String = SAVE_STATES_PATH + save_state.id + "/"

	var csv_util: CSVUtil = CSVUtil.new()
	# players
	csv_util.save_csv(
		csv_path + Const.CSV_PLAYERS_FILE,
		csv_util.players_to_csv(Global.world)
	)

	# free agents
	csv_util.save_csv(
		csv_path + Const.CSV_FREE_AGENTS_FILE,
		csv_util.free_agents_to_csv(Global.world)
	)
	
	# history match days csv
	# TODO: could be optimized even more by just appending new history,
	# instead of writing full history
	if write_match_history:
		csv_util.save_csv(
			csv_path + Const.CSV_MATCH_HISTORY_FILE,
			csv_util.match_days_to_csv(Global.match_list.history_match_days),
		)
		write_match_history = false

	# match days csv
	csv_util.save_csv(
		csv_path + Const.CSV_MATCH_LIST_FILE,
		csv_util.match_days_to_csv([Global.match_list.match_days]),
	)

	# calendar
	# TODO can be optimized by saving only date that changes in first line
	csv_util.save_csv(
		csv_path + Const.CSV_CALENDAR_FILE,
		csv_util.calendar_to_csv(Global.calendar)
	)

	# inbox
	csv_util.save_csv(
		csv_path + Const.CSV_INBOX_FILE,
		csv_util.inbox_to_csv(Global.inbox)
	)

	# offer list
	csv_util.save_csv(
		csv_path + Const.CSV_OFFER_LIST_FILE,
		csv_util.offer_list_to_csv(Global.offer_list)
	)


func _load_resource(path: String, resource: JSONResource, after_backup: bool = false) -> void:
	# make sure path is lower case
	path = SAVE_STATES_PATH + path.to_lower()

	# open file
	var file: FileAccess
	if COMPRESSION_ON:
		path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(path, FileAccess.READ, FileAccess.COMPRESSION_GZIP)
	else:
		path += FILE_SUFFIX
		file = FileAccess.open(path, FileAccess.READ)

	# check errors
	var err: int = FileAccess.get_open_error()
	if err != OK:
		if after_backup:
			print("opening file %s error with code %d after backup attempt." % [path, err])
			loading_failed.emit()
			return
		else:
			print("opening file %s error with code %d, restroing backup..." % [path, err])
			var backup_result: bool = backup_util.restore(path)
			if backup_result:
				# Main.loading_screen.update_message(tr("Restoring from backup"))
				_load_resource(path, resource, true)
		return

	# load and parse file
	var file_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var result: int = json.parse(file_text)

	# check for parsing errors
	if result != OK:
		if after_backup:
			print("parsing file %s error with code %d after backup" % [path, result])
			loading_failed.emit()
			return
		else:
			print("parsing file %s error with code %d, restoring backup..." % [path, result])
			var backup_result: bool = backup_util.restore(path)
			if backup_result:
				_load_resource(path, resource, true)
		return

	# convert to json resource
	file.close()
	var parsed_json: Dictionary = json.data
	resource.from_json(parsed_json)


func _save_resource(path: String, resource: JSONResource) -> void:
	print("converting resurce...")
	var json: Dictionary = resource.to_json()
	print("converting resource done.")
	_save_json(path, json)


func _save_json(path: String, json: Dictionary) -> void:
	# make sure path is lower case
	path = SAVE_STATES_PATH + path.to_lower()
	print("saving json %s..." % path)

	# create directory, if not exist yet
	var dir_path: String = path.get_base_dir()
	var dir: DirAccess = DirAccess.open(USER_PATH)
	if not dir.dir_exists(dir_path):
		print("dir %s not found, creating now..." % dir_path)
		var err_dir: Error = dir.make_dir_recursive(dir_path)
		if err_dir != OK:
			push_error("error while creating directory %s; error with code %d" % [dir_path, err_dir])
			return

	# print("saving resource...")
	var file: FileAccess
	if COMPRESSION_ON:
		path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(path, FileAccess.WRITE, COMPRESSION_MODE)
	else:
		path += FILE_SUFFIX
		file = FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		push_error("error while opening file: file is null")
		return

	# check for file errors
	var err: int = file.get_error()
	if err != OK:
		push_error("error while opening file: error with code %d" % err)
		return

	# save to file
	file.store_string(JSON.stringify(json))
	file.close()

	# check again for file errors
	err = file.get_error()
	if err != OK:
		print("again opening file error with code %d" % err)
		print(err)
		return

	# create backup
	backup_util.create(path)

	print("saving %s done..." % path)

