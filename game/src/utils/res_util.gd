# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

signal loading_failed

# .res for binary/compressed resource data
# .tres for text resource data
const RES_SUFFIX: StringName = ".res"
#var RES_SUFFIX: String = ".tres"

var loading_resources: Array[String]
var loaded_resources: Array[String]
var progress: Array
var load_status: ResourceLoader.ThreadLoadStatus


func _ready() -> void:
	loading_resources = []
	loaded_resources = []


func _process(_delta: float) -> void:
	for loading_resource: String in loading_resources:
		load_status = ResourceLoader.load_threaded_get_status(loading_resource, progress)

		LoadingUtil.update(progress[0])
		
		# still loading
		if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			continue

		# loading success
		if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			# assign references after resources are loaded
			Global.world = ResourceLoader.load_threaded_get(loading_resource)
			Global.team = Global.world.get_active_team()
			Global.league = Global.world.get_active_league()
			Global.manager = Global.team.staff.manager
			Global.transfers = Global.world.transfers
			Global.inbox = Global.world.inbox
			Global.save_states.get_active().is_broken = false

			# add to own array, to not remove element from
			# loading_resources_paths, while iterating
			loaded_resources.append(loading_resource)
			LoadingUtil.done()

		# loading failed
		else:
			# check if already restoring from backup
			if BackupUtil.BACKUP_SUFFIX in loading_resource:
				print("restoring backup for %s gone wrong..." % loading_resource)
				loaded_resources.append(loading_resource)
				loading_failed.emit()
				Global.save_states.get_active().is_broken = true

			# start restoring from backup
			else:
				print("restore backup for %s..." % loading_resource)

				LoadingUtil.start(tr("Restoring from backup"), LoadingUtil.Type.LOAD_GAME)
				var backup_path: String = BackupUtil.restore_backup(loading_resource, RES_SUFFIX)

				var err: Error = ResourceLoader.load_threaded_request(
					backup_path,
					"Resource",
					true,
				)

				loading_resources.append(backup_path)
				loaded_resources.append(loading_resource)
				
				if err:
					loaded_resources.append(backup_path)
					print(err)

	# remove loaded paths
	for loaded_path: String in loaded_resources:
		loading_resources.erase(loaded_path)

	loaded_resources.clear()


func load_resources() -> void:
	# load_threaded_resource("world")

	# non threaded way
	# Global.world = load_resource("world")
	# Global.team = Global.world.get_active_team()
	# Global.league = Global.world.get_active_league()
	# Global.manager = Global.team.staff.manager
	# Global.transfers = Global.world.transfers
	# Global.inbox = Global.world.inbox
	# LoadingUtil.done()


	var file: FileAccess = FileAccess.open_compressed(
		"user://world.json",
		FileAccess.READ,
		FileAccess.COMPRESSION_GZIP
	)
	var err: int = FileAccess.get_open_error()
	print(err)
	# file.store_var(world_json)
	var file_text: String = file.get_as_text()

	var json: JSON = JSON.new()
	var result: int = json.parse(file_text)

	if result == OK:
		Global.world.from_json(json.get_data())
		
		Global.team = Global.world.get_active_team()
		Global.league = Global.world.get_active_league()
		Global.manager = Global.team.staff.manager
		Global.transfers = Global.world.transfers
		Global.inbox = Global.world.inbox
	else:
		print(result)
	
	LoadingUtil.done()


func save_safe_states(_thread_world_save: bool = true) -> void:
	print("saving save states...")
	
	# save save states and create backup
	ResourceSaver.save(
		Global.save_states,
		Const.SAVE_STATES_PATH + "save_states" + RES_SUFFIX , ResourceSaver.FLAG_COMPRESS
	)
	BackupUtil.create_backup(Const.SAVE_STATES_PATH + "save_states", RES_SUFFIX)
	
	# save resources and active save state
	var save_state: SaveState = Global.save_states.get_active()

	if not save_state.meta_is_temp:
		save_resource("save_state", save_state)

		var world_json: Dictionary = Global.world.to_json()

		var file: FileAccess = FileAccess.open_compressed(
			"user://world.json",
			FileAccess.WRITE,
			FileAccess.COMPRESSION_GZIP
		)
		# file.store_var(world_json)
		file.store_string(str(world_json))


		# if thread_world_save:
		# 	ThreadUtil.save_world()
		# else:
		# 	ResUtil.save_resource("world", Global.world)
	
	print("saving save states done.")


func save_resource(res_key: StringName, resource: Resource) -> void:
	var path: StringName = Global.save_states.get_active_path(res_key)
	var resource_path: StringName = path + RES_SUFFIX
	ResourceSaver.save(resource, resource_path, ResourceSaver.FLAG_COMPRESS)
	BackupUtil.create_backup(path, RES_SUFFIX)


func load_save_states() -> SaveStates:
	var save_states: SaveStates = load_resource(Const.SAVE_STATES_PATH + "save_states", true)
	if save_states == null:
		return SaveStates.new()
	# scane for new save states
	save_states.scan()
	return save_states


func load_threaded_resource(res_key: String) -> void:
	var path: String = Global.save_states.get_active_path(res_key + RES_SUFFIX)
	print("loading threaded %s..."%path)
	loading_resources.append(path)
	ResourceLoader.load_threaded_request(path, "Resource", true)


func load_resource(res_key: String, absolute_path: bool = false) -> Resource:
	var path: String = res_key + RES_SUFFIX

	if not absolute_path:
		path = Global.save_states.get_active_path(res_key + RES_SUFFIX)
	
	# check first, if file exists
	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file_access == null:
		print("resource file %s does not exist"%path)
		return null

	print("loading resource %s..." % path)

	var resource: Resource = ResourceLoader.load(path)

	if resource == null:
		print("restoring backup...")
		var resource_path: StringName = BackupUtil.restore_backup(path, RES_SUFFIX)
		# try loading again
		resource = ResourceLoader.load(resource_path)
		if resource == null:
			print("restoring backup gone wrong")
		else:
			print("restoring backup done.")

	return resource
