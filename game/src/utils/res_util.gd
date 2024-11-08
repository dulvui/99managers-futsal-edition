# SPDX-FileCopyrightText: 2023 Simon Dalvai <info@simondalvai.org>

# SPDX-License-Identifier: AGPL-3.0-or-later

extends Node

# .res for binary/compressed resource data
# .tres for text resource data
const RES_SUFFIX: StringName = ".res"
#var RES_SUFFIX: String = ".tres"

var loading_resources: Array[String]
var backup_resources: Array[String]
var loaded_resources: Array[String]
var progress: Array
var load_status: ResourceLoader.ThreadLoadStatus


func _ready() -> void:
	loading_resources = []
	backup_resources = []
	loaded_resources = []


func _process(_delta: float) -> void:
	for loading_resource: String in loading_resources:
		load_status = ResourceLoader.load_threaded_get_status(loading_resource, progress)

		LoadingUtil.update(progress[0])

		if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			continue

		if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			# assign references after resources are loaded
			Global.world = ResourceLoader.load_threaded_get(loading_resource)
			Global.team = Global.world.get_active_team()
			Global.league = Global.world.get_active_league()
			Global.manager = Global.team.staff.manager

			# add to own array, to not remove element from
			# loading_resources_paths, while iterating
			loaded_resources.append(loading_resource)
			LoadingUtil.done()
		elif (
			load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED
			|| load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE
		):
			if BackupUtil.BACKUP_SUFFIX in loading_resource:
				print("restoring backup for %s gone wrong..." % loading_resource)
				loading_resources.append(loading_resource)
			else:
				print("restore backup for %s..." % loading_resource)

				LoadingUtil.start("RESTORING_BACKUP", LoadingUtil.Type.LOAD_GAME)

				var backup_path: StringName = BackupUtil.restore_backup(
					loading_resource, RES_SUFFIX
				)

				loaded_resources.append(loading_resource)
				backup_resources.append(backup_path)

				var err: Error = (
					ResourceLoader
					. load_threaded_request(
						backup_path,
						"Resource",
						true,
					)
				)
				if err:
					print(err)

	# remove loaded paths
	for loaded_path: String in loaded_resources:
		loading_resources.erase(loaded_path)
	# add new loaded resource paths
	for backup_resource: String in backup_resources:
		loading_resources.append(backup_resource)

	backup_resources.clear()
	loaded_resources.clear()


func save_save_states() -> void:
	print("saving save state...")
	var save_sate: SaveState = Global.save_states.get_active()
	if not save_sate.meta_is_temp:
		save_sate.start_date = Global.start_date
		save_sate.id_by_type = Global.id_by_type
		save_sate.current_season = Global.current_season
		save_sate.speed_factor = Global.speed_factor
		save_sate.generation_seed = Global.generation_seed
		save_sate.generation_state = Global.generation_state
		save_sate.generation_player_names = Global.generation_player_names

		save_sate.save_metadata()

		save_resource("inbox", Global.inbox)
		save_resource("transfers", Global.transfers)

		ThreadUtil.save_world()
		#ResUtil.save_resource("world", Global.world)

	# always save save_states
	var path: StringName = "user://save_states"
	var resource_path: StringName = BackupUtil.create_backup(path, RES_SUFFIX)
	# save new save state
	ResourceSaver.save(Global.save_states, resource_path, ResourceSaver.FLAG_COMPRESS)


func save_resource(res_key: StringName, resource: Resource) -> void:
	var path: StringName = Global.save_states.get_active_path(res_key)
	var resource_path: StringName = path + RES_SUFFIX
	ResourceSaver.save(resource, resource_path, ResourceSaver.FLAG_COMPRESS)
	BackupUtil.create_backup(path, RES_SUFFIX)


func load_save_states() -> SaveStates:
	var save_sates: SaveStates = load_resource("save_states", true)
	if save_sates == null:
		return SaveStates.new()
	return save_sates


func load_resources() -> void:
	Global.inbox = load_resource("inbox")
	if Global.inbox == null:
		Global.inbox = Inbox.new()

	Global.transfers = load_resource("transfers")
	if Global.inbox == null:
		Global.transfers = Transfers.new()

	load_threaded_resource("world")


func load_threaded_resource(res_key: String) -> void:
	#var start_time: int = Time.get_ticks_msec()

	var path: String = Global.save_states.get_active_path(res_key + RES_SUFFIX)
	print("loading threaded %s..." + path)

	loading_resources.append(path)

	ResourceLoader.load_threaded_request(path, "Resource", true)


func load_resource(res_key: String, root_path: bool = false) -> Resource:
	var start_time: int = Time.get_ticks_msec()

	var path: String = "user://" + res_key + RES_SUFFIX

	if not root_path:
		path = Global.save_states.get_active_path(res_key + RES_SUFFIX)

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

	var load_time: int = Time.get_ticks_msec() - start_time
	print("loaded in: " + str(load_time) + " ms")

	return resource
