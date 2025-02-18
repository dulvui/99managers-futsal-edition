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


func load_resources() -> void:
	# var file: FileAccess = FileAccess.open_compressed(
	# 	"user://world.json",
	# 	FileAccess.READ,
	# 	FileAccess.COMPRESSION_GZIP
	# )
	var file: FileAccess = FileAccess.open(
		"user://world.json",
		FileAccess.READ,
	)
	var err: int = FileAccess.get_open_error()
	if err != OK:
		print(err)
		loading_failed.emit()
		return
	# file.store_var(world_json)
	var file_text: String = file.get_as_text()

	var json: JSON = JSON.new()
	var result: int = json.parse(file_text)
	
	if result == OK:
		Global.world = World.new()
		Global.world.from_json(json.data)
		
		Global.team = Global.world.get_active_team()
		Global.league = Global.world.get_league_by_id(Global.team.league_id)
		Global.manager = Global.team.staff.manager
		Global.transfers = Global.world.transfers
		Global.inbox = Global.world.inbox
	else:
		print(result)
		loading_failed.emit()
	
	file.close()
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

		print("converting world...")
		var world_json: Dictionary = Global.world.to_json()
		# var file: FileAccess = FileAccess.open_compressed(
		# 	"user://world.json",
		# 	FileAccess.WRITE,
		# 	FileAccess.COMPRESSION_GZIP
		# )
		print("converting world done.")

		print("saving world...")
		var file: FileAccess = FileAccess.open(
			"user://world.json",
			FileAccess.WRITE,
		)
		var err: int = FileAccess.get_open_error()
		if err != OK:
			print(err)
			breakpoint
			return

		file.store_string(JSON.stringify(world_json))
		file.close()
		print("saving world done.")

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
