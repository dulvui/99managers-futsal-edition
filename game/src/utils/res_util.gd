# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_failed

const CONFIG_FILE: StringName = "settings_config"
const SAVE_STATE_FILE: StringName = "save_state"
const SAVE_STATES_FILE: StringName = "save_states"
const DATA_FILE: StringName = "data"

const USER_PATH: StringName = "user://"
const SAVE_STATES_DIR: StringName = "save_states/"
const SAVE_STATES_PATH: StringName = "user://save_states/"
const FILE_SUFFIX: StringName = ".json"
const FILE_SUFFIX_COMPRESS: StringName = ".save"
const BACKUP_SUFFIX: StringName = ".backup"
const COMPRESSION_MODE: FileAccess.CompressionMode = FileAccess.CompressionMode.COMPRESSION_GZIP
const COMPRESSION_ON: bool = true


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
	_save_resource(active.id + "/" + SAVE_STATE_FILE, active)


func load_save_state_data() -> void:
	var active: SaveState = Global.save_states.get_active()
	IdUtil.id_by_type = active.id_by_type
	Global.world = World.new()
	_load_resource(active.id + "/" + DATA_FILE, Global.world)

	Global.team = Global.world.get_active_team()
	Global.league = Global.world.get_league_by_id(Global.team.league_id)
	Global.manager = Global.team.staff.manager
	Global.transfers = Global.world.transfers
	Global.inbox = Global.world.inbox


func save_save_state_data() -> void:
	var active: SaveState = Global.save_states.get_active()
	if active == null:
		print("no active save state found to save data")
		return
	active.id_by_type = Global.id_by_type
	_save_resource(active.id + "/" + DATA_FILE, Global.world)


func _load_resource(path: String, resource: JSONResource, after_backup: bool = false) -> void:
	var full_path: String = SAVE_STATES_PATH + path
	# open file
	var file: FileAccess
	if COMPRESSION_ON:
		full_path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(
			full_path,
			FileAccess.READ,
			FileAccess.COMPRESSION_GZIP
		)
	else:
		full_path += FILE_SUFFIX
		file = FileAccess.open(
			full_path,
			FileAccess.READ,
		)
	
	# check errors
	var err: int = FileAccess.get_open_error()
	if err != OK:
		print("opening file %s error with code %d" % [full_path, err])
		if not after_backup:
			_restore_backup(full_path)
			LoadingUtil.message = tr("Restoring from backup")
			_load_resource(path, resource, true)
		return

	# load and parse file
	var file_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var result: int = json.parse(file_text)
	
	# check for parsing errors
	if result != OK:
		print("parsing file %s error with code %d" % [full_path, result])
		if not after_backup:
			_restore_backup(full_path)
			_load_resource(path, resource, true)
		return

	# convert to json resource
	file.close()
	var parsed_json: Dictionary = json.data
	resource.from_json(parsed_json)


func _save_resource(path: String, resource: JSONResource) -> void:
	path = SAVE_STATES_PATH + path
	print("saving %s..." % path)
	
	print("converting resurce...")
	var json: Dictionary = resource.to_json()
	print("converting resource done.")

	# create directory, if not exist yet
	var dir_path: String = path.get_base_dir()
	var dir: DirAccess = DirAccess.open(USER_PATH)
	if not dir.dir_exists(dir_path):
		print("dir %s not found, creating now..." % dir_path)
		dir.make_dir_recursive(dir_path)

	print("saving resource...")
	var file: FileAccess
	if COMPRESSION_ON:
		path += FILE_SUFFIX_COMPRESS
		file = FileAccess.open_compressed(
			path,
			FileAccess.WRITE,
			COMPRESSION_MODE
		)
	else:
		path += FILE_SUFFIX
		file = FileAccess.open(
			path,
			FileAccess.WRITE,
		)

	# check for file errors
	var err: int = FileAccess.get_open_error()
	if err != OK:
		print("opening file error with code %d" % err)
		print(err)
		return

	# save to file
	file.store_string(JSON.stringify(json))
	file.close()
	
	# create backup
	_create_backup(path)
	
	print("saving %s done..." % path)


func _create_backup(path: StringName) -> void:
	var backup_path: StringName = path + BACKUP_SUFFIX
	print("creating backup for %s..." % backup_path)

	var dir_access: DirAccess = DirAccess.open(path.get_base_dir())
	if dir_access:
		dir_access.copy(path, backup_path)
		print("creating backup for %s done." % path)
	else:
		print("creating backup for %s gone wrong." % path)


func _restore_backup(path: String) -> void:
	# check first, if file exists
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("backup file %s does not exist" % path)
		loading_failed.emit()
		return

	print("restoring backup for %s..." % path)
	var backup_path: StringName = path + BACKUP_SUFFIX

	var dir: DirAccess = DirAccess.open(path.get_base_dir())
	if dir:
		dir.copy(backup_path, path)
		print("restoring backup for %s done." % path)
	else:
		print("restoring backup for %s gone wrong." % path)
		loading_failed.emit()
		return


